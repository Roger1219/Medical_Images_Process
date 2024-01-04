#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.
patientList="PA4 PA5 PA6 PA7 PA8 PA10 PA15 PA16 PA17 PA20 PA21 PA22 PA23 PA25 PA26 PA27 PA28 PA30 PA31"

for patientName in $patientList
    do
    echo $patientName
    wd=/Volumes/RogerSSD/fMRI2023/TWOGAM/$patientName
    maskFolder=$wd/mni152Space/mergeFEF
    # 创建输出文件夹
    if [ ! -d $maskFolder ]; then
        mkdir $maskFolder
    fi
    cd $wd/mni152Space
    mrcalc -force binary_mask_DLPFC_L_to_iFEF_L_cleanedToMNI.nii binary_mask_DLPFC_L_to_sFEF_L_cleanedToMNI.nii -max $maskFolder/binary_mask_DLPFC_L_to_FEF_L_cleanedToMNI.nii
    mrcalc -force binary_mask_DLPFC_R_to_iFEF_R_cleanedToMNI.nii binary_mask_DLPFC_R_to_sFEF_R_cleanedToMNI.nii -max $maskFolder/binary_mask_DLPFC_R_to_FEF_R_cleanedToMNI.nii
    mrcalc -force binary_mask_iFEF_L_to_SC_cleanedToMNI.nii binary_mask_sFEF_L_to_SC_cleanedToMNI.nii -max $maskFolder/binary_mask_FEF_L_to_SC_cleanedToMNI.nii
    mrcalc -force binary_mask_iFEF_R_to_SC_cleanedToMNI.nii binary_mask_sFEF_R_to_SC_cleanedToMNI.nii -max $maskFolder/binary_mask_FEF_R_to_SC_cleanedToMNI.nii

    for maskName in $(ls $maskFolder |grep .nii)
    do
        extractMaskName=${maskName#*mask_}
        extractMaskName=${extractMaskName%_cleaned*}
        epiList="epi01 epi02"
        for epiFile in $epiList
            do
                epiWD=$wd/$epiFile.nii.gz
                echo $epiWD
                outputName=${epiFile}_${extractMaskName}
                mean1dfolder=$wd/mni152Space/mean1D
                3dmaskave -quiet -mask $maskFolder/$maskName $epiWD > $mean1dfolder/$outputName.1D
            done
    done
    done

