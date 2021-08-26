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

    fam_source_miss_idx = intersect(famidx, source_miss_idx);
    fam_source_miss_epid = [EEG.event(fam_source_miss_idx).epoch];

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
    num_fam_sourcemiss = size(fam_source_miss_epid, 2);
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
    fam_sourcemiss_mean = nan(size(EEG.data,2), size(EEG.data,1));
    sourcehit_mean = nan(size(EEG.data,2), size(EEG.data,1));
    sourcemiss_mean = nan(size(EEG.data,2), size(EEG.data,1));

    rem_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    fam_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    cr_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    miss_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    rem_and_fam_mean_smooth = nan(size(EEG_filt.data,2), size(EEG_filt.data,1));
    rem_sourcehit_mean_smooth = nan(size(EEG.data,2), size(EEG.data,1));
    rem_sourcemiss_mean_smooth = nan(size(EEG.data,2), size(EEG.data,1));
    fam_sourcemiss_mean_smooth = nan(size(EEG.data,2), size(EEG.data,1));
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
        fam_sourcemiss_mean(:, ielec) = mean(EEG.data(ielec, :, fam_source_miss_epid),3)';
        sourcehit_mean(:, ielec) = mean(EEG.data(ielec, :, source_hit_epid),3)';
        sourcemiss_mean(:, ielec) = mean(EEG.data(ielec, :, source_miss_epid),3)';

        rem_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, rem_epid),3)';
        fam_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, fam_epid),3)';
        cr_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, cr_epid),3)';
        miss_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, miss_epid),3)';
        rem_and_fam_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, rem_and_fam_epid),3)';
        rem_sourcehit_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, rem_source_hit_epid),3)';
        rem_sourcemiss_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, rem_source_miss_epid),3)';
        fam_sourcemiss_mean_smooth(:, ielec) = mean(EEG_filt.data(ielec, :, fam_source_miss_epid),3)';
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
    window_info(13).test_elec = 'Cz';
    window_info(13).elec_str = 'Cz';
    window_info(14).test_elec = 'F4';
    window_info(14).elec_str = 'F4';
    window_info(15).test_elec = 'P4';
    window_info(15).elec_str = 'P4';
    window_info(16).test_elec = 'AF3';
    window_info(16).elec_str = 'AF3';
    window_info(17).test_elec = 'AF4';
    window_info(17).elec_str = 'AF4';
    window_info(18).test_elec = 'PO3';
    window_info(18).elec_str = 'PO3';
    window_info(19).test_elec = 'PO4';
    window_info(19).elec_str = 'PO4';
    window_info(20).test_elec = 'F1';
    window_info(20).elec_str = 'F1';
    window_info(21).test_elec = 'AF8';
    window_info(21).elec_str = 'AF8';
    window_info(22).test_elec = 'F8';
    window_info(22).elec_str = 'F8';
    window_info(23).test_elec = 'F6';
    window_info(23).elec_str = 'F6';
    window_info(24).test_elec = 'F2';
    window_info(24).elec_str = 'F2';
    window_info(25).test_elec = 'AF7';
    window_info(25).elec_str = 'AF7';
    window_info(26).test_elec = 'F7';
    window_info(26).elec_str = 'F7';
    window_info(27).test_elec = 'F5';
    window_info(27).elec_str = 'F5';
    window_info(28).test_elec = 'FT8';
    window_info(28).elec_str = 'FT8';
    window_info(29).test_elec = 'F8';
    window_info(29).elec_str = 'F8';
    window_info(30).test_elec = 'T8';
    window_info(30).elec_str = 'T8';

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
    group_means.fam_sourcemiss_mean(:,:,isub) = fam_sourcemiss_mean;
    group_means.sourcehit_mean(:,:,isub) = sourcehit_mean;
    group_means.sourcemiss_mean(:,:,isub) = sourcemiss_mean;

    group_means.rem_mean_smooth(:,:,isub) = rem_mean_smooth;
    group_means.fam_mean_smooth(:,:,isub) = fam_mean_smooth;
    group_means.cr_mean_smooth(:,:,isub) = cr_mean_smooth;
    group_means.miss_mean_smooth(:,:,isub) = miss_mean_smooth;
    group_means.rem_and_fam_mean_smooth(:,:,isub) = rem_and_fam_mean_smooth;
    group_means.rem_sourcehit_mean_smooth(:,:,isub) = rem_sourcehit_mean_smooth;
    group_means.rem_sourcemiss_mean_smooth(:,:,isub) = rem_sourcemiss_mean_smooth;
    group_means.fam_sourcemiss_mean_smooth(:,:,isub) = fam_sourcemiss_mean_smooth;
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
fam_sourcemiss_grandmean = mean(group_means.fam_sourcemiss_mean, 3);
sourcehit_grandmean = mean(group_means.sourcehit_mean, 3);
sourcemiss_grandmean = mean(group_means.sourcemiss_mean, 3);

rem_grandmean_smooth = mean(group_means.rem_mean_smooth, 3);
fam_grandmean_smooth = mean(group_means.fam_mean_smooth, 3);
cr_grandmean_smooth = mean(group_means.cr_mean_smooth, 3);
miss_grandmean_smooth = mean(group_means.miss_mean_smooth, 3);
rem_and_fam_grandmean_smooth = mean(group_means.rem_and_fam_mean_smooth, 3);
rem_sourcehit_grandmean_smooth = mean(group_means.rem_sourcehit_mean_smooth, 3);
rem_sourcemiss_grandmean_smooth = mean(group_means.rem_sourcemiss_mean_smooth, 3);
fam_sourcemiss_grandmean_smooth = mean(group_means.fam_sourcemiss_mean_smooth, 3);
sourcehit_grandmean_smooth = mean(group_means.sourcehit_mean_smooth, 3);
sourcemiss_grandmean_smooth = mean(group_means.sourcemiss_mean_smooth, 3);

