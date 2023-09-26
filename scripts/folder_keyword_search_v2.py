# -------------------------------------------------------------------------------
# Name:        folder_keyword_search.py
# Purpose:     The purpose of the script is to parse text-based files such as
#              *.docx, *.pdf, *.xlsx, *.csv, and *.txt for keywords in a folder
#              path specified by the user. The keywords are written to pass a
#              REGEX search and there are prompts built in to add or remove
#              keywords. At the end of the search, a csv file is created that
#              lists the full filename path and the keyword found in the file.
#              The output removes duplicate lines to show only the first keyword
#              found per file.
#              The output file is saved to a specific folder which is checked
#              at the beginning of the script and created if it doesn't exist.
#
# Author:      HHAY, PPLATTEN
#
# Created:     2023
# Copyright:   (c) Optimization Team 2023
# Licence:     mine
# -------------------------------------------------------------------------------

# import python libraries
import os
import re
from datetime import datetime
import pandas as pd
from docx import Document
import PyPDF2
import textract
import openpyxl
import csv

# put cautions at the start of script execution
print("Things to know before proceeding:")
print("*" * 35)
print("1. You must be connected to the BCGOV network by VPN or ethernet cable.")
print(
    "2. You need to have OneDrive set up because your search results will be saved there as a CSV file."
)
print(
    "3. This script uses REGEX to find specific content within files. If you are adding new keywords to the search, you may want to visit https://www.dataquest.io/blog/regex-cheatsheet/.\n"
)

# set the file paths
UserName = os.environ.get("USERNAME")

OneDrive = f"C:/Users/{UserName}/OneDrive - Government of BC"
if not os.path.exists(OneDrive):
    print("Please enable OneDrive before running this script")
    exit()

SavePath = f"C:/Users/{UserName}/OneDrive - Government of BC/Optimize"
if not os.path.exists(SavePath):
    os.makedirs(SavePath)

# set the keyword list
keywords = [
    "^first aid$|^First aid$|^First Aid$",
    "[6][A]|[6][a]",
    "SIRP|sirp",
    r"\btrauma|\bTrauma",
    r"\bbully|\bBully",
    r"\bbullied|\Bullied",
    r"\bharass|\bHarass",
    r"\bsuicid|\bSuicid",
    r"\bassault|\bAssault",
    r"\babus|\bAbus",
]

print("The keyword list is: \n")
print("*" * 35)
for i, item in enumerate(keywords, start=0):
    print(i, item)

# prompt to add keywords
keywords_answer = input(
    "\nyes or no: Do you want to add more keywords to the existing list? "
)

# loop to confirm proper input
if keywords_answer == "yes":
    # add new keywords to list
    add_keywords = list()
    add_keywords = input("Add extra keywords, separated by commas:\n").split(", ")
    # keywords.append(add_keywords)
    keywords.extend(add_keywords)
    print("\nThe updated keyword list is: ")
    for i, item in enumerate(keywords, start=0):
        print(i, item)
elif keywords_answer == "no":
    print("\nOK, no additions will be made.\n")

while keywords_answer not in ("yes", "no"):
    keywords_answer = input("Enter yes or no: ")
    if keywords_answer == "yes":
        add_keywords = list()
        add_keywords = input("\nAdd extra keywords, separated by commas: ").split(", ")
        keywords.extend(add_keywords)
        print("\nThe updated keyword list is: ")
        for i, item in enumerate(keywords, start=0):
            print(i, item)
    elif keywords_answer == "no":
        print("\nOK, no additions will be made.")
        break
    else:
        print("Please enter yes or no.")

# prompt to remove keywords
keywords_next = input(
    "yes or no: Do you want to remove keywords from the existing list? "
)

if keywords_next == "yes":
    # remove keywords from list
    remove_keywords = list()
    remove_keywords = input(
        "\nEnter the keywords you want removed exactly as they were listed earlier, separated by commas: "
    ).split(", ")

    # looping list of numbers to remove
    for word in remove_keywords:
        # remove it from the list
        while word in keywords:
            keywords.remove(word)

    print("\nThe updated keyword list is: ")
    print("*" * 35)
    for i, item in enumerate(keywords, start=0):
        print(i, item)

elif keywords_next == "no":
    print("\nOK, no removals will be made.")

