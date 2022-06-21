% Script to perform cluster-based permutation test to correlate ERPs with behavioral results.
% This is the first step: reading the data, transforming it into
% FieldTrip-friendly structure, epoching and final preprocessing, and
% calculating ERPs. Based on:
% https://www.fieldtriptoolbox.org/faq/how_can_i_test_for_correlations_between_neuronal_data_and_quantitative_stimulus_and_behavioural_variables/.


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
    dataset  = fullfile(datapath, strcat(subjects{i}, filepath));
    
    % This reads in all the information from EEGLAB dataset so that
    % FieldTrip knows what is where
    hdr = ft_read_header(fullfile(datapath, strcat(subjects{i}, filepath)));
    data = ft_read_data(fullfile(datapath, strcat(subjects{i}, filepath)), 'header', hdr ); 
    events = ft_read_event(fullfile(datapath, strcat(subjects{i}, filepath)), 'header', hdr );
    
    
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select a subsample of trials from a dataset to equalize the number of trials (N=30 since this is the lowest number of trials in our data). 
    % Based on: https://github.com/natmegsweden/NatMEG_Wiki/wiki/Select-limited-number-of-trials-in-FieldTrip
    
    % Number of trials in data
    nTrials_CR = length(dataCR.trial);

    % Select in steps
    ii_CR=0; 
        ii_CR = ii_CR+1;
        idx_CR = zeros(nTrials_CR, 1);
        idx_CR(1:30) = 1;
        idx_CR = logical(idx_CR(randperm(length(idx_CR))));
    
        cfg = [];
        cfg.trials = idx_CR;
        dat_nRand_CR{ii_CR} = ft_selectdata(cfg, dataCR);
        save(fullfile(datapath, 'dat_nRand_CR.mat'), 'dat_nRand_CR');
end
toc

% ===The same step for FAM trials.===
% DATA EPOCHING AND GENERAL PREPROCESSING
tic
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    dataset  = fullfile(datapath, strcat(subjects{i}, filepath));
    
    hdr = ft_read_header(fullfile(datapath, strcat(subjects{i}, filepath)));
    data = ft_read_data(fullfile(datapath, strcat(subjects{i}, filepath)), 'header', hdr ); 
    events = ft_read_event(fullfile(datapath, strcat(subjects{i}, filepath)), 'header', hdr );
    
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select a subsample of trials from a dataset to equalize the number of trials (N=30 since this is the lowest number of trials in our data). 
    % Based on: https://github.com/natmegsweden/NatMEG_Wiki/wiki/Select-limited-number-of-trials-in-FieldTrip
    
    % Number of trials in data
    nTrials_FAM = length(dataFAM.trial);

    % Select in steps
    ii_FAM=0; 
        ii_FAM = ii_FAM+1;
        idx_FAM = zeros(nTrials_FAM, 1);
        idx_FAM(1:30) = 1;
        idx_FAM = logical(idx_FAM(randperm(length(idx_FAM))));
    
        cfg = [];
        cfg.trials = idx_FAM;
        dat_nRand_FAM{ii_FAM} = ft_selectdata(cfg, dataFAM);
        save(fullfile(datapath, 'dat_nRand_FAM.mat'), 'dat_nRand_FAM');
end
toc


% ===The same step for REM trials.===
% DATA EPOCHING AND GENERAL PREPROCESSING
tic 

