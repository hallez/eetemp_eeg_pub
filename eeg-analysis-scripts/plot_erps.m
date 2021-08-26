% Script to plot individual and group ERPs.
%
% Halle R. Dimsdale-Zucker

close all;
fclose('all');
clc;
clear all;

config = eetemp_initialize;
subjects = config.subjects;

% remove subjects who did not meet the trial count threshold
load(fullfile(config.analyzed_eeg_dir, sprintf('exclude_subj_less-than-%d-rem-trials.mat', config.min_trials_thresh)));
load(fullfile(config.analyzed_eeg_dir, sprintf('exclude_subj_less-than-%d-fam-trials.mat', config.min_trials_thresh)));
rem_remove_idx = ismember(subjects, erp_rem_exclude_subjects);
fam_remove_idx = ismember(subjects, erp_fam_exclude_subjects);
all_remove_idx = rem_remove_idx + fam_remove_idx;
subjects = subjects(~all_remove_idx);

PLOT_FLAG = 0;

% remember to convert from ms
epoch_start = (-1 .* config.erp_baseline_for_plots) .* 1000;
epoch_end = config.erp_epoch_end .* 1000;

for isub = 1:length(subjects)
    subj_start = tic;
    subj_str = subjects{isub};
    subj_anal_dir = fullfile(config.analyzed_eeg_dir, subj_str);

    set_str_in = sprintf('downsamp_electrode-ids_revalued-events_reref_hpf-%0.2g_erpep_removep-loc%0.2g-glob%0.2g_rmica_interpol_removep2_merged_rmbase',...
                            config.hpf_cutoff, config.local_threshold, config.global_threshold);
    set_str_out = 'erp-plot';

    % print out info to a diary file
    diaryname = fullfile(config.logs_dir, sprintf('%s_diaryfile-%s_%s.txt', subj_str, set_str_out, date));
    diary(diaryname);

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % start eeglab

    fname_in = sprintf('%s_eetemp_%s.set', subj_str, set_str_in);

    if ~exist(fullfile(subj_anal_dir, fname_in), 'file')
        fprintf('%s does not exist - continuing.\n', fname_in)
        continue;
    end

    EEG = pop_loadset('filename', fname_in,'filepath', subj_anal_dir); % load in dataset
    eeglab redraw;

    % save original data in case need to compare
    origEEG = EEG;

    % low pass filter to smooth for visualization purposes
    EEG_filt  = pop_basicfilter( EEG,  1:70 , 'Boundary', 'boundary', 'Cutoff',  config.lpf_cutoff,...
            'Design', 'butter', 'Filter', 'lowpass', 'Order',  2, 'RemoveDC', 'on' );

    % get trial indices based on labels as determined in 'epoch_erp.m'
    % remember hits = 211
    % familiar hits = 212
    % correct rejections = 204
    % FEELS VERY ERROR PRONE -- IS THERE A BETTER WAY???
    remidx = find([EEG.event.type] == 211);
    if(isempty(remidx))
        remidx = find(ismember({EEG.event.type}, '211'));
    end
    rem_epid = [EEG.event(remidx).epoch];

    famidx = find([EEG.event.type] == 212);
    if(isempty(famidx))
        famidx = find(ismember({EEG.event.type}, '212'));
    end
    fam_epid = [EEG.event(famidx).epoch];

    cridx = find([EEG.event.type] == 204);
    if(isempty(cridx))
        cridx = find(ismember({EEG.event.type}, '204'));
    end
    cr_epid = [EEG.event(cridx).epoch];

    missidx = find([EEG.event.type] == 215);
    if(isempty(missidx))
        missidx = find(ismember({EEG.event.type}, '215'));
    end
    miss_epid = [EEG.event(missidx).epoch];

    source_hit_idx = find(ismember([EEG.event(:).item_source_scored], 'correct'));
    source_hit_epid = [EEG.event(source_hit_idx).epoch];

    source_miss_idx = find(ismember([EEG.event(:).item_source_scored], 'incorrect'));
    source_miss_epid = [EEG.event(source_miss_idx).epoch];

    rem_source_hit_idx = intersect(remidx, source_hit_idx);
    rem_source_hit_epid = [EEG.event(rem_source_hit_idx).epoch];

    rem_source_miss_idx = intersect(remidx, source_miss_idx);
    rem_source_miss_epid = [EEG.event(rem_source_miss_idx).epoch];

    rem_and_fam_epid = [fam_epid, rem_epid];

    % save out information about the total number of epochs - this
    % information is printed into the diary
    num_remep = size(rem_epid,2);
    num_famep = size(fam_epid,2);
    num_crep = size(cr_epid,2);
    num_miss = size(miss_epid, 2);
    num_rem_and_fam = size(rem_and_fam_epid, 2);
    num_rem_sourcehit = size(rem_source_hit_epid, 2);
    num_rem_sourcemiss = size(rem_source_miss_epid, 2);
    num_sourcehit = size(source_hit_epid, 2);
    num_sourcemiss = size(source_miss_epid, 2);

    % take the average at each electrode for each condition
    % EEG.data = (electrodes, pnts [number of timepoints per trial/epoch], epochs)
    % can check by comparing w/ channel ERP - here's the code for
    % remembered trials at Pz
    % figure; pop_erpimage(EEG,1, [31],[[]],'PZ',10,1,{ '211'},[],'type' ,'yerplabel','\muV','erp','on','cbar','on','topo', { [31] EEG.chanlocs EEG.chaninfo } );
    % figure; plot(rem_mean(:, 31)); hold on; plot(zeros(size(rem_mean,1),1))
    rem_mean = nan(size(EEG.data,2), size(EEG.data,1));
    fam_mean = nan(size(EEG.data,2), size(EEG.data,1));
    cr_mean = nan(size(EEG.data,2), size(EEG.data,1));
    miss_mean = nan(size(EEG.data,2), size(EEG.data,1));
    rem_and_fam_mean = nan(size(EEG.data,2), size(EEG.data,1));
    rem_sourcehit_mean = nan(size(EEG.data,2), size(EEG.data,1));
    rem_sourcemiss_mean = nan(size(EEG.data,2), size(EEG.data,1));
    sourcehit_mean = nan(size(EEG.data,2), size(EEG.data,1));
    sourcemiss_mean = nan(size(EEG.data,2), size(EEG.data,1));

    rem_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    fam_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    cr_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    miss_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    rem_and_fam_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    rem_sourcehit_mean_smooth = nan(size(EEG.data,2), size(EEG.data,1));
    rem_sourcemiss_mean_smooth = nan(size(EEG.data,2), size(EEG.data,1));
    sourcehit_mean_smooth = nan(size(EEG.data,2), size(EEG.data,1));
    sourcemiss_mean_smooth = nan(size(EEG.data,2), size(EEG.data,1));

    for ielec = 1:size(EEG.data,1)
        rem_mean(:, ielec) = mean(EEG.data(ielec, :, rem_epid),3)';
        fam_mean(:, ielec) = mean(EEG.data(ielec, :, fam_epid),3)';
        cr_mean(:, ielec) = mean(EEG.data(ielec, :, cr_epid),3)';
        miss_mean(:, ielec) = mean(EEG.data(ielec, :, miss_epid),3)';
        rem_and_fam_mean(:, ielec) = mean(EEG.data(ielec, :, rem_and_fam_epid),3)';
        rem_sourcehit_mean(:, ielec) = mean(EEG.data(ielec, :, rem_source_hit_epid),3)';
        rem_sourcemiss_mean(:, ielec) = mean(EEG.data(ielec, :, rem_source_miss_epid),3)';
        sourcehit_mean(:, ielec) = mean(EEG.data(ielec, :, source_hit_epid),3)';
        sourcemiss_mean(:, ielec) = mean(EEG.data(ielec, :, source_miss_epid),3)';

        rem_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, rem_epid),3)';
        fam_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, fam_epid),3)';
        cr_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, cr_epid),3)';
        miss_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, miss_epid),3)';
        rem_and_fam_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, rem_and_fam_epid),3)';
        rem_sourcehit_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, rem_source_hit_epid),3)';
        rem_sourcemiss_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, rem_source_miss_epid),3)';
        sourcehit_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, source_hit_epid),3)';
        sourcemiss_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, source_miss_epid),3)';
    end

    % Should idealy grab cr and mean trials together since grabbing them
    % separately and then averaging biases by trial numbers, but since
    % there are more correct rejections than misses, misses may just be
    % muddying things up anyhow
    cr_and_miss_mean = cr_mean + miss_mean;
    cr_and_miss_mean_smooth = cr_mean_smooth + miss_mean_smooth;

    window_info(1).test_elec = 'PZ';
    window_info(1).elec_str = 'PZ';
    window_info(2).test_elec = 'F3';
    window_info(2).elec_str = 'F3';
    window_info(3).test_elec = 'FZ';
    window_info(3).elec_str = 'FZ';
    window_info(4).test_elec = 'P3';
    window_info(4).elec_str = 'P3';

    % ROI clusters from Woodruff et al . (2006) Fig. 1:
    % frontal: AF7/8, AF3/4, F7/8, F5/6, F3/4, F1/2
    % parietal: PO7/8, PO3/4, P7/8, P5/6, P3/4, P1/2
    frontal_left = {'F1', 'F3', 'F5', 'F7', 'AF3', 'AF7'};
    frontal_right = {'F2', 'F4', 'F6', 'F8', 'AF4', 'AF8'};
    parietal_left = {'P1', 'P3', 'P5', 'P7', 'PO3', 'PO7'};
    parietal_right = {'P2', 'P4', 'P6', 'P8', 'PO4', 'PO8'};

    window_info(5).test_elec = frontal_left;
    window_info(5).elec_str = 'frontal_left';
    window_info(6).test_elec = frontal_right;
    window_info(6).elec_str = 'frontal_right';
    window_info(7).test_elec = parietal_left;
    window_info(7).elec_str = 'parietal_left';
    window_info(8).test_elec = parietal_right;
    window_info(8).elec_str = 'parietal_right';

    % plot ERPs from occular channels as a control
    window_info(9).test_elec = 'LHEOG';
    window_info(9).elec_str = 'LHEOG';
    window_info(10).test_elec = 'RHEOG';
    window_info(10).elec_str = 'RHEOG';
    window_info(11).test_elec = 'VEOG';
    window_info(11).elec_str = 'VEOG';
    window_info(12).test_elec = 'UVEOG';
    window_info(12).elec_str = 'UVEOG';

    if PLOT_FLAG == 1
        for iwin = 1:length(window_info)

            % skip plotting with combined electrodes for individual
            % subjects
            if(length(window_info(iwin).test_elec) > 2)
                continue;
            end

            % figure out the timepoints for the ERP of interest
            times = dsearchn(EEG.times', [(epoch_start + 1), epoch_end]');
            elec_id = find(strcmp({EEG.chanlocs.labels}, window_info(iwin).test_elec));

            figure('Name', sprintf('Mean values (ERP) between %0.2d and %d at %s',...
                epoch_start, epoch_end, window_info(iwin).elec_str))
            plot(EEG.times(times(1):times(2)), rem_mean(times(1):times(2), elec_id), 'Color', [0.75, 0, 0.75], 'LineWidth', 2)
            hold on
            plot(EEG.times(times(1):times(2)), fam_mean(times(1):times(2), elec_id), 'g', 'LineWidth', 2)
            plot(EEG.times(times(1):times(2)), cr_mean(times(1):times(2), elec_id), 'Color', [0.3010, 0.7450, 0.9330], 'LineWidth', 2, 'LineStyle', '--')
            plot(EEG.times(times(1):times(2)), zeros(size([times(1):times(2)],2),1), 'k')
            line(repmat(0, [1, 2]), [get(gca,'YLim')], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '-');
            legend('rem', 'fam', 'cr')
            saveas(gcf, fullfile(subj_anal_dir, sprintf('%s_%s_erp.png', subj_str, window_info(iwin).elec_str)))

            % smooth for visualization
            figure('Name', sprintf('Mean values (ERP) between %0.2d and %d at %s (LPF at %d)',...
                epoch_start, epoch_end, window_info(iwin).elec_str, config.lpf_cutoff))
            plot(EEG_filt.times(times(1):times(2)), rem_mean_smooth(times(1):times(2), elec_id), 'Color', [0.75, 0, 0.75], 'LineWidth', 2)
            hold on
            plot(EEG_filt.times(times(1):times(2)), fam_mean_smooth(times(1):times(2), elec_id), 'g', 'LineWidth', 2)
            plot(EEG.times(times(1):times(2)), cr_mean_smooth(times(1):times(2), elec_id), 'Color', [0.3010, 0.7450, 0.9330], 'LineWidth', 2, 'LineStyle', '--')
            plot(EEG.times(times(1):times(2)), zeros(size([times(1):times(2)],2),1), 'k')
            line(repmat(0, [1, 2]), [get(gca,'YLim')], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '-');
            legend('rem', 'fam', 'cr')
            saveas(gcf, fullfile(subj_anal_dir, sprintf('%s_%s_erp_lpf-%d.png', subj_str, window_info(iwin).elec_str, config.lpf_cutoff)))

            % compute familiarity against correct rejections and misses
            figure('Name', sprintf('Mean values (ERP) between %0.2d and %d at %s',...
                epoch_start, epoch_end, window_info(iwin).elec_str))
            plot(EEG.times(times(1):times(2)), rem_mean(times(1):times(2), elec_id), 'Color', [0.75, 0, 0.75], 'LineWidth', 2)
            hold on
            plot(EEG.times(times(1):times(2)), fam_mean(times(1):times(2), elec_id), 'g', 'LineWidth', 2)
            plot(EEG.times(times(1):times(2)), cr_and_miss_mean(times(1):times(2), elec_id), 'Color', [0.3010, 0.7450, 0.9330], 'LineWidth', 2, 'LineStyle', '--')
            plot(EEG.times(times(1):times(2)), zeros(size([times(1):times(2)],2),1), 'k')
            line(repmat(0, [1, 2]), [get(gca,'YLim')], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '-');
            legend('rem', 'fam', 'cr+miss')
            saveas(gcf, fullfile(subj_anal_dir, sprintf('%s_%s_erp_fam-vs-cr-miss.png', subj_str, window_info(iwin).elec_str)))

            % smooth for visualization
            figure('Name', sprintf('Mean values (ERP) between %0.2d and %d at %s (LPF at %d)',...
                epoch_start, epoch_end, window_info(iwin).elec_str, config.lpf_cutoff))
            plot(EEG_filt.times(times(1):times(2)), rem_mean_smooth(times(1):times(2), elec_id), 'Color', [0.75, 0, 0.75], 'LineWidth', 2)
            hold on
            plot(EEG_filt.times(times(1):times(2)), fam_mean_smooth(times(1):times(2), elec_id), 'g', 'LineWidth', 2)
            plot(EEG.times(times(1):times(2)), cr_and_miss_mean_smooth(times(1):times(2), elec_id), 'Color', [0.3010, 0.7450, 0.9330], 'LineWidth', 2, 'LineStyle', '--')
            plot(EEG.times(times(1):times(2)), zeros(size([times(1):times(2)],2),1), 'k')
            line(repmat(0, [1, 2]), [get(gca,'YLim')], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '-');
            legend('rem', 'fam', 'cr+miss')
            saveas(gcf, fullfile(subj_anal_dir, sprintf('%s_%s_erp_fam-vs-cr-miss_lpf-%d.png', subj_str, window_info(iwin).elec_str, config.lpf_cutoff)))
            close all;
        end
    end

    group_means.rem_mean(:,:,isub) = rem_mean;
    group_means.fam_mean(:,:,isub) = fam_mean;
    group_means.cr_mean(:,:,isub) = cr_mean;
    group_means.miss_mean(:,:,isub) = miss_mean;
    group_means.rem_and_fam_mean(:,:,isub) = rem_and_fam_mean;
    group_means.rem_sourcehit_mean(:,:,isub) = rem_sourcehit_mean;
    group_means.rem_sourcemiss_mean(:,:,isub) = rem_sourcemiss_mean;
    group_means.sourcehit_mean(:,:,isub) = sourcehit_mean;
    group_means.sourcemiss_mean(:,:,isub) = sourcemiss_mean;

    group_means.rem_mean_smooth(:,:,isub) = rem_mean_smooth;
    group_means.fam_mean_smooth(:,:,isub) = fam_mean_smooth;
    group_means.cr_mean_smooth(:,:,isub) = cr_mean_smooth;
    group_means.miss_mean_smooth(:,:,isub) = miss_mean_smooth;
    group_means.rem_and_fam_mean_smooth(:,:,isub) = rem_and_fam_mean_smooth;
    group_means.rem_sourcehit_mean_smooth(:,:,isub) = rem_sourcehit_mean_smooth;
    group_means.rem_sourcemiss_mean_smooth(:,:,isub) = rem_sourcemiss_mean_smooth;
    group_means.sourcehit_mean_smooth(:,:,isub) = sourcehit_mean_smooth;
    group_means.sourcemiss_mean_smooth(:,:,isub) = sourcemiss_mean_smooth;

    subj_end = toc(subj_start);
    fprintf('\nThat took %d minutes and %f seconds.\n',floor(subj_end/60),rem(subj_end,60))
    diary off;
