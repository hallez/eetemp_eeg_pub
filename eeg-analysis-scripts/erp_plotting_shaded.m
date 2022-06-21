function erp_plotting_shaded(fig_name, eeg_chans, eeg_subj, all_eeg_times, eeg_times, data1, color1, data2, color2, data3, color3, legend_str, outname)
% function to plot ERPs. expects: 
% fig_name: formatted text string
% eeg_chans: channels to subset data*; expects a single channel 
% all_eeg_times: 'EEG.times' to create correct x-axis 
% eeg_times: start and end times of the plotting epoch, should exceed the
% length of the ERP itself so that there is a baseline period and values
% after the ERP
% data1, data2, data3: assumes three datasets (e.g., R, F, CR); should be
% times x channels. can be filtered (smoothed) or unfiltered. handles when
% there are multiple electrodes by taking the mean across the electrode
% dimension of the data.
% legend_str: {'data1_val', 'data2_val', 'data3_val'}
% outname: full file path where figure should be saved 
    h = figure('Name', fig_name);
    
    p1 = shadedErrorBar(all_eeg_times(eeg_times(1):eeg_times(2)), mean(data1(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj), 3), std(data1(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj),0, 3), 'm')

    hold on;
    p2 = shadedErrorBar(all_eeg_times(eeg_times(1):eeg_times(2)), mean(data2(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj), 3), std(data2(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj),0, 3), 'g')
    p3 = shadedErrorBar(all_eeg_times(eeg_times(1):eeg_times(2)), mean(data3(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj), 3), std(data3(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj),0, 3), 'b')
    p4 = plot(all_eeg_times(eeg_times(1):eeg_times(2)), mean(data1(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj), 3), 'Color', color1, 'LineWidth', 2);
    p5 = plot(all_eeg_times(eeg_times(1):eeg_times(2)), mean(data2(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj), 3), 'Color', color2, 'LineWidth', 2)
    p6 = plot(all_eeg_times(eeg_times(1):eeg_times(2)), mean(data3(eeg_times(1):eeg_times(2), eeg_chans, eeg_subj), 3), 'Color', color3, 'LineWidth', 2, 'LineStyle', '--')
    
    plot(all_eeg_times(eeg_times(1):eeg_times(2)), zeros(size([eeg_times(1):eeg_times(2)],2),1), 'k')
    
    ylim([-6, 7])
    xlim([-200, 800])
    set(gca, 'FontSize', 20)
    legend([p4 p5 p6], 'remember', 'familiar', 'correct rejection', 'FontSize', 16)
    saveas(h, outname)

end