for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    dataset  = fullfile(datapath, strcat(subjects{i}, filepath));
    
    hdr = ft_read_header(fullfile(datapath, strcat(subjects{i}, filepath)));
    data = ft_read_data(fullfile(datapath, strcat(subjects{i}, filepath)), 'header', hdr ); 
    events = ft_read_event(fullfile(datapath, strcat(subjects{i}, filepath)), 'header', hdr );
    
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select a subsample of trials from a dataset to equalize the number of trials (N=30 since this is the lowest number of trials in our data). 
    % Based on: https://github.com/natmegsweden/NatMEG_Wiki/wiki/Select-limited-number-of-trials-in-FieldTrip
    
    % Number of trials in data
    nTrials_REM = length(dataREM.trial);

    % Select in steps
    ii_REM=0; 
        ii_REM = ii_REM+1;
        idx_REM = zeros(nTrials_REM, 1);
        idx_REM(1:30) = 1;
        idx_REM = logical(idx_REM(randperm(length(idx_REM))));
    
        cfg = [];
        cfg.trials = idx_REM;
        dat_nRand_REM{ii_REM} = ft_selectdata(cfg, dataREM);
        save(fullfile(datapath, 'dat_nRand_REM.mat'), 'dat_nRand_REM');
end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTATION OF EVENT-RELATED POTENTIALS
tic
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    datafile = fullfile(datapath, 'dat_nRand_CR.mat');
      
    load(datafile);
    
    % Average across trials.
    cfg         = [];
    cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
    
    % Average
    for ii_CR = 1:length(dat_nRand_CR)
        cfg = [];
        dat_nRand_avg_CR{ii_CR} = ft_timelockanalysis(cfg, dat_nRand_CR{ii_CR});
    end
    timelockCR_nRand = dat_nRand_avg_CR{1,1}
    save(fullfile(datapath, 'timelockCR_nRand.mat'), 'timelockCR_nRand');
end

% Load single subject ERPs of CR trials in a single cell array.
alltimelockCR_nRand = cell(1,length(subjects));
for i=1:length(subjects)
    datapath     = strcat(path_data, subjects{i});
    datafile     = fullfile(datapath, 'timelockCR_nRand.mat');
    load(datafile);
    alltimelockCR_nRand{i} = timelockCR_nRand;
end
toc

% COMPUTATION OF EVENT-RELATED POTENTIALS
% ===The same step for FAM trials.===
tic
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    datafile = fullfile(datapath, 'dat_nRand_FAM.mat');
      
    load(datafile);
    
    % Average across trials.
    cfg         = [];
    cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
    
    % Average
    for ii_FAM = 1:length(dat_nRand_FAM)
        cfg = [];
        dat_nRand_avg_FAM{ii_FAM} = ft_timelockanalysis(cfg, dat_nRand_FAM{ii_FAM});
    end
    timelockFAM_nRand = dat_nRand_avg_FAM{1,1}
    save(fullfile(datapath, 'timelockFAM_nRand.mat'), 'timelockFAM_nRand');
end

% Load single subject ERPs of FAM trials in a single cell array.
alltimelockFAM_nRand = cell(1,length(subjects));
for i=1:length(subjects)
    datapath     = strcat(path_data, subjects{i});
    datafile     = fullfile(datapath, 'timelockFAM_nRand.mat');
    load(datafile);
    alltimelockFAM_nRand{i} = timelockFAM_nRand;
end
toc


% COMPUTATION OF EVENT-RELATED POTENTIALS
% ===The same step for REM trials.===
tic
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    datafile = fullfile(datapath, 'dat_nRand_REM.mat');
      
    load(datafile);
    
    % Average across trials.
    cfg         = [];
    cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};

    % Average
    for ii_REM = 1:length(dat_nRand_REM)
        cfg = [];
        dat_nRand_avg_REM{ii_REM} = ft_timelockanalysis(cfg, dat_nRand_REM{ii_REM});
    end
    timelockREM_nRand = dat_nRand_avg_REM{1,1}
    save(fullfile(datapath, 'timelockREM_nRand.mat'), 'timelockREM_nRand');
end

% Load single subject ERPs of REM trials in a single cell array.
alltimelockREM_nRand = cell(1,length(subjects));
for i=1:length(subjects)
    datapath     = strcat(path_data, subjects{i});
    datafile     = fullfile(datapath, 'timelockREM_nRand.mat');
    load(datafile);
    alltimelockREM_nRand{i} = timelockREM_nRand;
end
toc