end %isub

rem_grandmean = mean(group_means.rem_mean, 3);
fam_grandmean = mean(group_means.fam_mean, 3);
cr_grandmean = mean(group_means.cr_mean, 3);
miss_grandmean = mean(group_means.miss_mean, 3);
rem_and_fam_grandmean = mean(group_means.rem_and_fam_mean, 3);
rem_sourcehit_grandmean = mean(group_means.rem_sourcehit_mean, 3);
rem_sourcemiss_grandmean = mean(group_means.rem_sourcemiss_mean, 3);
sourcehit_grandmean = mean(group_means.sourcehit_mean, 3);
sourcemiss_grandmean = mean(group_means.sourcemiss_mean, 3);

rem_grandmean_smooth = mean(group_means.rem_mean_smooth, 3);
fam_grandmean_smooth = mean(group_means.fam_mean_smooth, 3);
cr_grandmean_smooth = mean(group_means.cr_mean_smooth, 3);
miss_grandmean_smooth = mean(group_means.miss_mean_smooth, 3);
rem_and_fam_grandmean_smooth = mean(group_means.rem_and_fam_mean_smooth, 3);
rem_sourcehit_grandmean_smooth = mean(group_means.rem_sourcehit_mean_smooth, 3);
rem_sourcemiss_grandmean_smooth = mean(group_means.rem_sourcemiss_mean_smooth, 3);
sourcehit_grandmean_smooth = mean(group_means.sourcehit_mean_smooth, 3);
sourcemiss_grandmean_smooth = mean(group_means.sourcemiss_mean_smooth, 3);

