% Script to run ICA.
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');
clc;
clear all;

config = eetemp_initialize;
subjects = config.subjects;

REREUN_FLAG = 0;

% loop to do for different analysis types (e.g., ERPs, time-frequency)
analysis_types = {'erp'};
num_iter = length(analysis_types);
if config.TIME_FREQ_FLAG == 0
    fprintf('Just ICA-ing for ERPs, skipping for TF.\n')
    num_iter = 1;
end

for iiter = 1:num_iter
    % select if analyzing for ERPs or TF on current loop
    cur_anal = analysis_types{iiter};

    for isub = 1:length(subjects)
        subj_start = tic;
        subj_str = subjects{isub};
        subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);

        set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-ica-%0.2g_%sep_removep-loc%0.2g-glob%0.2g',...
            config.hpf_ica_cutoff, cur_anal, config.local_threshold, config.global_threshold);
        set_str_out = 'ica';

        % print out info to a diary file
        diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s-%s_%s.txt', subj_str, set_str_out, upper(cur_anal), date));
        diary(diaryname);

        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab

        for iset = 1:config.num_blocks
            fname_in = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_str_in);

            if ~exist(fullfile(subj_anal_dir, fname_in), 'file')
                fprintf('%s does not exist - continuing.\n', fname_in)
                continue;
            end

            set_name_out = sprintf('%s_%s', set_str_in, set_str_out); % doesn't contain '.set' file string
            fname_out = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_name_out);

            % check to see if ica has already been run
            if(exist(fullfile(subj_anal_dir, fname_out), 'file') && REREUN_FLAG == 0)
                fprintf('ICA has already been run for %s block %d - not re-running.\n', subj_str, iset)
                continue;
            elseif(exist(fullfile(subj_anal_dir, fname_out), 'file') && REREUN_FLAG == 1)
                fprintf('ICA has already been run for %s block %d but re-running.\n***CAREFUL, THIS MAY UPDATE COMPONENT IDs***.\n', subj_str, iset)
            end

            EEG = pop_loadset('filename', fname_in,'filepath', subj_anal_dir); % load in dataset

            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            EEG = eeg_checkset( EEG );

            % save a copy of the original data
            origEEG = EEG;
            % read in any excluded channels
            bad_chans_fpath = fullfile(subj_anal_dir, sprintf('%s_b%s_bad-channels_lowSD-%0.2g_highSD-%2g.mat', ...
                subj_str, num2str(iset), config.channel_lower_SD, config.channel_upper_SD));

            if ~exist(bad_chans_fpath, 'file')
                fprintf('Bad channels file %s does not exist - skipping.\n', bad_chans_fpath)
                continue;
            end

            % this will load in the variable 'removed_chan_ids'
            load(bad_chans_fpath);

            if(isempty(removed_chan_ids))
                fprintf('No bad channels for block %s.\n', num2str(iset))
            end

            % run ica using the `runica` (default) algorithm
            emg_lbls = {'M1', 'M2'};
            chans_to_exclude = [removed_chan_ids, emg_lbls]; % concatenate all channels to exclude from the ICA
            idx_to_exclude = ismember({EEG.chanlocs.labels}, chans_to_exclude);
            include_idx = find(~idx_to_exclude);
            EEG = pop_runica(EEG, 'icatype', 'runica', 'chanind', include_idx);

            % save out dataset
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            EEG = pop_saveset(EEG, 'filename', fname_out, 'filepath', subj_anal_dir);
            eeglab redraw;

        end %iset

        subj_end = toc(subj_start);
        fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
        diary off;
    end %isub
end %iiter
