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

if(EXCLUDE_SUBJ_FLAG == 1){
  exclude_subjects <- c(202, 209, 215, 216, 220, 222, 225, 238, 239, 248, 249)
  rem_trialnums_cutoff <- 30
} else {
  exclude_subjects <- c(216, 222, 239) # these subjects are excluded irrespective of behavioral performance 
  rem_trialnums_cutoff <- 0
}


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
                rec_dualprocess = rem_hit_rate - rem_fa_rate, # calculation based on Barnett/HML slack message 9/24/18
                fam_hits_corrected = fam_hit_rate / (1 - rem_hit_rate), 
                fam_corrected = fam_fa_rate / (1 - rem_fa_rate),
                fam_dualprocess = fam_hits_corrected - fam_corrected)




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



#' ## Mean and SD for item and source memory
item_and_source_stats <- behav_all_counts %>%
  dplyr::ungroup() %>%
  dplyr::summarise(mean_rem_rate = mean(rem_hit_rate),
                   sd_rem_rate = sd(rem_hit_rate),
                   mean_fam_rate = mean(fam_hit_rate),
                   sd_fam_rate = sd(fam_hit_rate),
                   mean_cr_rate = mean(cr_rate),
                   sd_cr_rate = sd(cr_rate),
                   mean_rem_fa_rate = mean(rem_fa_rate),
                   sd_rem_fa_rate = sd(rem_fa_rate),
                   mean_fam_fa_rate = mean(fam_fa_rate),
                   sd_fam_fa_rate = sd(fam_fa_rate),
                   mean_source_exact_rate = mean(source_exact_hitrate),
                   sd_source_exact_rate = sd(source_exact_hitrate),
                   mean_source_liberal_rate = mean(source_questiontype_hitrate),
                   sd_source_liberal_rate = sd(source_questiontype_hitrate),
                   mean_rec_dualprocess = mean(rec_dualprocess),
                   sd_rec_dualprocess = sd(rec_dualprocess),
                   mean_fam_dualprocess = mean(fam_dualprocess),
                   sd_fam_dualprocess = sd(fam_dualprocess),
                   mean_source_rem = mean(Rec_correct/(Rec_correct + Rec_incorrect)),
                   sd_source_rem = sd(Rec_correct/(Rec_correct + Rec_incorrect)),
                   mean_source_fam = mean(Fam_correct/(Fam_correct + Fam_incorrect)),
                   sd_source_fam = sd(Fam_correct/(Fam_correct + Fam_incorrect))) %>%
  tidyr::gather(key = "measure", value = "value")

print(item_and_source_stats, n = nrow(item_and_source_stats))
source_rec_rate <- behav_all_counts$Rec_correct/(behav_all_counts$Rec_correct + behav_all_counts$Rec_incorrect)
source_fam_rate <- behav_all_counts$Fam_correct/(behav_all_counts$Fam_correct + behav_all_counts$Fam_incorrect)

t.test(source_rec_rate, source_fam_rate, paired = TRUE)

t.test(source_rec_rate, mu = 0.25, alternative = "greater")
t.test(source_fam_rate, mu = 0.25, alternative = "greater")






