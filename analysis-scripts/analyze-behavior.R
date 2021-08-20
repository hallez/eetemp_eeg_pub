#' ---
#' title: Analyze eetemp behavioral data
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
SAVE_FLAG <- 1
VERSION_FLAG <- 7
EXCLUDE_SUBJ_FLAG <- 1

#' ## Setup paths
project_dir <- ("../")
dropbox_dir <- paste0(halle::ensure_trailing_slash(config$directories$`dropbox-folder`))
analyzed_behavioral_dir <- paste0(project_dir,halle::ensure_trailing_slash(config$directories$`analyzed-behavioral-dir`))
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash("summary"))
figures_dir <- paste0(dropbox_dir, halle::ensure_trailing_slash("figures"))
dir.create(figures_dir)

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
  exclude_subjects <- c(202, 209, 215, 216, 220, 222, 225, 238, 239, 248, 249)
  rem_trialnums_cutoff <- 30
} else {
  exclude_subjects <- c(216, 222, 239) # these subjects are excluded irrespective of behavioral performance 
  rem_trialnums_cutoff <- 0
}

#' ## Make plot directory
dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)

#' # Load data
load(paste0(halle::ensure_trailing_slash(group_analyzed_dir),"tidied_data.Rdata"))

#' ## List subjects in `encdata`
unique(encdata$participant)

#' ### List subjects in `recdata`
unique(recdata$participant)

#' ### List subjects in `listsource`
unique(listsource$participant)

#' # Filter out non-responses for item recognition
# these occur when subjects make more than one response in a trial
recdata <- recdata %>%
  dplyr::filter(!is.na(item_recog_resp)) %>%
  dplyr::filter(!participant %in% exclude_subjects)

#' # Score 
# setup masks to use for scoring purposes
# could probably also use something like `dplyr::recode` and `ifelse`, but this is clearer
oldmask <- which(recdata$oldNew== "old")
newmask <- which(recdata$oldNew== "new")

Rresp <- which(recdata$item_recog_resp == "rem")
Fresp <- which(recdata$item_recog_resp == "fam")
Nresp <- which(recdata$item_recog_resp == "new")

bathtubList <- which(recdata$encQuest_factor == "bathtub")
convenienceList <- which(recdata$encQuest_factor == "convenience store")
fridgeList <- which(recdata$encQuest_factor == "fridge")
supermarketList <- which(recdata$encQuest_factor == "supermarket")
bathtubResp <- which(recdata$quest_source_resp == "bathtub")
convenienceResp <- which(recdata$quest_source_resp == "convenience store")
fridgeResp <- which(recdata$quest_source_resp == "fridge")
supermarketResp<- which(recdata$quest_source_resp == "supermarket")

fitList <- which(recdata$encQuest_factor == "bathtub" | recdata$encQuest_factor == "fridge")
findList <- which(recdata$encQuest_factor == "convenience store" | recdata$encQuest_factor == "supermarket")

bathtubHits <- intersect(bathtubList, bathtubResp)
convenienceHits <- intersect(convenienceList, convenienceResp)
fridgeHits <- intersect(fridgeList, fridgeResp)
supermarketHits <- intersect(supermarketList, supermarketResp)

bathtubMisses <- setdiff(bathtubResp, bathtubList)
convenienceMisses <- setdiff(convenienceResp, convenienceList)
fridgeMisses <- setdiff(fridgeResp, fridgeList)
supermarketMisses <- setdiff(supermarketResp, supermarketList)