while keywords_next not in ("yes", "no"):
    keywords_next = input("Enter yes or no: ")

    if keywords_next == "yes":
        # remove keywords from list
        remove_keywords = list()
        remove_keywords = input(
            "\nEnter the keywords you want removed exactly as they were listed earlier, separated by commas: "
        ).split(", ")

        # looping list of numbers to remove
        for word in remove_keywords:
            # remove it from the list
            while word in keywords:
                keywords.remove(word)

        print("\nThe updated keyword list is: ")
        print("*" * 35)
        for i, item in enumerate(keywords, start=0):
            print(i, item)

    elif keywords_next == "no":
        print("\nOK, no removals will be made.")
        break
    else:
        print("Please enter yes or no.")

# prompt to specify path used in search
user_dir = input(
    "\nEnter the directory you want to search exactly as you have it mapped on your computer: "
)

answer = input(f"\nyes or no: Is {user_dir} the correct directory to search? ")

if answer == "yes":
    # check that the path exists
    if os.path.exists(user_dir):
        # confirm the user_dir search
        print(
            f"\nSearching {user_dir} for file contents and compiling data to file, this may take several minutes or several hours depending on size."
        )
        print("Please keep this window running in the background until complete...\n")
    else:
        print(
            "Cannot reach network drive. Please check your exact path name and ensure you have permission to access this drive and/or folder./n"
        )
        # repeat user_dir prompt
        retry_dir = input(
            "\nTry again: Enter the directory you want to search exactly as you have it mapped on your computer: "
        )
        user_dir = retry_dir
        if os.path.exists(user_dir):
            # confirm the user_dir search
            print(
                f"\nSearching {user_dir} for file contents and compiling data to file, this may take several minutes or several hours depending on size."
            )
            print(
                "Please keep this window running in the background until complete...\n"
            )
        else:
            print("Cannot reach network drive. Exiting now...")
            exit()
elif answer == "no":
    # repeat user_dir prompt
    retry_dir = input(
        "\nTry again: Enter the directory you want to search exactly as you have it mapped on your computer: "
    )
    user_dir = retry_dir
    if os.path.exists(user_dir):
        # confirm the directory search
        print(
            f"\nSearching {user_dir} for file contents and compiling data to file, this may take several minutes or several hours depending on size."
        )
        print("Please keep this window running in the background until complete...\n")
    else:
        print(
            "Cannot reach {user_dir}, please confirm exact spelling and/or folder permissions\n",
        )
        # repeat directory prompt
        retry_dir = input(
            "\nTry again: Enter the directory you want to search exactly as you have it mapped on your computer: "
        )
        user_dir = retry_dir
        if os.path.exists(user_dir):
            # confirm the directory search
            print(
                f"\nSearching {user_dir} for file contents and compiling data to file, this may take several minutes or several hours depending on size."
            )
            print(
                "Please keep this window running in the background until complete...\n"
            )
        else:
            print("Cannot reach network drive. Exiting now...")
            exit()
while answer not in ("yes", "no"):
    answer = input("Enter yes or no: ")
    if answer == "yes":
        # confirm the directory search
        print(
            f"\nSearching {user_dir} for file contents and compiling data to file, this may take several minutes or several hours depending on size. /nPlease keep this window running in the background until complete...\n"
        )
    elif answer == "no":
        # repeat directory prompt
        retry_dir = input(
            "\nTry again: Enter the directory you want to search exactly as you have it mapped on your computer: "
        )
        user_dir = retry_dir
        if os.path.exists(user_dir):
            # confirm the directory search
            print(
                f"\nSearching {user_dir} for file contents and compiling data to file, this may take several minutes or several hours depending on size."
            )
            print(
                "Please keep this window running in the background until complete...\n"
            )
        else:
            print("Cannot reach network drive. Exiting now...")
            exit()
        break
    else:
        print("Please enter yes or no.")

# create list placeholders for filetype search results
match_docx_items = []
match_pdf_items = []
match_excel_items = []
match_csv_items = []
match_text_items = []

# create list of all file names in the user-specified directory
file_names = os.listdir(user_dir)

# search Word documents (.docx extension) and output results to dataframe
docx_names = [file for file in file_names if file.endswith(".docx")]
docx_names = [os.path.join(user_dir, file) for file in docx_names]

for file in docx_names:
    document = Document(file)
    for paragraph in document.paragraphs:
        for kw in keywords:
            regex = re.compile(kw)
            if regex.search(paragraph.text):
                # if kw in paragraph.text:
                match_docx_items.append([file, kw])

searched_docx = pd.DataFrame(
    match_docx_items,
    columns=["file_name", "keyword_match"],
    index=[i[0] for i in match_docx_items],
)

# print(searched_docx)
print("Finished searching Word files, moving on to PDF...\n")

