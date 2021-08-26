% Script to populate a STUDY variable
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');  
clc;
clear all; 

config = eetemp_initialize;
subjects = config.subjects;
num_subj = length(subjects);
group_dir = fullfile(config.analyzed_eeg_dir, 'group-analyses');
% since the study includes filepath, get computer-specific information
computer_id = getComputerName;

if ~exist(group_dir, 'dir')
    mkdir(group_dir);
end

set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g_erpep_removep-loc%0.2g-glob%0.2g_rmica_interpol_removep2_merged_rmbase',...
                            config.hpf_cutoff, config.local_threshold, config.global_threshold);
set_str_out = 'study';
study_str_out = sprintf('eetemp_study_N-%d_%s',num_subj, computer_id);

% setup empty variable to hold study info
allcommands = cell(1,length(subjects));

% loop across subjects to populate
for isub=1:length(subjects)
    subj_str = subjects{isub};
    subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);
    allcommands{isub} = {'index' isub 'load' fullfile(subj_anal_dir, sprintf('%s_eetemp_%s.set', subj_str, set_str_in))...
        'subject' subj_str 'session' 1 'condition' 'item-recog'};
end

% use eeglab to create the study
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

STUDY = [];
[STUDY ALLEEG] = std_editset(STUDY, ALLEEG, 'name', study_str_out,...
    'task', 'item-recog', ...
    'commands', allcommands, ...
    'updatedat','on',...
    'savedat','on',...
    'rmclust','on');

% check and save
[STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
[STUDY EEG] = pop_savestudy(STUDY, EEG, 'filename',sprintf('%s.study', study_str_out),'filepath',group_dir);

eeglab redraw;
    