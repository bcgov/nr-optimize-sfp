<img src="https://github.com/bcgov/nr-optimize-sfp/blob/main/docs/GFX_OptimizationLogo-Icon_v2.png" width=35% height=35%>

# README for Enhanced H Drive Category Reports
## Heather Hay c/o NRIDS Optimization Team 2023

### Pre-Requisites

> You must have your R environment configured already, as outlined in **README_R_SETUP** <br>
> The following files need to be in your **scripts** folder:
>
> -   nrm_breakout_hdrive_category_report.Rmd
> -   nrm_total_hdrive_category_report.Rmd
> -   GFX_OptimizationLogo-Icon_v2.png
> 
> The following files need to be in your **source** folder:
> - **all 7** of the NRM Ministry .csv files for the quarterly report on H Drives. The file names look like this: **<Ministry acronym>-U FileTypeCategory Summary Report**.
> - Make sure the source files all relate to the same timeframe, because the script reads in all files that end in *-U FileTypeCategory Summary Report*.
>

### Running the Scripts
> You must first update the following variables in the scripts with the correct collection date, quarter, and fiscal year.
```
collected <- as.Date("2023-07-10")
quarter <- "Q2"
fiscal <- "FY23-24"
```
>
> At the top-right of the code window in R Studio, click the drop-down arrow beside "Run" and choose either "Restart R and run all chunks" or "Run all". The PDF output will be saved to the "figure" folder.
