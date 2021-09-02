% Script to remove bad sections (epochs) of data prior to ICA. Also writes
% out epochs so can remove from the data.
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');  
clc;
clear all;

config = eetemp_initialize;
subjects = config.subjects;

% loop to do for both ERPs and TF
analysis_types = {'erp', 'tf'};
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

        set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-ica-%0.2g_%sep',...
            config.hpf_ica_cutoff, cur_anal);    
        set_str_out = sprintf('removep-loc%0.2g-glob%0.2g', config.local_threshold, config.global_threshold);

        % print out info to a diary file
        diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s_%s_%s.txt',...
            subj_str, upper(cur_anal), set_str_out, date)); 
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

            % use 'pop_jointprob' to detect unlikely segments of data
            origEEG = EEG; % make sure have original data in case need to compare
            % pop_jointprob(input data, type of rejection [1 = electrodes, 0 = components],...
            % data to consider [electrodes or components], single channel threshold,...
            % overall channel threshold, what to do w/ rejection marks [1 = show new and old, 0 = just new],...
            % what to do w/ marked segments [0 = don't reject, 1 = reject)
            epochidsEEG = pop_jointprob(EEG, 1, [1:EEG.nbchan], config.local_threshold, config.global_threshold, 1, 0);

            % number of segments rejected
            if(sum(epochidsEEG.reject.rejjp) == 0)
                fprintf('No epochs removed - same number before/after rejection.\n')
                removed_epoch_ids = [];
            else
                removed_epoch_ids = find(epochidsEEG.reject.rejjp); 
            end

            save(fullfile(subj_anal_dir, sprintf('%s_b%s_%s-bad-epochs_loc%0.2g-glob%0.2g.mat', ...
                subj_str, num2str(iset), upper(cur_anal), config.local_threshold, config.global_threshold)),...
                'removed_epoch_ids');
            csvwrite(fullfile(subj_anal_dir, sprintf('%s_b%s_%s-bad-epochs_loc%0.2g-glob%0.2g.txt', ...
                subj_str, num2str(iset), upper(cur_anal), config.local_threshold, config.global_threshold)),...
                removed_epoch_ids);

            % now actually remove the epochs - we do this in two stages so that
            % can figure out which epochs get rejected (and write out this
            % information) and then also to actualy remove them
            EEG = pop_jointprob(EEG, 1, [1:EEG.nbchan], config.local_threshold, config.global_threshold, 1, 1);

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