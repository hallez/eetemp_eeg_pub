% Script to baseline correct (in the time domain).
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');  
clc;
clear all; 

config = eetemp_initialize;
subjects = config.subjects;

for isub =  1:length(subjects)
    subj_start = tic;
    subj_str = subjects{isub};
    subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);
    
    set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g_erpep_removep-loc%0.2g-glob%0.2g_rmica_interpol_removep2_merged',...
                            config.hpf_cutoff, config.local_threshold, config.global_threshold);
    set_str_out = 'rmbase';
    
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
    
    % save original data in case need to compare
    origEEG = EEG;
    
    % baseline correct - since this is calculated individually for each
    % epoch (see line 163 in 'pop_rmbase' to confirm this), it's OK to do
    % on data that's been merged across blocks
    EEG = pop_rmbase( EEG, [-1000*config.erp_baseline_for_plots 0]);
             
    % save out dataset 
    set_name_out = sprintf('%s_%s', set_str_in, set_str_out); % doesn't contain '.set' file string
    fname_out = sprintf('%s_eetemp_%s.set', subj_str, set_name_out); % no longer include block ID b/c it's merged
    EEG = pop_saveset(EEG, 'filename', fname_out, 'filepath', subj_anal_dir);
    eeglab redraw;

    subj_end = toc(subj_start);
    fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
    diary off;
end
