#!/usr/bin/env tcsh

# created by Z. Reagh (March 26, 2018)
# creation date: Fri Apr 13 16:31:32 2018

# USAGE: loop through in the terminal, calling each subject as a variable (see line 13)

# N.B.: This does NOT preprocess your subjects, but rather creates subject-specific
# preprocessing scripts (naming convention: proc.$subj) in each subject's directory.
# You will need to later loop into each subject directory and actually execute these.
# The output preprocessing scripts are automatically and extensively commented!

# set subject and group identifiers
set subj  = $1
set gname = eetemp

# set data directory
set top_dir = /Volumes/dml/hrzucker/${gname}/analyzed-mri/z-analyses/${subj}

# run afni_proc.py to create a single subject processing script
afni_proc.py -subj_id $subj                                            \
        -script proc.$subj -scr_overwrite                              \
        -blocks despike tshift align tlrc volreg blur mask regress     \
        -copy_anat $top_dir/*.nii \
        -dsets                                                         \
            $top_dir/*_5.nii.gz          \
            $top_dir/*_6.nii.gz          \
            $top_dir/*_7.nii.gz          \
            $top_dir/*_8.nii.gz          \
            $top_dir/*_9.nii.gz          \
        -tcat_remove_first_trs 0                                       \
        -tlrc_base MNI_avg152T1+tlrc                                   \
        -volreg_align_to MIN_OUTLIER                                   \
        -volreg_align_e2a                                              \
        -volreg_tlrc_warp                                              \
        -blur_size 4.0                                                 \
        -regress_anaticor                                              \
        -regress_censor_motion 0.2                                     \
        -regress_censor_outliers 0.1                                   \
        -regress_bandpass 0.01 0.1                                     \
        -regress_apply_mot_types demean deriv                          \
        -regress_opts_3dD                                              \
            -GOFORIT 2                                                 \
        -regress_est_blur_errts