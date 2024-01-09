#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.
# 与proc4相同，用来重新分析proc5合并的mask

rawDataWd="/Volumes/RogerSSD/backup/fMRI2021/rawData"
pwd="/Volumes/RogerSSD/fMRI2023/TWOGAM"

#patientList="PA4 PA5 PA6 PA7 PA8 PA10 PA15 PA16 PA17 PA20 PA21 PA22 PA23 PA25 PA26 PA27 PA28 PA30 PA31"
patientList="PA4"
for patientName in $patientList
    do
        patientWD=$pwd/$patientName
        mean1DWD=$patientWD/mni152Space/mean1D
        patientPreWD=$patientWD/$patientName.results
        outputWD=$patientWD/result20240104
        if [ ! -d $outputWD ]; then
            mkdir $outputWD
        fi
        cd $outputWD
        # prepare head motion files for regression below
        # compute de-meaned motion parameters (for use in regression)
        # 1d_tool.py -infile dfile_rall.1D -set_nruns 2                            \
        #             -demean -write motion_demean.1D -overwrite
        # convert motion parameters for per-run regression
        # 1d_tool.py -infile motion_demean.1D -set_nruns 2                         \
        #             -split_into_pad_runs mot_demean -overwrite
        # create censor file motion_${subj}_censor.1D, for censoring motion 
        # 1d_tool.py -infile dfile_rall.1D -set_nruns 2                            \
        #             -show_censor_count -censor_prev_TR                            \
        #             -censor_motion 0.3 motion1_${patientName} -overwrite

        #extract each tract from epi01.nii and epi02.nii and calculate the mean of each voxel to generate the mean value - time file(.1D)
        for maskName in $(ls $mean1DWD |grep epi01)
            do
                extractMaskName=${maskName#*epi01_}
                extractMaskName=${extractMaskName%.1D}
                echo $extractMaskName
                if [ ! -d $outputWD/1dstat ]; then
                    mkdir $outputWD/1dstat
                fi
                1dcat $mean1DWD/epi01_$extractMaskName.1D\' $mean1DWD/epi02_$extractMaskName.1D\' > $mean1DWD/merge_$extractMaskName.1D
                3dDeconvolve -force_TR 2.4 \
                             -input1D $mean1DWD/merge_$extractMaskName.1D     \
                             -jobs 10                                            \
                             -polort A                                           \
                             -ortvec $patientPreWD/motion_demean.1D motion_demean            \
                             -censor $patientPreWD/motion1_${patientName}_censor.1D             \
                             -num_stimts 3                                                        \
                             -local_times                                                         \
                             -stim_times 1 /Volumes/RogerSSD/fMRI2023/stimuli_merge/Convergence.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,10)'               \
                             -stim_label 1 convergence                                            \
                             -stim_times 2 /Volumes/RogerSSD/fMRI2023/stimuli_merge/Relax.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,10)'                     \
                             -stim_label 2 relax                                                  \
                             -stim_times 3 /Volumes/RogerSSD/fMRI2023/stimuli_merge/Rest.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,8)'                       \
                             -stim_label 3 rest                                                   \
                             -gltsym 'SYM: convergence - relax'                                   \
                             -glt_label 1 C-R                                                     \
                             -fout -tout -bout -x1D $outputWD/X.xmat_${extractMaskName}.1D -xjpeg $outputWD/X_${extractMaskName}.jpg                              \
                             -x1D_uncensored $outputWD/X.nocensor.xmat_${extractMaskName}.1D                                   \
                             -errts $outputWD/errts.${patientName}_${extractMaskName}                                          \
                             -bucket $outputWD/1dstat/stats.${patientName}_${extractMaskName} > $outputWD/1dstat/stats.${patientName}_${extractMaskName}_details

            done
    done