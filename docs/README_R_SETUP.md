# README for Using R and R Studio
## Heather Hay c/o NRIDS Optimization Team 2023


### Installing R and R Studio
>
You need to install these programs from the Software Center. First install R, then Rstudio
>
* **RforWindowsX64 4.1.3 Gen P0**  
* **RStudioX64 2022.2.0.443 Gen P0**

>
To use the *rmarkdown* package you must have a recent version of **Pandoc** installed. RStudio automatically includes Pandoc in their IDE but if you require a newer version or are using VS Code, you will need to [install Pandoc](https://pandoc.org/installing.html).

>
Alternatively, you can install the latest versions from Chocolately running CMD as admin (this is what I prefer).
>
* *choco install r -y*  
* *choco install r.studio -y*
* *choco install pandoc -y*

>
The chocolatey documentation is here:
>
* [R](https://community.chocolatey.org/packages/R.Project#install)  
* [R Studio](https://community.chocolatey.org/packages/R.Studio#install)
* [Pandoc](https://community.chocolatey.org/packages/pandoc)

### Setting up Your Folder Hierarchy for R
>
> This is how I set up my working directory for R; I keep my **.RProj**, **.RProfile**, and **.REnviron** files in the top-level folder. If your setup is different (for example, if you wanted to work out of your GitHub folder), you may need to adjust your *here()* function to reflect that in the scripts.  
>
**RStudio_Heather**

* figure  
* output  
* scripts  
* source  

### Setting Working Directory in R Studio
>
> Go to Tools > Global Options > General  

* Leave the R version as "Default"  
* Set Default Working Directory (when not in a project) to your preferred location  
* Un-check Restore .RData into workspace at startup  
* Set Save workspace to .RData on exit to "Never"

### Setting Dark Mode in R Studio
>
> You can set RStudio to a variety of dark modes by going to Tools > Global Options > Appearance and changing the Editor theme. I use "Pastel on Dark", but pick what works best for you.

### Installing Library Packages
>
> To use the packages in your script's library call, they must first be installed.
In RStudio, you can go to the Packages tab on the right, select Install, type in the name of the package and press Install. Alternatively, you can enter *install.packages(package_name)* into the console. You might also see a popup message at the top of your script that says dependancies are not installed. If you select Install, all the required packages will be downloaded.
>
> Note that some packages aren't compatible with older versions of R, in which case you will need to either find one that does or update your version of R.

### Ease of Use - Packages
>
> Keep your R package library on the same drive as your scripts. For example, having the library in a folder on your home drive (H:) and your scripts in OneDrive (cached to a folder on C:) causes untenable lag caused by trying to connect to the network where your home drive lives. To check this, go to RStudio console and enter *.libPaths()* and ensure the directory is pointing to a folder on C:, such as C:\\Users\\<IDIR>\\OneDrive - Government of BC\\R\\win-library\\4.2 or C:\\Program Files\\R\\R-4.2\\library.
>
> You can get R Studio to change this setting by creating a file called **.RProfile** in the root folder of your working directory and putting this information inside it: *.libPaths("path_to_your_R_package_library")*

### Running in VS Code
>
> If you choose to run this script in VS Code instead of RStudio, you will need to install **R Extension for Visual Studio Code** by Yuki Ueda.
>
> You'll also want to set the system environment in VS Code with this line: <br>
*Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/")*
>
> You can find the correct directory by typing *Sys.getenv("RSTUDIO_PANDOC")* into the console

### Preferences
>
> I prefer to create new data analysis files with R Markdown (.Rmd) because it allows me to write code in "chunks". This way, I can run my chunks as I go along to make sure I'm getting the desired outcome, without having to write the whole script at once.

### Reference Material
>
>[R For Data Science](https://r4ds.had.co.nz/)
>
>[Using Projects](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects)
>
>[CRAN Packages](https://cran.r-project.org/web/packages/available_packages_by_name.html)
>
>[The here() package](https://github.com/jennybc/here_here)
>
>[R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/)
>
>[R Markdown Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/)
>
>[Data Science with R: A Resource Compendium](https://bookdown.org/martin_monkman/DataScienceResources_book/)
