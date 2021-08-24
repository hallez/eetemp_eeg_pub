% Script to lowpass filter on the 1Hz data filtered for ICA.
% This is both removing the 60Hz artifact and will smooth out the eventual
% ERPs
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
    set_str_out = sprintf('lpf%0.2g', config.lpf_cutoff);
    
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
        
        % low pass filter
        % there are no boundary events (b/c data hasn't been merged yet),
        % but this is the ERPLab default. Additionally, Luck recommendation
        % is to remove mean DC offset if have DC data (which I don't think
        % we do???) but also that it won't hurt if don't have DC data
        EEG  = pop_basicfilter( EEG,  1:70 , 'Boundary', 'boundary', 'Cutoff',  config.lpf_cutoff,...
            'Design', 'butter', 'Filter', 'lowpass', 'Order',  2, 'RemoveDC', 'on' );
    
        % save out dataset
        set_name_out = sprintf('%s_%s', set_str_in, set_str_out); % doesn't contain '.set' file string
        fname_out = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_name_out);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); 
        EEG = pop_saveset(EEG, 'filename', fname_out, 'filepath', subj_anal_dir);
        eeglab redraw;

    end % iset

    subj_end = toc(subj_start);
    fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
    diary off;
end