# Want to know when participants made errors but got the question stem (category) correct
bathtubList_fridgeResp <- intersect(bathtubList, fridgeResp)
fridgeList_bathtubResp <- intersect(fridgeList, bathtubResp)
fitHits <- c(bathtubList_fridgeResp, fridgeList_bathtubResp)
bathtubResp_questionCategoryError <- intersect(bathtubResp, findList)
fridgeResp_questionCategoryError <- intersect(fridgeResp, findList)
findList_questionCategoryError <- c(bathtubResp_questionCategoryError, fridgeResp_questionCategoryError)
convenienceList_supermarketResp <- intersect(convenienceList, supermarketResp)
supermarketList_convenienceList <- intersect(supermarketList, convenienceResp)
findHits <- c(convenienceList_supermarketResp, supermarketList_convenienceList)
convenienceResp_questionCategoryError <- intersect(convenienceResp, fitList)
supermarketResp_questionCategoryError <- intersect(supermarketResp, fitList)
fitList_questionCategoryError <- c(convenienceResp_questionCategoryError, supermarketResp_questionCategoryError)

#' ## Item recognition
recdata$itemScore <- factor(NA,levels=c("Rec","Fam","Miss","R-FA","F-FA","CR", "exclude"))
recdata$itemScore[intersect(oldmask,Rresp)] <- "Rec"
recdata$itemScore[intersect(oldmask,Fresp)] <- "Fam"
recdata$itemScore[intersect(oldmask,Nresp)] <- "Miss"
recdata$itemScore[intersect(newmask,Rresp)] <- "R-FA"
recdata$itemScore[intersect(newmask,Fresp)] <- "F-FA"
recdata$itemScore[intersect(newmask,Nresp)] <- "CR"
recdata$itemScore[recdata$participant==237 & recdata$blockID==4] <- "exclude"
table(recdata$participant,recdata$itemScore)

# include a column that just indicates correct/incorrect
# (this is helpful for splitting up plots)
recdata$item_corr_incorr <- dplyr::recode(recdata$itemScore, "Rec" = "correct", "Fam" = "correct", "CR" = "correct", 
                                          "Miss" = "incorrect", "R-FA" = "incorrect", "F-FA" = "incorrect")

item_hits <- which(recdata$itemScore == "Rec" | recdata$itemScore == "Fam")
item_misses <- which(recdata$itemScore == "Miss")

#' ## Question source
# NB: this does not handle if subjects don't respond (since this isn't possible in this version)
recdata$questionScore <- factor(NA, levels = c("new_item", "correct", "incorrect", "random_response"))
recdata$questionScore[intersect(oldmask, bathtubHits)] <- "correct"
recdata$questionScore[intersect(oldmask, convenienceHits)] <- "correct"
recdata$questionScore[intersect(oldmask, fridgeHits)] <- "correct"
recdata$questionScore[intersect(oldmask, supermarketHits)] <- "correct"
recdata$questionScore[intersect(oldmask, bathtubMisses)] <- "incorrect"
recdata$questionScore[intersect(oldmask, convenienceMisses)] <- "incorrect"
recdata$questionScore[intersect(oldmask, fridgeMisses)] <- "incorrect"
recdata$questionScore[intersect(oldmask, supermarketMisses)] <- "incorrect"
recdata$questionScore[newmask] <- "new_item"
recdata$questionScore[item_misses] <- "random_response"
table(recdata$participant, recdata$questionScore)

#' ### Score question source liberally (correct question type)
recdata$questionScoreLiberal <- factor(NA, levels = c("correct_questiontype", "incorrect", "random_response", "new_item"))
recdata$questionScoreLiberal[intersect(oldmask, bathtubHits)] <- "correct_questiontype"
recdata$questionScoreLiberal[intersect(oldmask, convenienceHits)] <- "correct_questiontype"
recdata$questionScoreLiberal[intersect(oldmask, fridgeHits)] <- "correct_questiontype"
recdata$questionScoreLiberal[intersect(oldmask, supermarketHits)] <- "correct_questiontype"
recdata$questionScoreLiberal[intersect(oldmask, fitHits)] <- "correct_questiontype"
recdata$questionScoreLiberal[intersect(oldmask, findHits)] <- "correct_questiontype"
recdata$questionScoreLiberal[intersect(oldmask, findList_questionCategoryError)] <- "incorrect"
recdata$questionScoreLiberal[intersect(oldmask, fitList_questionCategoryError)] <- "incorrect"
recdata$questionScoreLiberal[newmask] <- "new_item"
recdata$questionScoreLiberal[item_misses] <- "random_response"
table(recdata$participant, recdata$questionScoreLiberal)

