% Script to interpolate bad channels.
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');
clc;
clear all;

config = eetemp_initialize;
subjects = config.subjects;

% loop for different analysis types (e.g., ERPs, time-frequency)
analysis_types = {'erp'};
num_iter = length(analysis_types);
if config.TIME_FREQ_FLAG == 0
    fprintf('Just interpolating bad channels for ERPs, skipping for TF.\n')
    num_iter = 1;
end

for iiter = 1:num_iter
    % select if analyzing for ERPs or TF on current loop
    cur_anal = analysis_types{iiter};

    for isub = 1:length(subjects)
        subj_start = tic;
        subj_str = subjects{isub};
        subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);

        set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g_%sep_removep-loc%0.2g-glob%0.2g_rmica',...
                        config.hpf_cutoff, cur_anal, config.local_threshold, config.global_threshold);
        set_str_out = 'interpol';

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

            EEG = pop_loadset('filename', fname_in,'filepath', subj_anal_dir); % load in dataset

            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            EEG = eeg_checkset( EEG );
            % save a copy of the original data
            origEEG = EEG;

            % read in any excluded channels that were detected with automated
            % thresholds
            bad_chans_fpath = fullfile(subj_anal_dir, sprintf('%s_b%s_bad-channels_lowSD-%0.2g_highSD-%2g.mat', ...
                subj_str, num2str(iset), config.channel_lower_SD, config.channel_upper_SD));

            if ~exist(bad_chans_fpath, 'file')
                fprintf('Bad channels file %s does not exist - skipping.\n', bad_chans_fpath)
                continue;
            end

            % this will load in the variable 'removed_chan_ids'
            load(bad_chans_fpath);

            % read in manually detected channels to exclude
            manual_bad_chans_fpath = fullfile(subj_anal_dir, sprintf('%s_b%s_%s_BAD_CHANNELS.csv', subj_str, num2str(iset), upper(cur_anal)));
            if ~exist(manual_bad_chans_fpath, 'file')
                fprintf('Manually identified bad channels file %s does not exist - skipping.\n', manual_bad_chans_fpath)
                continue;
            end

            % read in manually identified channels handling numeric inputs,
            % string inputs, and when there are no channels (nan)
            manual_removed_chan_ids = table2cell(readtable(manual_bad_chans_fpath, 'ReadVariableNames', false));

            if isnumeric([manual_removed_chan_ids{:}])
                numeric_manual_removed_chan_ids = cell2mat(manual_removed_chan_ids);
                if any(isnan(numeric_manual_removed_chan_ids))
                    fprintf('No manually identified bad channels.\n')
                    manual_removed_chan_ids_labels = '';
                elseif isa(numeric_manual_removed_chan_ids, 'double')
                    manual_removed_chan_ids_labels = {origEEG.chanlocs([numeric_manual_removed_chan_ids]).labels};
                end
            else
                % if the input was already a string, just set the value of the
                % expected variable name to the existing channels so that it
                % works when merging with automatically detected channels
                manual_removed_chan_ids_labels = manual_removed_chan_ids;
            end

            % merge automatically detected bad channels with manually detected bad
            % channels
            all_removed_chan_ids = [removed_chan_ids, manual_removed_chan_ids_labels];

            if(isempty(all_removed_chan_ids))
                fprintf('No bad channels for block %s.\n', num2str(iset))
            else
                fprintf('Interpolating %d bad channel(s) in block %s.\n', size(all_removed_chan_ids, 2), num2str(iset))
                % figure out channel numbers of removed channel ids
                removed_chan_nums = find(ismember({origEEG.chanlocs.labels}, all_removed_chan_ids));
                % interpolate any bad channels
                EEG = pop_interp(EEG, removed_chan_nums, 'spherical');
            end

            % save out dataset - regardless of whether or not there were bad
            % channels that needed to be removed, save out w/ the same set name
            % so can read in to future scripts
            set_name_out = sprintf('%s_%s', set_str_in, set_str_out); % doesn't contain '.set' file string
            fname_out = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_name_out);
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            EEG = pop_saveset(EEG, 'filename', fname_out, 'filepath', subj_anal_dir);
            eeglab redraw;

        end %iset

        subj_end = toc(subj_start);
        fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
        diary off;
    end

end %iiter
