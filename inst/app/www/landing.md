
# Welcome to RawHummus &nbsp;<img src='www/img/logo.png' align="right" height="200"/>

<br></br>

Robust and reproducible data is essential to ensure high-quality analytical results and is particularly important for large-scale metabolomics studies where detector sensitivity drifts, retention time and mass accuracy shifts frequently occur. Therefore, raw data need to be inspected before data processing in order to verify system consistency, detect any measurement bias, and establish an appropriate data analysis workflow.

<b><span style="color:#F17F42">RawHummus</span></b> is a user-friendly web tool that automates raw data quality control (QC) for metabolomics studies. It generates a detailed QC report with interactive plots, tables, summary statistics, and explanations to help users evaluate the data quality.


In addition, RawHummus enables interactive visualization and inspection of LC-MS instrument log files, allowing users to compare over 40 different instrument metrics, such as ambient temperature and ambient humidity. (currently only Thermo Orbitrap instrument is supported).


---

## Workflow

The use of RawHummus is simple and straightforward. You can follow the user guide in each tab to perform your analysis.

It is worth noting that RawHummus uses the generic file formats, i.e., mzML and mzXML, for QC sample evaluation. This means that raw files must be converted prior to analysis. There are several methods available for converting vendor-specific raw data formats, and you can find more information on <a href="https://ccms-ucsd.github.io/GNPSDocumentation/fileconversion/" target="_blank">this page</a>.


Demo files for RawHummus (including 30 log files and 8 QC files) can be <a href="https://github.com/YonghuiDong/RawHummus_DemoData" target="_blank">downloaded here</a>.

---

## About RawHummus

RawHummus is publicly available on <a href="https://cran.r-project.org/web/packages/RawHummus/index.html" target="_blank">CRAN repository</a>, with source code available on <a href="https://github.com/YonghuiDong/RawHummus" target="_blank">GitHub</a> under a GPL-3 license. 

The web application can be installed in R/RStudio using a simple command `install.packages("RawHummus")`, and run locally with the command `run_app()`.

---

<a href= 'https://bcdd.tau.ac.il/'><img src='www/img/WIS.png' alt='WIS' title='Weizmann Institute of Science' width='300'/></a>

