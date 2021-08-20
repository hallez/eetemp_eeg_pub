#' ---
#' title: Analyze correlations in eetemp behavioral, rsFC, and EEG data
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
#'    code_folding: "hide"
#' ---

#' # Setup
 
#' ## Define functions
compute_cor_and_plot <- function(input_df, col1, col2, subj_col){ 
  pp <- NULL
  stat_vals <- NULL
  
  # calling column names in a function based on: https://stackoverflow.com/questions/2641653/pass-a-data-frame-column-name-to-a-function
  print(cor.test(input_df[[col1]], input_df[[col2]]))
  
  stat_vals <<- cor.test(input_df[[col1]], input_df[[col2]])
  # if set values in the plot as global variables, shit breaks
  tmp <- cor.test(input_df[[col1]], input_df[[col2]])
  stat_for_plot <- sprintf("t(%.f) = %0.3f,\nr = %0.3f, p = %s",
                           tmp$parameter, tmp$statistic, 
                           tmp$estimate, 
                           ifelse(tmp$p.value < 0.05, sprintf("%0.2f*", tmp$p.value), sprintf("%0.2f", tmp$p.value)))
  
  pp <<- input_df %>%
    ggplot2::ggplot(., ggplot2::aes_string(x = col1, y = col2)) +
    ggplot2::geom_point(ggplot2::aes_string(color = subj_col)) +
    ggplot2::annotate(geom = "text", x = -Inf, y = Inf, hjust = 0, vjust = 1, label = stat_for_plot, size = 7)
}

compute_cor_and_plot_no_annotate <- function(input_df, col1, col2, subj_col){ 
  pp <- NULL
  stat_vals <- NULL
  
  # calling column names in a function based on: https://stackoverflow.com/questions/2641653/pass-a-data-frame-column-name-to-a-function
  print(cor.test(input_df[[col1]], input_df[[col2]]))
  
  stat_vals <<- cor.test(input_df[[col1]], input_df[[col2]])
  # if set values in the plot as global variables, shit breaks
  tmp <- cor.test(input_df[[col1]], input_df[[col2]])
  stat_for_plot <- sprintf("t(%.f) = %0.3f, r = %0.3f, p = %s",
                           tmp$parameter, tmp$statistic, 
                           tmp$estimate, 
                           ifelse(tmp$p.value < 0.05, sprintf("%0.2f*", tmp$p.value), sprintf("%0.2f", tmp$p.value)))

  pp <<- input_df %>%
    ggplot2::ggplot(., ggplot2::aes_string(x = col1, y = col2)) +
    ggplot2::geom_point(ggplot2::aes_string(color = subj_col)) +
    ggplot2::annotate(geom = "text", x = -Inf, y = Inf, hjust = 0, vjust = 1, label = stat_for_plot, size = 5)
}

#' ## Load required packages
library(cowplot)
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
SAVE_FLAG <- 1
VERSION_FLAG <- 7

#' ## Setup paths
# for folders that contain dashes in config, will need to index with single quote
project_dir <- ("../")
dropbox_dir <- paste0(halle::ensure_trailing_slash(config$directories$`dropbox-folder`))
analyzed_behavioral_dir <- paste0(project_dir,halle::ensure_trailing_slash(config$directories$`analyzed-behavioral-dir`))
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash("summary"))
analyzed_eeg_dir <- paste0(dropbox_dir, halle::ensure_trailing_slash(config$directories$`analyzed-eeg-dir`))
analyzed_mri_dir <- paste0(halle::ensure_trailing_slash(config$directories$`analyzed-mri-dir`))
conn_group_dir <- paste0(analyzed_mri_dir, halle::ensure_trailing_slash("conn-group-analyses"))
conn_analysis_str <- "allsteps_dxrois_structural-functional-center_N44"
conn_results_dir <- paste0(conn_group_dir, conn_analysis_str)
sfn_2018_dir <- paste0(dropbox_dir, halle::ensure_trailing_slash("presentations"),
                       halle::ensure_trailing_slash("sfn-2018"))
dissertation_figures_dir <- file.path(dropbox_dir, "writeups", "figures")
sfn_theme <- ggplot2::theme(plot.title = element_text(size = 24),
                            axis.title.y = element_text(size = 28), axis.text.y = element_text(size = 20),
                            axis.title.x = element_text(size = 28), axis.text.x = element_text(size = 20), 
                            legend.position = "none")
cowplot_theme <- ggplot2::theme(legend.position = "none")

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

#' # Specify ROI to network mappings 
# this is a gross solution to hardcode, but since the mappings don't change, seems like a reasonable approach 
# the benefit of this approach is that if add in other atlases, can just update "at_roi_names" and "pm_roi_names" 
at_roi_names <- c("Amygdala", "aPaHC", "FOrb", "pTFusC", "pITG", "dx_fusiform", "dx_infTempG", "dx_infTempS", "dx_lOFC")
pm_roi_names <- c("AG", "Precuneous", "PC", "pPaHC", "dx_ANG", "dx_MTG", "dx_PCU", "dx_postdCing", "dx_postvCing", "dx_temporalPole")
hub_roi_names <- c("Hippocampus", "SubCalC", "MedFC")
dx_roi_names <- c("dx_fusiform", "dx_infTempG", "dx_infTempS", "dx_lOFC", "aPaHC", "Amygdala",
                  "dx_ANG", "dx_MTG", "dx_PCU", "dx_postdCing", "dx_postvCing", "dx_temporalPole", "pPaHC",
                  "Hippocampus", "SubCalC", "MedFC")
# add labels for network affiliations and format dataframes for merging 
at_rois <- data.frame(at_roi_names) %>%
  # this will scale nicely as add more region labels to the dataframe 
  dplyr::mutate(network = "AT") %>% 
  # rename column for merging purposes
  dplyr::rename(roi_names = at_roi_names) 

pm_rois <- data.frame(pm_roi_names) %>%
  dplyr::mutate(network = "PM") %>% 
  dplyr::rename(roi_names = pm_roi_names) 

hub_rois <- data.frame(hub_roi_names) %>%
  dplyr::mutate(network = "HUB") %>% 
  dplyr::rename(roi_names = hub_roi_names) 

# NB: will get an error about joining factors with different levels, this is expected and can ignore 
roi_network_dict <- dplyr::full_join(at_rois, pm_rois, by = c("roi_names", "network")) %>%
  dplyr::full_join(., hub_rois, by = c("roi_names", "network"))

#' # Load behavioral data (`all_scored`)
load(paste0(halle::ensure_trailing_slash(group_analyzed_dir),"scored_data.Rdata"))

if(EXCLUDE_SUBJ_FLAG == 1){
  exclude_subjects <- c(202, 203, 209, 216, 217, 220, 222, 225, 239, 240, 248, 250)
  rem_trialnums_cutoff <- 30
} else {
  exclude_subjects <- c(216, 222, 239) # these subjects are excluded irrespective of behavioral performance 
  rem_trialnums_cutoff <- 0
}

subjects <- unique(all_scored$participant)

#' ## Compute behavioral summaries by participant, rather than by trial
# start by just printing out - can double check that same values as in `analyze-behavior.R`
table(all_scored$participant, all_scored$itemScore)
table(all_scored$participant, all_scored$questionScore)

#' ### Item recog counts
item_scored_counts <- all_scored %>%
  dplyr::group_by(participant, itemScore) %>%
  dplyr::tally() %>%
  tidyr::spread(key = itemScore, value = n) %>%
  dplyr::select(-participant) %>%
  dplyr::summarise_all(funs(sum(., na.rm = TRUE))) %>%
  dplyr::group_by(participant) %>%
  # count number of old and new objects for each subjects not including excluded trials
  dplyr::mutate(num_old = sum(Rec, Fam, Miss, na.rm = TRUE), 
                num_new = sum(`R-FA`, `F-FA`, CR, na.rm = TRUE),
                rem_hit_rate = Rec / num_old, 
                fam_hit_rate = Fam / num_old,
                rem_fa_rate = `R-FA` / num_new,
                fam_fa_rate = `F-FA` / num_new,
                cr_rate = CR / num_new,
                rec_libby = (Rec - `R-FA`) / (1 - `R-FA`), # calculation based on Libby et al 2013 page 946
                rec_charan = Rec - `R-FA`, # calculation based on Charan's slack message 9/24/18
                rec_dualprocess = rem_hit_rate - rem_fa_rate, # calculation based on Barnett/HML slack message 9/24/18
                fam_hits_corrected = fam_hit_rate / (1 - rem_hit_rate), 
                fam_corrected = fam_fa_rate / (1 - rem_fa_rate),
                fam_dualprocess = fam_hits_corrected - fam_corrected)

item_scored_counts %>%
  tidyr::gather(key = "process_type", value = "value", -participant) %>%
  dplyr::filter(process_type %in% c("rec_dualprocess", "fam_dualprocess")) %>%
  # change x-axis labels to match source memory plots
  dplyr::mutate(process_type = dplyr::recode(process_type, "fam_dualprocess" = "fam", "rec_dualprocess" = "rec")) %>%
  ggplot2::ggplot(ggplot2::aes(x = process_type, y = value)) +
  ggplot2::geom_boxplot(width = 0.3) +
  ggplot2::geom_point(ggplot2::aes(color = as.factor(participant)),
                      position = ggplot2::position_jitterdodge(0.1)) +
  ggplot2::ggtitle("Dual Process Estimates") +
  ggplot2::ylab("mean estimate value") +
  ggplot2::theme_gray() +
  ggplot2::theme(legend.position = "none",
                 plot.title = element_text(hjust = 0.5, size = 20),
                 axis.title.x = element_blank(), axis.text.x = element_text(size = 15),
                 strip.text.x = element_text(size = 20), strip.background.x = element_rect(fill = "white"),
                 axis.title.y = element_text(size = 20), axis.text.y = element_text(size = 15))

