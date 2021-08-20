#' ---
#' title: Recode eetemp EEG event types
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
library(R.matlab)
library(tidyverse)
library(yaml)
# following instructions from http://kbroman.org/pkg_primer/pages/github.html
# this ensures that the most recent version of the `halle` package also gets added
devtools::install_github("hallez/halle", subdir="halle")

#' ## Load in config file
config <- yaml::yaml.load_file("../config.yml")

#' ## Flags
SAVE_FLAG <- 1
pilot_version_FLAG <- 7

#' ## Setup paths
# for folders that contain dashes in config, will need to index with single quote
project_dir <- ("../")
dropbox_dir <- paste0(halle::ensure_trailing_slash(config$directories$`dropbox-folder`))
analyzed_behavioral_dir <- paste0(project_dir,halle::ensure_trailing_slash(config$directories$`analyzed-behavioral-dir`))
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash("summary"))
dropbox_dir <- paste0(halle::ensure_trailing_slash(config$directories$`dropbox-folder`))

#' ### Print pilot version
sprintf("Analyzing pilot %d", pilot_version_FLAG)
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash(sprintf("pilot%d-summary", pilot_version_FLAG)))

#' # Load data
# should load a variable called `all_scored` that is created by `analyze-behavior.R`
load(paste0(halle::ensure_trailing_slash(group_analyzed_dir),"scored_data.Rdata"))

#' # Save out subject-specific trial information
subjects <- unique(all_scored$subj_factor)
for(isubj in 1:length(subjects)){
  cur_subj <- subjects[isubj]
  eeglab_info_path <- file.path(dropbox_dir, "analyzed-behavioral", halle::format_three_digit_subject_id(cur_subj))
  
  eeglab_events_fname <- file.path(eeglab_info_path, "eeglab-events_all-blocks.mat")
  if(!file.exists(eeglab_events_fname)){
    cat(sprintf("eeglab events file %s does not exist - skipping", eeglab_events_fname))
    next
  }
  
  eeglab_latencies_fname <- file.path(eeglab_info_path, "eeglab-latencies_all-blocks.txt")
  if(!file.exists(eeglab_latencies_fname)){
    cat(sprintf("eeglab events file %s does not exist - skipping", eeglab_latencies_fname))
    next
  }
  
  eeglab_types_fname <- file.path(eeglab_info_path, "eeglab-types_all-blocks.txt")
  if(!file.exists(eeglab_types_fname)){
    cat(sprintf("eeglab types file %s does not exist - skipping", eeglab_types_fname))
    next
  }
  
  cur_events <- R.matlab::readMat(eeglab_events_fname)
  cur_latencies <- load(eeglab_latencies_fname) # WHAT IS THIS ERROR???
  cur_dat <- all_scored %>%
    dplyr::filter(subj_factor == cur_subj)
} #isubj
