# Project setup
## Program requirements:
* Matlab (analyses were done in R2014b)
* R
* Python (scripts assume python 2, but should also work w/ Python 3)

## Setting paths
1. Copy `config.yml.example` to `config.yml` and update paths for local machine.
```
cp config.yml.example config.yml
vim config.yml
```

## Package requirements
1. Install python dependencies
```
pip install -r requirements.txt
```

1. Install external toolboxes for eeg analyses:
  * eeglab: https://sccn.ucsd.edu/eeglab/downloadtoolbox.php
    * can edit line 135 of `pop_subcomp` to say:
      ```
      eegplot( EEG.data(EEG.icachansind,:,:), 'srate', EEG.srate, 'title', 'Black = channel before rejection; red = after rejection -- eegplot()', ...
      'limits', [EEG.xmin EEG.xmax]*1000, 'data2', compproj, 'eloc_file', EEG.chanlocs(EEG.icachansind));
      ```
  * erplab >= 6.1.4 (install as a plugin for EEGLab)
  * clean_rawdata >= 0.32 (install as a plugin for EEGLab)
  * sasica >=1.3.4 (install as a plugin for EEGLab)
  * biosig >= 3.3.0 (follow the on-screen prompts the first time you try to load data using File -> Import data -> Using EEGLAB functions and plugins -> from Biosemi BDF file (BIOSIG toolbox))
  * trimOutlier >=0.16 (install as plugin for EEGLab)
  * FieldTrip
  * SPM12

1. R packages
  * halle (scripts will automatically download latest version from [GitHub](https://github.com/hallez/halle)), tidyverse (>= 1.3.0), yaml

# Subjects to exclude
* s202: less than 30 remembered trials
* s209: noise in mastoid channels that contaminates the data once it's re-referenced
* s215: less than 30 familiar trials (but not excluded from analyses)
* s216: incidental MRI finding
* s220: less than 30 remembered trials
* s222: subject had previously participated in a related pilot (EEG session not completed)
* s225: less than 30 remembered trials
* s238: less than 30 familiar trials (but not excluded from analyses)
* s239: subject did not understand task instructions (EEG session not completed)
* s248: less than 30 remembered trials
* s249: less than 30 familiar trials (but not excluded from analyses)

# Behavioral Analysis
1. Open the RStudio project file in `analysis-scripts`
   * Remember that this will write out the analyzed data to a local file (ie, it's not synched across machines automatically so need to re-run analyses on each computer)
1. Load in the data `load-behavior.R`
1. Generate behavioral analyses `analyze-behavior.R`

# EEG Analysis
* these scripts are located in the `eeg-analysis-scripts` folder

## Preprocessing
--- Can run through `ica.m` using `preproc_combined.m` ---
1. Downsample the data to 128 Hz `downsample_preproc.m`
1. Add in electrode IDs `relabel_electrodes.m`
1. Re-label the event codes with meaningful values `revalue_events.m`
1. Reference `rereference.m`
1. High-pass filter `hpf_preproc.m` and `hpf_for_ica.m`
   * This is done twice because one filter value is used to calculate ICA weights while the other is used to actually filter the data of interest.
   * This also means that the preprocessing pipeline gets split at this point and rejoins when removing ICA components
1. Automatically identify bad channels to be removed for ICA `identify_bad_channels.m`
   * Can check that this is reasonable by using `summarize_bad_channels.m` and `summarize_bad_channels.R` to plot
   * Channels are simply *identified* here are being bad and are then held out from ICA. They will be interpolated later.
1. Epoch for ERPs `epoch_trials.m`
1. Automatically identify bad epochs to be removed for ICA `identify_and_remove_bad_epochs_for_ica.m` and then also remove these from the 0.1Hz filtered data `remove_bad_epochs.m`
   * Summarize bad epochs with `summarize_bad_epochs.m` and `summarize_bad_epochs.R`
1. Run ica to identify eyeblink components for later removal. `ica.m`
1. Run sasica to help figure out which components to remove `sasica_preproc.m`
   * Note - this is a step that requires manual intervention (i.e., it cannot be run as a script across subjects)
   * Components that are candidates for removal should be highly correlated with the VEOG channels and have a frontal distribution (see Chaumon et al., 2015 for examples)
   * Candidate components should be checked by trying out removing them and ensuring only occular activity is removed.
1. Manually check the data (this will be done in the process of reviewing the ICA components).
1. Manually review ICA components `ica_btw_data.m` (to manually review)
   * This is where the two different HPF data streams get merged. Based on Makoto recommendations, the ICA components are computed on 1Hz HPF data and then applied to the 0.1 HPF data.
1. Create subject-specific files for blink components to remove (script also generates information about bad channels and epochs): `create_subject_drop_files.py`

--- Can run following steps with the script `post_ica_processing_combined.m` ---
1. Remove eyeblink components: `ica_btw_data_no_manual.m`
1. Interpolate removed channels. `interpolate_chans.m`
   * Interpolating *after* ICA as recommended by this post [!https://sccn.ucsd.edu/pipermail/eeglablist/2017/012384.html].
1. Remove manually identified bad epochs (must be done before merging because epoch ids are block specific): `remove_manual_bad_epochs.m`
1. Merge the data across blocks `merge.m`
1. Identify subjects who do not meet the minimum number of trials: `count_erp_epochs.m`
1. Baseline correct ERPs `baseline.m`

## Plotting
1. Group-level ERPs `plot_erps.m` and `erp_plotting.m`

## Nonparametric cluster-based permutation analysis
1. Perform the comparison between Familiar and Correct Rejection ERP trials as well as Remember and Familiar ERP trials at the group level `permutation_analysis_overall.m`. Need to have 'biosemi64new.lay' channel layout file.
1. Plot the overall Familiar - Correct Rejection and Remember - Familiar effects, respectively, corresponding roughly to the significant clusters identified in the data-driven permutation analysis `permutation_analysis_overall_plot_familiarity.m` and `permutation_analysis_overall_plot_recollection.m` 

## Correlation between ERPs and behavioral data
1. Perform the correlation analysis between Familiar - Correct Rejection ERP differences with familiarity behavioral estimates and between Remember - Familiar ERP differences with recollection behavioral estimates `permutation_analysis_correlation.m`
1. Plot the familiarity and recollection correlation effects, respectively, corresponding roughly to the significant clusters identified in the data-driven permutation analysis `permutation_analysis_correlation_plot_familiarity.m` and `permutation_analysis_correlation_plot_recollection.m`
