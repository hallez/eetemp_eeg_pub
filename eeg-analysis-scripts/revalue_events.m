% Script to re-value EEG.event.type
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

    set_str_in = 'downsamp_electrode-ids';
    set_str_out = 'revalued-events';

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

        % re-value
        % based on `EditEEGEvents.m` from Max Bluestone (MemoLab)
        % start by setting up all of the possible events into an easy to index
        % variable (because cells are gross to deal w/)
        eventTypes = cell(0);
        eventTypes = cell2mat({EEG.event.type});

        for ievent = 1:length(config.events.code_vals)
            % figure out where in the EEG data the current event code of
            % interest is (i.e., the index or `ind`)
            ind = find(eventTypes==str2double(config.events.code_vals{ievent}));

            % count all events of given type
            % \\TODO: write these out to an easy-to-read format (.mat file?)
            event_count = size(ind,2);
            sprintf('There are %d %s events (trigger code %d).\n', event_count, config.events.code_meaning{ievent}, str2double(config.events.code_vals{ievent}))

            % loop through all of these indices and re-value them w/
            % something meaningful
            for iind = ind %here, no need to loop from 1:something b/c `ind` is a range of values
                EEG.event(iind).type = config.events.code_meaning{ievent};
            end %ind
        end %ievent

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
end