% =========================================================================
% Calculating difference waveforms
for i=1:length(subjects)
    datapath = strcat(path_data, subjects{i});
    datafileCR_nRand = fullfile(datapath, 'timelockCR_nRand.mat');
    datafileFAM_nRand = fullfile(datapath, 'timelockFAM_nRand.mat');
    datafileREM_nRand = fullfile(datapath, 'timelockREM_nRand.mat');
      
    load(datafileCR_nRand);
    load(datafileFAM_nRand);
    load(datafileREM_nRand);
    
    cfg = [];
    cfg.operation = 'subtract';
    cfg.parameter = 'avg';
    diffFAMvsCR_nRand = ft_math(cfg, timelockFAM_nRand, timelockCR_nRand);
    diffREMvsFAM_nRand = ft_math(cfg, timelockREM_nRand, timelockFAM_nRand);
    
    save(fullfile(datapath, 'diffFAMvsCR_nRand.mat'), 'diffFAMvsCR_nRand');
    save(fullfile(datapath, 'diffREMvsFAM_nRand.mat'), 'diffREMvsFAM_nRand');
end


% Load single subject ERP difference waveforms of FAM-CR, REM-CR and REM-FAM conditions in a single cell array.
all_diff_FAMvsCR_nRand = cell(1,length(subjects));
for i=1:length(subjects)
    datapath     = strcat(path_data, subjects{i});
    datafile     = fullfile(datapath, 'diffFAMvsCR_nRand.mat');
    load(datafile);
    all_diff_FAMvsCR_nRand{i} = diffFAMvsCR_nRand;
end

all_diff_REMvsFAM_nRand = cell(1,length(subjects));
for i=1:length(subjects)
    datapath     = strcat(path_data, subjects{i});
    datafile     = fullfile(datapath, 'diffREMvsFAM_nRand.mat');
    load(datafile);
    all_diff_REMvsFAM_nRand{i} = diffREMvsFAM_nRand;
end



% =========================================================================
% This is the second step: defining the neighbours (the channels which are
% close to each other and that's why signals measured at those sites are
% correlated).

cfg_neighb        = [];
cfg_neighb.method = 'template'; 
cfg.template      = 'biosemi64_neighb.mat';
cfg.layout        = 'biosemi64new.lay';
neighbours        = ft_prepare_neighbours(cfg_neighb, dataCR);
cfg.feedback      = 'yes';

cfg.neighbours    = neighbours;  % the neighbours specify for each sensor with
                                 % which other sensors it can form clusters
cfg.channel       = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};     % cell-array with selected channel labels
cfg.latency       = [0 0.7];       % time interval over which the experimental
                                 % conditions must be compared (in seconds)
                                 
                              
                                                     
% =========================================================================
% This is the third step: configuring the parameters of cluster-based permutation test. 

cfg = [];
cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
cfg.latency = [0 0.7];

% Method used to calculate the significance probability.
cfg.method = 'montecarlo';  

cfg.statistic = 'ft_statfun_correlationT';
cfg.type      = 'Pearson';
cfg.computecritval = 'yes';

% Test statistic used to solve the MCP (multi comparison problem).
cfg.correctm = 'cluster';      

% To choose the critical value that will be used for thresholding the sample-specific T-statistics.
cfg.clusteralpha = 0.05; 

% To choose the test statistic that will be evaluated under the permutation distribution. This is recommended in the
% FieldTrip tutorial.
cfg.clusterstatistic = 'maxsum'; 
cfg.clusterthreshold = 'nonparametric_common';

