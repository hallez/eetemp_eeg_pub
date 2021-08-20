#' ---
#' title: Summarize removed epochs
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
local_thresh <- 6
global_thresh <- 2
analysis_type <- "ERP" # either "ERP" or "TF"
print(sprintf("Local threshold is %2.f, global threshold is %2.f for %s", local_thresh, global_thresh, analysis_type))

#' # Load data
summ <- read.csv(file.path(config$directories$`dropbox-folder`, 
                           config$directories$`analyzed-eeg-dir`, 
                           sprintf('bad_epochs_%s_summary_loc%s-glob%s.csv', analysis_type, local_thresh, global_thresh)))

summary(summ)
summ$block <- factor(summ$block)
summ$subject <- factor(summ$subject)

#' # Number of bad epochs
summ %>%
  dplyr::select(subject, block, badepochs) %>%
  dplyr::group_by(subject, block) %>%
  dplyr::count() %>%
  ggplot2::ggplot(., ggplot2::aes(x = subject, y = n, color = block)) +
  # jitter the points so that if multiple blocks have the same number of dropped epochs can still see
  ggplot2::geom_point(position = "jitter") +  # ensure only get integers on y axis
  ggplot2::scale_y_continuous(breaks = scales::pretty_breaks()) +
  ggplot2::expand_limits(y = 0) +
  ggplot2::ylab("number of bad epochs")

#' # Bad epoch ids
summ %>%
  dplyr::filter(badepochs != "none") %>%
  dplyr::distinct() %>%
  ggplot2::ggplot(., ggplot2::aes(x = badepochs)) +
  ggplot2::geom_bar() +
  ggplot2::xlab("bad epoch id") 

#' # Bad epoch ids by subject
summ %>%
  dplyr::filter(badepochs != "none") %>%
  dplyr::distinct() %>%
  ggplot2::ggplot(., ggplot2::aes(x = badepochs, y = block)) +
  ggplot2::geom_point() +
  ggplot2::xlab("bad epoch id") +
  ggplot2::facet_wrap(~subject)