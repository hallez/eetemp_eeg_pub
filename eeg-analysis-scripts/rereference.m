% Script to re-reference to linked mastoids.
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
    
    set_str_in = 'downsamp_electrode-ids_revalued-events';
    set_str_out = 'reref';
    
    % print out info to a diary file
    diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s_%s.txt', subj_str, set_str_out, date)); 
    diary(diaryname);
    
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab
    
    for iset = 1:config.num_blocks
        if(strcmp('s217', subj_str) && ((iset == 2) || (iset == 3)))
            fprintf('For %s %s overwrite input filename.\n', subj_str, num2str(iset))
            set_str_in = 'downsamp_electrode-ids_revalued-events-split';
        end 

        fname_in = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_str_in);

        if ~exist(fullfile(subj_anal_dir, fname_in), 'file')
            fprintf('%s does not exist - continuing.\n', fname_in)
            continue;
        end
        
        EEG = pop_loadset('filename', fname_in,'filepath', subj_anal_dir); % load in dataset

        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset( EEG );
        
        % re-reference to linked (average) mastoids (EXG1, EXG2) keeping 
        % them in the data. exclude other external channels
        EEG = pop_reref( EEG, [65 66] ,'exclude',[67:70] ,'keepref','on');
        
        % reset set_str_in so that the value does not propogate for the
        % rest of data processing 
        if(strcmp('s217', subj_str))
             set_str_in = 'downsamp_electrode-ids_revalued-events';
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
end