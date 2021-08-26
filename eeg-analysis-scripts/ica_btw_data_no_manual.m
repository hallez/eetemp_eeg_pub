% Script to remove ICA eyeblink components from data w/o the opportunity to
% review the components (to be used after 'ica_btw_data.m'.
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');
clc;
clear all;

config = eetemp_initialize;
subjects = config.subjects;

% loop  for different analysis types (e.g., ERPs, time-frequency)
analysis_types = {'erp'};
num_iter = length(analysis_types);
if config.TIME_FREQ_FLAG == 0
    fprintf('Just removing ICA components for ERPs, skipping for TF.\n')
    num_iter = 1;
end

for iiter = 1:num_iter
    % select if analyzing for ERPs or TF on current loop
    cur_anal = analysis_types{iiter};

    for isub = 1:length(subjects)
        subj_start = tic;
        subj_str = subjects{isub};
        subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);
        set_str_out = 'rmica';

        % print out info to a diary file
        diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s-%s_%s.txt', subj_str, set_str_out, upper(cur_anal), date));
        diary(diaryname);

        for iset = 1:config.num_blocks
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
                continue;
            end

            if ~exist(fullfile(subj_anal_dir, ica_fname_in), 'file')
                fprintf('%s does not exist.\n', ica_fname_in)
                continue;
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
            component_fpath = fullfile(config.analyzed_eeg_dir, subj_str, sprintf('%s_b%s_%s_BLINK_COMPONENTS.csv', subj_str, num2str(iset), upper(cur_anal)));

            if ~exist(component_fpath, 'file')
                fprintf('Component ids file %s does not exist. Skipping.\n', component_fpath)
                continue;
            end

            component_ids = csvread(component_fpath);

            if any(isnan(component_ids))
                fprintf('No eyeblink components.\n')
            else
                % remove eyeblink components from 0.1Hz data
                EEG = pop_subcomp(EEG, component_ids);
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

end % iiter
