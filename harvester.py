import requests
import re
import json
from bs4 import BeautifulSoup

# First get a list of all sessions
URL = "https://www.vacourts.gov/courts/scv/oral_arguments/home.html"
page = requests.get(URL)
results = BeautifulSoup(page.content, "html.parser")
sessions = results.find_all("li")
argument_urls = []
for session in sessions:
    session_element = session.find("a")
    argument_urls.append('https://www.vacourts.gov' + session_element["href"])

all_arguments = []

# Iterate through the list of sessions and get a list of arguments for them    
for argument_url in argument_urls:

    print('Fetching ' + argument_url)

    page = requests.get(argument_url)
    results = BeautifulSoup(page.content, "html.parser")

    # If this is a modern page with an embedded MP3 player
    if "audioplayer" in page.text:
        
        # Iterate over the contents of every table row
        arguments = results.find_all("tr")
        for argument in arguments:

            # Each table has a single table row that doesn't contain an argument--skip it
            if 'Argument Audio' in argument.text:
                continue
            
            # Determine if this is a 2-TD or a 3-TD record
            all_tds = argument.find_all("td")

            # 2-TD
            if len(all_tds) == 2:
                title_element = argument.find("td")
                # Save the case ID and case name
                case_id = title_element.text.strip().split()[0]
                case_name = ' '.join(title_element.text.strip().split()[1:])
            
            # 3-TD
            elif len(all_tds) == 3:

                # Save the case ID and case name
                case_id = argument.text.strip().split()[0]
                case_name = ' '.join(argument.text.strip().split()[1:])
            
            # Mystery number of TDs
            else:
                print("Error: Unanticipated table row structure")
                print ("Number of TDs" + len(all_tds))
                continue
            
            # Save the audio file
            case_mp3 = 'https://www.vacourts.gov' + argument.find("source")["src"]

            # Remove any asterisks from the case name or ID, which is used for footnotes
            case_name = case_name.replace('*', '')
            case_id = case_id.replace('*', '')

            # Add this case to the main list
            all_arguments.append({'case_id': case_id, 'case_name': case_name, 'url': case_mp3})

    # If this is an older page without an embedded MP3 player
    else:

        # Iterate over the contents of every list item from the first UL in the content text
        content_div = results.find("div", {"id": "contenttext"})
        ul = content_div.find("ul")
        li_list = ul.find_all("li")
        for li in li_list:

            # Save the case ID and case name
            case_id = li.text.strip().split()[0]
            case_name = ' '.join(li.text.strip().split()[1:])

            # Save the MP3 URL
            a = li.find("a")
            if a is not None:
                case_mp3 = 'https://www.vacourts.gov' + a.get("href")

        # Remove any asterisks from the case name or ID, which is used for footnotes
        case_name = case_name.replace('*', '')
        case_id = case_id.replace('*', '')

        # Add this case to the main list
        all_arguments.append({'case_id': case_id, 'case_name': case_name, 'url': case_mp3})   

# Save the resulting data to a file
with open('arguments.json', 'w', encoding='utf-8') as f:
    json.dump(all_arguments, f, ensure_ascii=False, indent=4)