if(SAVE_FLAG){
  ggplot2::ggsave(filename = file.path(dissertation_figures_dir, "dual_process_estimates.pdf"), width = 6, height = 4)
}

item_scored_counts %>%
  dplyr::select(participant, contains("rate")) %>%
  tidyr::gather(-participant, key = "item_recog_resp", value = "mean_resprate") %>%
  dplyr::group_by(item_recog_resp) %>%
  dplyr::summarize(mean_resprate = mean(mean_resprate)) %>%
  ggplot2::ggplot(ggplot2::aes(x = item_recog_resp, y = mean_resprate)) +
  ggplot2::geom_bar(stat = "identity", width = 0.5) 

#' ### Liberal question source counts
source_liberal_scored_counts <- all_scored %>%
  dplyr::select(participant, questionScoreLiberal) %>%
  dplyr::group_by(participant, questionScoreLiberal) %>%
  dplyr::tally() %>%
  tidyr::spread(key = questionScoreLiberal, value = n) %>%
  dplyr::select(-participant) %>%
  dplyr::summarise_all(funs(sum(., na.rm = TRUE))) %>%
  # rename duplicated columns for clarity
  dplyr::rename(questliberal_source_incorrect = incorrect,
                questliberal_source_random_response = random_response,
                questliberal_source_new_item = new_item)

sourceXitemmem_liberal_scored_counts <- all_scored %>%
  dplyr::select(participant, questionScoreLiberal, itemScore) %>%
  # to avoid confusion w/ source exact, revalue
  dplyr::mutate(questionScoreLiberal_reval = dplyr::recode(questionScoreLiberal, 
                                                           "incorrect" = "questliberal_source_incorrect",
                                                           "random_response" = "questliberal_source_random_response",
                                                           "new_item" = "questliberal_source_new_item")) %>%
  dplyr::group_by(participant, questionScoreLiberal_reval, itemScore) %>%
  dplyr::tally() %>%
  # merge item and question
  tidyr::unite(col = itemmem_questmemliberal, itemScore, questionScoreLiberal_reval) %>%
  tidyr::spread(key = itemmem_questmemliberal, value = n) %>%
  dplyr::select(-participant) %>%
  dplyr::summarise_all(funs(sum(., na.rm = TRUE))) 

#' ### Exact question source counts
source_exact_scored_counts <- all_scored %>%
  dplyr::select(participant, questionScore) %>%
  dplyr::group_by(participant, questionScore) %>%
  dplyr::tally() %>%
  tidyr::spread(key = questionScore, value = n) %>%
  dplyr::select(-participant) %>%
  dplyr::summarise_all(funs(sum(., na.rm = TRUE)))

sourceXitemmem_exact_scored_counts <- all_scored %>%
  dplyr::select(participant, questionScore, itemScore) %>%
  dplyr::group_by(participant, questionScore, itemScore) %>%
  dplyr::tally() %>%
  # merge item and question
  tidyr::unite(col = itemmem_questmem, itemScore, questionScore) %>%
  tidyr::spread(key = itemmem_questmem, value = n) %>%
  dplyr::select(-participant) %>%
  dplyr::summarise_all(funs(sum(., na.rm = TRUE)))

#' ### Merge all and compute source mem rates
behav_all_counts <- item_scored_counts %>%
  dplyr::full_join(source_liberal_scored_counts, by = "participant") %>%
  dplyr::full_join(source_exact_scored_counts, by = "participant") %>%
  dplyr::full_join(sourceXitemmem_exact_scored_counts, by = "participant") %>%
  dplyr::full_join(sourceXitemmem_liberal_scored_counts, by = "participant") %>%
  # now make the subject id match other dataframes
  dplyr::mutate(subj_id = sprintf('s%s', participant)) %>%
  # Remove participants who have less than 30 remembered trials or are listed in "exclude_subjects"
  dplyr::filter(Rec > rem_trialnums_cutoff) %>%
  dplyr::filter(!participant %in% exclude_subjects) %>%
  # compute source memory rates
  dplyr::mutate(source_questiontype_hitrate = correct_questiontype / num_old, 
                source_exact_hitrate = correct / num_old)

#' ### Graphically check
behav_all_counts %>%
  dplyr::select(participant, contains("rate")) %>%
  tidyr::gather(-participant, key = "response_type", value = "mean_resprate") %>%
  dplyr::group_by(response_type) %>%
  dplyr::summarize(mean_resprate = mean(mean_resprate)) %>%
  ggplot2::ggplot(ggplot2::aes(x = response_type, y = mean_resprate)) +
  ggplot2::geom_bar(stat = "identity", width = 0.5)

# split source mem on the basis of item mem
behav_all_counts %>%
  dplyr::select(participant, Rec_correct, Rec_incorrect, Fam_correct, Fam_incorrect) %>%
  tidyr::gather(-participant, key = "response_type", value = "mean_count") %>%
  dplyr::group_by(response_type) %>%
  dplyr::summarize(mean_count = mean(mean_count)) %>%
  ggplot2::ggplot(ggplot2::aes(x = response_type, y = mean_count)) +
  ggplot2::geom_bar(stat = "identity", width = 0.5) +
  ggtitle("count of exact quest source mem by item mem")

behav_all_counts %>%
  dplyr::select(participant, Rec_correct_questiontype, Rec_questliberal_source_incorrect, Fam_correct_questiontype, Fam_questliberal_source_incorrect) %>%
  tidyr::gather(-participant, key = "response_type", value = "mean_count") %>%
  dplyr::group_by(response_type) %>%
  dplyr::summarize(mean_count = mean(mean_count)) %>%
  ggplot2::ggplot(ggplot2::aes(x = response_type, y = mean_count)) +
  ggplot2::geom_bar(stat = "identity", width = 0.5) +
  ggtitle("count of liberal quest source mem by item mem")
  
#' ## Mean and SD for item and source memory
# idealy, this would be in `analyze-behavior.R`, but putting it here so don't need to duplicate code
behav_all_counts %>%
  dplyr::ungroup() %>%
  dplyr::summarise(mean_rem_rate = mean(rem_hit_rate),
                   sd_rem_rate = sd(rem_hit_rate),
                   mean_fam_rate = mean(fam_hit_rate),
                   sd_fam_rate = sd(fam_hit_rate),
                   mean_cr_rate = mean(cr_rate),
                   sd_cr_rate = sd(cr_rate),
                   mean_source_exact_rate = mean(source_exact_hitrate),
                   sd_source_exact_rate = sd(source_exact_hitrate),
                   mean_source_liberal_rate = mean(source_questiontype_hitrate),
                   sd_source_liberal_rate = sd(source_questiontype_hitrate)) %>%
  tidyr::gather(key = "measure", value = "value")

#' ## Test for differences in source memory on the basis of R vs F
t.test(behav_all_counts$Rec_correct, behav_all_counts$Fam_correct, paired = TRUE)

t.test(behav_all_counts$Rec_correct_questiontype, behav_all_counts$Fam_correct_questiontype, paired = TRUE)

#' ## Report number of subjects included
sprintf("Currently analyzing %d subjects. Excluding participants with less than %d remembered trials.", length(behav_all_counts$participant), rem_trialnums_cutoff)
cat(print("Included subject numbers: \n"))
unique(behav_all_counts$participant)
cat(print("Excluded subject numbers: \n"))
exclude_subjects

#' ## Correlations between recollection and familiarity estimates and source memory 
#' ### Compare different calculations for recollection 
behav_all_counts %>%
  ggplot2::ggplot(., ggplot2::aes(x = rec_charan, y = rec_dualprocess)) +
  ggplot2::geom_point(ggplot2::aes(color = subj_id))

behav_all_counts %>%
  ggplot2::ggplot(., ggplot2::aes(x = rec_charan, y = rec_libby)) +
  ggplot2::geom_point(ggplot2::aes(color = subj_id))

behav_all_counts %>%
  ggplot2::ggplot(., ggplot2::aes(x = rec_libby, y = rec_dualprocess)) +
  ggplot2::geom_point(ggplot2::aes(color = subj_id))

#' ### Compare recollection and familiarity
behav_all_counts %>%
  dplyr::ungroup() %>%
  dplyr::select(subj_id, fam_dualprocess, rec_dualprocess) %>%
  tidyr::gather(., key = "memory_type", value = "dualprocess_est", -subj_id) %>%
  ggplot2::ggplot(., ggplot2::aes(x = memory_type, y = dualprocess_est)) +
  ggplot2::geom_boxplot() +
  ggplot2::geom_jitter(ggplot2::aes(color = subj_id))  

cor.test(behav_all_counts$fam_dualprocess, behav_all_counts$rec_dualprocess)
behav_all_counts %>%
  ggplot2::ggplot(., ggplot2::aes(x = fam_dualprocess, y = rec_dualprocess)) +
  ggplot2::geom_point(ggplot2::aes(color = subj_id)) +
  geom_smooth(method='lm')

#' ### Compare recollection and source memory
#' #### Require exact source memory (correct question, 1/4)
cor.test(behav_all_counts$rec_dualprocess, behav_all_counts$correct)
behav_all_counts %>%
  ggplot2::ggplot(., ggplot2::aes(x = rec_dualprocess, y = correct)) +
  ggplot2::geom_point(ggplot2::aes(color = subj_id)) +
  geom_smooth(method='lm')

