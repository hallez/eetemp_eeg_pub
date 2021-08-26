% Script to remove ICA eyeblink components from data.
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');  
clc;
clear all;

config = eetemp_initialize;

% since each subject needs to be reviewed manually, it's better *not* to
% have this as a for loop. instead, just input the subject ID and block ID
% that want to look at
cur_subj = 210; % should be a numeric input
iset = 4; % should be a number between 1-6
PLOT_FLAG = 1; % run first w/ plotting and then re-run w/o plotting so can save out the dataset
cur_anal = 'erp'; % either 'erp' or 'tf'

%%% DON'T NEED TO CHANGE %%%
subj_str = sprintf('s%s', num2str(cur_subj));
subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);

% this is the 1Hz filtered data where ICA has been computed
ica_wts_set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-ica-%0.2g_%sep_removep-loc%0.2g-glob%0.2g_ica',...
        config.hpf_ica_cutoff, cur_anal, config.local_threshold, config.global_threshold); 
% this is the 0.1Hz data that the ICA weights will be applied to
set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g_%sep_removep-loc%0.2g-glob%0.2g',...
        config.hpf_cutoff, cur_anal, config.local_threshold, config.global_threshold); 
set_str_out = 'rmica';

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab

fname_in = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_str_in);
ica_fname_in = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), ica_wts_set_str_in);

if ~exist(fullfile(subj_anal_dir, fname_in), 'file')
    fprintf('%s does not exist.\n', fname_in)
end

if ~exist(fullfile(subj_anal_dir, ica_fname_in), 'file')
    fprintf('%s does not exist.\n', ica_fname_in)
end

% load ica-ed, 1Hz data  
icaEEG = pop_loadset('filename', ica_fname_in, 'filepath', subj_anal_dir); % load in dataset

% load 0.1Hz data to EEG
EEG = pop_loadset('filename', fname_in, 'filepath', subj_anal_dir); % load in dataset

% check that the datasets are the same. for now, just checking the size b/c
% can't think of how else to verify that they're from the same subject,
% same block, etc.
if ~(isequal(size(EEG.data), size(icaEEG.data)))
    error('The datasets are different sizes. Stopping. \n')
end

% add information about ICA matrix from 1Hz data to 0.1Hz data
EEG.icaact = icaEEG.icaact;
EEG.icawinv = icaEEG.icawinv;
EEG.icasphere = icaEEG.icasphere;
EEG.icaweights = icaEEG.icaweights;
EEG.icachansind = icaEEG.icachansind;

% read in component information 
component_fpath = fullfile(config.analyzed_eeg_dir, subj_str, sprintf('%s_b%s_%s_ica-components.csv', subj_str, num2str(iset), upper(cur_anal)));

if ~exist(component_fpath, 'file')
    error('Component ids file does not exist. Skipping.\n')
end

component_ids = csvread(component_fpath);

% remove eyeblink components from 0.1Hz data
if PLOT_FLAG==1
    % this will also plot the data - use 'plot single trials' option
    % for some reason, when select "accept" hits an error, so just re-run
    % the script w/o plotting after happy w/ component removal to save out
    % the new dataset
    EEG = pop_subcomp(EEG, component_ids, 1); 
else
    EEG = pop_subcomp(EEG, component_ids); 
    % save out dataset
    set_name_out = sprintf('%s_%s', set_str_in, set_str_out); % doesn't contain '.set' file string
    fname_out = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_name_out);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); 
    EEG = pop_saveset(EEG, 'filename', fname_out, 'filepath', subj_anal_dir);
    eeglab redraw;
end

