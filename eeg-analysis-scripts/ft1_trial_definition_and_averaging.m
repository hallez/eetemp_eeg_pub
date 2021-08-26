% Script to perform cluster-based permutation test on ERPs.
% This is the first step: reading the data, trasforming it into
% FieldTrip-friendly structure, epoching and final preprocessing, and
% calculating ERPs.

clear
close all
clc

% initialize fieldtrip and show path to data
addpath /Users/karinamaciejewska/Documents/MATLAB/fieldtrip-20190618;
path_data = '/Users/karinamaciejewska/Documents/eetemp/analyzed-eeg/';
ft_defaults;

% List of subjects
subjects = {'s203', 's204', 's205', 's206', 's207', 's208', 's210', 's211', 's212', 's213', 's214', 's218', 's219', 's221', 's223', 's224', 's226', 's227', 's228', 's229', 's230', 's231', 's232', 's233', 's234', 's235', 's236', 's237', 's240', 's241', 's242', 's243', 's244', 's245', 's246', 's247', 's250'};


% DATA EPOCHING AND GENERAL PREPROCESSING
tic 
 
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    dataset  = fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set'));
    
    % This reads in all the information from EEGLAB dataset so that
    % FieldTrip knows what is where
    hdr = ft_read_header(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')));
    data = ft_read_data(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')), 'header', hdr ); 
    events = ft_read_event(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')), 'header', hdr );
    
    
    % In this step the epochs-of-interest are defined using ft_definetrials
    % function. Eventtype and eventvalue must be properly assigned. If we
    % don't know which event types and values there are in the data, we can
    % check it using this code:
    % cfg         = [];
    % cfg.dataset = 'path-to-file';
    % cfg.trialdef.eventtype = '?';
    %ft_definetrials(cfg);
    
    cfg           = [];
    cfg.dataset   = dataset;
    cfg.trialfun  = 'ft_trialfun_general'; 
    cfg.trialdef.eventtype = 'trigger';
    
    % This loop is because for some subjects the event values are strings and for other
    % they are numbers.
    % Reading in the CR events.
    if ismember(204, [events.value])
        cfg.trialdef.eventvalue = 204;
    else
        cfg.trialdef.eventvalue = '204';
    end
    cfg.trialdef.prestim    = 0.2;
    cfg.trialdef.poststim   = 1;
    cfg           = ft_definetrial(cfg);
 
    
    % In this step the data is read from file, and basic preprocessing is applied
    cfg.channel    = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
    
    % These are commented out because our data is already rereferenced and baseline corrected.
    %cfg.reref      = 'yes';
    %cfg.refchannel = 'all';
    %cfg.demean     = 'yes';
    %cfg.baselinewindow  = [-0.2 0];
    cfg.lpfilter   = 'yes';  % apply lowpass filter
    cfg.lpfreq     = 20;
    dataCR = ft_preprocessing(cfg);
    save(fullfile(datapath, 'dataCR.mat'), 'dataCR');
end
toc

% ===The same step for FAM trials.===
% DATA EPOCHING AND GENERAL PREPROCESSING
tic
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    dataset  = fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set'));
    
    hdr = ft_read_header(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')));
    data = ft_read_data(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')), 'header', hdr ); 
    events = ft_read_event(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')), 'header', hdr );
    
    cfg           = [];
    cfg.dataset   = dataset;
    cfg.trialfun  = 'ft_trialfun_general'; 
    cfg.trialdef.eventtype = 'trigger';
    
    % Reading in the FAM events.
    if ismember(212, [events.value])
        cfg.trialdef.eventvalue = 212;
    else
        cfg.trialdef.eventvalue = '212';
    end
    cfg.trialdef.prestim    = 0.2;
    cfg.trialdef.poststim   = 1;
    cfg           = ft_definetrial(cfg);
     
    cfg.channel    = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
    
    %cfg.reref      = 'yes';
    %cfg.refchannel = 'all';
    %cfg.demean     = 'yes';
    %cfg.baselinewindow  = [-0.2 0];
    cfg.lpfilter   = 'yes';  % apply lowpass filter
    cfg.lpfreq     = 20;
    dataFAM = ft_preprocessing(cfg);
    save(fullfile(datapath, 'dataFAM.mat'), 'dataFAM');
end
toc


% ===The same step for REM trials.===
% DATA EPOCHING AND GENERAL PREPROCESSING
tic 

for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    dataset  = fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set'));
    
    hdr = ft_read_header(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')));
    data = ft_read_data(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')), 'header', hdr ); 
    events = ft_read_event(fullfile(datapath, strcat(subjects{i},'_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set')), 'header', hdr );
    
    cfg           = [];
    cfg.dataset   = dataset;
    cfg.trialfun  = 'ft_trialfun_general'; 
    cfg.trialdef.eventtype = 'trigger';

    % Reading in the REM events.
    if ismember(211, [events.value])
        cfg.trialdef.eventvalue = 211;
    else
        cfg.trialdef.eventvalue = '211';
    end
    cfg.trialdef.prestim    = 0.2;
    cfg.trialdef.poststim   = 1;
    cfg           = ft_definetrial(cfg);

    cfg.channel    = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
    %cfg.reref      = 'yes';
    %cfg.refchannel = 'all';
    %cfg.demean     = 'yes';
    %cfg.baselinewindow  = [-0.2 0];
    cfg.lpfilter   = 'yes';  % apply lowpass filter
    cfg.lpfreq     = 20;
    dataREM = ft_preprocessing(cfg);
    save(fullfile(datapath, 'dataREM.mat'), 'dataREM');
end
toc


% COMPUTATION OF EVENT-RELATED POTENTIALS
tic
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    datafile = fullfile(datapath, 'dataCR.mat');
      
    load(datafile);
    
    % Average across trials.
    cfg         = [];
    cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
    %cfg.keeptrials = 'yes';
    
    % Compute ERPs for every subject timelocked to CR trials.
    timelockCR = ft_timelockanalysis(cfg,dataCR);
    save(fullfile(datapath, 'timelockCR.mat'), 'timelockCR');
end

% Load single subject ERPs of CR trials in a single cell array.
alltimelockCR = cell(1,length(subjects));
for i=1:length(subjects)
    datapath     = strcat(path_data, subjects{i});
    datafile     = fullfile(datapath, 'timelockCR.mat');
    load(datafile);
    alltimelockCR{i} = timelockCR;
end
toc

% COMPUTATION OF EVENT-RELATED POTENTIALS
% ===The same step for FAM trials.===
tic
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    datafile = fullfile(datapath, 'dataFAM.mat');
      
    load(datafile);
    
    % Average across trials.
    cfg         = [];
    cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
    %cfg.keeptrials = 'yes';
    
    % Compute ERPs for every subject timelocked to FAM trials.
    timelockFAM = ft_timelockanalysis(cfg,dataFAM);
    save(fullfile(datapath, 'timelockFAM.mat'), 'timelockFAM');
end

% Load single subject ERPs of FAM trials in a single cell array.
alltimelockFAM = cell(1,length(subjects));
for i=1:length(subjects)
    datapath     = strcat(path_data, subjects{i});
    datafile     = fullfile(datapath, 'timelockFAM.mat');
    load(datafile);
    alltimelockFAM{i} = timelockFAM;
end
toc


% COMPUTATION OF EVENT-RELATED POTENTIALS
% ===The same step for REM trials.===
tic
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    datafile = fullfile(datapath, 'dataREM.mat');
      
    load(datafile);
    
    % Average across trials.
    cfg         = [];
    cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
    %cfg.keeptrials = 'yes';
    
    % Compute ERPs for every subject timelocked to REM trials.
    timelockREM = ft_timelockanalysis(cfg,dataREM);
    save(fullfile(datapath, 'timelockREM.mat'), 'timelockREM');
end

% Load single subject ERPs of REM trials in a single cell array.
alltimelockREM = cell(1,length(subjects));
for i=1:length(subjects)
    datapath     = strcat(path_data, subjects{i});
    datafile     = fullfile(datapath, 'timelockREM.mat');
    load(datafile);
    alltimelockREM{i} = timelockREM;
end
toc