#' #### Allow liberal source memory (correct question type, 2/4)
cor.test(behav_all_counts$rec_dualprocess, behav_all_counts$correct_questiontype)
behav_all_counts %>%
  ggplot2::ggplot(., ggplot2::aes(x = rec_dualprocess, y = correct_questiontype)) +
  ggplot2::geom_point(ggplot2::aes(color = subj_id)) +
  geom_smooth(method='lm')

#' ### Compare familiarity and source memory
#' #### Require exact source memory (correct question, 1/4)
cor.test(behav_all_counts$fam_dualprocess, behav_all_counts$correct)
behav_all_counts %>%
  ggplot2::ggplot(., ggplot2::aes(x = fam_dualprocess, y = correct)) +
  ggplot2::geom_point(ggplot2::aes(color = subj_id)) +
  geom_smooth(method='lm')

#' #### Allow liberal source memory (correct question type, 2/4)
cor.test(behav_all_counts$fam_dualprocess, behav_all_counts$correct_questiontype)
behav_all_counts %>%
  ggplot2::ggplot(., ggplot2::aes(x = fam_dualprocess, y = correct_questiontype)) +
  ggplot2::geom_point(ggplot2::aes(color = subj_id)) +
  geom_smooth(method='lm')

#' # Read in rsFC values
rsfc_fpath <- file.path(conn_results_dir, "rsfc_vals_nsub44.csv")

if(!file.exists(rsfc_fpath)){
  cat(sprintf("\t%s does not exist. Stopping.\n", rsfc_fpath))
  break
}

rsfc_vals <- read.csv(rsfc_fpath)

# NB: will get an error about number of expected pieces and missing pieces being filled with NA - can ignore
all_rsfc <- rsfc_vals %>%
  dplyr::mutate(subj_id = as.character(subject)) %>%
  # remove excluded subjects
  dplyr::mutate(subj_num = as.numeric(sub("s", "", subject))) %>%
  dplyr::filter(!subj_num %in% exclude_subjects) %>%
  # format the destrieux roi hemisphere labels like the HOA labels
  dplyr::mutate(source_roi_tmp = sub("\\_([rl])$", " \\1", source_roi_name)) %>%
  tidyr::separate(source_roi_tmp, c("source_atlas", "source_extra"), extra = "merge", sep = " ") %>%
  dplyr::mutate(source_roi = sub("atlas.", "", source_atlas)) %>%
  tidyr::separate(source_extra, c("source_hemi_tmp", "source_extra2"), extra = "merge", sep = "\\(") %>%
  dplyr::mutate(source_hemi_nospace = sub(" ", "", source_hemi_tmp)) %>%
  # checking for empty character based on: https://stackoverflow.com/questions/21243588/replace-blank-cells-with-character
  dplyr::mutate(source_hemi = sub("^$", "bilat", source_hemi_nospace)) %>%
  dplyr::mutate(target_roi_tmp = sub("\\_([rl])$", " \\1", target_roi_name)) %>%
  tidyr::separate(target_roi_tmp, c("target_atlas", "target_extra"), extra = "merge", sep = " ") %>%
  tidyr::separate(target_extra, c("target_hemi_tmp", "target_extra2"), extra = "merge", sep = "\\(") %>%
  dplyr::mutate(target_hemi_nospace = sub(" ", "", target_hemi_tmp)) %>%
  dplyr::mutate(target_hemi = sub("^$", "bilat", target_hemi_nospace)) %>%
  dplyr::mutate(target_roi = sub("atlas.", "", target_atlas)) %>%
  dplyr::select(-source_atlas, -source_hemi_tmp, -source_extra2,
                -target_atlas, -target_hemi_tmp, -target_extra2) %>%
  # add in network labels, to do this, need to have matching column names
  dplyr::rename(roi_names = source_roi) %>%
  dplyr::full_join(., roi_network_dict, by = c("roi_names")) %>%
  # rename columns before figuring out atlas affiliations for target ROIs (yes, this is a gross system)
  dplyr::rename(source_roi = roi_names,
                source_network = network) %>%
  dplyr::rename(roi_names = target_roi) %>%
  dplyr::full_join(., roi_network_dict, by = c("roi_names")) %>%
  dplyr::rename(target_roi = roi_names,
                target_network = network) %>%
  dplyr::mutate(source_target_network = paste0(source_network, "_", target_network),
                source_target_hemi = paste0(source_hemi, "_", target_hemi),
                source_target_network_by_hemi = paste0(source_network, "_", target_network, "_", source_target_hemi),
                source_target_roi = paste0(source_roi, "_", target_roi),
                source_target_roi_by_hemi = paste0(source_target_roi, "_", source_target_hemi),
                source_roi_by_hemi = paste0(source_roi, "_", source_hemi),
                target_roi_by_hemi = paste0(target_roi, "_", target_hemi))

rsfc_subj_means <- all_rsfc %>%
  # ensure that not double-counting ROIs so exclue Destrieux
  dplyr::filter(!grepl("dx_", source_roi)) %>%
  dplyr::filter(!grepl("dx_", target_roi)) %>%
  dplyr::group_by(source_target_network, subj_id) %>%
  # since ROI rsfc values are nans, remove these when taking the mean
  dplyr::summarise(mean_rsfc = mean(rsfc_value, na.rm = TRUE))

rsfc_subj_means_dx_rois <- all_rsfc %>%
  dplyr::group_by(source_target_network, subj_id) %>%
  # since ROI rsfc values are nans, remove these when taking the mean
  dplyr::summarise(mean_rsfc = mean(rsfc_value, na.rm = TRUE))

#' ## Try to replicate Ritchey et al 2014 JOCN fig 1
# average across all subjects
avg_rsfc <- all_rsfc %>%
  dplyr::group_by(source_roi_by_hemi, target_roi_by_hemi, source_network, target_network) %>%
  dplyr::summarise(mean_rsfc = mean(rsfc_value)) %>%
  as.data.frame()

# print out some summary information, so have an intuition
summary(avg_rsfc)

rsfc_cor <- avg_rsfc %>%
  dplyr::mutate(source_roi_by_hemi_and_network = paste0(source_network, "_", source_roi_by_hemi),
                target_roi_by_hemi_and_network = paste0(target_network, "_", target_roi_by_hemi)) %>%
  dplyr::select(source_roi_by_hemi_and_network, target_roi_by_hemi_and_network, mean_rsfc) %>%
  tidyr::spread(target_roi_by_hemi_and_network, mean_rsfc)

rownames(rsfc_cor) <- rsfc_cor$source_roi_by_hemi_and_network

rsfc_cor_mtx <- rsfc_cor %>%
  dplyr::select(-source_roi_by_hemi_and_network)

png(file.path(plots_dir, sprintf("rsfc_group_dendro_%s.png", conn_analysis_str)), height = 900, width = 800)
superheat::superheat(rsfc_cor_mtx,
                     left.label.size = 0.7, left.label.text.size = 5,
                     bottom.label.size = 0.7, bottom.label.text.size = 5, bottom.label.text.angle = 90,
                     row.dendrogram = TRUE)
dev.off()

png(file.path(plots_dir, sprintf("rsfc_group_%s.png", conn_analysis_str)), height = 900, width = 800)
superheat::superheat(rsfc_cor_mtx,
                     left.label.size = 0.7, left.label.text.size = 5,
                     bottom.label.size = 0.7, bottom.label.text.size = 5, bottom.label.text.angle = 90)
dev.off()

png(file.path(plots_dir, sprintf("rsfc_group_maureen-range_%s.png", conn_analysis_str)), height = 900, width = 800)
superheat::superheat(rsfc_cor_mtx,
                     left.label.size = 0.7, left.label.text.size = 5,
                     bottom.label.size = 0.7, bottom.label.text.size = 5, bottom.label.text.angle = 90,
                     heat.lim = c(0, 0.6))
dev.off()

#' ### Try with Destrieux ROIs
avg_rsfc_dx_rois <- all_rsfc %>%
  dplyr::filter(source_roi %in% dx_roi_names) %>%
  dplyr::filter(target_roi %in% dx_roi_names) %>%
  dplyr::group_by(source_roi_by_hemi, target_roi_by_hemi, source_network, target_network) %>%
  dplyr::summarise(mean_rsfc = mean(rsfc_value)) %>%
  as.data.frame()

