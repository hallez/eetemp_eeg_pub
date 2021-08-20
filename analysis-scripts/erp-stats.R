#' ---
#' title: Run ERP stats
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
library(ez)
library(halle)
library(superheat)
library(tidyverse)
library(yaml)
# following instructions from http://kbroman.org/pkg_primer/pages/github.html
# this ensures that the most recent version of the `halle` package also gets added
devtools::install_github("hallez/halle", subdir="halle")

#' ## Load in config file
config <- yaml::yaml.load_file("../config.yml")

#' ## Flags
EXCLUDE_SUBJ_FLAG <- 1
VERSION_FLAG <- 7

#' ## Setup paths
# for folders that contain dashes in config, will need to index with single quote
project_dir <- ("../")
dropbox_dir <- paste0(halle::ensure_trailing_slash(config$directories$`dropbox-folder`))
analyzed_behavioral_dir <- paste0(project_dir,halle::ensure_trailing_slash(config$directories$`analyzed-behavioral-dir`))
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash("summary"))
analyzed_eeg_dir <- paste0(dropbox_dir, halle::ensure_trailing_slash(config$directories$`analyzed-eeg-dir`))
analyzed_mri_dir <- paste0(halle::ensure_trailing_slash(config$directories$`analyzed-mri-dir`))

#' ### Print version
sprintf("Analyzing version %d", VERSION_FLAG)
if(VERSION_FLAG < 7){
  expt_str <- sprintf("pilot%d", VERSION_FLAG)
} else{
  expt_str <- "experiment"
}
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash(sprintf("%s-summary", expt_str)))
plots_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash(sprintf("%s-plots", expt_str)))

#' ## Make plot directory
dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)

#' ## Exclude subjects
if(EXCLUDE_SUBJ_FLAG == 1){
  exclude_subjects <- c(202, 203, 216, 217, 220, 222, 225, 239, 240, 248, 250)
  rem_trialnums_cutoff <- 30
} else {
  exclude_subjects <- c(216, 222, 239) # these subjects are excluded irrespective of behavioral performance 
  rem_trialnums_cutoff <- 0
}

#' # Load ERP data
# this file is created by `compute_subj_integrals_no_study.m`
erp_fpath <- file.path(analyzed_eeg_dir, "group_erp_integral_diffs.csv")
if(!file.exists(erp_fpath)){
  cat(sprintf("\t%s does not exist. Stopping.\n", erp_fpath))
  break
}

erp_vals <- read.csv(erp_fpath) %>%
  # create a subj_id column so can join data frames
  dplyr::mutate(subj_id = as.character(subject)) %>%
  dplyr::mutate(participant = sub("s", "", subject)) %>%
  # remove any excluded subjects - remember that who gets excluded can be varied with EXCLUDE_SUBJ_FLAG
  dplyr::filter(!participant %in% exclude_subjects) 

#' ## Report number of subjects included
sprintf("Currently analyzing %d subjects. Excluding participants with less than %d remembered trials.", length(unique(erp_vals$participant)), rem_trialnums_cutoff)
print("Included subject numbers: \n")
unique(erp_vals$participant)
print("Excluded subject numbers: \n")
exclude_subjects

#' # Stats by ROI and hemisphere
erp_by_roi <- erp_vals %>%
  dplyr::filter(electrode %in% c("parietal_left", "parietal_right", "frontal_left", "frontal_right")) %>%
  tidyr::separate(electrode, into = c("elec_roi", "hemisphere"), sep = "_")

#' ## LPC stats
lpc_by_roi <- erp_by_roi %>%
  dplyr::filter(erp_component == "LPC")

ez::ezANOVA(data = lpc_by_roi, 
            dv = .(rem_minus_fam_area),
            wid = .(subject),
            within = .(elec_roi, hemisphere),
            # note that type 2 is the default, but setting just to make sure
            type = 2)

#' ### LPC frontal
lpc_by_roi %>%
  dplyr::filter(elec_roi == "frontal") %>%
  ez::ezANOVA(data = .,
              dv = .(rem_minus_fam_area),
              wid = .(subject),
              within = .(hemisphere),
              type = 2)

#' ### LPC parietal
lpc_by_roi %>%
  dplyr::filter(elec_roi == "parietal") %>%
  ez::ezANOVA(data = .,
              dv = .(rem_minus_fam_area),
              wid = .(subject),
              within = .(hemisphere),
              type = 2)

#' ## FN400 stats
fn400_by_roi <- erp_by_roi %>%
  dplyr::filter(erp_component == "FN400")

ez::ezANOVA(data = fn400_by_roi, 
            dv = .(rem_minus_fam_area),
            wid = .(subject),
            within = .(elec_roi, hemisphere),
            # note that type 2 is the default, but setting just to make sure
            type = 2)

#' ### FN400 frontal
fn400_by_roi %>%
  dplyr::filter(elec_roi == "frontal") %>%
  ez::ezANOVA(data = .,
              dv = .(rem_minus_fam_area),
              wid = .(subject),
              within = .(hemisphere),
              type = 2)

#' ### FN400 parietal
fn400_by_roi %>%
  dplyr::filter(elec_roi == "parietal") %>%
  ez::ezANOVA(data = .,
              dv = .(rem_minus_fam_area),
              wid = .(subject),
              within = .(hemisphere),
              type = 2)