# search PDF files (.pdf extension) and output results to dataframe
pdf_names = [file for file in file_names if file.endswith(".pdf")]
pdf_names = [os.path.join(user_dir, file) for file in pdf_names]

for file in pdf_names:
    with open(file, "rb") as f:
        pdfReader = PyPDF2.PdfReader(f)
        num_pages = len(pdfReader.pages)
        count = 0
        pdf_text = ""

        while count < num_pages:  # while loop will read each page
            f = pdfReader.pages[count]
            count += 1
            pdf_text += f.extract_text()

        if (
            pdf_text != ""
        ):  # if statement exists to check if the above library returned #words. It's done because PyPDF2 cannot read scanned files.
            pdf_text = pdf_text  # if returns as False, we run the OCR library textract to #convert scanned/image based PDF files into text
        else:
            pdf_text = textract.process(
                "http://bit.ly/epo_keyword_extraction_document",
                method="tesseract",
                language="eng",
            )  # now we have a text variable which contains all the text derived from our PDF file.

        pdf_text = pdf_text.encode("ascii", "ignore").lower()  # lowercasing each word
        pdf_text = pdf_text.decode('utf-8')

        for kw in keywords:
            regex = re.compile(kw)
            if regex.search(pdf_text):
                match_pdf_items.append([file, kw])

searched_pdf = pd.DataFrame(
    match_pdf_items,
    columns=["file_name", "keyword_match"],
    index=[i[0] for i in match_pdf_items],
)

# print(searched_pdf)
print("Finished searching PDF files, moving on to Excel...\n")

# search Excel files (.xlsx extension) and output results to dataframe
excel_names = [file for file in file_names if file.endswith(".xlsx")]
excel_names = [os.path.join(user_dir, file) for file in excel_names]

for file in excel_names:
    wb = openpyxl.load_workbook(file)
    for ws in wb.worksheets:
        for row in ws.iter_rows():
            for cell in row:
                for kw in keywords:
                    regex = re.compile(kw)
                    if regex.search(cell.value):
                        match_excel_items.append([file, kw])

searched_excel = pd.DataFrame(
    match_excel_items,
    columns=["file_name", "keyword_match"],
    index=[i[0] for i in match_excel_items],
)

# print(searched_excel)
print("Finished searching Excel files, moving on to CSV...\n")

# search CSV files (.csv extension) and output results to dataframe
csv_names = [file for file in file_names if file.endswith(".csv")]
csv_names = [os.path.join(user_dir, file) for file in csv_names]

for file in csv_names:
    with open(file, "rt") as f:
        reader = csv.reader(f)
        for row in reader:
            for field in row:
                for kw in keywords:
                    regex = re.compile(kw)
                    if regex.search(field):
                        match_csv_items.append([file, kw])

searched_csv = pd.DataFrame(
    match_csv_items,
    columns=["file_name", "keyword_match"],
    index=[i[0] for i in match_csv_items],
)

# print(searched_csv)
print("Finished searching CSV files, moving on to Text files...\n")

# search Notepad files (.txt extension) and output results to dataframe
text_names = [file for file in file_names if file.endswith(".txt")]
text_names = [os.path.join(user_dir, file) for file in text_names]

for file in text_names:
    with open(file, "r") as f:
        content = f.read()
        for kw in keywords:
            regex = re.compile(kw)
            if regex.search(content):
                match_text_items.append([file, kw])

searched_text = pd.DataFrame(
    match_text_items,
    columns=["file_name", "keyword_match"],
    index=[i[0] for i in match_text_items],
)

# print(searched_text)
print("Finished searching Text files, updating your report...\n")

# prepare the final dataframe

# create list of dataframes
searched_df_list = [
    searched_docx,
    searched_pdf,
    searched_excel,
    searched_csv,
    searched_text,
]

# set index of each dataframe
searched_df = [df for df in searched_df_list]

# concatenate dataframes
searched_df = pd.concat(searched_df)

# sort by file name and remove duplicates from file_name column
searched_df = searched_df.sort_values(by=["file_name"]).drop_duplicates(
    subset=["file_name"], keep="first"
)

# prepare the output file name

# set the date formatting
now = datetime.now()
dt_string = now.strftime("%Y-%b-%d-%H%M%S")

SaveName = f"{SavePath}/filtered_path_report_" + dt_string + ".csv"

# send the prepared report to CSV

# save dataframe to file
searched_df.to_csv(SaveName, index=False)

# advise user where their saved report is located
print(
    f"Your Keyword Report can be found here: {SaveName} \nPlease contact NRIDS.Optimize@gov.bc.ca if you require further assistance. Thank you!"
)
