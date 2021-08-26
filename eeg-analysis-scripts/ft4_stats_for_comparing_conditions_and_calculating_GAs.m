% Script to perform cluster-based permutation test on ERPs.
% This is the forth step: stat outputs for all three
% comparisons: FAMvsCR, REMvsCR and REMvsFAM and calculating grand averages.

% Has to change version of spm to spm12, because of an error with loading
% mexmaci64 library under spm8.
cfg.spmversion='spm12'

[stat_FAMvsCR] = ft_timelockstatistics(cfg, alltimelockFAM{:}, alltimelockCR{:})
save(fullfile('/Users/karinamaciejewska/Documents/eetemp/Perm_stats/all_oursubj', 'FAMvsCR.mat'), 'stat_FAMvsCR');

[stat_REMvsCR] = ft_timelockstatistics(cfg, alltimelockREM{:}, alltimelockCR{:})
save(fullfile('/Users/karinamaciejewska/Documents/eetemp/Perm_stats/all_oursubj', 'REMvsCR.mat'), 'stat_REMvsCR');

[stat_REMvsFAM] = ft_timelockstatistics(cfg, alltimelockREM{:}, alltimelockFAM{:})
save(fullfile('/Users/karinamaciejewska/Documents/eetemp/Perm_stats/all_oursubj', 'REMvsFAM.mat'), 'stat_REMvsFAM');


% Calculate the grand averages for each condition.
cfg = [];
cfg.channel   = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
cfg.latency   = 'all';
cfg.parameter = 'avg';
GA_CR         = ft_timelockgrandaverage(cfg,alltimelockCR{:});
GA_FAM        = ft_timelockgrandaverage(cfg,alltimelockFAM{:});
GA_REM        = ft_timelockgrandaverage(cfg,alltimelockREM{:});
% "{:}" means to use data from all elements of the variable.