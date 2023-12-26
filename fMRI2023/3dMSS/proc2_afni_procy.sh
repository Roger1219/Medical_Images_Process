#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.
rawDataWd="/Volumes/RogerSSD/fMRI2023/rawData"
pwd="/Volumes/RogerSSD/fMRI2023/result"
if [ ! -d $pwd ]; then 
    mkdir $pwd
fi

folders="PA7"
for folder in $folders
  do
    subjFolder=$pwd/$folder
    if [ ! -d $subjFolder ]; then 
        mkdir $subjFolder
    fi
    cd $subjFolder
    afni_proc.py                                                         \
        -subj_id                  $folder                                  \
        -copy_anat                $rawDataWd/$folder/T1_3D.nii                        \
        -dsets                    $rawDataWd/$folder/epi_r?.nii                 \
        -blocks                   tshift align tlrc volreg mask blur     \
                                  scale regress                         \
        -radial_correlate_blocks  tcat volreg                            \
        -tcat_remove_first_trs    5                                      \
        -align_unifize_epi        local                                  \
        -align_opts_aea           -cost lpc+ZZ                           \
                                  -giant_move                            \
                                  -check_flip                            \
        -tlrc_base                MNI152_2009_template.nii.gz            \
        -volreg_align_to          MIN_OUTLIER                            \
        -volreg_align_e2a                                                \
        -volreg_tlrc_warp                                                \
        -volreg_compute_tsnr      yes                                    \
        -mask_epi_anat            yes                                    \
        -blur_size                6.0                                    \
    \
        -regress_stim_times \
        /Volumes/RogerSSD/backup/fMRI2021/stimuli/Convergence.txt   \
        /Volumes/RogerSSD/backup/fMRI2021/stimuli/Relax.txt     \
        -regress_stim_labels convergence relax \
        -regress_basis 'TENT(0,10,5)'                    \
        -regress_opts_3dD  -jobs 8                                      \
                           -gltsym 'SYM: convergence - relax'           \
                           -glt_label 1 C-R                             \
        -regress_motion_per_run                                         \
        -regress_censor_motion 0.3                                      \
        -regress_compute_fitts \
        -regress_make_ideal_sum sum_ideal.1D           \
        -regress_est_blur_epits \
        -regress_est_blur_errts \
    \
        -script proc.$folder \
        -scr_overwrite \
    \
        -html_review_style pythonic                               \
        -execute
    3dAFNItoNIFTI -prefix epi01.nii.gz  ./$folder.results/pb04.$folder.r01.scale+tlrc.BRIK
    3dAFNItoNIFTI -prefix epi02.nii.gz  ./$folder.results/pb04.$folder.r02.scale+tlrc.BRIK
    done