rem_minus_fam = rem_grandmean - fam_grandmean;
rem_minus_cr = rem_grandmean - cr_grandmean;
fam_minus_cr = fam_grandmean - cr_grandmean;
rem_and_fam_minus_cr = rem_and_fam_grandmean - cr_grandmean;
cr_plus_miss_grandmean = cr_grandmean + miss_grandmean;
cr_plus_miss_grandmean_smooth = cr_grandmean_smooth + miss_grandmean_smooth;

lpc_times = dsearchn(EEG.times', [501, 800]');
fn400_times = dsearchn(EEG.times', [301, 500]');

% if want to highlight a specific electrode in the topoplots, after the
% topoplot line that generates the headmap, include something like this
% changing the electrode ID based on what is being plotted:
% p3_id = find(strcmp({EEG.chanlocs.labels}, 'P3'));
% fz_id = find(strcmp({EEG.chanlocs.labels}, 'FZ'));
% topoplot(mean(rem_minus_fam(lpc_times(1):lpc_times(2),:),1), EEG.chanlocs(1:64), 'electrodes', 'on', 'style', 'map', 'emarker2', {p3_id, 's', 'k'});
topo_plotting('remember minus familiar (500-800ms)', mean(rem_minus_fam(lpc_times(1):lpc_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile(config.analyzed_eeg_dir, sprintf('%s_N%d.png', 'group_topo_rem-minus-fam_erp_500-800', length(subjects))));

topo_plotting('remember minus cr (500-800ms)', mean(rem_minus_cr(lpc_times(1):lpc_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile(config.analyzed_eeg_dir, sprintf('%s_N%d.png', 'group_topo_rem-minus-cr_erp_500-800', length(subjects))));

topo_plotting('remember&fam minus cr (500-800ms)', mean(rem_and_fam_minus_cr(lpc_times(1):lpc_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile(config.analyzed_eeg_dir, sprintf('%s_N%d.png', 'group_topo_rem-and-fam-minus-cr_erp_500-800', length(subjects))));

topo_plotting('familiar minus cr (300-500ms)', mean(fam_minus_cr(fn400_times(1):fn400_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile(config.analyzed_eeg_dir, sprintf('%s_N%d.png', 'group_topo_fam-minus-cr_erp_300-500', length(subjects))));

topo_plotting('remember minus cr (300-500ms)', mean(rem_minus_cr(fn400_times(1):fn400_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile(config.analyzed_eeg_dir, sprintf('%s_N%d.png', 'group_topo_rem-minus-cr_erp_300-500', length(subjects))));

% plot a topomap that just shows electrode locations
cluster_sites = [frontal_left, frontal_right, parietal_left, parietal_right];
cluster_ids = find(ismember({EEG.chanlocs.labels}, cluster_sites));
h = figure;
topoplot([],EEG.chanlocs(cluster_ids),'style','blank','electrodes','on','chaninfo',EEG.chaninfo);
saveas(h, fullfile(config.analyzed_eeg_dir, 'blank_electrode_sites.png'));

rem_color = [0.75, 0, 0.75];
fam_color = 'g';
cr_color = [0.3010, 0.7450, 0.9330];

for iwin = 1:length(window_info)
    % figure out the timepoints for the ERP of interest
    times = dsearchn(EEG.times', [(epoch_start + 1), epoch_end]');

    if(length(window_info(iwin).test_elec) > 2)
        elec_id = find(ismember({EEG.chanlocs.labels}, window_info(iwin).test_elec));
    else
        elec_id = find(strcmp({EEG.chanlocs.labels}, window_info(iwin).test_elec));
    end

    % compute familiarity as familiar vs. correct rejections
    erp_plotting(sprintf('Group mean values (ERP) between %0.2d and %d at %s',...
        epoch_start, epoch_end, window_info(iwin).elec_str), elec_id, EEG.times,...
        times, rem_grandmean, rem_color, fam_grandmean, fam_color, cr_grandmean, cr_color, {'rem', 'fam', 'cr'},...
        fullfile(config.analyzed_eeg_dir, sprintf('group_erp_%s_rem-vs-fam-vs-cr_N%d.png', window_info(iwin).elec_str, size(group_means.rem_mean, 3))));

    % smooth for visualization
    erp_plotting(sprintf('Group mean values (ERP) between %0.2d and %d at %s (LPF at %d)',...
        epoch_start, epoch_end, window_info(iwin).elec_str, config.lpf_cutoff), elec_id, EEG_filt.times,...
        times, rem_grandmean_smooth, rem_color, fam_grandmean_smooth, fam_color, cr_grandmean_smooth, cr_color, {'rem', 'fam', 'cr'},...
        fullfile(config.analyzed_eeg_dir, sprintf('group_erp_%s_lpf-%d_rem-vs-fam-vs-cr_N%d.png', window_info(iwin).elec_str, config.lpf_cutoff, size(group_means.rem_mean, 3))));

    % compute familiariy as familiar vs. correct rejections and misses
    % (this is noisier because misses are rare)
    erp_plotting(sprintf('Group mean values (ERP) between %0.2d and %d at %s',...
        epoch_start, epoch_end, window_info(iwin).elec_str), elec_id, EEG.times,...
        times, rem_grandmean, rem_color, fam_grandmean, fam_color, cr_plus_miss_grandmean, cr_color, {'rem', 'fam', 'cr+miss'},...
        fullfile(config.analyzed_eeg_dir, sprintf('group_erp_%s_rem-vs-fam-vs-cr-miss_N%d.png', window_info(iwin).elec_str, size(group_means.rem_mean, 3))));

    % smooth for visualization
    erp_plotting(sprintf('Group mean values (ERP) between %0.2d and %d at %s (LPF at %d)',...
        epoch_start, epoch_end, window_info(iwin).elec_str, config.lpf_cutoff), elec_id, EEG_filt.times,...
        times, rem_grandmean_smooth, rem_color, fam_grandmean_smooth, fam_color, cr_plus_miss_grandmean_smooth, cr_color, {'rem', 'fam', 'cr+miss'},...
        fullfile(config.analyzed_eeg_dir, sprintf('group_erp_%s_lpf-%d_rem-vs-fam-vs-cr-miss_N%d.png', window_info(iwin).elec_str, config.lpf_cutoff, size(group_means.rem_mean, 3))));

    close all;
end
