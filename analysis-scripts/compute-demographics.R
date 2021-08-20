#' ---
#' title: Compute demographic information
#' author: Halle R. Dimsdale-Zucker
#' output:
#'  html_document:
#'    toc: true
#'    toc_depth: 5
#'    toc_float:
#'      collapsed: false
#'      smooth_scroll: false
#'    number_sections: true
#'    theme: spacelab
#' ---

#' # Setup
#' ## Hide all code chunks
# based on: http://cfss.uchicago.edu/block013_rmarkdown.html
knitr::opts_chunk$set(
  echo = FALSE
)

#' ## Load required packages
library(halle)
library(tidyverse)
library(yaml)
# following instructions from http://kbroman.org/pkg_primer/pages/github.html
# this ensures that the most recent version of the `halle` package also gets added
devtools::install_github("hallez/halle", subdir="halle")

#' ## Load in config file
config <- yaml::yaml.load_file("../config.yml")

#' ## Flags
VERSION_FLAG <- 7
EXCLUDE_SUBJ_FLAG <- 1

#' ## Setup paths
# for folders that contain dashes in config, will need to index with single quote
project_dir <- ("../")
dropbox_dir <- paste0(halle::ensure_trailing_slash(config$directories$`dropbox-folder`))
analyzed_behavioral_dir <- paste0(project_dir,halle::ensure_trailing_slash(config$directories$`analyzed-behavioral-dir`))
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash("summary"))

#' ### Print version
sprintf("Analyzing version %d", VERSION_FLAG)
if(VERSION_FLAG < 7){
  expt_str <- sprintf("pilot%d", VERSION_FLAG)
} else{
  expt_str <- "experiment"
}
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash(sprintf("%s-summary", expt_str)))
plots_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash(sprintf("%s-plots", expt_str)))

if(EXCLUDE_SUBJ_FLAG == 1){
  exclude_subjects <- c(202, 203, 209, 216, 217, 220, 222, 225, 239, 240, 248, 250)
  rem_trialnums_cutoff <- 30
} else {
  exclude_subjects <- c(216, 222, 239) # these subjects are excluded irrespective of behavioral performance 
  rem_trialnums_cutoff <- 0
}

#' ## Make plot directory
dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)

#' # Load data
demog_info <- readxl::read_excel(file.path(project_dir, "eetemp_demo_log_clean.xlsx"))

#' # Filter out excluded subjects
subj_info <- demog_info %>%
  dplyr::rename(gender = "M/F", 
                age = "Age at test") %>%
  # convoluted system of renaming the column before changing to numeric because otherwise gets completely filled with NAs
  dplyr::mutate(age2 = as.numeric(age)) %>%
  dplyr::select(-age) %>%
  dplyr::rename(age = age2) %>%
  dplyr::filter(!Participant %in% exclude_subjects)

#' ## Report number of subjects included
sprintf("Currently analyzing %d subjects. Excluding participants with less than %d remembered trials.", length(subj_info$Participant), rem_trialnums_cutoff)
cat(print("Included subject numbers: \n"))
unique(subj_info$Participant)
cat(print("Excluded subject numbers: \n"))
exclude_subjects

#' # Tabulate by gender 
subj_info %>%
  dplyr::count(gender)

#' # Get mean and SD of ages
subj_info %>%
  dplyr::summarise(mean_age = mean(age, na.rm = TRUE), 
                   sd_age = sd(age, na.rm = TRUE))