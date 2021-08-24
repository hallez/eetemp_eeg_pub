close all;
fclose('all');  
clc;
clear all;

config = eetemp_initialize;

summary = {'subject' 'block' 'totalnumbadchans' 'badid'};
counter = 2;

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
       
        filename = fullfile(config.analyzed_eeg_dir, subj_str, sprintf('%s_b%s_bad-channels_lowSD-%0.2g_highSD-%2g.mat', subj_str, num2str(iblock), config.channel_lower_SD, config.channel_upper_SD));
        
        if ~exist(filename,'file')
            fprintf('%s does not exist - skipping.\n', filename)
            continue;
        end
        
        load(filename); % loads cell array
        
        % handle case where there are no removed channels
        if(isempty(removed_chan_ids))
            removed_chan_ids = {'none'};
        end
        
        % loop through all bad channels, writing out one per row so that
        % can save out as a csv file. deal w/ multiple rows in R graphing
        % script
        for ichan = 1:length(removed_chan_ids)
            summary(counter,1) = {cur_subj};
            summary(counter,2) = {iblock};
            summary(counter,3) = {num_bad_channels};
            summary(counter,4) = {removed_chan_ids{ichan}};
            counter = counter + 1;
        end
        
    end
end

outfile = fullfile(config.analyzed_eeg_dir, sprintf('bad_channels_summary_lowSD-%0.2g_highSD-%2g.csv', config.channel_lower_SD, config.channel_upper_SD));
cell2csv(outfile,summary);
