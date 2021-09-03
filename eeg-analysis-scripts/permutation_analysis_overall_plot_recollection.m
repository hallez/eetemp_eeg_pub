% Script to perform cluster-based permutation test on ERPs.
% This is the fifth step (condition 'b'): plotting REMvsFAM comparison. Need
% to have stat_REMvsFAM_38subjs, dataCR, alltimelockFAM, and alltimelockREM
% files in the Workspace.

% Calculate the grand averages for each condition.
cfg = [];
cfg.channel   = {'FP1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'C1', 'C3', 'C5', 'T7', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'Oz', 'POz', 'PZ', 'CPZ', 'FPZ', 'FP2', 'AF8', 'AF4', 'AFZ', 'FZ', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'Cz', 'C2', 'C4', 'C6', 'T8', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'};
cfg.latency   = 'all';
cfg.parameter = 'avg';
GA_FAM        = ft_timelockgrandaverage(cfg,alltimelockFAM{:});
GA_REM        = ft_timelockgrandaverage(cfg,alltimelockREM{:});

%PLOTTING
cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
GA_REMvsFAM = ft_math(cfg,GA_REM, GA_FAM);

figure;
% Define parameters for plotting.
timestep = 0.15;      %(in seconds)
sampling_rate = dataCR.fsample;
sample_count = length(stat_REMvsFAM_38subjs.time);
j = [0.55:timestep:0.7];   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
m = [1:timestep*sampling_rate:sample_count];  % Temporal endpoints in EEG samples
% get relevant (significant) values
pos_cluster_pvals = [stat_REMvsFAM_38subjs.posclusters(:).prob];
neg_cluster_pvals = [stat_REMvsFAM_38subjs.negclusters(:).prob];

pos_signif_clust = find(pos_cluster_pvals < stat_REMvsFAM_38subjs.cfg.alpha);
neg_signif_clust = find(neg_cluster_pvals < stat_REMvsFAM_38subjs.cfg.alpha);
pos = ismember(stat_REMvsFAM_38subjs.posclusterslabelmat, pos_signif_clust);
neg = ismember(stat_REMvsFAM_38subjs.negclusterslabelmat, neg_signif_clust);

% First ensure the channels to have the same order in the average and in the statistical output.
[i1,i2] = match_str(GA_REMvsFAM.label, stat_REMvsFAM_38subjs.label);

% Plotting
for k = 1:1;
   subplot(1,1,k);
   cfg = [];
   cfg.xlim=[j(k) j(k+1)];
   pos_int = zeros(numel(GA_REMvsFAM.label),1);
   neg_int = zeros(numel(GA_REMvsFAM.label),1);
   pos_int(i1) = all(pos(i2, m(k):m(k+1)), 2);
   neg_int(i1) = all(neg(i2, m(k):m(k+1)), 2);
   cfg.highlight = 'off';
   cfg.highlightchannel = find(pos_int | neg_int);
   cfg.comment = 'xlim'; %'no' or 'xlim';
   cfg.commentpos = 'title';
   cfg.fontsize = 12;
   cfg.markersymbol = '.';
   cfg.markersize = 12;
   
   
   % Uses modified layout, because in the original labels didn't match
   % (e.g. Fz instead of FZ).
   cfg.zlim       = [-1 1];
   cfg.layout = 'biosemi64new.lay';
   ft_topoplotER(cfg, GA_REMvsFAM); colorbar
end