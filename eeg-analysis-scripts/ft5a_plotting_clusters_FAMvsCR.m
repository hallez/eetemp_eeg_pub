% Script to perform cluster-based permutation test on ERPs.
% This is the fifth step (condition 'a'): plotting significant clusters for the FAMvsCR
% comparison.

cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
GA_FAMvsCR = ft_math(cfg,GA_FAM,GA_CR);

figure;
% Define parameters for plotting.
timestep = 0.05;      %(in seconds)
sampling_rate = dataCR.fsample;
sample_count = length(stat_FAMvsCR.time);
j = [0:timestep:1];   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
m = [1:timestep*sampling_rate:sample_count];  % Temporal endpoints in EEG samples
% get relevant (significant) values
pos_cluster_pvals = [stat_FAMvsCR.posclusters(:).prob];
neg_cluster_pvals = [stat_FAMvsCR.negclusters(:).prob];

% Ensure stat.cfg.alpha exists.
if ~isfield(stat_FAMvsCR.cfg,'alpha'); stat_FAMvsCR.cfg.alpha = 0.05; end;

pos_signif_clust = find(pos_cluster_pvals < stat_FAMvsCR.cfg.alpha);
neg_signif_clust = find(neg_cluster_pvals < stat_FAMvsCR.cfg.alpha);
pos = ismember(stat_FAMvsCR.posclusterslabelmat, pos_signif_clust);
neg = ismember(stat_FAMvsCR.negclusterslabelmat, neg_signif_clust);

% First ensure the channels to have the same order in the average and in the statistical output.
% This might not be the case, because ft_math might shuffle the order.
[i1,i2] = match_str(GA_FAMvsCR.label, stat_FAMvsCR.label);

% Plot the topoplots with significant clusters marked with an asterisk.
% Here we have 19 topoplots, because of the real time interval (0-0.953 s).
for k = 1:19;
   subplot(4,5,k);
   cfg = [];
   cfg.xlim=[j(k) j(k+1)];
   pos_int = zeros(numel(GA_FAMvsCR.label),1);
   neg_int = zeros(numel(GA_FAMvsCR.label),1);
   pos_int(i1) = all(pos(i2, m(k):m(k+1)), 2);
   neg_int(i1) = all(neg(i2, m(k):m(k+1)), 2);
   cfg.highlight = 'on';
   cfg.highlightchannel = find(pos_int | neg_int);
   cfg.comment = 'xlim';
   cfg.commentpos = 'title';
   
   % Uses modified layout, because in the original labels didn't match
   % (e.g. Fz instead of FZ).
   cfg.layout = 'biosemi64new.lay';
   ft_topoplotER(cfg, GA_FAMvsCR); colorbar
end