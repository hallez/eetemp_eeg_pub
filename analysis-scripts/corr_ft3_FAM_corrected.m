% Script to perform cluster-based permutation test to correlate ERPs with behavioral results.
% This is the third step: configuring the parameters of cluster-based permutation test. 
% In this particular script we correlate the ERPs from FAM trials with FAM corrected behavioral results. 


cfg = [];
cfg.channel = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
cfg.latency = [0 1];

% Method used to calculate the significance probability.
cfg.method = 'montecarlo';  

% Since in this case we use a within subject study design, we use dependent samples T-statistic 
% to evaluate the effect. Can use 'ft_statfun_indepsamplesT' for between-UO (units of observation) 
% design or 'ft_statfun_indepsamplesF' and
% 'ft_statfun_depsamplesFmultivariate' to compare more than two experimental conditions.
cfg.statistic = 'ft_statfun_correlationT'; 
cfg.type      = 'Pearson'; % may be also 'Spearman'

% Test statistic used to solve the MCP (multi comparison problem).
cfg.correctm = 'cluster';      

% To choose the critical value that will be used for thresholding the sample-specific T-statistics.
cfg.clusteralpha = 0.025; 

% To choose the test statistic that will be evaluated under the permutation distribution. 
% This is the actual test statistic and it must be distinguished from the sample-specific
% T-statistics that are used for thresholding. 'maxsum', the actual test statistic, is 
% the maximum of the cluster-level statistics. A cluster-level statistic is equal to 
% the sum of the sample-specific T-statistics that belong to this cluster. 
% Taking the largest of these cluster-level statistics of the different
% clusters produces the actual test statistic. This is recommended int the
% FieldTrip tutorial.
cfg.clusterstatistic = 'maxsum';    

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
% of falsely rejecting the null hypothesis). Here we use 0.25, because we use two-sided statistical test. 
cfg.alpha = 0.05;

% To control the number of draws from the permutation distribution. Usually
% not less than 1000.
cfg.numrandomization = 1000;

% Define number or subjects and set the design.
subj = 34;
design(1,1:subj)       = [0.6538462	0.4117647	0.556391	0.6808511	0.4224138	0.7475728	0.75	0.8115942	0.5742574	0.7227723	0.7115385	0.8536585	0.8	0.797619	0.6356589	0.75	0.6419753	0.625	0.5350877	0.52	0.6022727	0.4631579	0.5748031	0.6629213	0.5581395	0.7586207	0.5068493	0.9	0.5181818	0.6478873	0.7241379	0.7466667	0.5972222	0.5544554];
cfg.design   = design;
cfg.ivar     = 1;

% Has to change version of spm to spm12, because of an error with loading
% mexmaci64 library under spm8.
cfg.spmversion='spm12'
% Here we take ERPs from FAM trials, so we pick alltimelockFAM.
stat = ft_timelockstatistics(cfg, alltimelockFAM{:});