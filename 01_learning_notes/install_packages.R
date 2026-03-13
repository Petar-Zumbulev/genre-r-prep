packages <- c(
  "tidyverse",
  "lubridate",
  "readxl",
  "openxlsx",
  "shiny",
  "DBI",
  "RPostgres",
  "jsonlite",
  "httr2",
  "pdftools",
  "tesseract"
)

installed <- rownames(installed.packages())

for (pkg in packages) {
  if (!pkg %in% installed) {
    install.packages(pkg)
  }
}