#' ## List source
max_encList <- max(listsource$encList)
if(VERSION_FLAG < 6) {
  remove_cols <- c("-oldStatus", "-trialPresentation.thisRepN", "-trialPresentation.thisTrialN", "-trialPresentation.thisN", "-trialPresentation.thisIndex",
                   "-response.keys", "-response.corr", "-response.rt")
} 
remove_cols <- c("-encRatingScale")

listsource_scored <- listsource %>%
  dplyr::filter(!participant %in% exclude_subjects) %>%
  dplyr::mutate(list_scored_lag = factor((list_source_resp - encList), levels = c(-4:4))) %>%
  dplyr::mutate(listScore = factor(ifelse(list_scored_lag == 0, "correct", "incorrect"), levels = c("correct", "incorrect")),
                # score list source based on opportunities to make each response
                # This is similar to the approach in https://github.com/trjonker/order-free-recall
                raw_score = list_source_resp - encList, # this is the same as how `list_scored_lag` is computed but it's *not* a factor
                distance = abs(raw_score),
                # condition "recall" probabilities - idea comes from Howard & Kahana, 1999 but using here for recognition
                # if a lag is possible = 0, if lag is possible *and* is what participant responded = 1, if lag is NOT possible = NA
                # essentially: if the raw score == current lag -> TRUE, 
                # else if the current item is NOT from list1 *and* it's NOT possible for the current item to have a lag greater than the current lag -> FALSE
                lag_neg4 = ifelse(raw_score == -4, 1, ifelse(((encList + -4) > 0), 0, NA)),
                lag_neg3 = ifelse(raw_score == -3, 1, ifelse(((encList + -3) > 0), 0, NA)),
                lag_neg2 = ifelse(raw_score == -2, 1, ifelse(((encList + -2) > 0), 0, NA)),
                lag_neg1 = ifelse(raw_score == -1, 1, ifelse(((encList + -1) > 0), 0, NA)),
                lag_pos1 = ifelse(raw_score == 1, 1, ifelse(((encList + 1) <= max_encList), 0, NA)),
                lag_pos2 = ifelse(raw_score == 2, 1, ifelse(((encList + 2) <= max_encList), 0, NA)),
                lag_pos3 = ifelse(raw_score == 3, 1, ifelse(((encList + 3) <= max_encList), 0, NA)),
                lag_pos4 = ifelse(raw_score == 4, 1, ifelse(((encList + 4) <= max_encList), 0, NA))) %>%
  # remove columns that cause problems when left_join w/ `recdata`
  dplyr::select_(remove_cols) 

table(listsource_scored$participant, listsource_scored$listScore)

#' ## Join all scored data
all_scored <- recdata %>%
  dplyr::left_join(listsource_scored) %>%
  # make a factor again
  dplyr::mutate(encQuest_factor = factor(encQuest_factor, levels = c(NA, "bathtub", "supermarket", "fridge", "convenience store"))) %>%
  # compute a globally unique trial number (this is needed to match up w the EEG data)
  dplyr::mutate(global_item_recog_trial_number = ((blockID - 1) * 45) + trial_number.item_recog) %>%
  dplyr::filter(!participant %in% exclude_subjects)

summary(all_scored)
save(all_scored, file = paste0(halle::ensure_trailing_slash(group_analyzed_dir),"scored_data.Rdata"))

