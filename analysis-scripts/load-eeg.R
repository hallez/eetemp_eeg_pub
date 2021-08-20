#' ---
#' title: Read in single subject EEG data and convert to group format
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

#' ## Setup paths
# for folders that contain dashes in config, will need to index with single quote
project_dir <- ("../")
dropbox_dir <- paste0(halle::ensure_trailing_slash(config$directories$`dropbox-folder`))
analyzed_behavioral_dir <- paste0(project_dir,halle::ensure_trailing_slash(config$directories$`analyzed-behavioral-dir`))
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash("summary"))
analyzed_eeg_dir <- paste0(dropbox_dir, halle::ensure_trailing_slash(config$directories$`analyzed-eeg-dir`))

#' ## Define subjects
subjects <- c(list.files(path = analyzed_eeg_dir, pattern = "^[s][(123456789)][(0123456789)][(0123456789)]$"))

#' ## Read in eeg electrode labels
eeg_lbls_file <- file.path(project_dir, "bioSemi64.ced")
eeg_lbls <- read.delim(eeg_lbls_file)

#' ## Figure out time labels
# Use the fact that the eeg data was windowed from -500 to 1000 ms when the erps were extracted
# and that this results in 191 time bins (rows) at a sampling rate of 128Hz
num_bins <- 191
bin_duration <- 1500/num_bins
bin_timestamps <- seq(-500, 1000, bin_duration)
# truncate the last time stamp 
bin_timestamps <- bin_timestamps[1:num_bins]

#' # Look across subjects, loading in data
for(isubj in 1:length(subjects)){
  cur_subj <- subjects[isubj]
  cur_subj_eeg_path <- file.path(analyzed_eeg_dir, cur_subj)
  
  rem_fpath <- file.path(cur_subj_eeg_path, sprintf("%s_rem_mean.csv", cur_subj))
  fam_fpath <- file.path(cur_subj_eeg_path, sprintf("%s_fam_mean.csv", cur_subj))
  cr_fpath <- file.path(cur_subj_eeg_path, sprintf("%s_cr_mean.csv", cur_subj))
  
  if(!file.exists(rem_fpath)){
    cat(sprintf("remembered means file %s does not exist.", rem_fpath))
    next
  }
  cur_rem <- read.csv(rem_fpath) 
  # seems like a reasonable assumption that the columns should be in the correct order as the eeg channels
  colnames(cur_rem) <- eeg_lbls$labels
  
  if(!file.exists(fam_fpath)){
    cat(sprintf("familiarity means file %s does not exist.", fam_fpath))
    next
  }
  cur_fam <- read.csv(fam_fpath) 
  colnames(cur_fam) <- eeg_lbls$labels
  
  if(!file.exists(cr_fpath)){
    cat(sprintf("correct rejections means file %s does not exist.", cr_fpath))
    next
  }
  cur_cr <- read.csv(cr_fpath) 
  colnames(cur_cr) <- eeg_lbls$labels
  
  # THIS IS NOT WORKING - WHEN TRY TO ADD COLUMN LABELS, LOSE DATA VALUES
  fn400_fpath <- file.path(cur_subj_eeg_path, sprintf("%s_FN400_fam-vs-cr.csv", cur_subj))
  fn400_fam_cr <- read.csv(fn400_fpath)
  colnames(fn400_fam_cr) <- eeg_lbls$labels
  
} #isubj
