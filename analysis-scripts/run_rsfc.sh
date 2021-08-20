# This shell script executes a series of commands in AFNI that take you from extracting a time course from your ROIs to generating
# z-scored functional connectivity maps.

# Created by Z. Reagh 04/2018

# Execute with the following: for subj in {SUBJECTS}; do cd $subj/*results*; echo "Beginning RSFC analysis for" $subj; ../.././run_rsfc.sh; echo "Done!"; cd ../..; done
# N.B.: PRC and PHC masks are "resampled" - all this means is that I enforced the grid size of the processed fMRI data (the "anaticor" files below) onto the masks

# Extract time series of a single subject using this mask:
echo "Extracting time series from the masks..."
3dmaskave -quiet -mask PRC_mask_resampled+tlrc *anaticor+tlrc* > PRC_timecourse.txt
3dmaskave -quiet -mask PHC_mask_resampled+tlrc *anaticor+tlrc* > PHC_timecourse.txt

# Enforce a TR structure on the data (IMPORTANT!!! Otherwise 3dfim+ in the next step will barf):
echo "Reminding AFNI that our 'data' file has a TR structure..."
3drefit -TR 1.22 *anaticor+tlrc*

# Create functional connectivity maps:
echo "Computing functional connectivity maps..."
3dfim+ -input *anaticor+tlrc.BRIK* -polort 0 -ideal_file PRC_timecourse.txt -out Correlation -bucket PRC_corrmap
3dfim+ -input *anaticor+tlrc.BRIK* -polort 0 -ideal_file PHC_timecourse.txt -out Correlation -bucket PHC_corrmap

# Convert to z-scores:
echo "Z-scoring functional connectivity maps..."
3dcalc -a *PRC_corrmap*BRIK -expr 'log((1+a)/(1-a))/2' -prefix PRC_corr_z
3dcalc -a *PHC_corrmap*BRIK -expr 'log((1+a)/(1-a))/2' -prefix PHC_corr_Z
