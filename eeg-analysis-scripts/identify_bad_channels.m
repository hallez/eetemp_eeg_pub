% Script to remove bad channels. Recommended by Makoto.
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');  
clc;
clear all;

config = eetemp_initialize;
subjects = config.subjects;

for isub = 1:length(subjects)
    subj_start = tic;
    subj_str = subjects{isub};
    subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);
    
    set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-ica-%0.2g', config.hpf_ica_cutoff);
    set_str_out = sprintf('no-bad-chan-lowSD-%0.2g_highSD-%2g', config.channel_lower_SD, config.channel_upper_SD);
    
    % print out info to a diary file
    diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s_%s.txt', subj_str, set_str_out, date)); 
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
        chanlocs = origEEG.chanlocs;
        
        % remove external channels b/c don't care if these are considered
        % for outlier removal
        exg_lbls = {'M1', 'M2', 'LHEOG', 'RHEOG', 'VEOG', 'UVEOG'};
        EEG_no_exg = pop_select(origEEG, 'nochannel', exg_lbls);
        
        % trimOutlier wiki: https://sccn.ucsd.edu/wiki/TrimOutlier
        % trimOutlier(EEG, SD lower bound [Makoto recommends 2 microvolts
        % to identify "dead" channels), SD upper bound [here, depends on
        % what percentage of the data you're willing to discard; can
        % visually inspect and create an average across all data, but
        % starting w/ Makoto default of 200], amplitude threshold [this is
        % if you're trying to use this to also reject timepoints, which I'm
        % not so just using Makoto default of 300 microvolts], point spread
        % [range in which to look for these amplitudes; again, I'm using
        % Makoto default of 1second just so this will run but I'm not
        % actually using this to clean the data]
        EEG_filt = trimOutlier(EEG_no_exg, config.channel_lower_SD, config.channel_upper_SD, config.amp_thresh, config.point_spread);
        num_bad_channels = size(EEG_no_exg.chanlocs,2) - size(EEG_filt.chanlocs,2);
        chan_idx = ismember({EEG_no_exg.chanlocs.labels}, {EEG_filt.chanlocs.labels});
        removed_chan_ids = {EEG_no_exg.chanlocs(~chan_idx).labels};
        
        % save out bad channel info, but don't actually remove here b/c it
        % will mess up the channel indices - we will remove these channels
        % later when we interpolate
        fprintf('clean_rawdata identified %d bad channels.\n', num_bad_channels)
        save(fullfile(subj_anal_dir, sprintf('%s_b%s_bad-channels_lowSD-%0.2g_highSD-%2g.mat', subj_str, num2str(iset), config.channel_lower_SD, config.channel_upper_SD)),...
            'num_bad_channels', 'removed_chan_ids');
        cell2csv(fullfile(subj_anal_dir, sprintf('%s_b%s_bad-channels_lowSD-%0.2g_highSD-%2g.txt', subj_str, num2str(iset), config.channel_lower_SD, config.channel_upper_SD)),...
            removed_chan_ids);
        
        % no need to save out a newdata set b/c didn't make any changes
        
    end %iset
       
    subj_end = toc(subj_start);
    fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
    diary off;
end