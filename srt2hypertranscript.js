// By Chris Zubak-Skees

const fs = require("fs");

const paraSplitTime = 2;
const paraPunct = false;

function parseSRT(data) {
  let i = 0;
  let len = 0;
  let idx = 0;
  let lines;
  let time;
  let text;
  let sub;

  // Simple function to convert HH:MM:SS,MMM or HH:MM:SS.MMM to SS.MMM
  // Assume valid, returns 0 on error

  const toSeconds = (t_in) => {
    const t = t_in.split(":");

    try {
      let s = t[2].split(",");

      // Just in case a . is decimal seperator
      if (s.length === 1) {
        s = t[2].split(".");
      }

      return (
        parseFloat(t[0], 10) * 3600 +
        parseFloat(t[1], 10) * 60 +
        parseFloat(s[0], 10) +
        parseFloat(s[1], 10) / 1000
      );
    } catch (e) {
      return 0;
    }
  };

  let outputString = "<article><section><p>";
  const lineBreaks = true;
  let ltime = 0;
  let ltext;

  // Here is where the magic happens
  // Split on line breaks
  lines = data.split(/(?:\r\n|\r|\n)/gm);
  len = lines.length;

  for (i = 0; i < len; i++) {
    sub = {};
    text = [];

    sub.id = parseInt(lines[i++], 10);

    // Split on '-->' delimiter, trimming spaces as well

    try {
      time = lines[i++].split(/[\t ]*-->[\t ]*/);
    } catch (e) {
      console.error(`Warning. Possible issue on line ${i}: '${lines[i]}'.`);
    }

    sub.start = toSeconds(time[0]);

    // So as to trim positioning information from end
    if (!time[1]) {
      console.error(`Warning. Issue on line ${i}: '${lines[i]}'.`);
      return;
    }

    idx = time[1].indexOf(" ");
    if (idx !== -1) {
      time[1] = time[1].substr(0, idx);
    }
    sub.end = toSeconds(time[1]);

    // Build single line of text from multi-line subtitle in file
    while (i < len && lines[i]) {
      text.push(lines[i++]);
    }

    // Join into 1 line, SSA-style linebreaks
    // Strip out other SSA-style tags
    sub.text = text
      .join("\\N")
      .replace(/\{(\\[\w]+\(?([\w\d]+,?)+\)?)+\}/gi, "");

    // Escape HTML entities
    sub.text = sub.text.replace(/</g, "&lt;").replace(/>/g, "&gt;");

    // Unescape great than and less than when it makes a valid html tag of a supported style (font, b, u, s, i)
    // Modified version of regex from Phil Haack's blog: http://haacked.com/archive/2004/10/25/usingregularexpressionstomatchhtml.aspx
    // Later modified by kev: http://kevin.deldycke.com/2007/03/ultimate-regular-expression-for-html-tag-parsing-with-php/
    sub.text = sub.text.replace(
      /&lt;(\/?(font|b|u|i|s))((\s+(\w|\w[\w\-]*\w)(\s*=\s*(?:\".*?\"|'.*?'|[^'\">\s]+))?)+\s*|\s*)(\/?)&gt;/gi,
      "<$1$3$7>"
    );
    //sub.text = sub.text.replace( /\\N/gi, "<br />" );
    sub.text = sub.text.replace(/\\N/gi, " ");

    const splitMode = 0;

    const wordLengthSplit = false;

    // enhancements to take account of word length

    const swords = sub.text.split(" ");
    const sduration = sub.end - sub.start;
    const stimeStep = sduration / swords.length;

    // determine length of words

    const swordLengths = [];
    const swordTimes = [];

    let totalLetters = 0;
    for (var si = 0, sl = swords.length; si < sl; ++si) {
      totalLetters = totalLetters + swords[si].length;
      swordLengths[si] = swords[si].length;
    }

    const letterTime = sduration / totalLetters;
    let wordStart = 0;

    for (var si = 0, sl = swords.length; si < sl; ++si) {
      const wordTime = swordLengths[si] * letterTime;
      let stime;
      if (wordLengthSplit) {
        stime = Math.round((sub.start + si * stimeStep) * 1000);
      } else {
        stime = Math.round((wordStart + sub.start) * 1000);
      }

      wordStart = wordStart + wordTime;
      const stext = swords[si];

      if (stime - ltime > paraSplitTime * 1000 && paraSplitTime > 0) {
        //console.log("fullstop? "+stext+" - "+stext.indexOf("."));
        const punctPresent =
          ltext &&
          (ltext.indexOf(".") > 0 ||
            ltext.indexOf("?") > 0 ||
            ltext.indexOf("!") > 0);
        if (!paraPunct || (paraPunct && punctPresent)) {
          outputString += "</p><p>";
        }
      }

      outputString += `<span data-m="${stime}">${stext} </span>`;

      ltime = stime;
      ltext = stext;

      if (lineBreaks) outputString = `${outputString}\n`;
    }
  }
  return `${outputString}</p></section></article>`;
}

const data = fs.readFileSync(process.argv[2], "utf8");

const result = parseSRT(data);

fs.writeFileSync(process.argv[3], result, "utf8");