rsfc_cor_dx <- avg_rsfc_dx_rois %>%
  dplyr::mutate(source_roi_by_hemi_and_network = paste0(source_network, "_", source_roi_by_hemi),
                target_roi_by_hemi_and_network = paste0(target_network, "_", target_roi_by_hemi)) %>%
  dplyr::select(source_roi_by_hemi_and_network, target_roi_by_hemi_and_network, mean_rsfc) %>%
  tidyr::spread(target_roi_by_hemi_and_network, mean_rsfc) %>%
  dplyr::mutate(tmp = dplyr::recode(source_roi_by_hemi_and_network, "AT_Amygdala_l" = "AT_AMY_l",
                "AT_Amygdala_r" = "AT_AMY_r",
                "AT_aPaHC_l" = "AT_PRC_l",
                "AT_aPaHC_r" = "AT_PRC_r",
                "AT_dx_fusiform_l" = "AT_FUSIF_l",
                "AT_dx_fusiform_r" = "AT_FUSIF_r",
                "AT_dx_infTempG_l" = "AT_infTG_l",
                "AT_dx_infTempG_r" = "AT_infTG_r",
                "AT_dx_infTempS_l" = "AT_infTS_l",
                "AT_dx_infTempS_r" = "AT_infTS_r",
                "AT_dx_lOFC_l" = "AT_lOFC_l",
                "AT_dx_lOFC_r" = "AT_lOFC_r",
                "HUB_Hippocampus_l" = "HUB_HC_l",
                "HUB_Hippocampus_r" = "HUB_HC_r",
                "HUB_MedFC_bilat" = "HUB_vmPFC1",
                "HUB_SubCalC_bilat" = "HUB_vmPFC2",
                "PM_dx_ANG_l" = "PM_ANG_l",
                "PM_dx_ANG_r" = "PM_ANG_r",
                "PM_dx_MTG_l" = "PM_MTG_l",
                "PM_dx_MTG_r" = "PM_MTG_r",
                "PM_dx_PCU_l" = "PM_PCU_l",
                "PM_dx_PCU_r" = "PM_PCU_r",
                "PM_dx_postdCing_l" = "PM_postdCing_l",
                "PM_dx_postdCing_r" = "PM_postdCing_r",
                "PM_dx_postvCing_l" = "PM_postvCing_l",
                "PM_dx_postvCing_r" = "PM_postvCing_r",
                "PM_dx_temporalPole_l" = "PM_tempPole_l",
                "PM_dx_temporalPole_r" = "PM_tempPole_r",
                "PM_pPaHC_l" = "PM_PHC_l",
                "PM_pPaHC_r" = "PM_PHC_r"))

roi_labels <- rsfc_cor_dx$tmp

rownames(rsfc_cor_dx) <- roi_labels

rsfc_cor_dx_mtx <- rsfc_cor_dx %>%
  dplyr::select(-source_roi_by_hemi_and_network, -tmp)

colnames(rsfc_cor_dx_mtx) <- roi_labels

png(file.path(dissertation_figures_dir, sprintf("rsfc_group_dx_%s_%s-included.png", conn_analysis_str, length(unique(all_rsfc$subject)))), height = 900, width = 800)
superheat::superheat(rsfc_cor_dx_mtx,
                     left.label.size = 0.3, left.label.text.size = 5,
                     bottom.label.size = 0.3, bottom.label.text.size = 5, bottom.label.text.angle = 90)
dev.off()

#' # Load ERP data
# this file is created by `compute_subj_integrals_no_study.m`
erp_fpath <- file.path(analyzed_eeg_dir, "group_erp_integral_diffs.csv")
if(!file.exists(erp_fpath)){
  cat(sprintf("\t%s does not exist. Stopping.\n", erp_fpath))
  break
}

erp_vals <- read.csv(erp_fpath) %>%
  # create a subj_id column so can join data frames
  dplyr::mutate(subj_id = as.character(subject))

#' # Load TF data
# this file is created by `compute_tf.m`
tf_fpath <- file.path(analyzed_eeg_dir, "group_mean_theta_power.csv")
if(!file.exists(tf_fpath)){
  cat(sprintf("\t%s does not exist. Stopping.\n", tf_fpath))
  break
}

tf_vals <- read.csv(tf_fpath) %>%
  dplyr::rename(tf_chan_id = chan_id)

#' # Combine behavioral, rsFC, and EEG data
all_data <- behav_all_counts %>%
  dplyr::full_join(., rsfc_subj_means, by = "subj_id") %>%
  dplyr::full_join(., erp_vals, by = "subj_id") %>%
  dplyr::full_join(., tf_vals, by = "subj_id") %>%
  dplyr::mutate(subj_num = sub("s", "", subj_id)) %>%
  dplyr::filter(!subj_num %in% exclude_subjects) %>%
  # for now, let's only focus on AT and PM connectivity disregarding between network connectivity
  dplyr::filter(source_target_network %in% c("AT_AT", "HUB_HUB", "PM_PM")) %>%
  dplyr::filter(!is.na(tf_chan_id))

all_data_dx_rois <- behav_all_counts %>%
  dplyr::full_join(., rsfc_subj_means_dx_rois, by = "subj_id") %>%
  dplyr::full_join(., erp_vals, by = "subj_id") %>%
  dplyr::full_join(., tf_vals, by = "subj_id") %>%
  dplyr::mutate(subj_num = sub("s", "", subj_id)) %>%
  dplyr::filter(!subj_num %in% exclude_subjects) %>%
  # for now, let's only focus on AT and PM connectivity disregarding between network connectivity
  dplyr::filter(source_target_network %in% c("AT_AT", "HUB_HUB", "PM_PM")) %>%
  dplyr::filter(!is.na(tf_chan_id))

# for simplicity of making figures, smush behavior back into rows instead of spread across columns
all_data_dx_rois_mem_grouped <- all_data_dx_rois %>%
  tidyr::gather(key = "memory_type", value = "value", 
                contains("rate"), contains("dualprocess")) 

#' ## Correlate ERPs with behavior
erp_chans <- unique(all_data$electrode)
erp_components <- unique(all_data$erp_component)

for (icomp in 1:length(erp_components)) {
  for (ichan in 1:length(erp_chans)) {
    cur_comp <- erp_components[icomp]
    cur_chan <- erp_chans[ichan]

    cur_erp_data <- all_data %>%
      dplyr::filter(electrode == cur_chan) %>%
      dplyr::filter(erp_component == cur_comp) %>%
      # remove columns that cause rows to get duplicated so that degrees of freedom are correct in the correlation
      dplyr::select(-tf_chan_id, -mean_power, -mean_rsfc, -source_target_network) %>%
      dplyr::distinct(.keep_all = TRUE)

    # test to see if have an empty dataframe. this will happen for components not measured at the current channel
    if(dim(cur_erp_data)[1] == 0) {
      print(sprintf("No data for %s at %s. Continuing to next channel.\n", cur_comp, cur_chan))
      next
    }

    cur_component <- unique(cur_erp_data$erp_component)
    line_color <- ifelse(cur_component == "FN400", "limegreen",
                         ifelse(cur_component == "LPC", "darkorchid3", "black"))

    # --- correlate w/ LPC (rem - fam)
    compute_cor_and_plot(cur_erp_data, "rem_minus_fam_area", "rec_dualprocess", "subj_id")
    p <- pp +
      ggplot2::geom_smooth(method='lm', color = line_color) +
      ggplot2::ggtitle(sprintf("Correlation between recollection\nand %s at %s", cur_component, cur_chan))
    print(p)
    ggplot2::ggsave(filename = file.path(plots_dir, sprintf("rec_rem-minus-fam_%s-at-%s.pdf", cur_component, cur_chan)), width = 6, height = 4)

    compute_cor_and_plot(cur_erp_data, "rem_minus_fam_area", "fam_dualprocess", "subj_id")
    p <- pp +
      ggplot2::geom_smooth(method='lm', color = line_color) +
      ggplot2::ggtitle(sprintf("Correlation between familiarity and %s at %s", cur_component, cur_chan))
    print(p)
    ggplot2::ggsave(filename = file.path(plots_dir, sprintf("fam_rem-minus-fam_%s-at-%s.pdf", cur_component, cur_chan)), width = 6, height = 4)
    
    compute_cor_and_plot(cur_erp_data, "rem_minus_fam_area", "source_exact_hitrate", "subj_id")
    p <- pp +
      ggplot2::geom_smooth(method='lm', color = line_color) +
      ggplot2::ggtitle(sprintf("Correlation between precise source memory\nand %s at %s", cur_component, cur_chan)) +
      ggplot2::ylab("precise source memory rate")
    print(p)
    ggplot2::ggsave(filename = file.path(plots_dir, sprintf("source-exact_rem-minus-fam_%s-at-%s.pdf", cur_component, cur_chan)), width = 6, height = 4)
    
    compute_cor_and_plot(cur_erp_data, "rem_minus_fam_area", "source_questiontype_hitrate", "subj_id")
    p <- pp +
      ggplot2::geom_smooth(method='lm', color = line_color) +
      ggplot2::ggtitle(sprintf("Correlation between coarse source memory\nand %s at %s", cur_component, cur_chan)) +
      ggplot2::ylab("coarse source memory rate")
    print(p)
    ggplot2::ggsave(filename = file.path(plots_dir, sprintf("source-liberal_rem-minus-fam_%s-at-%s.pdf", cur_component, cur_chan)), width = 6, height = 4)

    # --- also correlate w/ FN400 (fam - cr)
    compute_cor_and_plot(cur_erp_data, "fam_minus_cr_area", "rec_dualprocess", "subj_id")
    p <- pp +
      ggplot2::geom_smooth(method='lm', color = line_color) +
      ggplot2::ggtitle(sprintf("Correlation between familiarity and %s at %s", cur_component, cur_chan))
    print(p)
    ggplot2::ggsave(filename = file.path(plots_dir, sprintf("rec_fam-minus-cr_%s-at-%s.pdf", cur_component, cur_chan)), width = 6, height = 4)
    
    compute_cor_and_plot(cur_erp_data, "fam_minus_cr_area", "fam_dualprocess", "subj_id")
    p <- pp +
      ggplot2::geom_smooth(method='lm', color = line_color) +
      ggplot2::ggtitle(sprintf("Correlation between familiarity and %s at %s", cur_component, cur_chan))
    print(p)
    ggplot2::ggsave(filename = file.path(plots_dir, sprintf("fam_fam-minus-cr_%s-at-%s.pdf", cur_component, cur_chan)), width = 6, height = 4)

    compute_cor_and_plot(cur_erp_data, "fam_minus_cr_area", "source_exact_hitrate", "subj_id")
    p <- pp +
      ggplot2::geom_smooth(method='lm', color = line_color) +
      ggplot2::ggtitle(sprintf("Correlation between precise source memory\nand %s at %s", cur_component, cur_chan)) +
      ggplot2::ylab("precise source memory rate")
    print(p)
    ggplot2::ggsave(filename = file.path(plots_dir, sprintf("source-exact_fam-minus-cr_%s-at-%s.pdf", cur_component, cur_chan)), width = 6, height = 4)

    compute_cor_and_plot(cur_erp_data, "fam_minus_cr_area", "source_questiontype_hitrate", "subj_id")
    p <- pp +
      ggplot2::geom_smooth(method='lm', color = line_color) +
      ggplot2::ggtitle(sprintf("Correlation between coarse source memory\nand %s at %s", cur_component, cur_chan)) +
      ggplot2::ylab("coarse source memory rate")
    print(p)
    ggplot2::ggsave(filename = file.path(plots_dir, sprintf("source-liberal_fam-minus-cr_%s-at-%s.pdf", cur_component, cur_chan)), width = 6, height = 4)
  }
}

