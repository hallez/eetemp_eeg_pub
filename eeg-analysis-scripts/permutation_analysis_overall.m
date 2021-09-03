% Script to perform cluster-based permutation test to compare Familiar with Correct Rejection ERP trials and Remember with Familiar ERP trials.
% This is the first step: reading the data, transforming it into
% FieldTrip-friendly structure, epoching and final preprocessing, and
% calculating ERPs. Based on:
% https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/.

close all;
fclose('all');  
clc;
clear all; 
    

% Initiate config file
config = eetemp_initialize;

% List of subjects
subjects = config.subjects;

% remove subjects who did not meet the trial count threshold 
load(fullfile(config.analyzed_eeg_dir, sprintf('exclude_subj_less-than-%d-rem-trials.mat', config.min_trials_thresh)));
load(fullfile(config.analyzed_eeg_dir, sprintf('exclude_subj_less-than-%d-fam-trials.mat', config.min_trials_thresh)));
rem_remove_idx = ismember(subjects, erp_rem_exclude_subjects);
fam_remove_idx = ismember(subjects, erp_fam_exclude_subjects);
all_remove_idx = rem_remove_idx + fam_remove_idx;
subjects = subjects(~all_remove_idx);


% Add path to FieldTrip folder (using command "addpath path_to_fieldtrip_folder;") and show path to data
path_data = fullfile(config.analyzed_eeg_dir);
filepath = '_eetemp_downsamp_electrode-ids_revalued-events_reref_hpf-0.1_erpep_removep-loc6-glob2_rmica_interpol_removep2_merged_rmbase.set';
ft_defaults;

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

% =========================================================================
% This is the second step: defining the neighbours (the channels which are
% close to each other and that's why signals measured at those sites are
% correlated). This is the basic assumption of the cluster-based test.

cfg_neighb        = [];
cfg_neighb.method = 'template';
cfg.template      = 'biosemi64_neighb.mat';
cfg.layout        = 'biosemi64new.lay';
neighbours        = ft_prepare_neighbours(cfg_neighb, dataCR);

cfg.neighbours    = neighbours;  % the neighbours specify for each sensor with
                                 % which other sensors it can form clusters
cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
cfg.latency       = [0 0.8];       % time interval over which the experimental
                                 % conditions must be compared (in seconds)



                                 
% =========================================================================
% This is the third step: configuring the parameters of cluster-based permutation test. 


cfg = [];
cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
cfg.latency = [0 0.7];

% Method used to calculate the significance probability.
cfg.method = 'montecarlo';  
cfg.statistic = 'depsamplesT'; 

% Test statistic used to solve the MCP (multi comparison problem).
cfg.correctm = 'cluster';      

% To choose the critical value that will be used for thresholding the sample-specific T-statistics.
cfg.clusteralpha = 0.05; 

% To choose the test statistic that will be evaluated under the permutation distribution. 
cfg.clusterstatistic = 'maxsum';  
cfg.clusterthreshold = 'nonparametric_common';

% To specify the minimum number of neighborhood channels that is required for a selected sample 
% (i.e., a sample who's T-value exceeds the threshold) to be included in
% the clustering algorithm.
cfg.minnbchan = 2;

% Neighbours specified in the second step.
cfg.neighbours = neighbours;

% One-sided or a two-sided statistical test.
cfg.tail = 0;
cfg.clustertail = 0;
cfg.correcttail      = 'alpha';

% To control the false alarm rate of the permutation test (the probability
% of falsely rejecting the null hypothesis). 
cfg.alpha = 0.05;

% To control the number of draws from the permutation distribution.
cfg.numrandomization = 1000;

% Define number or subjects and set the design.
subj = length(subjects);
design = zeros(2,2*subj);
for i = 1:subj
design(1,i) = i;
end
for i = 1:subj
design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design = design;
cfg.uvar  = 1;
cfg.ivar  = 2;


% =========================================================================
% This is the forth step: stat outputs for familiarity and recollection ERP
% comparisons: FAMvsCR and REMvsFAM ERP trials and calculating grand averages.

% Has to change version of spm to spm12, because of an error with loading
% mexmaci64 library under spm8.
cfg.spmversion='spm12';

[stat_FAMvsCR_38subjs] = ft_timelockstatistics(cfg, alltimelockFAM{:}, alltimelockCR{:});
save(fullfile('filepath', 'stat_FAMvsCR_38subjs.mat'), 'stat_FAMvsCR_38subjs');

[stat_REMvsFAM_38subjs] = ft_timelockstatistics(cfg, alltimelockREM{:}, alltimelockFAM{:});
save(fullfile('filepath', 'stat_REMvsFAM_38subjs.mat'), 'stat_REMvsFAM_38subjs');


% Calculate the grand averages for each condition.
cfg = [];
cfg.channel   = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
cfg.latency   = 'all';
cfg.parameter = 'avg';
GA_CR         = ft_timelockgrandaverage(cfg,alltimelockCR{:});
GA_FAM        = ft_timelockgrandaverage(cfg,alltimelockFAM{:});
GA_REM        = ft_timelockgrandaverage(cfg,alltimelockREM{:});
% "{:}" means to use data from all elements of the variable.