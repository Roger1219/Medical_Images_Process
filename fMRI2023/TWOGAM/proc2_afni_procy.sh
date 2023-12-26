#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.
rawDataWd="/Volumes/RogerSSD/backup/fMRI2021/rawData"
pwd="/Volumes/RogerSSD/fMRI2023/TWOGAM"
if [ ! -d $pwd ]; then 
    mkdir $pwd
fi
patientList="PA15 PA16 PA17 PA20 PA21 PA22 PA23 PA25 PA26 PA27 PA28 PA30 PA31"
for folder in $patientList
  do
    subjFolder=$pwd/$folder
    if [ ! -d $subjFolder ]; then 
        mkdir $subjFolder
    fi
    cd $subjFolder
    afni_proc.py                                                         \
        -subj_id                  $folder                                \
        -copy_anat                $rawDataWd/$folder/T1_3D.nii           \
        -dsets                    $rawDataWd/$folder/epi_r?.nii          \
        -blocks                   tshift align tlrc volreg mask blur     \
                                  scale                                  \
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
        -script proc.$folder \
        -scr_overwrite \
    \
        -html_review_style pythonic                               \
        -execute
    3dAFNItoNIFTI -prefix epi01.nii.gz  ./$folder.results/pb04.$folder.r01.scale+tlrc.BRIK
    3dAFNItoNIFTI -prefix epi02.nii.gz  ./$folder.results/pb04.$folder.r02.scale+tlrc.BRIK
    done