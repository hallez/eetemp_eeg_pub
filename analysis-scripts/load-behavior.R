#' ---
#' title: Load eetemp behavioral data
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
#' ## Load required packages
library(halle)
library(tidyverse)
library(yaml)
# following instructions from http://kbroman.org/pkg_primer/pages/github.html
# this ensures that the most recent version of the `halle` package also gets added
devtools::install_github("hallez/halle", subdir="halle")

#' ## Load in config file
config <- yaml::yaml.load_file("../config.yml")

#' ## Flag which version of pilot or task
VERSION_FLAG <- 7

#' ## Setup paths
# for folders that contain dashes in config, will need to index with single quote
project_dir <- ("../")
dropbox_dir <- paste0(halle::ensure_trailing_slash(config$directories$`dropbox-folder`))
raw_behavioral_dir <- paste0(dropbox_dir, halle::ensure_trailing_slash("raw-behavioral"))

analyzed_behavioral_dir <- paste0(project_dir,halle::ensure_trailing_slash(config$directories$`analyzed-behavioral-dir`))

#' # Figure out subjects
# assume that subjects have folders in `raw_behavioral_dir` that start with `s` and are followed by three digits
subjects <- c(list.files(path=raw_behavioral_dir,pattern="^[s][(123456789)][(0123456789)][(0123456789)]$"))

#' ## Set subjects for whom recognition was mis-labeled as encoding
mislabeled_subjects <- c(149:155) 
mislabeled_subjects_formatted <- NULL
for(i in 1:length(mislabeled_subjects)){
  mislabeled_subjects_formatted[i] <- halle::prepend_s_to_subject_id(mislabeled_subjects[i])
}

#' ## Set information (eg, subjects) by version
if(VERSION_FLAG < 7){
  expt_str <- sprintf("pilot%d", VERSION_FLAG)
} else{
  expt_str <- "experiment"
}

if(VERSION_FLAG == 1){
  sprintf("Analyzing %s", expt_str)
  subjects <- c("s105", "s106", "s108", "s109", "s110", "s111", "s112")
  exclude_subjects <- c(101, 102, 103, 104, 107) # these should just be numbers
} else if(VERSION_FLAG == 2){
  sprintf("Analyzing %s", expt_str)
  subjects <- c("s113", "s114", "s115", "s116", "s117", "s119", "s120", "s122", "s123")
  exclude_subjects <- c(101:112, 118, 121)
} else if(VERSION_FLAG == 3){
  sprintf("Analyzing %s", expt_str)
  subjects <- c("s124","s125","s126","s127","s128","s129","s130", "s131","s132","s133","s134","s135")
  exclude_subjects <- c(101:123, 128, 129, 131, 132)
} else if(VERSION_FLAG == 4){
  sprintf("Analyzing %s", expt_str)
  subjects <- c("s137", "s138", "s139", "s140", "s141", "s142", "s143", "s144", "s145", "s146", "s147", "s148")
  exclude_subjects <- c(101:135, 136, 149:154) # for now, exclude 136 until can figure out how to score separately
} else if (VERSION_FLAG == 5) {
  sprintf("Analyzing %s", expt_str)
  subjects <- c("s149", "s150", "s152", "s153", "s154", "s155", "s156", "s157", "s158", "s159", 
                "s160", "s161", "s162", "s163", "s164", "s166", "s167")
  exclude_subjects <- c(101:148, 151)
} else if (VERSION_FLAG == 6) {
  # s168 and s169 were accidentally run on eeg version of scripts (so had mini-blocks and "trigger" codes)
  sprintf("Analyzing %s", expt_str)
  exclude_subjects <- c(101:167, 178) # technically, 170 is really 170E
} else if (VERSION_FLAG == 7){
  sprintf("Analyzing %s", expt_str)
  exclude_subjects <- c(101:180, 201, 209, 216, 222, 239) # technically, 170 is really 170E
}

# format and filter
exclude_subjects_formatted <- NULL
for(i in 1:length(exclude_subjects)){
  exclude_subjects_formatted[i] <- halle::prepend_s_to_subject_id(exclude_subjects[i])
}