#' # Save out subject data for EEG
subj_list <- unique(all_scored$participant)
for(isubj in 1:length(subj_list)){
  cur_subj <- subj_list[isubj]
  
  cur_dat <- NULL
  cur_dat <- all_scored %>%
    dplyr::filter(participant == cur_subj) %>%
    # ensure that trials are in order w/in each block
    dplyr::arrange(blockID, trial_number.item_recog)
  
  subj_out_dir <- file.path(group_analyzed_dir, sprintf('s%d', cur_subj))
  dir.create(subj_out_dir, recursive = TRUE, showWarnings = FALSE)
  
  write.csv(cur_dat, file = file.path(subj_out_dir, sprintf("s%d_scored_behavior.txt", cur_subj)), row.names = FALSE)
  write.csv(cur_dat, file = file.path(subj_out_dir, sprintf("s%d_scored_behavior.csv", cur_subj)), row.names = FALSE) #easier to read in excel for checking purposes
  
}

#' # d Prime
# compute z-scored response rate 
item_respcount_by_oldNew <- recdata %>%
  dplyr::mutate(itemResp_oldNew = as.factor(ifelse(item_recog_resp %in% c("rem", "fam"), "old", as.character(item_recog_resp)))) %>% 
  dplyr::group_by(subj_factor, oldNew, itemResp_oldNew) %>%
  dplyr::summarise(respcount = length(itemResp_oldNew))

head(item_respcount_by_oldNew)

z_resprate_oldNew <- recdata %>%
  dplyr::group_by(subj_factor, oldNew) %>%
  dplyr::summarise(allcount = length(oldNew)) %>%
  dplyr::left_join(item_respcount_by_oldNew) %>%
  dplyr::mutate(resprate = respcount/allcount) %>%
  dplyr::group_by(oldNew, itemResp_oldNew) %>%
  dplyr::mutate(mean_resprate = mean(resprate, na.rm = TRUE), # do as mutate instead of summarize to preserve `resprate` column
                sd_resprate = sd(resprate, na.rm = TRUE)) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(subj_factor) %>%
  dplyr::mutate(z_resprate = ((resprate - mean_resprate) / sd_resprate))

head(z_resprate_oldNew)

# separate out FA
false_alarms_oldNew <- z_resprate_oldNew %>%
  dplyr::filter(oldNew == "new") %>%
  dplyr::filter(itemResp_oldNew == "old") %>%
  dplyr::rename(fa_z_resprate = z_resprate) %>%
  dplyr::select(subj_factor, fa_z_resprate, itemResp_oldNew)

head(false_alarms_oldNew)

# separate out hits
hits_oldNew <- z_resprate_oldNew %>%
  dplyr::filter(oldNew == "old") %>%
  dplyr::filter(itemResp_oldNew == "old") %>%  
  dplyr::rename(hit_z_resprate = z_resprate) %>%
  dplyr::select(subj_factor, hit_z_resprate, itemResp_oldNew)

head(hits_oldNew)

# compute d'
d_prime_vals_oldNew <- hits_oldNew %>%
  dplyr::left_join(false_alarms_oldNew) %>%
  dplyr::group_by(subj_factor) %>%
  dplyr::mutate(d_prime = hit_z_resprate - fa_z_resprate)

head(d_prime_vals_oldNew)

#' ## Test d' vs 0
t.test(x = d_prime_vals_oldNew$d_prime, mu = 0)

d_prime_vals_oldNew %>%
  dplyr::ungroup() %>%
  dplyr::rename(var1 = d_prime) %>%
  dplyr::select(var1) %>%
  halle::compute_cohens_d_vs_0(.)

#' ## Graph d'
d_prime_vals_oldNew %>%
  dplyr::ungroup() %>%
  ggplot2::ggplot(ggplot2::aes(x = itemResp_oldNew, y = d_prime)) +
  ggplot2::geom_boxplot(width = 0.4) +
  ggplot2::geom_point(ggplot2::aes(color = subj_factor),
                      position = ggplot2::position_jitterdodge()) +
  ggplot2::ggtitle("Sensitivity index: Item Recognition") +
  ggplot2::ylab("hit_z_resprate - fa_z_resprate") +
  ggplot2::theme(legend.position = "none", 
                 plot.title = element_text(hjust = 0.5, size = 20),
                 axis.title.x = element_blank(), axis.text.x = element_blank(),
                 axis.title.y = element_text(size = 20), axis.text.y = element_text(size = 15))

