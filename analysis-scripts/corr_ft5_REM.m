% Script to perform cluster-based permutation test to correlate ERPs with behavioral results.
% This is the fifth step (condition 'b'): plotting significant clusters for
% the ERPs from REM trials.

cfg = [];

figure;
% Define parameters for plotting.
timestep = 0.025;      %(in seconds)
sampling_rate = dataREM.fsample;
sample_count = length(stat.time);
j = [0:timestep:1];   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
m = [1:timestep*sampling_rate:sample_count];  % Temporal endpoints in EEG samples
% get relevant (significant) values
pos_cluster_pvals = [stat.posclusters(:).prob];
neg_cluster_pvals = [stat.negclusters(:).prob];

% Ensure stat.cfg.alpha exists.
if ~isfield(stat.cfg,'alpha'); stat.cfg.alpha = 0.05; end;

pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
neg_signif_clust = find(neg_cluster_pvals < stat.cfg.alpha);
pos = ismember(stat.posclusterslabelmat, pos_signif_clust);
neg = ismember(stat.negclusterslabelmat, neg_signif_clust);

% First ensure the channels to have the same order in the average and in the statistical output.
% This might not be the case, because ft_math might shuffle the order.
[i1,i2] = match_str(timelockREM.label, stat.label);

% Plot the topoplots with significant clusters marked with an asterisk.
% Here we have 39 topoplots, because of the real time interval (0-0.953 s).
for k = 1:39;
   subplot(5,8,k);
   cfg = [];
   cfg.xlim=[j(k) j(k+1)];
   pos_int = zeros(numel(timelockREM.label),1);
   neg_int = zeros(numel(timelockREM.label),1);
   pos_int(i1) = all(pos(i2, m(k):m(k+1)), 2);
   neg_int(i1) = all(neg(i2, m(k):m(k+1)), 2);
   cfg.highlight = 'on';
   cfg.highlightchannel = find(pos_int | neg_int);
   cfg.comment = 'xlim';
   cfg.commentpos = 'title';
   
   
    cfg.alpha      = stat.cfg.alpha;
    cfg.parameter  = 'rho';
    cfg.zlim       = [-0.4 0.4];
    cfg.layout = 'biosemi64new.lay';
    ft_topoplotER(cfg, stat); colorbar
   
   
end