#' ## Correlate rsFC with behavior
# if want to run correlations with all subjects, set EXCLUDE_SUBJ_FLAG = 0 in this script and also in `analyze-behavior.R`
rsfc_networks <- c("AT_AT", "PM_PM")

for (inet in 1:length(rsfc_networks)) {
  cur_network <- rsfc_networks[inet]

  cur_data <- all_data %>%
    dplyr::filter(source_target_network == cur_network) %>%
    dplyr::select(-tf_chan_id, -mean_power, -electrode, -erp_component, -rem_minus_fam_area, -rem_minus_cr_area, -fam_minus_cr_area) %>%
    dplyr::distinct(.keep_all = TRUE)

  compute_cor_and_plot(cur_data, "mean_rsfc", "rec_dualprocess", "subj_id")
  p <- pp +
    ggplot2::geom_smooth(method='lm') +
    ggplot2::ggtitle(sprintf("Correlation between recollection and %s", cur_network))
  print(p)
  ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_rec_behav.pdf", cur_network)), width = 6, height = 4)

  compute_cor_and_plot(cur_data, "mean_rsfc", "fam_dualprocess", "subj_id")
  p <- pp +
    ggplot2::geom_smooth(method='lm') +
    ggplot2::ggtitle(sprintf("Correlation between familiarity and %s", cur_network))
  print(p)
  ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_fam_behav.pdf", cur_network)), width = 6, height = 4)

  # repeat with Destrieux ROIs
  cur_data_dx <- all_data_dx_rois %>%
    dplyr::filter(source_target_network == cur_network) %>%
    dplyr::select(-tf_chan_id, -mean_power, -electrode, -erp_component, -rem_minus_fam_area, -rem_minus_cr_area, -fam_minus_cr_area) %>%
    dplyr::distinct(.keep_all = TRUE)

  compute_cor_and_plot(cur_data_dx, "mean_rsfc", "rec_dualprocess", "subj_id")
  p <- pp +
    ggplot2::geom_smooth(method='lm') +
    ggplot2::ggtitle(sprintf("Correlation between recollection and %s (Destrieux)", cur_network))
  print(p)
  ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_dx_rec_behav.pdf", cur_network)), width = 6, height = 4)

  compute_cor_and_plot(cur_data_dx, "mean_rsfc", "fam_dualprocess", "subj_id")
  p <- pp +
    ggplot2::geom_smooth(method='lm') +
    ggplot2::ggtitle(sprintf("Correlation between familiarity and %s (Destrieux)", cur_network))
  print(p)
  ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_dx_fam_behav.pdf", cur_network)), width = 6, height = 4)

  compute_cor_and_plot(cur_data_dx, "mean_rsfc", "correct", "subj_id")
  p <- pp +
    ggplot2::geom_smooth(method='lm') +
    ggplot2::ggtitle(sprintf("Correlation between source (exact) and %s (Destrieux)", cur_network))
  print(p)
  ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_dx_source-exact_behav.pdf", cur_network)), width = 6, height = 4)

  compute_cor_and_plot(cur_data_dx, "mean_rsfc", "correct_questiontype", "subj_id")
  p <- pp +
    ggplot2::geom_smooth(method='lm') +
    ggplot2::ggtitle(sprintf("Correlation between source (coarse) and %s (Destrieux)", cur_network))
  print(p)
  ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_dx_source-liberal_behav.pdf", cur_network)), width = 6, height = 4)
}

#' ## Correlate ERPs with rsFC
rsfc_networks <- c("AT_AT", "PM_PM")
erp_chans <- unique(all_data$electrode)
erp_components <- unique(all_data$erp_component)

for (icomp in 1:length(erp_components)) {
  for (ichan in 1:length(erp_chans)) {

    for (inet in 1:length(rsfc_networks)) {
      cur_chan <- erp_chans[ichan]
      cur_network <- rsfc_networks[inet]
      cur_comp <- erp_components[icomp]

      cur_data <- all_data %>%
        dplyr::filter(electrode == cur_chan) %>%
        dplyr::filter(source_target_network == cur_network) %>%
        dplyr::filter(erp_component == cur_comp) %>%
        dplyr::select(-tf_chan_id, -mean_power) %>%
        dplyr::distinct(.keep_all = TRUE)

      # test to see if have an empty dataframe. this will happen for components not measured at the current channel
      if(dim(cur_data)[1] == 0) {
        print(sprintf("No data for %s at %s. Continuing to next channel.\n", cur_comp, cur_chan))
        next
      }

      cur_component <- unique(cur_data$erp_component)

      line_color <- ifelse(cur_component == "FN400", "limegreen",
                           ifelse(cur_component == "LPC", "darkorchid3", "black"))

      compute_cor_and_plot(cur_data, "rem_minus_fam_area", "mean_rsfc", "subj_id")
      p <- pp +
        ggplot2::geom_smooth(method='lm', color = line_color) +
        ggplot2::ggtitle(sprintf("Connectivity between %s regions %s at %s", cur_network, cur_component, cur_chan))
      print(p)
      ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_rem-minus-fam_%s-at-%s.pdf", cur_network, cur_component, cur_chan)), width = 6, height = 4)

      compute_cor_and_plot(cur_data, "fam_minus_cr_area", "mean_rsfc", "subj_id")
      p <- pp +
        ggplot2::geom_smooth(method='lm', color = line_color) +
        ggplot2::ggtitle(sprintf("Connectivity between %s regions %s at %s", cur_network, cur_component, cur_chan))
      print(p)
      ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_fam-minus-cr_%s-at-%s.pdf", cur_network, cur_component, cur_chan)), width = 6, height = 4)

      # repeat for destrieux rois
      cur_data_dx <- all_data_dx_rois %>%
        dplyr::filter(electrode == cur_chan) %>%
        dplyr::filter(source_target_network == cur_network) %>%
        dplyr::filter(erp_component == cur_comp) %>%
        dplyr::select(-tf_chan_id, -mean_power) %>%
        dplyr::distinct(.keep_all = TRUE)

      cur_component_dx <- unique(cur_data_dx$erp_component)

      line_color_dx <- ifelse(cur_component_dx == "FN400", "limegreen",
                              ifelse(cur_component_dx == "LPC", "darkorchid3", "black"))

      compute_cor_and_plot(cur_data_dx, "rem_minus_fam_area", "mean_rsfc", "subj_id")
      p <- pp +
        ggplot2::geom_smooth(method='lm', color = line_color_dx) +
        ggplot2::ggtitle(sprintf("Connectivity between %s (Destrieux) regions %s at %s", cur_network, cur_component, cur_chan))
      print(p)
      ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_dx_rem-minus-fam_%s-at-%s.pdf", cur_network, cur_component_dx, cur_chan)), width = 6, height = 4)

      compute_cor_and_plot(cur_data_dx, "fam_minus_cr_area", "mean_rsfc", "subj_id")
      p <- pp +
        ggplot2::geom_smooth(method='lm', color = line_color_dx) +
        ggplot2::ggtitle(sprintf("Connectivity between %s (Destrieux) regions %s at %s", cur_network, cur_component, cur_chan))
      print(p)
      ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_dx_fam-minus-cr_%s-at-%s.pdf", cur_network, cur_component_dx, cur_chan)), width = 6, height = 4)
    }
  }
}

#' ### Figures for paper
#' #### ERPs with behavior
fn400_frontal_left_fam <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "fam_dualprocess") %>%
  dplyr::filter(electrode == "frontal_left") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "value", "subj_id")

fn400_frontal_left_fam_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nFamiliarity and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_left)") +
  ggplot2::ylab("Familiarity") +
  cowplot_theme
print(fn400_frontal_left_fam_plot)

fn400_frontal_right_fam <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "fam_dualprocess") %>%
  dplyr::filter(electrode == "frontal_right") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "value", "subj_id")

fn400_frontal_right_fam_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nFamiliarity and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_right)") +
  ggplot2::ylab("Familiarity") +
  cowplot_theme
print(fn400_frontal_right_fam_plot)

fn400_frontal_left_rec <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "rec_dualprocess") %>%
  dplyr::filter(electrode == "frontal_left") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "value", "subj_id")

fn400_frontal_left_rec_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nRecollection and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_left)") +
  ggplot2::ylab("Recollection") +
  cowplot_theme
print(fn400_frontal_left_rec_plot)

