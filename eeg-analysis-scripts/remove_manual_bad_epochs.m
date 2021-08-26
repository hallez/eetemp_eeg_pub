% Script to remove bad sections (epochs) of data that were manually
% identified. This is in addition to the removal of automatically detected
% bad epochs which occured before ICA (remove_bad_epochs.m)
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
    fprintf('Just removing epochs for ERPs, skipping for TF.\n')
    num_iter = 1;
end

for iiter = 1:num_iter
    % select if analyzing for ERPs or TF on current loop
    cur_anal = analysis_types{iiter};

    for isub = 1:length(subjects)
        subj_start = tic;
        subj_str = subjects{isub};
        subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);

        set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g_%sep_removep-loc%0.2g-glob%0.2g_rmica_interpol',...
                        config.hpf_cutoff, cur_anal, config.local_threshold, config.global_threshold);
        set_str_out = 'removep2';

        % print out info to a diary file
        diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s-%s-removal_%s.txt', subj_str, upper(cur_anal), set_str_out, date));
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

            % use 'pop_jointprob' to reject unlikely segments of data
            origEEG = EEG; % make sure have original data in case need to compare

            % remove epochs that were identified manually. file containing
            % these epochs is created by 'create_subject_drop_files.py'
            removed_fpath = fullfile(subj_anal_dir, sprintf('%s_b%s_%s_BAD_EPOCHS.csv', subj_str, num2str(iset), upper(cur_anal)));

            if ~exist(removed_fpath, 'file')
                fprintf('File of removed epochs does not exist - skipping.\n')
                continue;
            end

            removed_epoch_ids = csvread(removed_fpath);

             if isnan(removed_epoch_ids)
                fprintf('No manually identified epochs to remove.\n')
             else
                fprintf('Removing %d epochs.\n', size(removed_epoch_ids, 2))
                EEG = pop_selectevent( EEG, 'omitepoch', removed_epoch_ids, 'deleteevents', 'off', 'deleteepochs', 'on', 'invertepochs', 'off');
             end

            % save out dataset
            set_name_out = sprintf('%s_%s', set_str_in, set_str_out); % doesn't contain '.set' file string
            fname_out = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_name_out);
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            EEG = pop_saveset(EEG, 'filename', fname_out, 'filepath', subj_anal_dir);
            eeglab redraw;

        end %iset

        subj_end = toc(subj_start);
        fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
        diary off;
    end %isub
end %iiter