subjects <- subjects[!is.element(subjects, exclude_subjects_formatted)]

#' ## List subjects
subjects
length(subjects)

#' # Load data
#+ warning = FALSE, message = FALSE
task_string <- "enc"
list_source_string <- "list-source"

# setup empty group dataframes
encdata <- data.frame()
recdata <- data.frame()
listsource <- data.frame()

for(cur_subj in subjects){
  cat(sprintf("\nWorking on %s\n", cur_subj))
  
  if(cur_subj %in% mislabeled_subjects_formatted){
    cat(sprintf("\t%s had mislabeled files.\n", cur_subj))
    
    task_fname_pattern <- paste0("^(", sub("s", "", cur_subj), task_string, ").*(csv)") 
    task_fname <- list.files(path = paste0(halle::ensure_trailing_slash(raw_behavioral_dir), cur_subj), pattern = task_fname_pattern)
    if(length(task_fname > 1)){
      task_string <- "enc"
      
      date_pattern <- paste0("[0-9][0-9][0-9][0-9].csv")
      pattern_match_indices <- regexec(pattern = date_pattern, task_fname)  
      date_strings <- as.numeric(sub(".csv", "", regmatches(task_fname, pattern_match_indices)))
      # encoding always happens before recognition, therefore the "earlier" date is encoding
      if((date_strings[1] - date_strings[2]) < 0){
        enc_fname_pattern <- paste0("^(", sub("s", "", cur_subj), task_string,").*(", as.character(date_strings[1]),".csv)")
        recog_fname_pattern <- paste0("^(", sub("s", "", cur_subj), task_string,").*(", as.character(date_strings[2]),".csv)")
      } else if((date_strings[1] - date_strings[2]) > 0){
        enc_fname_pattern <- paste0("^(", sub("s", "", cur_subj), task_string,").*(", as.character(date_strings[2]),".csv)")
        recog_fname_pattern <- paste0("^(", sub("s", "", cur_subj), task_string,").*(", as.character(date_strings[1]),".csv)")
      }
      
      cat(sprintf("\tUsing %s as encoding file and %s as recognition file.\n", enc_fname_pattern, recog_fname_pattern))
      
      
      # --- read in encoding data ---
      enc_fname <- list.files(path = paste0(halle::ensure_trailing_slash(raw_behavioral_dir), cur_subj), pattern = enc_fname_pattern)
      if(is.character(enc_fname) && length(enc_fname) == 0){
        cat(sprintf("\tNo %s file for %s. Continuing to next subject.\n", enc_string, cur_subj))
        next
      } 
      
      enc_fpath <- file.path(raw_behavioral_dir, cur_subj, enc_fname)
      if(!file.exists(enc_fpath)){
        cat(sprintf("\t%s does not exist for %s. Continuing to next subject.\n", enc_fpath, cur_subj))
        next
      }

      cur_enc <- readr::read_csv(enc_fpath, col_types = cols())
      
      # --- read in recognition data ---
      recog_fname <- list.files(path = paste0(halle::ensure_trailing_slash(raw_behavioral_dir), cur_subj), pattern = recog_fname_pattern)
      if(is.character(recog_fname) && length(recog_fname) == 0){
        cat(sprintf("\tNo %s file for %s. Continuing to next subject.\n", recog_string, cur_subj))
        next
      } 
      
      recog_fpath <- file.path(raw_behavioral_dir, cur_subj, recog_fname)
      if(!file.exists(recog_fpath)){
        cat(sprintf("\t%s does not exist for %s. Continuing to next subject.\n", recog_fpath, cur_subj))
        next
      }
      
      cur_retrieval <- readr::read_csv(recog_fpath, col_types = cols())
      
    } else if(is.character(task_fname) && length(task_fname) == 0){
      cat(sprintf("\tNo %s file for %s. Continuing to next subject.\n", task_string, cur_subj))
      next
    }
    # end mislabeled_subjects_formatted
  } else if(VERSION_FLAG > 4){
    enc_string <- "enc"
    recog_string <- "recog"
    
    # --- read in encoding data ---
    enc_fname_pattern <- paste0("^(", sub("s", "", cur_subj), enc_string, ").*(csv)") 
    enc_fname <- list.files(path = paste0(halle::ensure_trailing_slash(raw_behavioral_dir), cur_subj), pattern = enc_fname_pattern)
    if(is.character(enc_fname) && length(enc_fname) == 0){
      cat(sprintf("\tNo %s file for %s. Continuing to next subject.\n", enc_string, cur_subj))
      next
    } 
    
    if(cur_subj=="s220"){
      enc_exclude_block <- "220enc2018_Feb_26_1042.csv"
      enc_fname <- enc_fname[!is.element(enc_fname, enc_exclude_block)]
    }
    
    enc_fpath <- file.path(raw_behavioral_dir, cur_subj, enc_fname)
    if(!file.exists(enc_fpath)){
      cat(sprintf("\t%s does not exist for %s. Continuing to next subject.\n", enc_fpath, cur_subj))
      next
    }
    
    # NB will get a warning about missing column names being filled in (see: https://github.com/tidyverse/readr/issues/364)
    # this doesn't seem to impact the data, so ignoring these warnings for now
    cur_enc <- readr::read_csv(enc_fpath, col_types = cols())
    
    # --- read in recognition data ---
    recog_fname_pattern <- paste0("^(", sub("s", "", cur_subj), recog_string, ").*(csv)") 
    recog_fname <- list.files(path = paste0(halle::ensure_trailing_slash(raw_behavioral_dir), cur_subj), pattern = recog_fname_pattern)
    if(is.character(recog_fname) && length(recog_fname) == 0){
      cat(sprintf("\tNo %s file for %s. Continuing to next subject.\n", recog_string, cur_subj))
      next
    }

    if(cur_subj=="s217"){
      recog_exclude_block <- "217recog2018_Feb_16_1650.csv"
      recog_fname <- recog_fname[!is.element(recog_fname, recog_exclude_block)]
    }
    
    if(length(recog_fname) > 1){ # this is true for subjects starting from s201 (eeg-v4 scripts)
      for(ifile in 1:length(recog_fname)){
        recog_fpath <- file.path(raw_behavioral_dir, cur_subj, recog_fname[ifile])
        if(ifile == 1){
          cur_retrieval <- readr::read_csv(recog_fpath, col_types = cols())
        } else {
          cur_dat <- readr::read_csv(recog_fpath, col_types = cols())
          cur_retrieval <- dplyr::full_join(cur_retrieval, cur_dat, by = intersect(names(cur_retrieval), names(cur_dat)))
        }
      }
    } else {
      recog_fpath <- file.path(raw_behavioral_dir, cur_subj, recog_fname)
      if(!file.exists(recog_fpath)){
        cat(sprintf("\t%s does not exist for %s. Continuing to next subject.\n", recog_fpath, cur_subj))
        next
      }
      cur_retrieval <- readr::read_csv(recog_fpath, col_types = cols())
    }

  } else {
    task_fname_pattern <- paste0("^(", sub("s", "", cur_subj), task_string, ").*(csv)") 
    task_fname <- list.files(path = paste0(halle::ensure_trailing_slash(raw_behavioral_dir), cur_subj), pattern = task_fname_pattern)
    if(cur_subj == "s220"){
      task_fname <- "220enc2018_Feb_26_0918.csv" #no data in "220enc2018_Feb_26_1042.csv"
    }
    
    if(is.character(task_fname) && length(task_fname) == 0){
      cat(sprintf("\tNo %s file for %s. Continuing to next subject.\n", task_string, cur_subj))
      next
    } 
    
    task_fpath <- file.path(raw_behavioral_dir, cur_subj, task_fname)
    if(!file.exists(task_fpath)){
      cat(sprintf("\t%s does not exist for %s. Continuing to next subject.\n", task_fpath, cur_subj))
      next
    }
    
    cur_task_data <- readr::read_csv(task_fpath, col_types = cols())
    
    by_task <-
      cur_task_data %>%
      dplyr::mutate(task_phase = ifelse(is.na(encLoop.thisTrialN), "retrieval", 
                                        ifelse(is.numeric(encLoop.thisTrialN), "encoding", 
                                               "NA"))) %>%
      # remove rows between loops
      dplyr::filter(!is.na(oldStatus)) %>%
      as.data.frame()
    
    # sanity check that have correct number of trials
    by_task %>% dplyr::group_by(task_phase) %>% dplyr::summarise(num_trials = n())
    
    # split encoding and retrieval for ease of tidying
    cur_enc <- by_task %>%
      dplyr::filter(task_phase == "encoding")
    
    cur_retrieval <- by_task %>%
      dplyr::filter(task_phase == "retrieval")
  } # define filenames based on version and read in
  
  # --- tidy up data ---
  # remove list 1 items for s150
  if(cur_subj == "s150"){
    cur_enc <-
      cur_enc %>%
      dplyr::filter(encList != 1)
    
    cur_retrieval <-
      cur_retrieval %>%
      dplyr::filter(encList != 1) # this is overly conservative and removes list 1 lures as well
    
  }
  
  if(cur_subj %in% c("s202", "s203", "s227", "s234", "s235", "s249")) { # no responses were recorded at encoding for these subjects
    cur_enc <- cur_enc %>%
      # make empty columns for the missing data
      dplyr::mutate(response.rt = NA) 
  } 
  
  tidy_enc <- cur_enc %>%
    dplyr::select(listNum, stim, oldStatus,
                  starts_with("enc"), starts_with("trialsLoop"), starts_with("encLoop"),
                  response.keys, response.rt, date, frameRate, expName, session, participant) %>%
    # add 1 b/c python is zero-indexed
    dplyr::mutate(trial_number.enc = encLoop.thisTrialN + 1) %>%
    dplyr::mutate(encQuest_factor = factor(encQuest, levels = c("fridge", "bathtub", "convenience store", "supermarket"))) %>%
    # revalue character responses to numeric
    # this is because they're written out as python lists
    # strip off when participant used number keypad or when they used numbers
    # do sub for numberpad version, then check again for just numeric responses
    dplyr::mutate(enc_response.keys_stripped = sub("\\['num_([12]*)'\\]", "\\1", response.keys)) %>%
    dplyr::mutate(enc_response.keys_stripped = sub("\\['([12]*)'\\]", "\\1", enc_response.keys_stripped)) %>%
    # 'None' responses will be automatically replaced as 'NA' (as Warning message says)
    dplyr::mutate(enc_resp.numeric = as.numeric(enc_response.keys_stripped)) %>%
    # NB: converting to numeric in this step will truncate to 7 decimal places (which should be fine for RT)
    dplyr::mutate(enc_resp.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", response.rt))) %>%
    # revalue `participants` as a factor (this is better when plotting)
    dplyr::mutate(subj_factor = as.factor(participant)) %>%
    # use verbal labels for old/new status
    dplyr::mutate(oldNew = dplyr::recode(oldStatus, '1' = "old", '0' = "new")) %>%
    # remove rows that do not correspond to trials (e.g., end screen)
    dplyr::filter(!is.na(stim)) %>%
    dplyr::select(-oldStatus, -contains("Loop"), -response.keys, -response.rt, -date, -frameRate, -starts_with("X"), 
                  -expName, -session, -enc_response.keys_stripped, -encQuest)

  # append to group dataframe
  if(length(encdata) == 0){
    encdata <- tidy_enc
  } 
  encdata <- dplyr::full_join(encdata, tidy_enc, by = intersect(names(encdata), names(tidy_enc)))
  
  if(VERSION_FLAG >=7) {
    # switched to using letter responses at eeg-v4 scripts
    tidy_retrieval <- cur_retrieval %>%
      dplyr::filter(!is.na(stim)) %>% # this will remove between-block rows for eeg version
      dplyr::mutate(trial_number.item_recog = responseLoop.thisTrialN + 1) %>%
      dplyr::mutate(encQuest_factor = factor(encQuest, levels = c("bathtub", "convenience store", "fridge", "supermarket"))) %>%
      dplyr::mutate(item_recog_resp.keys_stripped = sub("\\['([fghjk]*)'\\]", "\\1", item_recog_resp.keys)) %>% # will get a "NAs introduced by coercion" error for multiple responses
      dplyr::mutate(item_recog_resp.numeric = as.numeric(car::recode(item_recog_resp.keys_stripped, c("'f'=1; 'g'=2;'h'=3;'j'=4;'k'=5")))) %>%
      dplyr::mutate(question_source.keys_stripped = sub("\\['([fghjk]*)'\\]", "\\1", source_response.keys)) %>%
      dplyr::mutate(quest_source_resp.numeric = as.numeric(car::recode(question_source.keys_stripped, c("'f'=1; 'g'=2;'h'=3;'j'=4;'k'=5")))) %>%
      dplyr::mutate(item_recog_resp.rt_orig = item_recog_resp.rt) %>%
      dplyr::mutate(item_recog_resp.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", item_recog_resp.rt))) %>%
      dplyr::mutate(item_conf.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", item_conf_response.rt))) %>%
      dplyr::mutate(quest_source.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", source_response.rt))) %>%
      dplyr::mutate(subj_factor = as.factor(participant)) %>%
      dplyr::mutate(oldNew = dplyr::recode(oldStatus, '1' = "old", '0' = "new")) %>%
      dplyr::filter(!is.na(stim)) %>%
      dplyr::select(-oldStatus, -encQuest, -contains("Loop"), -contains("responseLoop"), -contains("stripped"), -contains("orig"),
                    -item_recog_resp.keys, -source_response.keys, -starts_with("X"),
                    -date, -frameRate, -expName, -session, -source_response.rt,
                    -starts_with("RecogInstr"), -starts_with("EndResp"), -contains("nDroppedFrames"),
                    -contains("numFrames"), -contains("pulse"), -contains("intrMouse"), -contains("mouse"),
                    -contains("subjBreak"), -contains("subj_break"))
  } else {
    tidy_retrieval <- cur_retrieval %>%
      dplyr::filter(!is.na(stim)) %>% # this will remove between-block rows for eeg version
      dplyr::mutate(trial_number.item_recog = responseLoop.thisTrialN + 1) %>%
      dplyr::mutate(trial_number.quest_source = responseLoop.thisTrialN + 1) %>%
      dplyr::mutate(encQuest_factor = factor(encQuest, levels = c("bathtub", "convenience store", "fridge", "supermarket"))) %>%
      dplyr::mutate(item_recog_resp.keys_stripped = sub("\\['num_([123]*)'\\]", "\\1", item_recog_resp.keys)) %>%
      dplyr::mutate(item_recog_resp.keys_stripped = sub("\\['([123]*)'\\]", "\\1", item_recog_resp.keys_stripped)) %>% # will get a "NAs introduced by coercion" error for multiple responses
      dplyr::mutate(item_recog_resp.numeric = as.numeric(item_recog_resp.keys_stripped)) %>% 
      dplyr::mutate(question_source.keys_stripped = sub("\\['num_([1234]*)'\\]", "\\1", source_response.keys)) %>%
      dplyr::mutate(question_source.keys_stripped = sub("\\['([1234]*)'\\]", "\\1", question_source.keys_stripped)) %>%
      dplyr::mutate(quest_source_resp.numeric = as.numeric(question_source.keys_stripped)) %>%
      dplyr::mutate(item_recog_resp.rt_orig = item_recog_resp.rt) %>%
      dplyr::mutate(item_recog_resp.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", item_recog_resp.rt))) %>%
      dplyr::mutate(quest_source.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", source_response.rt))) %>%
      dplyr::mutate(subj_factor = as.factor(participant)) %>%
      dplyr::mutate(oldNew = dplyr::recode(oldStatus, '1' = "old", '0' = "new")) %>%
      dplyr::filter(!is.na(stim)) %>%
      dplyr::select(-oldStatus, -encQuest, -contains("Loop"), -contains("responseLoop"), -contains("stripped"), -contains("orig"),
                    -item_recog_resp.keys, -source_response.keys, -starts_with("X"),
                    -date, -frameRate, -expName, -session, -source_response.rt,
                    -starts_with("RecogInstr"), -starts_with("EndResp")) 
  }
  
  # now deal w/ item confidence responses
  if(VERSION_FLAG > 5){
    if(cur_subj %in% c("s168", "s169", "s170")){
      tidy_retrieval <- tidy_retrieval %>%
        dplyr::mutate(item_conf_response.keys_stripped = sub("num_([1234]*)", "\\1", item_conf_response.keys)) %>% # no `[]` for item conf responses b/c didn't record "all" responses for these subjects
        dplyr::mutate(item_conf_response.numeric = as.numeric(item_conf_response.keys_stripped)) %>%
        dplyr::mutate(item_conf_response.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", item_conf_response.rt))) %>%
        dplyr::select(-item_conf_response.keys, -contains("stripped"))
    } else if (VERSION_FLAG >=7) {
      tidy_retrieval <- tidy_retrieval %>%
        dplyr::mutate(item_conf_resp.keys_stripped = sub("\\['([fghjk]*)'\\]", "\\1", item_conf_response.keys)) %>%
        dplyr::mutate(item_conf_response.numeric = as.numeric(car::recode(item_conf_resp.keys_stripped, c("'f'=1; 'g'=2;'h'=3;'j'=4;'k'=5")))) %>%
        dplyr::select(-item_conf_response.keys, -contains("stripped"))
    } else {
      tidy_retrieval <- tidy_retrieval %>%
        dplyr::mutate(item_conf_response.keys_stripped = sub("\\['num_([1234]*)'\\]", "\\1", item_conf_response.keys)) %>%
        dplyr::mutate(item_conf_response.keys_stripped = sub("\\['([1234]*)'\\]", "\\1", item_conf_response.keys_stripped)) %>%
        dplyr::mutate(item_conf_response.numeric = as.numeric(item_conf_response.keys_stripped)) %>%
        dplyr::mutate(item_conf_response.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", item_conf_response.rt))) %>%
        dplyr::select(-item_conf_response.keys, -contains("stripped"))
    }
    
    tidy_retrieval$item_conf_resp <- factor(dplyr::recode(tidy_retrieval$item_conf_response.numeric, 
                                                          `1` = "highly", `2` = "moderately", `3` = "somewhat",` 4` = "not at all"), 
                                            levels = c("highly", "moderately", "somewhat", "not at all"))
  }
  
  # recode responses based on subject-specific response scale
  if(unique(tidy_retrieval$rememberResp) == 1){
    tidy_retrieval$item_recog_resp <- factor(dplyr::recode(tidy_retrieval$item_recog_resp.numeric,`1` = "rem", `2` = "fam", `3` = "new"), levels = c("rem", "fam", "new"))
  } else if(unique(tidy_retrieval$rememberResp) == 3) {
    tidy_retrieval$item_recog_resp <- factor(dplyr::recode(tidy_retrieval$item_recog_resp.numeric, `1` = "new", `2` = "fam", `3` = "rem"), levels = c("rem", "fam", "new"))
  }
  
  tidy_retrieval$quest_source_resp <- factor(dplyr::recode(tidy_retrieval$quest_source_resp.numeric, 
                                                    `1` = unique(tidy_retrieval$q1),
                                                    `2` = unique(tidy_retrieval$q2),
                                                    `3` = unique(tidy_retrieval$q3),
                                                    `4` = unique(tidy_retrieval$q4)), levels = c("bathtub", "convenience store", "fridge", "supermarket"))
  
  if(length(recdata) == 0){
    recdata <- tidy_retrieval
  } 
  recdata <- dplyr::full_join(recdata, tidy_retrieval, by = intersect(names(recdata), names(tidy_retrieval)))
  
  list_source_fname_pattern <- paste0("^(", sub("s", "", cur_subj), list_source_string, ").*(csv)")
  list_source_fname <- list.files(path = paste0(halle::ensure_trailing_slash(raw_behavioral_dir), cur_subj), pattern = list_source_fname_pattern)
  if(is.character(list_source_fname) && length(list_source_fname) == 0){
    cat(sprintf("\tNo %s file for %s. Continuing to next subject.\n", list_source_string, cur_subj))
    next
  }

  list_source_fpath <- file.path(raw_behavioral_dir, cur_subj, list_source_fname)
  if(!file.exists(list_source_fpath)){
    cat(sprintf("\t%s does not exist for %s. Continuing to next subject.\n", list_source_fpath, cur_subj))
    next
  }

  cur_list_source_data <- readr::read_csv(list_source_fpath, col_types = cols())

  if(VERSION_FLAG >= 7){
    tidy_list_source <- cur_list_source_data %>%
      dplyr::mutate(trial_number.list_source = trialPresentation.thisTrialN + 1) %>%
      dplyr::mutate(encQuest_factor = factor(encQuest, levels = c("fridge", "bathtub", "convenience store", "supermarket"))) %>%
      dplyr::mutate(list_source_resp.keys_stripped = sub("\\['([fghjk]*)'\\]", "\\1", response.keys)) %>%
      dplyr::mutate(list_source_resp = as.numeric(car::recode(list_source_resp.keys_stripped, c("'f'=1; 'g'=2;'h'=3;'j'=4;'k'=5")))) %>%
      dplyr::mutate(list_source.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", response.rt))) %>%
      # remove row for end screen
      dplyr::filter(!is.na(oldStatus)) %>%
      dplyr::mutate(subj_factor = as.factor(participant)) %>%
      dplyr::mutate(oldNew = dplyr::recode(oldStatus, '1' = "old", '0' = "new")) %>%
      dplyr::select(-oldStatus, -contains("trialPresentation"), -contains("response"), -contains("endScreenResp"),
                    -starts_with("X"), #this handles subjects who don't have columns for `endScreen` and therefore have a different number of columns
                    -date, -frameRate, -expName, -session, -list_source_resp.keys_stripped)
  } else {
    tidy_list_source <- cur_list_source_data %>%
      dplyr::mutate(trial_number.list_source = trialPresentation.thisTrialN + 1) %>%
      dplyr::mutate(encQuest_factor = factor(encQuest, levels = c("fridge", "bathtub", "convenience store", "supermarket"))) %>%
      dplyr::mutate(list_source_resp.keys_stripped = sub("\\['num_([12345]*)'\\]", "\\1", response.keys)) %>%
      dplyr::mutate(list_source_resp.keys_stripped = sub("\\['([12345]*)'\\]", "\\1", list_source_resp.keys_stripped)) %>%
      dplyr::mutate(list_source_resp = as.numeric(list_source_resp.keys_stripped)) %>%
      dplyr::mutate(list_source.rt = as.numeric(sub("\\[([0-9]*\\.[0-9]*)\\]","\\1", response.rt))) %>%
      # remove row for end screen
      dplyr::filter(!is.na(oldStatus)) %>%
      dplyr::mutate(subj_factor = as.factor(participant)) %>%
      dplyr::mutate(oldNew = dplyr::recode(oldStatus, '1' = "old", '0' = "new")) %>%
      dplyr::select(-oldStatus, -contains("trialPresentation"), -contains("response"), -contains("endScreenResp"),
                    -starts_with("X"), #this handles subjects who don't have columns for `endScreen` and therefore have a different number of columns
                    -date, -frameRate, -expName, -session, -list_source_resp.keys_stripped)
  }

  if(length(listsource) == 0){
    listsource <- tidy_list_source
  } 
  listsource <- dplyr::full_join(listsource, tidy_list_source, by = intersect(names(listsource), names(tidy_list_source)))

} #for(cur_subj in subjects


#' # Summarize the data
#' ## Encoding
summary(encdata)

#' ## Object recognition
summary(recdata)

#' ## List source memory
summary(listsource)

#' # Save out group datafiles
group_analyzed_dir <- paste0(analyzed_behavioral_dir, halle::ensure_trailing_slash(sprintf("%s-summary", expt_str)))

# if directory already exists, will return a warning
dir.create(group_analyzed_dir, recursive = TRUE, showWarnings = FALSE)

save(encdata, recdata, listsource, file = paste0(halle::ensure_trailing_slash(group_analyzed_dir),"tidied_data.Rdata"))
