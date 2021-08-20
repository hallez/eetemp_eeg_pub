#' ---
#' title: Summarize removed channels
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
lower_SD <- 2
upper_SD <- 200
print(sprintf("Lower SD value is %2.f, upper is %2.f", lower_SD, upper_SD))

#' # Load data
summ <- read.csv(file.path(config$directories$`dropbox-folder`, 
                           config$directories$`analyzed-eeg-dir`, 
                           sprintf('bad_channels_summary_lowSD-%s_highSD-%s.csv', lower_SD, upper_SD)))


summary(summ)
summ$block <- factor(summ$block)
summ$subject <- factor(summ$subject)

#' # Number of bad channels
# remember that if there are no excluded channels for a block then it's not shown
summ %>%
  dplyr::select(subject, block, totalnumbadchans) %>%
  dplyr::distinct() %>%
  ggplot2::ggplot(., ggplot2::aes(x = subject, y = totalnumbadchans, color = block)) +
  # jitter the points so that if multiple blocks have the same number of dropped channels can still see
  ggplot2::geom_point(position = "jitter") +
  # ensure only get integers on y axis
  ggplot2::scale_y_continuous(breaks = scales::pretty_breaks()) +
  ggplot2::expand_limits(y = 0) +
  ggplot2::ylab("number of bad channels")

#' ## Mean number of bad channels per subject
summ %>%
  dplyr::select(subject, totalnumbadchans) %>%
  dplyr::distinct() %>%
  dplyr::group_by(subject) %>%
  dplyr::summarise_all(funs(mean, sd)) %>%
  knitr::kable(., format = "html")  

#' # Bad channel ids
# this is helpful to see if anything systematic is happening across subjects
summ %>%
  dplyr::filter(badid != "none") %>%
  dplyr::distinct() %>%
  ggplot2::ggplot(., ggplot2::aes(x = badid)) +
  ggplot2::geom_bar() +
  ggplot2::xlab("bad channel id") +
  # shrink text size so can read channel labels in knitr output
  ggplot2::theme(axis.text.x = ggplot2::element_text(size = 5))

#' # Bad channel ids by subject
# seems like a gross way to do this visualization - better ideas?
summ %>%
  dplyr::filter(badid != "none") %>%
  ggplot2::ggplot(., ggplot2::aes(x = badid, fill = subject)) +
  ggplot2::geom_bar() +
  ggplot2::xlab("bad channel id") +
  ggplot2::theme(axis.text.x = ggplot2::element_text(size = 5))
