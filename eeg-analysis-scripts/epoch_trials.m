% Script to epoch for ERPs or TF for both ICA and standard analyses.
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
    fprintf('Just epoching for ERPs, skipping for TF.\n')
    num_iter = 1;
end

for iiter = 1:num_iter
    % select if analyzing for ERPs or TF on current loop
    cur_anal = analysis_types{iiter};

    % set ERP vs TF epoching info
    if strcmp(cur_anal, 'erp')
        event_code = 'item1_onset';
        epoch_min = config.erp_epoch_start; 
        epoch_max = config.erp_epoch_end;
    elseif strcmp(cur_anal, 'tf')
        event_code = 'item1_onset'; 
        epoch_min = config.tf_epoch_start;
        epoch_max = config.tf_epoch_end;
    else
        fprintf('No epoching information for current analysis type.\n')
        break;
    end
    
    fprintf('Epoching for %s. Epoch start: %g, epoch end: %g.\n',...
        upper(cur_anal), epoch_min, epoch_max)
    
    for iica = 1:2
        % it's arbitrary to do non-ICA then ICA epoching
        if iica == 1
            set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g',...
                config.hpf_cutoff);
            ica_var = 'no-ica';
        elseif iica == 2
            set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-ica-%0.2g',...
            config.hpf_ica_cutoff);
        ica_var = 'for-ica';
        end
        
        for isub = 1:length(subjects)
            subj_start = tic;
            subj_str = subjects{isub};
            subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);

            set_str_out = sprintf('%sep', cur_anal);

            % print out info to a diary file
            diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s_%s_%s.txt',...
                subj_str, set_str_out, ica_var, date)); 
            diary(diaryname);

            % load in behavioral data (this file is created by `analyze-behavior.R`)
            scored_behav_fname = fullfile(config.analyzed_behavioral_dir, 'experiment-summary', subj_str, sprintf('%s_scored_behavior.txt', subj_str));
            if ~exist(scored_behav_fname, 'file')
                fprintf('%s does not exist - skipping\n', scored_behav_fname) 
                continue;
            end
            cur_behavioral_data = readtable(scored_behav_fname); % this will give a warning about variable names being modified for MATLAB (seems to convert '.' to '_')

            [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab

            for iset = 1:config.num_blocks
                
                if(strcmp(subj_str,'s237') & iset==4)
                    fprintf('\nBlock %d is excluded for %s.\n\n',iset,subj_str)
                    continue;
                end
                
                fname_in = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_str_in);

                if ~exist(fullfile(subj_anal_dir, fname_in), 'file')
                    fprintf('%s does not exist - continuing.\n', fname_in)
                    continue;
                end

                EEG = pop_loadset('filename', fname_in,'filepath', subj_anal_dir); % load in dataset

                [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
                EEG = eeg_checkset( EEG );

                % epoch the data
                EEG = pop_epoch( EEG, {event_code}, [epoch_min epoch_max], 'newname', set_str_out, 'epochinfo', 'yes');  

                % add in behavioral information about each trial
                % based on `AddEEGInfo.m` from Max Bluestone
                % subset for current block, ensuring that still in the same order
                % as the trials ocurred at recog
                behav_filt = cur_behavioral_data(cur_behavioral_data.blockID == iset, :);
                block_behavioral_data = sortrows(behav_filt, 'global_item_recog_trial_number');

                % check that the behavioral data and the EEG data have the same number
                % of events
                num_behav_trials = size(block_behavioral_data,1);
                num_eeg_epochs = EEG.event(size(EEG.event,2)).epoch;

                if~(num_behav_trials == num_eeg_epochs)
                    fprintf('Number of %s epochs (%d) does not match behavioral trials (%d) - skipping.\n',...
                        cur_anal, num_eeg_epochs, num_behav_trials)
                    continue;
                end

                % create empty columns for new EEG event structure info
                [EEG.event(size(EEG.event,2)).encoding_list] = []; %encList
                [EEG.event(size(EEG.event,2)).encoding_question] = []; %encQuest
                [EEG.event(size(EEG.event,2)).item_recog_block] = []; %blockID
                [EEG.event(size(EEG.event,2)).item_recog_trial_id] = []; %trial_number_item_recog

                [EEG.event(size(EEG.event,2)).item_old_new] = []; %oldNew
                [EEG.event(size(EEG.event,2)).item_recog_resp] = []; %item_recog_resp
                [EEG.event(size(EEG.event,2)).item_recog_rt] = []; %item_recog_resp_rt
                [EEG.event(size(EEG.event,2)).item_recog_scored] = []; %itemScore
                [EEG.event(size(EEG.event,2)).item_recog_corr_incorr] = []; %item_corr_incorr

                [EEG.event(size(EEG.event,2)).item_conf_resp] = []; %item_conf_resp
                [EEG.event(size(EEG.event,2)).item_conf_rt] = []; %item_conf_rt (this is a better formatted version of `item_conf_response_rt`)

                [EEG.event(size(EEG.event,2)).item_source_scored] = []; %questionScore
                [EEG.event(size(EEG.event,2)).item_source_rt] = []; %quest_source_rt

                [EEG.event(size(EEG.event, 2)).event_label] = []; %because ERPLab requires numeric event labels, put the sensible one here

                % loop through each epoch and add trial information
                for itrial=1:num_behav_trials

                    % grab relevant epoch that corresponds to this trial
                    % because each epoch includes 2 `type` labels ('item1_onset' *and* 
                    % 'think_cue_onset'), need to be very specific about the index
                    cur_epoch_idx = find([EEG.event.epoch]==itrial & strcmp({EEG.event.type}, 'item1_onset'));

                    % insert this trial's information into EEG
                    EEG.event(cur_epoch_idx).encoding_list = block_behavioral_data.encList(itrial);
                    EEG.event(cur_epoch_idx).encoding_question = block_behavioral_data.encQuest(itrial);
                    EEG.event(cur_epoch_idx).item_recog_block = block_behavioral_data.blockID(itrial); 
                    EEG.event(cur_epoch_idx).item_recog_trial_id = block_behavioral_data.trial_number_item_recog(itrial); 

                    EEG.event(cur_epoch_idx).item_old_new = block_behavioral_data.oldNew(itrial); 
                    EEG.event(cur_epoch_idx).item_recog_resp = block_behavioral_data.item_recog_resp(itrial); 
                    EEG.event(cur_epoch_idx).item_recog_rt = block_behavioral_data.item_recog_resp_rt(itrial); 
                    EEG.event(cur_epoch_idx).item_recog_scored = block_behavioral_data.itemScore(itrial); 
                    EEG.event(cur_epoch_idx).item_recog_corr_incorr = block_behavioral_data.item_corr_incorr(itrial); 

                    EEG.event(cur_epoch_idx).item_conf_resp = block_behavioral_data.item_conf_resp(itrial); 
                    EEG.event(cur_epoch_idx).item_conf_rt = block_behavioral_data.item_conf_rt(itrial); 

                    EEG.event(cur_epoch_idx).item_source_scored = block_behavioral_data.questionScore(itrial); 
                    EEG.event(cur_epoch_idx).item_source_rt = block_behavioral_data.quest_source_rt(itrial); 

                    % re-label events w/ numeric codes to make ERPLab happy
                    % hundreds: trial type (2 = item1 onset; not using '1' as a starting numeral b/c these are in the actual trigger codes)
                    % tends: old/new (1 = old, 0 = new)
                    % ones: response (1 = Rec, 2 = Fam, 3 = F-FA, 4 = CR, 5 = Miss)
                    % TODO: figure out how to include source memory scoring
                    % in this b/c cannot exceed 255 w/ event codes (or is
                    % this just when sending trigger codes during data
                    % collection?)
                    EEG.event(cur_epoch_idx).event_label = EEG.event(cur_epoch_idx).type; % these are the sensible labels that were assigned in `revalue_events.m`
                    if(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'new') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'Rec'))
                        EEG.event(cur_epoch_idx).type = 201; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'new') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'Fam'))
                        EEG.event(cur_epoch_idx).type = 202; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'new') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'F-FA'))
                        EEG.event(cur_epoch_idx).type = 203; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'new') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'CR'))
                        EEG.event(cur_epoch_idx).type = 204; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'new') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'Miss'))
                        EEG.event(cur_epoch_idx).type = 205; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'old') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'Rec'))
                        EEG.event(cur_epoch_idx).type = 211; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'old') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'Fam'))
                        EEG.event(cur_epoch_idx).type = 212; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'old') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'F-FA'))
                        EEG.event(cur_epoch_idx).type = 213; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'old') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'CR'))
                        EEG.event(cur_epoch_idx).type = 214; 
                    elseif(strcmp(EEG.event(cur_epoch_idx).item_old_new, 'old') && strcmp(EEG.event(cur_epoch_idx).item_recog_scored, 'Miss'))
                        EEG.event(cur_epoch_idx).type = 215; 
                    end

                    % also need to re-label other text event codes so binlister is
                    % happy even though these won't be used in the current analysis
                    think_cue_idx = find([EEG.event.epoch]==itrial & strcmp({EEG.event.type}, 'think_cue_onset'));
                    EEG.event(think_cue_idx).event_label = EEG.event(think_cue_idx).type;
                    EEG.event(think_cue_idx).type = 11; % this is the code that all 'think_cue_onset' should have had (see `revalue_events.m`)
                end % itrial

                % count up trials of interest
                num_rec_trials = size(find([EEG.event.type] == 211),2);
                num_fam_trials = size(find([EEG.event.type] == 212),2);
                num_rem_source_hits = sum(ismember(find(strcmp([EEG.event.item_source_scored], 'correct')), find([EEG.event.type] == 211)));
                num_rem_source_miss = sum(ismember(find(strcmp([EEG.event.item_source_scored], 'incorrect')), find([EEG.event.type] == 211)));

                fprintf('Subject %s has %d recollected trials and %d familiar trials for %s before removal of epochs.\n',...
                    subj_str, num_rec_trials, num_fam_trials, upper(cur_anal))
                
                fprintf('Of the %d recollected trials %d are source hits and %d are source misses before removal of epochs.\n',...
                    num_rec_trials, num_rem_source_hits, num_rem_source_miss)

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
    end %iica
end %iiter

