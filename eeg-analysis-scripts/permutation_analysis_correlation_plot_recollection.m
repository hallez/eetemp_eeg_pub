% Script to perform cluster-based permutation test to correlate ERPs with behavioral results.
% This is the fifth step: plotting topomaps showing correlations between Rememeber - Familiar ERP trials and familiarity behavioral estimates, corresponding roughly to the significant clusters identified in the data-driven permutation analysis.
% Need to have stat_diff_REMvsFAM_corr_REMdualprocess_38subjs and dataCR
% files in the Workspace.

cfg = [];

figure;
% Define parameters for plotting.
timestep = 0.05;      %(in seconds)
sampling_rate = dataCR.fsample;
sample_count = length(stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.time);
j = [0.6:timestep:0.65];   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
m = [1:timestep*sampling_rate:sample_count];  % Temporal endpoints in EEG samples
% get relevant (significant) values
pos_cluster_pvals = [stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.posclusters(:).prob];
neg_cluster_pvals = [stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.negclusters(:).prob];

pos_signif_clust = find(pos_cluster_pvals < stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.cfg.alpha);
neg_signif_clust = find(neg_cluster_pvals < stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.cfg.alpha);
pos = ismember(stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.posclusterslabelmat, pos_signif_clust);
neg = ismember(stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.negclusterslabelmat, neg_signif_clust);

% First ensure the channels to have the same order in the average and in the statistical output.
[i1,i2] = match_str(dataCR.label, stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.label);

% Plotting
for k = 1:1;
   subplot(1,1,k);
   cfg = [];
   cfg.xlim=[j(k) j(k+1)];
   pos_int = zeros(numel(dataCR.label),1);
   neg_int = zeros(numel(dataCR.label),1);
   pos_int(i1) = all(pos(i2, m(k):m(k+1)), 2);
   neg_int(i1) = all(neg(i2, m(k):m(k+1)), 2);
   cfg.highlight = 'off';
   cfg.highlightchannel = find(pos_int | neg_int);
   cfg.comment = 'xlim';
   cfg.commentpos = 'title';
   cfg.fontsize = 12;
   cfg.markersymbol = '.';
   cfg.markersize = 12;
   
  
    cfg.alpha      = stat_diff_REMvsFAM_corr_REMdualprocess_38subjs.cfg.alpha;
    cfg.parameter  = 'rho';
    %cfg.zlim       = [0 0.5];
    cfg.layout = 'biosemi64new.lay';
    ft_topoplotER(cfg, stat_diff_REMvsFAM_corr_REMdualprocess_38subjs); colorbar
   
   
end