# Day 08

## Main Idea: Data in R -> excel output

In real work, analysis often is not finished when the plot looks nice.
It is finished when somebody else can open the file, read it, filter it, and use it


read_excel() 
- read excel into R

openxlsx
- used for writing polished Excel files from R
- main functions:

createWorkbook()
addWorksheet()
writeData()
saveWorkbook()
setColWidths()
freezePane()
createStyle()
addStyle()


Whenever you create an R object, create it in a project-level data folder

The data should always be in a project-level data folder for easier access

Do not save it under another folder because that makes the R object and/or 
data retrieval more difficult
