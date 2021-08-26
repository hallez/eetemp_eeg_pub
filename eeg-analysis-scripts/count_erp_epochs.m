% Script to count ERP epochs after data cleaning steps.
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');  
clc;
clear all; 

config = eetemp_initialize;
subjects = config.subjects;
erp_rem_exclude_subjects = {};
erp_fam_exclude_subjects = {};

for isub =  1:length(subjects)
    subj_start = tic;
    subj_str = subjects{isub};
    subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);
    
    set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g_erpep_removep-loc%0.2g-glob%0.2g_rmica_interpol_removep2_merged',...
                            config.hpf_cutoff, config.local_threshold, config.global_threshold);
    set_str_out = 'count-eps';
    
    % print out info to a diary file
    diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s_%s.txt', subj_str, set_str_out, date)); 
    diary(diaryname);
    
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab
    
    fname_in = sprintf('%s_eetemp_%s.set', subj_str, set_str_in);
    
    if ~exist(fullfile(subj_anal_dir, fname_in), 'file')
        fprintf('%s does not exist - continuing.\n', fname_in)
        continue;
    end

    EEG = pop_loadset('filename', fname_in,'filepath', subj_anal_dir); % load in dataset
    
    % count up trials of interest
    % cannot use 'EEG.event.item_recog_scored' to tabulate trial numbers,
    % because for every epoch, the trial label gets repeated 
    if isa([EEG.event.type], 'double')
        num_rec_trials = size(find([EEG.event.type] == 211),2);
        num_fam_trials = size(find([EEG.event.type] == 212),2);
        num_rem_source_hits = sum(ismember(find(strcmp([EEG.event.item_source_scored], 'correct')), find([EEG.event.type] == 211)));
        num_rem_source_miss = sum(ismember(find(strcmp([EEG.event.item_source_scored], 'incorrect')), find([EEG.event.type] == 211)));
    else
        num_rec_trials = sum(strcmp({EEG.event.type}, '211'));
        num_fam_trials =  sum(strcmp({EEG.event.type}, '212'));
        num_rem_source_hits = sum(ismember(find(strcmp([EEG.event.item_source_scored], 'correct')), find(strcmp({EEG.event.type}, '211'))));
        num_rem_source_miss = sum(ismember(find(strcmp([EEG.event.item_source_scored], 'incorrect')), find(strcmp({EEG.event.type}, '211'))));
    end

    fprintf('Subject %s has %d recollected trials and %d familiar trials.\n',...
        subj_str, num_rec_trials, num_fam_trials)

    fprintf('Of the %d recollected trials %d are source hits and %d are source misses.\n',...
        num_rec_trials, num_rem_source_hits, num_rem_source_miss)
  
    if num_rec_trials < config.min_trials_thresh 
        erp_rem_exclude_subjects = [erp_rem_exclude_subjects, subj_str]; 
    end

    if num_fam_trials < config.min_trials_thresh
        erp_fam_exclude_subjects = [erp_fam_exclude_subjects, subj_str]; 
    end
    
    subj_end = toc(subj_start);
    fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
    diary off;
end

save(fullfile(config.analyzed_eeg_dir, sprintf('exclude_subj_less-than-%d-rem-trials.mat', config.min_trials_thresh)), 'erp_rem_exclude_subjects')
save(fullfile(config.analyzed_eeg_dir, sprintf('exclude_subj_less-than-%d-fam-trials.mat', config.min_trials_thresh)), 'erp_fam_exclude_subjects')