if(SAVE_FLAG){
  ggplot2::ggsave(filename = paste0(plots_dir, "item_recog_d_prime.pdf"), width = 6, height = 4)
}

#' # Recollection vs Familiarity
item_respcount <- recdata %>%
  dplyr::group_by(subj_factor, oldNew, item_recog_resp, itemScore) %>%
  dplyr::summarise(respcount = length(item_recog_resp)) %>%
  dplyr::ungroup() 
head(item_respcount)

# check that each subject made R_FA responses; if not, insert zeros
subjs <- unique(item_respcount$subj_factor)
for(isubj in 1:length(subjs)){
  cur_subj <- subjs[isubj]
  
  cur_dat <- item_respcount %>%
    dplyr::filter(subj_factor == cur_subj)
  
  if("R-FA" %in% unique(cur_dat$itemScore)){
    print(sprintf("%s has R-FA responses - continuing", cur_subj))
  } else {
    print(sprintf("%s does not has R-FA responses - inserting zeros", cur_subj))
    num_rows <- dim(cur_dat)[1]
    cur_dat[num_rows+1,]$subj_factor <- cur_subj
    cur_dat[num_rows+1,]$oldNew <- "new"
    cur_dat[num_rows+1,]$item_recog_resp <- "rem"
    cur_dat[num_rows+1,]$itemScore <- "R-FA"
    cur_dat[num_rows+1,]$respcount <- 0
    
    # merge back into the existing dataframe
    item_respcount <- dplyr::full_join(item_respcount, cur_dat, by = intersect(names(item_respcount), names(cur_dat)))
  }
}

item_rates <- recdata %>%
  dplyr::group_by(subj_factor, oldNew) %>%
  dplyr::summarise(allcount = length(oldNew)) %>%
  dplyr::left_join(item_respcount) %>%
  dplyr::mutate(resprate = respcount/allcount) 
head(item_rates)

item_rates_split <- item_rates %>%
  dplyr::select(subj_factor, itemScore, resprate) %>%
  dplyr::filter(!is.na(itemScore)) %>%
  dplyr::filter(itemScore!="exclude") %>%
  as.data.frame() %>%
  dplyr::mutate(item_score_relabel = dplyr::recode_factor(itemScore, `R-FA` = "R_FA", `F-FA` = "F_FA")) %>%
  dplyr::select(-itemScore) %>%
  tidyr::spread(item_score_relabel, resprate) %>%
  as.data.frame()
head(item_rates_split)

rec_fam <- item_rates_split %>%
  # dplyr::group_by(subj_factor) %>%
  # dual process equations for recollection and familiarity
  # see Libby schizo review for equations
  dplyr::mutate(recollection = (Rec - R_FA) / (1 - R_FA),
                familiarity = ((Fam / ((1 - Rec)) - (F_FA/(1 - R_FA))))) %>%
  tidyr::gather(process_type, estimate, recollection:familiarity)
summary(rec_fam)

#' ## Test that process estimates differ from zero
rec_fam_tt <- rec_fam %>%
  tidyr::spread(process_type, estimate) %>%
  dplyr::ungroup() 

#' ### Recollection
t.test(rec_fam_tt$recollection, mu = 0)

rec_fam_tt %>%
  dplyr::rename(var1 = recollection) %>%
  dplyr::select(var1) %>%
  halle::compute_cohens_d_vs_0(.)

#' ### Familiarity
t.test(rec_fam_tt$familiarity, mu = 0)

rec_fam_tt %>%
  dplyr::rename(var1 = familiarity) %>%
  dplyr::select(var1) %>%
  halle::compute_cohens_d_vs_0(.)

