<img src="https://github.com/bcgov/nr-optimize-sfp/blob/main/docs/GFX_OptimizationLogo-Icon_v2.png" width=35% height=35%>

# README for Enhanced SFP Reports
## Heather Hay c/o NRIDS Optimization Team 2023

### Pre-Requisites

> You must have your R environment configured already, as outlined in **README_R_SETUP** <br>
> The following files need to be in your **scripts** folder:
>
> -   GFX_OptimizationLogo-Icon_v2.png
> -   header.tex
> -   load_groupshare_files.R
> -   custom_sfp_functions.R
> -   enhanced_sfp_report_overview.rmd
> -   enhanced_sfp_report_share.rmd
> -   enhanced_sfp_report_folder.rmd
> -   render_enhanced_sfp_report_overview.R
> -   render_sfp_enhanced_report_share.R
> -   render_sfp_enhanced_report_folder.R
> 
> The following files need to be in your **source** folder:
> - **all** of the individual NRM Ministry .xlsx files for monthly group share consumption *that match the month of the report you're compiling*
> - the NRM Ministry .csv files for shared file enhanced reporting
>   - The enhanced data for ENV & FOR arrives as multiple .csv files and they'll need to be combined into one ENV & FOR file each. You can use this command line [example](https://www.ablebits.com/office-addins-blog/merge-multiple-csv-files-excel/#:~:text=In%20the%20command%20line%2C%20after,%2C%20merged%2Dcsv%2Dfiles.) _copy *.csv YYYY-MM-DD_MIN_SFP_Enhanced_Data.csv_ or one of your own if you have a preferred method.
### Reporting on the Ministry-level SFP
>
> -   open the file ***render_enhanced_sfp_report_overview.R***
> -   change the bracketed text in the final line of the script to your desired parameters, like in this example: <br>
render_report("2026-06-30_FOR_SFP_Enhanced_Data.csv", "FOR", "2026-06-30")
> -   there are 3 mandatory fields to enter <ins>**in order**</ins>:
>     -   the name of the csv file (you must include .csv in the file name)
>     -   the acronym of the Minstry
>     -   the date on the raw data file from the OCIO, so clients have an idea of when the storage snapshot was taken <br>
> -   select all the text (ctrl-a) and then run the script by either pressing ctrl-Enter OR pressing the "Run" button in R Studio at the top right.
>
> The end result is 2 files in your **output** folder, named dynamically based on the parameters you input earlier.
>
> -   **SFP_Enhanced_Report_ministry_date.xlsx**
> -   **SFP_Enhanced_Report_ministry_date.pdf**
### Reporting on an SFP share
>
> -   open the file ***render_enhanced_sfp_report_share.R***
> -   change the bracketed text in the final line of the script to your desired parameters, like in this example: <br>
render_report("2026-06-30_FOR_SFP_Enhanced_Data.csv", "FOR", "S63001", "2026-06-30")
> -   there are 4 mandatory fields to enter <ins>**in order**</ins>:
>     -   the name of the csv file (you must include .csv in the file name)
>     -   the acronym of the Minstry
>     -   the name of the share
>     -   the date on the raw data file from the OCIO, so clients have an idea of when the storage snapshot was taken
> -   select all the text (ctrl-a) and then run the script by either pressing ctrl-Enter OR pressing the "Run" button in R Studio at the top right.
>
> The end result is 2 files in your **output** folder, named dynamically based on the parameters you input earlier.
>
> -   **SFP_Enhanced_Report_ministry_sharename_date.xlsx**
> -   **SFP_Enhanced_Report_ministry_sharename_date.pdf**
### Reporting on an SFP folder
>
> -   open the file ***render_enhanced_sfp_report_folder.R***
> -   change the bracketed text in the final line of the script to your desired parameters, like in this example: <br>
render_report("2026-06-30_FOR_SFP_Enhanced_Data.csv", "FOR", "/ifs/sharedfile/top_level/C64/S63063/ILMB_CRIM_BMGS", "ILMB_CRIM_BMGS", "2026-06-30")
> -   there are 5 mandatory fields to enter <ins>**in order**</ins>:
>     -   the name of the csv file (you must include .csv in the file name)
>     -   the acronym of the Minstry
>     -   the folder path as shown in the raw OCIO file. It will look different in the BCWS file which is OK because the script has been designed to handle it.
>     -   the date on the raw data file from the OCIO, so clients have an idea of when the storage snapshot was taken (please format as YYYY-MM-DD for consistency)
> -   select all the text (ctrl-a) and then run the script by either pressing ctrl-Enter OR pressing the "Run" button in R Studio at the top right.
>
> The end result is 2 files in your **output** folder, named dynamically based on the parameters you input earlier.
>
> -   **SFP_Enhanced_Report_ministry_foldername_date.xlsx**
> -   **SFP_Enhanced_Report_ministry_foldername_date.pdf**
### Alternate Method of Running the Reports
>
> -   open the *enhanced_sfp_report_<overview, share, or folder>.rmd* file 
> -   press the arrow beside "Knit" and select "Knit with Parameters"
> -   populate the fields in the resultant prompt window with your parameters, following the examples provided\
>     <img src="https://github.com/bcgov/nr-optimize-sfp/blob/main/reference/KWP.jpg" width=40% height=40%>
> -   press "Knit"
>
> The end result is both an excel file and a PDF file in your **output** folder that are named dynamically based on the parameters you input earlier. For example:
>
> -   SFP_Enhanced_Report_FOR_2026-06-30.xlsx **and** SFP_Enhanced_Report_FOR_2026-06-30.pdf
> -   SFP_Enhanced_Report_FOR_S63001_2026-06-30.xlsx **and** SFP_Enhanced_Report_FOR_S63001_2026-06-30.pdf
> -   SFP_Enhanced_Report_FOR_ILMB_CRIM_BMGS_2026-06-30.xlsx **and** SFP_Enhanced_Report_FOR_ILMB_CRIM_BMGS_2026-06-30.pdf
### Reference Material
>
>[An Introduction to R](https://intro2r.com/) <br>
>[Knitting with Parameters](https://bookdown.org/yihui/rmarkdown/params-knit.html)
>
