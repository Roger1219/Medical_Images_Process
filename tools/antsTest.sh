#!/bin/bash
set -e
wd="/media/win/MRI_Project/DTI_raw/tractFmriAnalysis/PA4/test"
fixedImage="HCP1065_mni_icbm152_t1_tal_nlin_asym_09c_brain.nii.gz"
movedImage="PA4_t1_bet.nii.gz"
outputImage="T1ToMNI152"
# antsRegistrationSyN.sh -d 3 -f "$wd/$fixedImage" -m "$wd/$movedImage" -t a -o "$wd/$outputImage"

# antsApplyTransforms -d 3 -i "$wd/$movedImage" -o "$wd/T1toMNI152.nii.gz" -r "$wd/$fixedImage"\
#                     -t "$wd/${outputImage}0GenericAffine.mat"

# antsApplyTransforms -d 3 -i "$wd/$fixedImage" -o "$wd/MNI152ToT1.nii.gz" -r "$wd/$movedImage" \
#                     -t ["$wd/${outputImage}0GenericAffine.mat",1] 

#transform .mif tract ROI files to .nii

tract="fibs_CAL_to_MT_L_cleaned.tck"
#tckmap -template "$wd/PA4_dt_md.mif" "$wd/$tract" - | mrthreshold - "$wd/binary_mask_${tract}.mif" -abs 0.5 -f
#mrconvert "$wd/binary_mask_${tract}.mif" "$wd/binary_mask_${tract}.nii"

#inputImage="$wd/binary_mask_${tract}.nii"
inputImage="$wd/binary_mask_fibs_CAL_to_MT_L_cleaned.tck.nii"
outputImage="$wd/binary_mask_fibs_CAL_to_MT_L_cleanedToMNI152-1.nii"
referenceImage="$wd/HCP1065_mni_icbm152_t1_tal_nlin_asym_09c_brain.nii.gz"
antsApplyTransforms -d 3 -i $inputImage \
                    -o $outputImage \
                    -r $referenceImage \
                    -t ["$wd/HCP_to_T1_to_DTI_b0_0GenericAffine.mat",1] \
                    -t "$wd/HCP_to_T1_to_DTI_b0_1InverseWarp.nii.gz"
                    