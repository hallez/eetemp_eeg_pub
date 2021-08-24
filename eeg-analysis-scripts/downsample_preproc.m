% Script to load in `.bdf` files and save downsampled `.set` files 
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
    bare_id = strsplit(subj_str, 's');
    cur_subj = bare_id{2}; % just the id - no 's'
    subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);
    
    set_str_out = 'downsamp';
    
    % print out info to a diary file
    diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s_%s.txt', subj_str, set_str_out, date)); 
    diary(diaryname);

    if ~isdir(subj_anal_dir)
        mkdir(subj_anal_dir);
    end
    
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab
    
    for iset = 1:config.num_blocks % loop across blocks
        filename = fullfile(config.raw_eeg_dir,cur_subj,sprintf('eetemp_%s_block%s.bdf', cur_subj, num2str(iset))); 
        if ~exist(filename, 'file')
            fprintf('%s does not exist - skipping\n', filename) 
            continue;
        end
        
        % NB: this will spit out warnings about V/S, mHg, etc. being obsolete - ignore
        % seems to happen only the first time that `pop_biosig` is called
        %
        % only load in channels 1:70 - this is the 64 channels of data plus
        % the additional 6 external channels (mastoids [2], VEOG [2], and
        % HEOG [2])
        EEG = pop_biosig(filename, 'channels', 1:70);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off'); 
        
        % downsample the data to reduce the filesize. also, since we're not
        % interested in looking at anything that's very high frequency no
        % need to be worried about aliasing if downsample. this includes an
        % anti-aliasing filter so should be OK.
        EEG = pop_resample(EEG, 128);
                
        % save out into eeglab filetypes (.set, .fdt)
        EEG = eeg_checkset( EEG );
        fname_out = sprintf('%s_eetemp_b%s_%s.set', subj_str, num2str(iset), set_str_out);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); 
        EEG = pop_saveset(EEG, 'filename', fname_out, 'filepath', subj_anal_dir);
        eeglab redraw; % this updates the GUI w/ any new info about the data
    end

    subj_end = toc(subj_start);
    fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
    diary off;
end