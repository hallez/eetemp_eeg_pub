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
  * fieldtrip
  * //TODO Karina: add information re what's needed for cluster-based permutation testing

1. R packages
  * halle (scripts will automatically download latest version from [GitHub](https://github.com/hallez/halle)), tidyverse (>= 1.3.0), yaml

# Subjects to exclude
//TODO Karina: confirm which subjects are excluded for EEG analyses only (ie, if dropped for MRI, may be included here)
* s202: less than 30 remembered trials
* s203: issue in MRI data, run 1 **need to figure out what to do**
* s209: noise in mastoid channels that contaminates the data once it's re-referenced
* s215: less than 30 familiar trials (but not excluded from analyses)
* s216: incidental MRI finding
* s217: problem when merge behavioral and EEG data **need to figure out what to do**
* s220: less than 30 remembered trials
* s222: subject had previously participated in a related pilot (EEG and MRI sessions not completed)
* s225: less than 30 remembered trials
* s234: exclude block 4 due to mislabeled event codes
* s237: exclude block 4 due to experimenter error
* s238: less than 30 familiar trials (but not excluded from analyses)
* s239: subject did not understand task instructions (EEG and MRI sessions not completed)
* s240: excluding temporarily; seems to be something off in scoring of source data
* s248: less than 30 remembered trials
* s249: less than 30 familiar trials (but not excluded from analyses)
* s250: less than 30 remembered trials after EEG cleaning (only had 31 before cleaning)

# Behavioral Analysis
1. Open the RStudio project file in `analysis-scripts`
  * Remember that this will write out the analyzed data to a local file (ie, it's not synched across machines automatically so need to re-run analyses on each computer)
1. Load in the data `load-behavior.R`
1. Generate behavioral analyses `analyze-behavior.R`
//TODO Karina: remove scripts here that you didn't use for final EEG analyses

# EEG Analysis
## Preprocessing (can run through `ica.m` using `preproc_combined.m`)
1. Downsample the data to 128 Hz `downsample_preproc.m`
1. Add in electrode IDs `relabel_electrodes.m`
1. Re-label the event codes with meaningful values `revalue_events.m`
1. Reference `rereference.m`
1. High-pass filter `hpf_preproc.m` and `hpf_for_ica.m`
  * This is done twice because one filter value is used to calculate ICA weights while the other is used to actually filter the data of interest.
  * This also means that the preprocessing pipeline gets split at this point and rejoins when removing ICA components
1. Low-pass filter `lpf_preproc.m` and `lpf_for_ica.m`
1. Automatically identify bad channels to be removed for ICA `identify_bad_channels.m`
  * Can check that this is reasonable by using `summarize_bad_channels.m` and `summarize_bad_channels.R` to plot
  * Channels are simply *identified* here are being bad and are then held out from ICA. They will be interpolated later.
---

//TODO Halle start reviewing scripts below here
1. Epoch separately for time-frequency (`epoch_tf.m`) and ERPs (`epoch_erp.m` and `epoch_erp_ica_data.m`)
  * **STILL NEED TO UPDATE EPOCH_TF.M**
1. Automatically identify bad epochs to be removed for ICA `remove_bad_epochs_for_ica.m` and then also remove these from the 0.1Hz filtered data `remove_bad_epochs.m`
  * Summarize bad epochs with `summarize_bad_epochs.m` and `summarize_bad_epochs.R`
  * **DECIDE IF WANT TO ALSO USE `pop_eegthresh` - see `threshold_reject.m`**
1. Run ica to identify eyeblink components for later removal. `ica.m`
1. Run sasica to help figure out which components to remove `sasica_preproc.m`
  * Note - this is a step that requires manual intervention (i.e., it cannot be run as a script across subjects)
  * Components that are candidates for removal should be highly correlated with the VEOG channels and have a frontal distribtion (see Chaumon et al., 2015 for examples)
  * Candidate components should be checked by trying out removing them and ensuring only occular activity is removed.
1. Manually check the data (this will be done in the process of reviewing the ICA components).
1. Manually review ICA components `ica_btw_data.m` (to manually review)
  * This is where the two different HPF data streams get merged. Based on Makoto recommendations, the ICA components are computed on 1Hz HPF data and then applied to the 0.1 HPF data.
1. Create subject-specific files for blink components to remove (script also generates information about bad channels and epochs): `create_subject_drop_files.py`
1. --- Can run following steps with the script `post_ica_processing_combined.m`
1. Remove eyeblink components: `ica_btw_data_no_manual.m`
1. Interpolate removed channels. `interpolate_chans.m`
  * Interpolating *after* ICA as recommended by this post [!https://sccn.ucsd.edu/pipermail/eeglablist/2017/012384.html]. This makes more sense to me so that all of the data that's fed into earlier ICA and filtering steps is independent channels rather than interpolations.
1. Get a summary of all of the rejections (see Maureen's `get_rejection_report`)
  * **DOESN'T EXIST YET**
1. Remove manually identified bad epochs (must be done before merging because epoch ids are block specific): `remove_manual_bad_epochs.m`
1. (I think this is when this step is applied) `epoch_erp_ica_data.m`: this file will also contain labels for trial types
1. Merge the data across blocks `merge.m`
1. Identify subjects who do not meet the minimum number of trials: `count_erp_epochs.m`
1. Baseline correct ERPs (`baseline.m`) `baseline.m`
1. Extract area under the curve for subject specific ERPs: `compute_subj_integrals_no_study.m`
1. Create a group study dataset. `make_study.m` (this script exists, but finding the plotting with STUDY nonintuitive)
1. Group-level ERPs `plot_erps.m`
1. Time frequency `compute_tf.m`
1. Plot difference waveforms using `plot_erps_GA.m` script and `erp_plotting2.m` function, also for additional channels including fronto-temporal areas. Calculate ERPs with source response taken into account (REM_source_hits - REM trials only followed by correct source response and FAM_source_miss - FAM trials only followed by incorrect source response).
1. Perform cluster-based permutation test on ERPs using within-UO design to compare the ERPs between FAM, REM and CR cnditions, corrected for MCP. Follow scripts: `ft1_trial_definition_and_averaging.m`, `ft2_defining_neighborhood.m`, `ft3_configuring_the_test_parameters.m`, `ft4_stats_for_comparing_conditions_and_calculating_GAs.m`, `ft5a_plotting_clusters_FAMvsCR.m`, `ft5b_plotting_clusters_REMvsCR.m`, `ft5c_plotting_clusters_REMvsFAM.m`. Need to have 'biosemi64new.lay' channel layout file. -->