#' ## Graph recollection and familiarity estimates
rec_fam %>%
  ggplot2::ggplot(ggplot2::aes(x = process_type, y = estimate)) +
  ggplot2::geom_boxplot(width = 0.5) +
  ggplot2::geom_point(ggplot2::aes(color = subj_factor),
                      position = ggplot2::position_jitterdodge()) +
  ggplot2::ggtitle("Dual process estimates") +
  ggplot2::ylab("mean estimate value") +
  ggplot2::theme(legend.position = "none",
                 plot.title = element_text(hjust = 0.5, size = 20),
                 axis.title.x = element_blank(), 
                 strip.text.x = element_text(size = 20), strip.background.x = element_rect(fill = "white"),
                 axis.title.y = element_text(size = 20), axis.text.y = element_text(size = 15)) +
  ggplot2::theme(axis.text.x = element_blank())

if(SAVE_FLAG){
  ggplot2::ggsave(filename = paste0(plots_dir, "dual_process_estimates.pdf"), width = 6, height = 4)
}

rec_fam %>%
  # change x-axis labels to match source memory plots
  dplyr::mutate(process_type = dplyr::recode(process_type, "familiarity" = "fam", "recollection" = "rec")) %>%
  ggplot2::ggplot(ggplot2::aes(x = process_type, y = estimate)) +
  ggplot2::geom_boxplot(width = 0.3) +
  ggplot2::geom_point(ggplot2::aes(color = subj_factor),
                      position = ggplot2::position_jitterdodge(0.1)) +
  ggplot2::ggtitle("Dual Process Estimates") +
  ggplot2::ylab("mean estimate value") +
  ggplot2::theme(legend.position = "none",
                 plot.title = element_text(hjust = 0.5, size = 20),
                 axis.title.x = element_blank(), 
                 strip.text.x = element_text(size = 20), axis.text.x = element_text(size = 20),
                 strip.background.x = element_rect(fill = "white"),
                 axis.title.y = element_text(size = 20), axis.text.y = element_text(size = 15)) 



#' # Graph question source 
#' ## Counts
recdata %>%
  dplyr::filter(oldNew == "old") %>%
  dplyr::filter(questionScore != "random_response") %>%
  dplyr::group_by(subj_factor, questionScore) %>%
  dplyr::mutate(respFreq = length(questionScore)) %>%
  dplyr::summarise(count = n()) %>%
  plot_counts_no_facet(., "questionScore", "count", "Mean count of question source accuracy")
p


#' ## rates
questXitem_resprates <- recdata %>%
  dplyr::filter(!subj_factor == "106") %>%
  dplyr::filter(oldNew == "old") %>%
  dplyr::filter(itemScore %in% c("Rec", "Fam")) %>%
  dplyr::group_by(subj_factor, itemScore) %>%
  dplyr::summarise(allcount = length(encQuest_factor)) %>%
  dplyr::left_join(questXitem_respcount) %>%
  dplyr::mutate(resprate = respcount/allcount) %>%
  dplyr::group_by(questionScore, itemScore) %>%
  dplyr::summarise(mean_resprate = mean(resprate),
                   sd_resprate = sd(resprate),
                   num_subj = length(resprate),
                   sem_resprate = sd_resprate / sqrt(num_subj)) 
print(questXitem_resprates)

#' ## Source memory statistics
questXitem_resprates <- recdata %>%
  filter(!subj_factor == "106") %>%
  filter(oldNew == "old") %>%
  filter(itemScore %in% c("Rec", "Fam")) %>%
  group_by(subj_factor, itemScore) %>%
  summarise(allcount = length(encQuest_factor)) %>%
  left_join(questXitem_respcount) %>%
  mutate(resprate = respcount/allcount) %>%
  group_by(questionScore, itemScore) %>%
  summarise(shapiro = shapiro.test(resprate)$p.value,
                   t_test_stat = t.test(resprate, mu = 0.25, alternative = "greater")$statistic,
                   t_test_p = t.test(resprate, mu = 0.25, alternative = "greater")$p.value,
                   t_test_df = t.test(resprate, mu = 0.25, alternative = "greater")$parameter,
                   t_test_mean = t.test(resprate, mu = 0.25, alternative = "greater")$estimate)
print(questXitem_resprates)





