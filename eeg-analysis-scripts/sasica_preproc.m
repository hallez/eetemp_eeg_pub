% Script to run SASICA.
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
cur_subj = 232; % should be a numeric input
iset = 3; % should be a number between 1-6

%%% DON'T NEED TO CHANGE %%%
subj_str = sprintf('s%s', num2str(cur_subj));
subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);

set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-ica-%0.2g_erpep_removep-loc%0.2g-glob%0.2g_ica',...
        config.hpf_ica_cutoff, config.local_threshold, config.global_threshold);

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab

fname_in = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_str_in);

if ~exist(fullfile(subj_anal_dir, fname_in), 'file')
    fprintf('%s does not exist.\n', fname_in)
end

EEG = pop_loadset('filename', fname_in,'filepath', subj_anal_dir); % load in dataset

[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );

% use sasica to determine what to do w/ ica components
% it will look up the channels in the dataset if given names of
% channels (could also feed in channel indices, but not all of the
% SASICA functions play nicely w/ this [e.g., FASTER])
vert_chan_names = {'VEOG', 'UVEOG'};
horz_chan_names = {'LHEOG', 'RHEOG'};
all_eye_names = {'VEOG', 'UVEOG', 'LHEOG', 'RHEOG'};

cfg = struct;
cfg.trialfoc.enable = true;
cfg.EOGcorr.Veogchannames = vert_chan_names;
cfg.EOGcorr.Heogchannames = horz_chan_names;
cfg.EOGcorr.corthreshV = 0.4;
cfg.EOGcorr.corthreshH = 0.4;
cfg.chancorr.corthresh = 0.4;
cfg.chancorr.enable = true;
cfg.chancorr.channames = all_eye_names;
% there are three algorithms that can be used (ADJUST, FASTER, and
% MARA) - see 'help eeg_SASICA' for more information. can run all
% of them to get more info (i.e., they shouldn't conflict w/ one
% another)
cfg.ADJUST.enable = true;
cfg.FASTER.blinkchanname = all_eye_names;
cfg.FASTER.enable = true; 
cfg.MARA.enable = true;
cfg.opts.noplot = 0; % show plots
EEG = eeg_SASICA(EEG,cfg);

eeglab redraw;