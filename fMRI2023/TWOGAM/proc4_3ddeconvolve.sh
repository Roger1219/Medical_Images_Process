#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.
rawDataWd="/Volumes/RogerSSD/backup/fMRI2021/rawData"
pwd="/Volumes/RogerSSD/fMRI2023/TWOGAM"

patientList="PA5 PA6 PA7 PA8 PA10 PA15 PA16 PA17 PA20 PA21 PA22 PA23 PA25 PA26 PA27 PA28 PA30 PA31"
#patientList="PA4"
for patientName in $patientList
    do
        patientWD=$pwd/$patientName
        maskWD=$patientWD/mni152Space
        if [ ! -d $maskWD/mean1D ]; then
            mkdir $maskWD/mean1D
        fi
        patientPreWD=$patientWD/$patientName.results
        cd $patientPreWD
        # prepare head motion files for regression below
        # compute de-meaned motion parameters (for use in regression)
        1d_tool.py -infile dfile_rall.1D -set_nruns 2                            \
                    -demean -write motion_demean.1D -overwrite
        # convert motion parameters for per-run regression
        1d_tool.py -infile motion_demean.1D -set_nruns 2                         \
                    -split_into_pad_runs mot_demean -overwrite
        # create censor file motion_${subj}_censor.1D, for censoring motion 
        1d_tool.py -infile dfile_rall.1D -set_nruns 2                            \
                    -show_censor_count -censor_prev_TR                            \
                    -censor_motion 0.3 motion1_${patientName} -overwrite

        #extract each tract from epi01.nii and epi02.nii and calculate the mean of each voxel to generate the mean value - time file(.1D)
        for maskName in $(ls $maskWD |grep .nii)
            do
                extractMaskName=${maskName#*mask_}
                extractMaskName=${extractMaskName%_cleaned*}
                outputFolder="1dstat"
                if [ ! -d $outputFolder ]; then
                    mkdir $outputFolder
                fi
                3dDeconvolve -force_TR 2.4 -input $maskWD/mean1D/epi01_$extractMaskName.1D\' $maskWD/mean1D/epi02_$extractMaskName.1D\'     \
                             -jobs 10                                            \
                             -polort A                                           \
                             -ortvec mot_demean.r01.1D mot_demean_r01            \
                             -ortvec mot_demean.r02.1D mot_demean_r02            \
                             -censor motion1_${patientName}_censor.1D             \
                             -num_stimts 3                                                        \
                             -local_times                                                         \
                             -stim_times 1 /Volumes/RogerSSD/fMRI2023/stimuli/Convergence.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,10)'               \
                             -stim_label 1 convergence                                            \
                             -stim_times 2 /Volumes/RogerSSD/fMRI2023/stimuli/Relax.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,10)'                     \
                             -stim_label 2 relax                                                  \
                             -stim_times 3 /Volumes/RogerSSD/fMRI2023/stimuli/Rest.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,8)'                       \
                             -stim_label 3 rest                                                   \
                             -gltsym 'SYM: convergence - relax'                                   \
                             -glt_label 1 C-R                                                     \
                             -fout -tout -bout -x1D $outputFolder/X.xmat_${extractMaskName}.1D -xjpeg $outputFolder/X_${extractMaskName}.jpg                              \
                             -x1D_uncensored $outputFolder/X.nocensor.xmat_${extractMaskName}.1D                                   \
                             -errts $outputFolder/errts.${patientName}_${extractMaskName}                                          \
                             -bucket $outputFolder/stats.${patientName}_${extractMaskName} > $outputFolder/stats.${patientName}_${extractMaskName}_details

            done
    done