fn400_frontal_right_rec <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "rec_dualprocess") %>%
  dplyr::filter(electrode == "frontal_right") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "value", "subj_id")

fn400_frontal_right_rec_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nRecollection and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_right)") +
  ggplot2::ylab("Recollection") +
  cowplot_theme
print(fn400_frontal_right_rec_plot)

fn400_rec_fam_plots <- cowplot::plot_grid(fn400_frontal_left_fam_plot, fn400_frontal_right_fam_plot,
                                       fn400_frontal_left_rec_plot, fn400_frontal_right_rec_plot,
                                       labels = c("A", "B", "C", "D"), ncol = 2)
cowplot::save_plot(file.path(dissertation_figures_dir, "fn400_rec_fam_plots.png"), fn400_rec_fam_plots,
                   ncol = 2, # we're saving a grid plot of 2 columns
                   nrow = 2, # and 2 rows
                   # each individual subplot should have an aspect ratio of 1.3
                   base_aspect_ratio = 1.3
)

# --- now do with LPC
lpc_parietal_left_fam <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "fam_dualprocess") %>%
  dplyr::filter(electrode == "parietal_left") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "value", "subj_id")

lpc_parietal_left_fam_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nFamiliarity and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_left)") +
  ggplot2::ylab("Familiarity") +
  cowplot_theme
print(lpc_parietal_left_fam_plot)

lpc_parietal_right_fam <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "fam_dualprocess") %>%
  dplyr::filter(electrode == "parietal_right") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "value", "subj_id")

lpc_parietal_right_fam_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nFamiliarity and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_right)") +
  ggplot2::ylab("Familiarity") +
  cowplot_theme
print(lpc_parietal_right_fam_plot)

lpc_parietal_left_rec <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "rec_dualprocess") %>%
  dplyr::filter(electrode == "parietal_left") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "value", "subj_id")

lpc_parietal_left_rec_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nRecollection and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_left)") +
  ggplot2::ylab("Recollection") +
  cowplot_theme
print(lpc_parietal_left_rec_plot)

lpc_parietal_right_rec <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "rec_dualprocess") %>%
  dplyr::filter(electrode == "parietal_right") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "value", "subj_id")

lpc_parietal_right_rec_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nRecollection and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_right)") +
  ggplot2::ylab("Recollection") +
  cowplot_theme
print(lpc_parietal_right_rec_plot)

lpc_rec_fam_plots <- cowplot::plot_grid(lpc_parietal_left_fam_plot, lpc_parietal_right_fam_plot,
                                          lpc_parietal_left_rec_plot, lpc_parietal_right_rec_plot,
                                          labels = c("A", "B", "C", "D"), ncol = 2)
cowplot::save_plot(file.path(dissertation_figures_dir, "lpc_rec_fam_plots.png"), lpc_rec_fam_plots,
                   ncol = 2, # we're saving a grid plot of 2 columns
                   nrow = 2, # and 2 rows
                   # each individual subplot should have an aspect ratio of 1.3
                   base_aspect_ratio = 1.3
)

# --- FN400 and source memory
fn400_frontal_left_source_precise <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_exact_hitrate") %>%
  dplyr::filter(electrode == "frontal_left") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "value", "subj_id")

fn400_frontal_left_source_precise_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nSource (precise) and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_left)") +
  ggplot2::ylab("Source (precise)") +
  cowplot_theme
print(fn400_frontal_left_source_precise_plot)

fn400_frontal_right_source_precise <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_exact_hitrate") %>%
  dplyr::filter(electrode == "frontal_right") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "value", "subj_id")

fn400_frontal_right_source_precise_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nSource (precise) and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_right)") +
  ggplot2::ylab("Source (precise)") +
  cowplot_theme
print(fn400_frontal_right_source_precise_plot)

fn400_frontal_left_source_coarse <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_questiontype_hitrate") %>%
  dplyr::filter(electrode == "frontal_left") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "value", "subj_id")

fn400_frontal_left_source_coarse_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nSource (coarse) and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_left)") +
  ggplot2::ylab("Source (coarse)") +
  cowplot_theme
print(fn400_frontal_left_source_coarse_plot)

fn400_frontal_right_source_coarse <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_questiontype_hitrate") %>%
  dplyr::filter(electrode == "frontal_right") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "value", "subj_id")

fn400_frontal_right_source_coarse_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nSource (coarse) and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_right)") +
  ggplot2::ylab("Source (coarse)") +
  cowplot_theme
print(fn400_frontal_right_source_coarse_plot)

fn400_source_plots <- cowplot::plot_grid(fn400_frontal_left_source_precise_plot, fn400_frontal_right_source_precise_plot,
                                          fn400_frontal_left_source_coarse_plot, fn400_frontal_right_source_coarse_plot,
                                          labels = c("A", "B", "C", "D"), ncol = 2)
cowplot::save_plot(file.path(dissertation_figures_dir, "fn400_source_plots.png"), fn400_source_plots,
                   ncol = 2, # we're saving a grid plot of 2 columns
                   nrow = 2, # and 2 rows
                   # each individual subplot should have an aspect ratio of 1.3
                   base_aspect_ratio = 1.3
)

# --- LPC and source memory
lpc_parietal_left_source_precise <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_exact_hitrate") %>%
  dplyr::filter(electrode == "parietal_left") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "value", "subj_id")

lpc_parietal_left_source_precise_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nSource (precise) and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_left)") +
  ggplot2::ylab("Source (precise)") +
  cowplot_theme
print(lpc_parietal_left_source_precise_plot)

lpc_parietal_right_source_precise <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_exact_hitrate") %>%
  dplyr::filter(electrode == "parietal_right") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "value", "subj_id")

lpc_parietal_right_source_precise_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nSource (precise) and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_right)") +
  ggplot2::ylab("Source (precise)") +
  cowplot_theme
print(lpc_parietal_right_source_precise_plot)

lpc_parietal_left_source_coarse <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_questiontype_hitrate") %>%
  dplyr::filter(electrode == "parietal_left") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "value", "subj_id")

lpc_parietal_left_source_coarse_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nSource (coarse) and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_left)") +
  ggplot2::ylab("Source (coarse)") +
  cowplot_theme
print(lpc_parietal_left_source_coarse_plot)

lpc_parietal_right_source_coarse <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_questiontype_hitrate") %>%
  dplyr::filter(electrode == "parietal_right") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power, -source_target_network, -mean_rsfc) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "value", "subj_id")

lpc_parietal_right_source_coarse_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nSource (coarse) and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_right)") +
  ggplot2::ylab("Source (coarse)") +
  cowplot_theme
print(lpc_parietal_right_source_coarse_plot)

lpc_source_plots <- cowplot::plot_grid(lpc_parietal_left_source_precise_plot, lpc_parietal_right_source_precise_plot,
                                         lpc_parietal_left_source_coarse_plot, lpc_parietal_right_source_coarse_plot,
                                         labels = c("A", "B", "C", "D"), ncol = 2)
cowplot::save_plot(file.path(dissertation_figures_dir, "lpc_source_plots.png"), lpc_source_plots,
                   ncol = 2, # we're saving a grid plot of 2 columns
                   nrow = 2, # and 2 rows
                   # each individual subplot should have an aspect ratio of 1.3
                   base_aspect_ratio = 1.3
)

#' #### ERPs with rsFC
fn400_frontal_left_at <- all_data_dx_rois %>%
  dplyr::filter(electrode == "frontal_left") %>%
  dplyr::filter(source_target_network == "AT_AT") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "mean_rsfc", "subj_id")

fn400_frontal_left_at_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nAT and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_left)") +
  ggplot2::ylab("mean rsFC") +
  cowplot_theme
print(fn400_frontal_left_at_plot)

fn400_frontal_right_at <- all_data_dx_rois %>%
  dplyr::filter(electrode == "frontal_right") %>%
  dplyr::filter(source_target_network == "AT_AT") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "mean_rsfc", "subj_id")

fn400_frontal_right_at_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nAT and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_right)") +
  ggplot2::ylab("mean rsFC") +
  cowplot_theme
print(fn400_frontal_right_at_plot)

fn400_frontal_left_pm <- all_data_dx_rois %>%
  dplyr::filter(electrode == "frontal_left") %>%
  dplyr::filter(source_target_network == "PM_PM") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "mean_rsfc", "subj_id")

fn400_frontal_left_pm_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nPM and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_left)") +
  ggplot2::ylab("mean rsFC") +
  cowplot_theme
print(fn400_frontal_left_pm_plot)

fn400_frontal_right_pm <- all_data_dx_rois %>%
  dplyr::filter(electrode == "frontal_right") %>%
  dplyr::filter(source_target_network == "PM_PM") %>%
  dplyr::filter(erp_component == "FN400") %>%
  dplyr::select(-tf_chan_id, -mean_power) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "fam_minus_cr_area", "mean_rsfc", "subj_id")

fn400_frontal_right_pm_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "limegreen") +
  ggplot2::ggtitle("Correlation between\nPM and FN400") +
  ggplot2::xlab("FN400 magnitude\n(frontal_right)") +
  ggplot2::ylab("mean rsFC") +
  cowplot_theme
print(fn400_frontal_right_pm_plot)

lpc_parietal_left_at <- all_data_dx_rois %>%
  dplyr::filter(electrode == "parietal_left") %>%
  dplyr::filter(source_target_network == "AT_AT") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "mean_rsfc", "subj_id")

lpc_parietal_left_at_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nAT and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_left)") +
  ggplot2::ylab("mean rsFC") +
  cowplot_theme
