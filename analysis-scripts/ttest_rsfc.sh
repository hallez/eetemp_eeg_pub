# This shell script runs a one-sample t-test for each of our 2 ROIs (PRC and PHC).
# Briefly, this tests voxels against a null hypothesis of no significant correlations
# (i.e., a mean correlation coefficient of zero) at the group level. Inputs are "-prefix"
# to name your output, "-setA" to define your condition (just one for a one-sample test),
# and unfortunately, you have to input each subject's data manually here. Thanks AFNI.

# Created by Z. Reagh 10/18/2016

3dttest++ -prefix PRC_rsfc            \
-setA zscore_PRC_rsfc       		    \
subj1 "./s206/s206.results/PRC_corr_z+tlrc" \
subj2 "./s207/s207.results/PRC_corr_z+tlrc" \
subj3 "./s208/s208.results/PRC_corr_z+tlrc" \
subj4 "./s209/s209.results/PRC_corr_z+tlrc" \
subj5 "./s210/s210.results/PRC_corr_z+tlrc" \
subj6 "./s211/s211.results/PRC_corr_z+tlrc" \
subj7 "./s212/s212.results/PRC_corr_z+tlrc" \
subj8 "./s213/s213.results/PRC_corr_z+tlrc" \
subj9 "./s214/s214.results/PRC_corr_z+tlrc" \
subj10 "./s218/s218.results/PRC_corr_z+tlrc" \
subj11 "./s219/s219.results/PRC_corr_z+tlrc" \
subj12 "./s220/s220.results/PRC_corr_z+tlrc" \
subj13 "./s221/s221.results/PRC_corr_z+tlrc" \

3dttest++ -prefix PHC_rsfc            \
-setA zscore_PHC_rsfc                   \
subj1 "./s206/s206.results/PHC_corr_z+tlrc" \
subj2 "./s207/s207.results/PHC_corr_z+tlrc" \
subj3 "./s208/s208.results/PHC_corr_z+tlrc" \
subj4 "./s209/s209.results/PHC_corr_z+tlrc" \
subj5 "./s210/s210.results/PHC_corr_z+tlrc" \
subj6 "./s211/s211.results/PHC_corr_z+tlrc" \
subj7 "./s212/s212.results/PHC_corr_z+tlrc" \
subj8 "./s213/s213.results/PHC_corr_z+tlrc" \
subj9 "./s214/s214.results/PHC_corr_z+tlrc" \
subj10 "./s218/s218.results/PHC_corr_z+tlrc" \
subj11 "./s219/s219.results/PHC_corr_z+tlrc" \
subj12 "./s220/s220.results/PHC_corr_z+tlrc" \
subj13 "./s221/s221.results/PHC_corr_z+tlrc" \