% To specify the minimum number of neighborhood channels that is required for a selected sample 
% (i.e., a sample who's T-value exceeds the threshold) to be included in
% the clustering algorithm.
cfg.minnbchan = 2;

% Neighbours specified in the second step.
cfg.neighbours = neighbours;

% One-sided or a two-sided statistical test (Here: two-sided).
cfg.tail = 0;
cfg.clustertail = 0;
cfg.correcttail      = 'alpha';

% To control the false alarm rate of the permutation test (the probability
% of falsely rejecting the null hypothesis). 
cfg.alpha = 0.05;

% To control the number of draws from the permutation distribution. Usually
% not less than 1000.
cfg.numrandomization = 1000;

% Define number or subjects and set the design.
subj = length(subjects);


% Take behavioral dual process estimates of familiarity and recollection
% from 'behav_all_counts' generated by 'analyze-behavior.R' script.

% When corellating ERPs with familiarity behavioral estimates. 
%design(1,1:subj)       = [0.5223776, 0.2975243	0.3339869 0.4665033	0.5123117	0.2557471	0.5453256	0.55	0.5057118	0.5409241	0.6104127 0.1451117	0.2052093	0.4679443	0.7772727	0.5248918	0.54677	0.6722222	0.5864198	0.4622093	0.256018	0.2342857	0.4467172	0.3836124	0.4303587	0.5617978	0.4359173	0.6350252	0.2739726 0.2816993	0.7111111	0.340404	0.4574111	0.4192599	0.3972691	0.2885802	0.4976373 0.3561521];

% When corellating ERPs with recollection behavioral estimates.
design(1,1:subj)       = [0.2055555 0.3888889	0.4333333	0.25	0.4666667	0.3555556	0.4166667	0.4222222	0.5611111	0.4388889	0.4277778 0.25	0.5888889	0.55	0.3111111	0.5111111	0.2833333	0.6666667	0.55	0.4666667	0.3222222	0.5166667	0.5111111	0.45	0.2944444	0.4944444	0.2833333	0.6666667	0.4866667 0.5444444	0.5555556	0.3888889	0.5388889	0.5888889	0.5055556	0.5	0.4166667 0.1722222];


cfg.design   = design;
cfg.ivar     = 1;


% =========================================================================
% This is the forth step: stat outputs for the correlations: (1) FAM-CR
% difference waveforms and REM-FAM difference waveforms with behavioral estimates of familiarity, (2) FAM-CR difference waveforms and REM-FAM difference waveforms with behavioral estimates of recollection.

% Has to change version of spm to spm12, because of an error with loading
% mexmaci64 library under spm8.
cfg.spmversion='spm12'

%Correlation with familiarity behavioral estimates
stat_diff_FAMvsCR_corr_FAMdualprocess_38subjs_nRand = ft_timelockstatistics(cfg, all_diff_FAMvsCR_nRand{:});
save(fullfile('file_path', 'stat_diff_FAMvsCR_corr_FAMdualprocess_38subjs_nRand.mat'), 'stat_diff_FAMvsCR_corr_FAMdualprocess_38subjs_nRand');

stat_diff_REMvsFAM_corr_FAMdualprocess_38subjs_nRand = ft_timelockstatistics(cfg, all_diff_REMvsFAM_nRand{:});
save(fullfile('file_path', 'stat_diff_REMvsFAM_corr_FAMdualprocess_38subjs_nRand.mat'), 'stat_diff_REMvsFAM_corr_FAMdualprocess_38subjs_nRand');


%Correlation with recollection behavioral estimates
stat_diff_FAMvsCR_corr_REMdualprocess_38subjs_nRand = ft_timelockstatistics(cfg, all_diff_FAMvsCR_nRand{:});
save(fullfile('file_path', 'stat_diff_FAMvsCR_corr_REMdualprocess_38subjs_nRand.mat'), 'stat_diff_FAMvsCR_corr_REMdualprocess_38subjs_nRand');

stat_diff_REMvsFAM_corr_REMdualprocess_38subjs_nRand = ft_timelockstatistics(cfg, all_diff_REMvsFAM_nRand{:});
save(fullfile('file_path', 'stat_diff_REMvsFAM_corr_REMdualprocess_38subjs_nRand.mat'), 'stat_diff_REMvsFAM_corr_REMdualprocess_38subjs_nRand');
