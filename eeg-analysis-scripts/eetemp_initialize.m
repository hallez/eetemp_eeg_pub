function [config] = eetemp_initialize()
    % Initialize script for EETemp directories
    % Author: Halle R. Dimsdale-Zucker

    % add project-specific paths
    % will also need to have `eeglab` w `erplab` plugin on the path, but
    % this is added w/ HDZ's `startup.m` file - see https://github.com/hallez/MatlabFunctions
    project_dir = fullfile('..'); % ideally, this should be an absolute path not a relative path so doesn't mess up matlab's path in general
    addpath(genpath(fullfile(project_dir,'vendor','yamlmatlab','0.4.3')));
    addpath(genpath(fullfile(project_dir, 'vendor', 'clean_rawdata0.32')))
    config_file = ReadYaml(fullfile(project_dir,'config.yml'));

    % base directories
    config.dropbox_dir = fullfile(config_file.directories.dropbox0x2Dfolder);
    config.base_dir = fullfile(config_file.directories.base0x2Ddir);

    % data directories
    config.raw_behavioral_dir = fullfile(config.dropbox_dir, config_file.directories.raw0x2Dbehavioral0x2Ddir);
    config.analyzed_behavioral_dir = fullfile(config.base_dir, config_file.directories.analyzed0x2Dbehavioral0x2Ddir);
    config.raw_eeg_dir = fullfile(config.dropbox_dir, config_file.directories.raw0x2Deeg0x2Ddir);
    config.analyzed_eeg_dir = fullfile(config.dropbox_dir, config_file.directories.analyzed0x2Deeg0x2Ddir);

    % script directories
    config.eeg_scripts = fullfile(config.base_dir, config_file.directories.scripts);

    % notes and diaries directories
    config.logs_dir = fullfile(config.base_dir, config_file.directories.logs0x2Ddir);

    % subjects
    all_subj = dir(fullfile(config.raw_behavioral_dir, 's2*')); % use this so new subjects are automatically pulled in
    config.all_subjects = {all_subj.name};
    config.exclude_subjects = {'s201', 's209', 's216', 's217', 's222', 's239'};
    remove_idx = ismember(config.all_subjects, config.exclude_subjects);
    config.subjects = config.all_subjects(~remove_idx);

    % script-invariant information
    config.num_blocks = 6;

    % 0.1 Hz is Luck's recommendation (2017 BootCamp and https://github.com/lucklab/erplab/wiki/Filtering-EEG-and-ERPs:-Tutorial)
    % 1 Hz is Makoto's recommendation for use w/ ICA, but using this high
    % of a HPF value is known to reduce the apparent amplitude of N400 and
    % P300 (see Duncan-Johnson and donchin, 1979) so playing it safe by
    % using the 1Hz value only for the calculation of ICA weights and the
    % 0.1 Hz filtering for the task data
    config.hpf_ica_cutoff = 1;
    config.hpf_cutoff = 0.1;

    % this low-pass filter is doing two things: (1) it's essentially acting
    % as a notch filter (since we know there's line noise @ 60Hz, it will
    % be stripped out by this low pass filter b/c 60 > 20). we could also
    % use a notch filter to do this. (2) it's essentially going to smooth
    % our resultant ERPs (ie, less little wigglies). CAVEAT - if i ever
    % want to look at a faster frequency (e.g., beta), would need to change
    % this value. but 20 Hz shouldn't be problematic if fastest frequency
    % of interest is theta
    config.lpf_cutoff = 20; % this is Luck's recommendation (https://github.com/lucklab/erplab/wiki/Filtering-EEG-and-ERPs:-Tutorial)
    % Luck also recommends 30 (https://github.com/lucklab/erplab/wiki/Filtering)
    % "In many cases, *mildly filtering the data removes a great deal of noise
    % while causing minimal distortion of the data, making it very worthwhile.
    % In most cognitive experiments, for example, you will increase your
    % statistical power by filtering the low frequencies with a cutoff of
    % ~0.1 Hz and by filtering the high frequencies with a cutoff of ~30 Hz*."

    % this value is used by 'clean_rawdata'. 0.85 is the default. 0.8 is
    % what Max Bluestone uses
    config.channel_criterion_value = 0.85;

    % if using trimOutlier for channel rejection
    config.channel_lower_SD = 2; % recommended by Makoto (see https://sccn.ucsd.edu/wiki/TrimOutlier)
    config.channel_upper_SD = 200;
    config.amp_thresh = 300;
    config.point_spread = 1;

    % set criteria for 'pop_jointprob' based on Makoto default
    % recommendations (https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline#Reject_epochs_for_cleaning,
    % see 'Reject epochs for cleaning')
    config.local_threshold = 6;
    config.global_threshold = 2;

    erp_event_duration = 0.7; % should be 0.7 assuming event_code = '10'
    config.erp_baseline_dur = 0.5; % Makoto recommends at least 500ms baseline if using ICA
    config.erp_baseline_for_plots = 0.2; % CR recommends for ERP baselines
    erp_seconds_buffer = 0.3;
    config.erp_epoch_start = -1*config.erp_baseline_dur; % when event_code = 11 (170e), should be -1*(event_duration + baseline_dur)
    config.erp_epoch_end = erp_event_duration + erp_seconds_buffer;

    config.TIME_FREQ_FLAG = 1; % set a flag for whether or not to analyze TF
    shortest_freq_of_interest = 3; % 4 is lowest range of human theta so go down to 3 so can show
    freq_in_seconds = 1/shortest_freq_of_interest;
    cycle_buffer = 3; % Michael X. Cohen (2014) p. 77 recommends a buffer of 3 cycles; this is because he's assuming wavelet = 6 and so this is 1/2 of wavelet
    tf_seconds_buffer = cycle_buffer * freq_in_seconds;
    tf_event_duration = 1.7;
    tf_prior_event_duration = erp_event_duration;
    tf_baseline_dur = 0.5;
    config.tf_epoch_start = -1*(tf_baseline_dur + tf_seconds_buffer);
    config.tf_epoch_end = erp_event_duration + tf_event_duration + tf_seconds_buffer;

    % setup key/value for event codes and their meaning
    % TODO: think of a less error-prone way of coding this; for instance, this
    % is highly prone to off-by-one errors
    %
    % codes that are sent that it's unclear what they are: 125 (unsure if
    % item confidence onset or response)
    config.events = cell(0);
    config.events.code_vals = {'3',... %3 not sent for everyone (and not sent everytime), unsure why this is
        '40', '107',...
        '10', '41', '43',... %technically, 41 should be sent for ITI_offset, but count as item1_onset
        '11', '12', '121',...
        '131','14', '143',... %technically, 131 should be item confidence response, but count as source_onset
        '141', '99'};
    config.events.code_meaning = {'recog_instruc_start',...
        'ITI_onset', 'ITI_onset',...
        'item1_onset', 'item1_onset', 'item1_onset',...
        'think_cue_onset', 'item2_onset', 'item_recog_resp',...
        'source_onset', 'source_onset', 'source_onset', ...
        'source_resp', 'subj_break_onset'};


    % create logs directory if doesn't already exist
    if ~isdir(config.logs_dir)
        fprintf('Creating logs directory.\n')
        mkdir(config.logs_dir);
    end

    % choose a threshold for trial numbers - 30 seems reasonable for ERPs
    config.min_trials_thresh = 30;

end
