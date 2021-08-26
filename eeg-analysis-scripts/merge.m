% Script to merge `.set` file for all blocks
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
    fprintf('Just merging blocks for ERPs, skipping for TF.\n')
    num_iter = 1;
end

for iiter = 1:num_iter
    % select if analyzing for ERPs or TF on current loop
    cur_anal = analysis_types{iiter};

    for isub =  1:length(subjects)
        subj_start = tic;
        subj_str = subjects{isub};
        subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);

        set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g_%sep_removep-loc%0.2g-glob%0.2g_rmica_interpol_removep2',...
                            config.hpf_cutoff, cur_anal, config.local_threshold, config.global_threshold);
        set_str_out = 'merged';

        % print out info to a diary file
        diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s-%s_%s.txt', subj_str, set_str_out, upper(cur_anal), date));
        diary(diaryname);

        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab

        if ismember(subj_str, {'s234', 's237'})
            % actually dropping block 4, but since the input file for block
            % 4 does not exist, there are only 5 blocks that get loaded, so
            % cannot use [1 2 3 5 6] because will get an indexing error
            blocks_to_merge = [1 2 3 4 5];
        else
            blocks_to_merge = [1 2 3 4 5 6];
        end

        % read in all of the data across blocks
        for iset = 1:config.num_blocks
            fname_in = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_str_in);

            if ~exist(fullfile(subj_anal_dir, fname_in), 'file')
                fprintf('%s does not exist - continuing.\n', fname_in)
                continue;
            end

            EEG = pop_loadset('filename', fname_in,'filepath', subj_anal_dir); % load in dataset

            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            EEG = eeg_checkset( EEG );

            eeglab redraw;

        end %iset

        if(isempty(ALLEEG))
            fprintf('No files to merge for %s - continuing.\n', subj_str)
            continue;
        end

        mergedEEG = pop_mergeset( ALLEEG, blocks_to_merge, 0);

        % save out dataset
        set_name_out = sprintf('%s_%s', set_str_in, set_str_out); % doesn't contain '.set' file string
        fname_out = sprintf('%s_eetemp_%s.set', subj_str, set_name_out); % no longer include block ID b/c it's merged
        EEG = pop_saveset(mergedEEG, 'filename', fname_out, 'filepath', subj_anal_dir);
        eeglab redraw;

        % be super cautious and clear out the sets between subjects
        clear ALLEEG EEG mergedEEG

        subj_end = toc(subj_start);
        fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
        diary off;
    end

end %iiter
