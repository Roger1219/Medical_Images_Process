#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.
rawDataWd="/Volumes/RogerSSD/backup/fMRI2021/rawData"
pwd="/Volumes/RogerSSD/fMRI2023/TWOGAM"

patientList="PA10 PA15 PA16 PA17 PA20 PA21 PA22 PA23 PA25 PA26 PA27 PA28 PA30 PA31"
for patientName in $patientList
    do
        patientWD=$pwd/$patientName
        maskWD=$patientWD/mni152Space
        scp -r roger@192.168.50.38:/media/win/MRI_Project/DTI_raw/tractFmriAnalysis/$patientName/trksROI/mni152Space $maskWD/
        if [ ! -d $maskWD/mean1D ]; then
            mkdir $maskWD/mean1D
        fi
        #extract each tract from epi01.nii and epi02.nii and calculate the mean of each voxel to generate the mean value - time file(.1D)
        for maskName in $(ls $maskWD |grep .nii)
            do
                extractMaskName=${maskName#*mask_}
                extractMaskName=${extractMaskName%_cleaned*}
                epiList="epi01 epi02"
                for epiFile in $epiList
                    do
                        epiWD=$patientWD/$epiFile.nii.gz
                        echo $epiWD
                        outputName=${epiFile}_${extractMaskName}
                        3dmaskave -quiet -mask $maskWD/$maskName $epiWD > $maskWD/mean1D/$outputName.1D
                    done
            done
    done