rem_minus_fam = rem_grandmean - fam_grandmean;
rem_minus_cr = rem_grandmean - cr_grandmean;
fam_minus_cr = fam_grandmean - cr_grandmean;
rem_and_fam_minus_cr = rem_and_fam_grandmean - cr_grandmean;
fam_minus_rem = fam_grandmean - rem_grandmean;
cr_plus_miss_grandmean = cr_grandmean + miss_grandmean;

rem_minus_fam_smooth = rem_grandmean_smooth - fam_grandmean_smooth;
rem_minus_cr_smooth = rem_grandmean_smooth - cr_grandmean_smooth;
fam_minus_cr_smooth = fam_grandmean_smooth - cr_grandmean_smooth;
rem_and_fam_minus_cr_smooth = rem_and_fam_grandmean_smooth - cr_grandmean_smooth;
fam_minus_rem_smooth = fam_grandmean_smooth - rem_grandmean_smooth;
cr_plus_miss_grandmean_smooth = cr_grandmean_smooth + miss_grandmean_smooth;
rem_sourcehit_minus_fam_sourcemiss_smooth = rem_sourcehit_grandmean_smooth - fam_sourcemiss_grandmean_smooth;
fam_sourcemiss_minus_rem_sourcehit_smooth = fam_sourcemiss_grandmean_smooth - rem_sourcehit_grandmean_smooth;
rem_sourcehit_minus_cr_smooth = rem_sourcehit_grandmean_smooth - cr_grandmean_smooth;
fam_sourcemiss_minus_cr_smooth = fam_sourcemiss_grandmean_smooth - cr_grandmean_smooth;

lpc_times = dsearchn(EEG.times', [501, 800]');
fn400_times = dsearchn(EEG.times', [221, 500]');
eog_times = dsearchn(EEG.times', [401, 700]');

topo_plotting('familiar sourcemiss (220-500ms)', mean(fam_sourcemiss_grandmean_smooth(fn400_times(1):fn400_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile('/Users/karinamaciejewska/Documents/eetemp/analyzed-eeg/newplots', sprintf('%s_N%d.png', 'sm_group_topo_fam-sourcemiss_erp_220-500', length(subjects))));

topo_plotting('familiar sourcemiss_minus_cr (220-500ms)', mean(fam_sourcemiss_minus_cr_smooth(fn400_times(1):fn400_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile('/Users/karinamaciejewska/Documents/eetemp/analyzed-eeg/newplots', sprintf('%s_N%d.png', 'sm_group_topo_fam-sourcemiss_minus_cr_erp_220-500', length(subjects))));

topo_plotting('familiar sourcemiss_minus_rem_sourcehit (220-500ms)', mean(fam_sourcemiss_minus_rem_sourcehit_smooth(fn400_times(1):fn400_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile('/Users/karinamaciejewska/Documents/eetemp/analyzed-eeg/newplots', sprintf('%s_N%d.png', 'sm_group_topo_fam-sourcemiss_minus_rem-sourcehit_erp_220-500', length(subjects))));

topo_plotting('remember sourcehit (500-800ms)', mean(rem_sourcehit_grandmean_smooth(lpc_times(1):lpc_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile('/Users/karinamaciejewska/Documents/eetemp/analyzed-eeg/newplots', sprintf('%s_N%d.png', 'sm_group_topo_rem-sourcehit_erp_500-800', length(subjects))));

topo_plotting('remember sourcehit_minus_cr (500-800ms)', mean(rem_sourcehit_minus_cr_smooth(lpc_times(1):lpc_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile('/Users/karinamaciejewska/Documents/eetemp/analyzed-eeg/newplots', sprintf('%s_N%d.png', 'sm_group_topo_rem-sourcehit_minus_cr_erp_500-800', length(subjects))));

topo_plotting('remember sourcehit_minus_familiar sourcemiss (500-800ms)', mean(rem_sourcehit_minus_fam_sourcemiss_smooth(lpc_times(1):lpc_times(2),:), 1), EEG.chanlocs(1:64),...
    fullfile('/Users/karinamaciejewska/Documents/eetemp/analyzed-eeg/newplots', sprintf('%s_N%d.png', 'sm_group_topo_rem-sourcehit_minus_fam-sourcemiss_erp_500-800', length(subjects))));

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

    erp_plotting2(sprintf('Group diff mean values (ERP) between %0.2d and %d at %s (LPF at %d)',...
        epoch_start, epoch_end, window_info(iwin).elec_str, config.lpf_cutoff), elec_id, EEG_filt.times,...
        times, rem_sourcehit_grandmean_smooth, rem_color, fam_sourcemiss_grandmean_smooth, fam_color, cr_grandmean_smooth, cr_color, rem_sourcehit_minus_cr_smooth, rem_color, fam_sourcemiss_minus_cr_smooth, fam_color, {'rem_shit', 'fam_smiss', 'cr', 'rem_shit-cr', 'fam_smiss-cr'},...
        fullfile('/Users/karinamaciejewska/Documents/eetemp/analyzed-eeg/newplots', sprintf('group_erp_%s_lpf-%d_rem_shit-vs-fam_smiss-vs-cr-diff_N%d.png', window_info(iwin).elec_str, config.lpf_cutoff, size(group_means.rem_mean, 3))));

    close all;
end