print(lpc_parietal_left_at_plot)

lpc_parietal_right_at <- all_data_dx_rois %>%
  dplyr::filter(electrode == "parietal_right") %>%
  dplyr::filter(source_target_network == "AT_AT") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "mean_rsfc", "subj_id")

lpc_parietal_right_at_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nAT and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_right)") +
  ggplot2::ylab("mean rsFC") +
  cowplot_theme
print(lpc_parietal_right_at_plot)

lpc_parietal_left_pm <- all_data_dx_rois %>%
  dplyr::filter(electrode == "parietal_left") %>%
  dplyr::filter(source_target_network == "PM_PM") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "mean_rsfc", "subj_id")

lpc_parietal_left_pm_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nPM and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_left)") +
  ggplot2::ylab("mean rsFC") +
  cowplot_theme
print(lpc_parietal_left_pm_plot)

lpc_parietal_right_pm <- all_data_dx_rois %>%
  dplyr::filter(electrode == "parietal_right") %>%
  dplyr::filter(source_target_network == "PM_PM") %>%
  dplyr::filter(erp_component == "LPC") %>%
  dplyr::select(-tf_chan_id, -mean_power) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "rem_minus_fam_area", "mean_rsfc", "subj_id")

lpc_parietal_right_pm_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "darkorchid3") +
  ggplot2::ggtitle("Correlation between\nPM and LPC") +
  ggplot2::xlab("LPC magnitude\n(parietal_right)") +
  ggplot2::ylab("mean rsFC") +
  cowplot_theme
print(lpc_parietal_right_pm_plot)

# now put all the plots together
fn400_rsfc_plots <- cowplot::plot_grid(fn400_frontal_left_at_plot, fn400_frontal_right_at_plot,
                   fn400_frontal_left_pm_plot, fn400_frontal_right_pm_plot,
                   labels = c("A", "B", "C", "D"), ncol = 2)
cowplot::save_plot(file.path(dissertation_figures_dir, "fn400_rsfc_plots.png"), fn400_rsfc_plots,
          ncol = 2, # we're saving a grid plot of 2 columns
          nrow = 2, # and 2 rows
          # each individual subplot should have an aspect ratio of 1.3
          base_aspect_ratio = 1.3
)

lpc_rsfc_plots <- cowplot::plot_grid(lpc_parietal_left_at_plot, lpc_parietal_right_at_plot,
                                       lpc_parietal_left_pm_plot, lpc_parietal_right_pm_plot,
                                       labels = c("A", "B", "C", "D"), ncol = 2)
cowplot::save_plot(file.path(dissertation_figures_dir, "lpc_rsfc_plots.png"), lpc_rsfc_plots,
                   ncol = 2, # we're saving a grid plot of 2 columns
                   nrow = 2, # and 2 rows
                   # each individual subplot should have an aspect ratio of 1.3
                   base_aspect_ratio = 1.3
)

#' ### rsFC w/ behavior 
# --- PM network (color as #feb24c)
rec_pm <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "rec_dualprocess") %>%
  dplyr::filter(source_target_network == "PM_PM") %>%
  dplyr::select(-tf_chan_id, -mean_power, -erp_component, -electrode, 
                -contains("minus")) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "mean_rsfc", "value", "subj_id")

rec_pm_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "#feb24c") +
  ggplot2::ggtitle("Correlation between\nRecollection and PM connectivity") +
  ggplot2::xlab("Mean PM Network Connectivity") +
  ggplot2::ylab("Recollection") +
  cowplot_theme
print(rec_pm_plot)

fam_pm <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "fam_dualprocess") %>%
  dplyr::filter(source_target_network == "PM_PM") %>%
  dplyr::select(-tf_chan_id, -mean_power, -erp_component, -electrode, 
                -contains("minus")) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "mean_rsfc", "value", "subj_id")

fam_pm_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "#feb24c") +
  ggplot2::ggtitle("Correlation between\nFamiliarity and PM connectivity") +
  ggplot2::xlab("Mean PM Network Connectivity") +
  ggplot2::ylab("Familiarity") +
  cowplot_theme
print(fam_pm_plot)

source_precise_pm <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_exact_hitrate") %>%
  dplyr::filter(source_target_network == "PM_PM") %>%
  dplyr::select(-tf_chan_id, -mean_power, -erp_component, -electrode, 
                -contains("minus")) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "mean_rsfc", "value", "subj_id")

source_precise_pm_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "#feb24c") +
  ggplot2::ggtitle("Correlation between\nSource (precise) and PM connectivity") +
  ggplot2::xlab("Mean PM Network Connectivity") +
  ggplot2::ylab("Source (precise)") +
  cowplot_theme
print(source_precise_pm_plot)

source_coarse_pm <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_questiontype_hitrate") %>%
  dplyr::filter(source_target_network == "PM_PM") %>%
  dplyr::select(-tf_chan_id, -mean_power, -erp_component, -electrode, 
                -contains("minus")) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "mean_rsfc", "value", "subj_id")

source_coarse_pm_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "#feb24c") +
  ggplot2::ggtitle("Correlation between\nSource (coarse) and PM connectivity") +
  ggplot2::xlab("Mean PM Network Connectivity") +
  ggplot2::ylab("Source (coarse)") +
  cowplot_theme
print(source_coarse_pm_plot)

behav_pm_rsfc_plots <- cowplot::plot_grid(rec_pm_plot, fam_pm_plot,
                                     source_precise_pm_plot, source_coarse_pm_plot,
                                     labels = c("A", "B", "C", "D"), ncol = 2)
cowplot::save_plot(file.path(dissertation_figures_dir, "behav_pm_rsfc_plots.png"), behav_pm_rsfc_plots,
                   ncol = 2, # we're saving a grid plot of 2 columns
                   nrow = 2, # and 2 rows
                   # each individual subplot should have an aspect ratio of 1.3
                   base_aspect_ratio = 1.3
)

# --- AT network (color as #3182bd)
rec_at <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "rec_dualprocess") %>%
  dplyr::filter(source_target_network == "AT_AT") %>%
  dplyr::select(-tf_chan_id, -mean_power, -erp_component, -electrode, 
                -contains("minus")) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "mean_rsfc", "value", "subj_id")

rec_at_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "#3182bd") +
  ggplot2::ggtitle("Correlation between\nRecollection and AT connectivity") +
  ggplot2::xlab("Mean AT Network Connectivity") +
  ggplot2::ylab("Recollection") +
  cowplot_theme
print(rec_at_plot)

fam_at <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "fam_dualprocess") %>%
  dplyr::filter(source_target_network == "AT_AT") %>%
  dplyr::select(-tf_chan_id, -mean_power, -erp_component, -electrode, 
                -contains("minus")) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "mean_rsfc", "value", "subj_id")

fam_at_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "#3182bd") +
  ggplot2::ggtitle("Correlation between\nFamiliarity and AT connectivity") +
  ggplot2::xlab("Mean AT Network Connectivity") +
  ggplot2::ylab("Familiarity") +
  cowplot_theme
print(fam_at_plot)

source_precise_at <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_exact_hitrate") %>%
  dplyr::filter(source_target_network == "AT_AT") %>%
  dplyr::select(-tf_chan_id, -mean_power, -erp_component, -electrode, 
                -contains("minus")) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "mean_rsfc", "value", "subj_id")

source_precise_at_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "#3182bd") +
  ggplot2::ggtitle("Correlation between\nSource (precise) and AT connectivity") +
  ggplot2::xlab("Mean AT Network Connectivity") +
  ggplot2::ylab("Source (precise)") +
  cowplot_theme
print(source_precise_at_plot)

source_coarse_at <- all_data_dx_rois_mem_grouped %>%
  dplyr::filter(memory_type == "source_questiontype_hitrate") %>%
  dplyr::filter(source_target_network == "AT_AT") %>%
  dplyr::select(-tf_chan_id, -mean_power, -erp_component, -electrode, 
                -contains("minus")) %>%
  dplyr::distinct(.keep_all = TRUE) %>%
  compute_cor_and_plot_no_annotate(., "mean_rsfc", "value", "subj_id")

source_coarse_at_plot <- pp +
  ggplot2::geom_smooth(method='lm', color = "#3182bd") +
  ggplot2::ggtitle("Correlation between\nSource (coarse) and AT connectivity") +
  ggplot2::xlab("Mean AT Network Connectivity") +
  ggplot2::ylab("Source (coarse)") +
  cowplot_theme
print(source_coarse_at_plot)

behav_at_rsfc_plots <- cowplot::plot_grid(rec_at_plot, fam_at_plot,
                                          source_precise_at_plot, source_coarse_at_plot,
                                          labels = c("A", "B", "C", "D"), ncol = 2)
cowplot::save_plot(file.path(dissertation_figures_dir, "behav_at_rsfc_plots.png"), behav_at_rsfc_plots,
                   ncol = 2, # we're saving a grid plot of 2 columns
                   nrow = 2, # and 2 rows
                   # each individual subplot should have an aspect ratio of 1.3
                   base_aspect_ratio = 1.3
)

