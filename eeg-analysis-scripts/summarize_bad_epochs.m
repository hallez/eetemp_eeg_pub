close all;
fclose('all');
clc;
clear all;

config = eetemp_initialize;

summary = {'subject' 'block' 'badepochs'};
counter = 2;

% loop in case want to do multiple types of analyses (e.g., ERPs, time-frequency)
analysis_types = {'erp'};
num_iter = length(analysis_types);
if config.TIME_FREQ_FLAG == 0
    fprintf('Just ICA-ing for ERPs, skipping for TF.\n')
    num_iter = 1;
end

for iiter = 1:num_iter
    % select analysis type for current loop
    cur_anal = analysis_types{iiter};

    for isub=1:length(config.subjects)
        subj_str = config.subjects{isub};
        bare_id = strsplit(subj_str, 's');
        cur_subj = bare_id{2}; % just the id - no 's'

        if ismember(subj_str, config.exclude_subjects)
            fprintf('s%s is marked for exclusion. Skipping.\n', cur_subj);
            continue
        end

        fprintf('Working on subject %s.\n', subj_str)

        for iblock=1:config.num_blocks

            filename = fullfile(config.analyzed_eeg_dir, subj_str, sprintf('%s_b%s_%s-bad-epochs_loc%0.2g-glob%0.2g.mat', ...
                    subj_str, num2str(iblock), upper(cur_anal), config.local_threshold, config.global_threshold));

            if ~exist(filename,'file')
                fprintf('%s does not exist - skipping.\n', filename)
                continue;
            end

            % load 'removed_epoch_ids' variable
            load(filename);

            % convert to a cell for R formatting purposes
            removed_epoch_ids_cell = num2cell(removed_epoch_ids);

            % handle case where there are no removed channels
            if(isempty(removed_epoch_ids))
                removed_epoch_ids_cell = {'none'};
            end

            % loop through all bad channels, writing out one per row so that
            % can save out as a csv file. deal w/ multiple rows in R graphing
            % script
            for iepoch = 1:length(removed_epoch_ids_cell)
                summary(counter,1) = {cur_subj};
                summary(counter,2) = {iblock};
                % write each epoch out as its own row
                summary(counter,3) = {removed_epoch_ids_cell{iepoch}};
                counter = counter + 1;
            end

        end
    end

    outfile = fullfile(config.analyzed_eeg_dir, sprintf('bad_epochs_%s_summary_loc%0.2g-glob%0.2g.csv',...
    upper(cur_anal), config.local_threshold, config.global_threshold));
    cell2csv(outfile,summary);
end %iiter