#' ## Correlate rsFC nodes with ERPs
rsfc_by_node_subj_means <- all_rsfc %>%
  dplyr::group_by(subj_id, source_target_roi) %>%
  # this essentially should collapse across hemispheres - IS THIS THE CORRECT WAY TO DO THIS?
  dplyr::summarise(mean_rsfc = mean(rsfc_value, na.rm = TRUE)) %>%
  dplyr::select(subj_id, mean_rsfc, source_target_roi) %>%
  tidyr::spread(.,value = mean_rsfc, key = source_target_roi) %>%
  dplyr::group_by(subj_id) %>%
  # since ROI rsfc values are nans, remove these when taking the mean
  # seems like there should be a way to specify these means programatically, but doing manually for now to be safe
  dplyr::summarise(amygdala_AT_mean_rsfc = mean(Amygdala_aPaHC, Amygdala_FOrb, Amygdala_pTFusC, Amygdala_pITG, na.rm = TRUE),
                   PRC_AT_mean_rsfc = mean(aPaHC_Amygdala, aPaHC_FOrb, aPaHC_pTFusC, aPaHC_pITG, na.rm = TRUE),
                   lOFC_AT_mean_rsfc = mean(FOrb_Amygdala, FOrb_aPaHC, FOrb_pTFusC, FOrb_pITG, na.rm = TRUE),
                   fusif_AT_mean_rsfc = mean(pTFusC_Amygdala, pTFusC_aPaHC, pTFusC_FOrb, pTFusC_pITG, na.rm = TRUE),
                   inftempc_AT_mean_rsfc = mean(pITG_Amygdala, pITG_aPaHC, pITG_FOrb, pITG_pTFusC, na.rm = TRUE),
                   AG_PM_mean_rsfc = mean(AG_Precuneous, AG_PC, AG_pPaHC, na.rm = TRUE),
                   PCU_PM_mean_rsfc = mean(Precuneous_AG, Precuneous_PC, Precuneous_pPaHC, na.rm = TRUE),
                   postcing_PM_mean_rsfc = mean(PC_AG, PC_Precuneous, PC_pPaHC, na.rm = TRUE),
                   PHC_PM_mean_rsfc = mean(pPaHC_AG, pPaHC_Precuneous, pPaHC_PC, na.rm = TRUE),
                   dx_amygdala_AT_mean_rsfc = mean(Amygdala_dx_fusiform, Amygdala_dx_infTempG, Amygdala_dx_infTempS, Amygdala_dx_lOFC, Amygdala_aPaHC, na.rm = TRUE),
                   dx_PRC_AT_mean_rsfc = mean(aPaHC_dx_fusiform, aPaHC_dx_infTempG, aPaHC_dx_infTempS, aPaHC_dx_lOFC, aPaHC_Amygdala, na.rm = TRUE),
                   dx_fusiform_AT_mean_rsfc = mean(dx_fusiform_Amygdala, dx_fusiform_dx_infTempG, dx_fusiform_dx_infTempS, dx_fusiform_dx_lOFC, dx_fusiform_aPaHC, na.rm = TRUE),
                   dx_infTempG_AT_mean_rsfc = mean(dx_infTempG_Amygdala, dx_infTempG_dx_fusiform, dx_infTempG_dx_infTempS, dx_infTempG_dx_lOFC, dx_infTempG_aPaHC, na.rm = TRUE),
                   dx_infTempS_AT_mean_rsfc = mean(dx_infTempS_Amygdala, dx_infTempS_dx_fusiform, dx_infTempG_dx_infTempS, dx_infTempS_dx_lOFC, dx_infTempS_aPaHC, na.rm = TRUE),
                   dx_lOFC_AT_mean_rsfc = mean(dx_lOFC_Amygdala, dx_lOFC_dx_fusiform, dx_lOFC_dx_infTempS, dx_lOFC_dx_infTempG, dx_lOFC_aPaHC, na.rm = TRUE),
                   dx_ANG_PM_mean_rsfc = mean(dx_ANG_dx_PCU, dx_ANG_dx_MTG, dx_ANG_dx_postdCing, dx_ANG_dx_postvCing, dx_ANG_dx_temporalPole, dx_ANG_pPaHC, na.rm = TRUE),
                   dx_MTG_PM_mean_rsfc = mean(dx_MTG_dx_PCU, dx_MTG_dx_ANG, dx_MTG_dx_postdCing, dx_MTG_dx_postvCing, dx_MTG_dx_temporalPole, dx_MTG_pPaHC, na.rm = TRUE),
                   dx_PCU_PM_mean_rsfc = mean(dx_PCU_dx_MTG, dx_PCU_dx_ANG, dx_PCU_dx_postdCing, dx_PCU_dx_postvCing, dx_PCU_dx_temporalPole, dx_PCU_pPaHC, na.rm = TRUE),
                   dx_postdCing_PM_mean_rsfc = mean(dx_postdCing_dx_MTG, dx_postdCing_dx_ANG, dx_postdCing_dx_PCU, dx_postdCing_dx_postvCing, dx_postdCing_dx_temporalPole, dx_postdCing_pPaHC, na.rm = TRUE),
                   dx_postvCing_PM_mean_rsfc = mean(dx_postvCing_dx_MTG, dx_postvCing_dx_ANG, dx_postvCing_dx_PCU, dx_postvCing_dx_postdCing, dx_postvCing_dx_temporalPole, dx_postvCing_pPaHC, na.rm = TRUE),
                   dx_temporalPole_PM_mean_rsfc = mean(dx_temporalPole_dx_MTG, dx_temporalPole_dx_ANG, dx_temporalPole_dx_PCU, dx_temporalPole_dx_postdCing, dx_temporalPole_dx_postvCing, dx_temporalPole_pPaHC, na.rm = TRUE),
                   dx_PHC_PM_mean_rsfc = mean(pPaHC_dx_MTG, pPaHC_dx_ANG, pPaHC_dx_PCU, pPaHC_dx_postdCing, pPaHC_dx_postvCing, pPaHC_dx_temporalPole, na.rm = TRUE),
                   dx_HC_PM_mean_rsfc = mean(Hippocampus_dx_MTG, Hippocampus_dx_ANG, Hippocampus_dx_PCU, Hippocampus_dx_postdCing, Hippocampus_dx_postvCing, Hippocampus_dx_temporalPole, Hippocampus_pPaHC, na.rm = TRUE))

all_data_by_node <- behav_all_counts %>%
  dplyr::full_join(., rsfc_by_node_subj_means, by = "subj_id") %>%
  dplyr::full_join(., erp_vals, by = "subj_id") %>%
  dplyr::mutate(subj_num = sub("s", "", subj_id)) %>%
  dplyr::filter(!subj_num %in% exclude_subjects)

rsfc_cols_of_interest <- c("amygdala_AT_mean_rsfc", "PRC_AT_mean_rsfc", "lOFC_AT_mean_rsfc", "fusif_AT_mean_rsfc", "inftempc_AT_mean_rsfc",
                           "AG_PM_mean_rsfc", "PCU_PM_mean_rsfc", "postcing_PM_mean_rsfc", "PHC_PM_mean_rsfc",
                           "dx_amygdala_AT_mean_rsfc", "dx_PRC_AT_mean_rsfc", "dx_fusiform_AT_mean_rsfc", "dx_infTempG_AT_mean_rsfc", "dx_infTempS_AT_mean_rsfc", "dx_lOFC_AT_mean_rsfc",
                           "dx_ANG_PM_mean_rsfc", "dx_MTG_PM_mean_rsfc", "dx_PCU_PM_mean_rsfc", "dx_postdCing_PM_mean_rsfc", "dx_postvCing_PM_mean_rsfc", "dx_temporalPole_PM_mean_rsfc", "dx_PHC_PM_mean_rsfc",
                           "dx_HC_PM_mean_rsfc")

erp_chans <- unique(all_data_by_node$electrode)
erp_components <- unique(all_data_by_node$erp_component)

for (icomp in 1:length(erp_components)) {
  for (ichan in 1:length(erp_chans)) {
    cur_chan <- erp_chans[ichan]
    cur_comp <- erp_components[icomp]

    cur_erp_data <- all_data_by_node %>%
      dplyr::filter(electrode == cur_chan) %>%
      dplyr::filter(erp_component == cur_comp)

    # test to see if have an empty dataframe. this will happen for components not measured at the current channel
    if(dim(cur_erp_data)[1] == 0) {
      print(sprintf("No data for %s at %s. Continuing to next channel.\n", cur_comp, cur_chan))
      next
    }

    cur_component <- unique(cur_erp_data$erp_component)
    line_color <- ifelse(cur_component == "FN400", "limegreen",
                         ifelse(cur_component == "LPC", "darkorchid3", "black"))

    for(irsfc in 1:length(rsfc_cols_of_interest)) {
      cur_rsfc <- rsfc_cols_of_interest[irsfc]

      compute_cor_and_plot(cur_erp_data, "rem_minus_fam_area", cur_rsfc, "subj_id")
      p <- pp +
        ggplot2::geom_smooth(method='lm', color = line_color) +
        ggplot2::ggtitle(sprintf("%s as measured at electrode %s\nwith %s", cur_component, cur_chan, cur_rsfc))
      print(p)
      ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_rem-minus-fam_%s-at-%s.pdf", cur_rsfc, cur_component, cur_chan)), width = 6, height = 4)

      compute_cor_and_plot(cur_erp_data, "fam_minus_cr_area", cur_rsfc, "subj_id")
      p <- pp +
        ggplot2::geom_smooth(method='lm', color = line_color) +
        ggplot2::ggtitle(sprintf("%s as measured at electrode %s\nwith %s", cur_component, cur_chan, cur_rsfc))
      print(p)
      ggplot2::ggsave(filename = file.path(plots_dir, sprintf("%s_fam-minus-cr_%s-at-%s.pdf", cur_rsfc, cur_component, cur_chan)), width = 6, height = 4)
    }
  }
}

