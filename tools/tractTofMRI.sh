#!/bin/bash
set -e

# 提取tract 转换成ROI
dir="/media/win/MRI_Project/DTI_raw/tractFmriAnalysis"
for subj in $(ls $dir)
  do
  if [ -d $dir/$subj ]; then
      patient=$subj
      wd="$dir/${patient}"
      trkDir="/media/win/MRI_Project/DTI_raw/${patient}/trks_202310/trks_stat"
      matDir="/media/win/MRI_Project/DTI_raw/${patient}/ants_regestration"
      #copy trks mask from dti folder
      cp -r $trkDir $wd/
      if [ ! -d $wd/trksROI ]; then
         mkdir $wd/trksROI 
      fi
      #transform from .mif to .nii
      for mifFile in $(ls $wd/trks_stat/*.mif)
      do
      #去除路径和扩展名
      prefix=$(basename $mifFile)
      prefix=${prefix%.mif} 
      mrconvert $mifFile $wd/trksROI/$prefix.nii
      done
      rm -r $wd/trks_stat

      # transform trks mask to mni152 space
      echo "$patient starts transform trks"
      if [ ! -d $wd/trksROI/mni152Space ]; then
         mkdir $wd/trksROI/mni152Space 
      fi
      for maskFile in $(ls $wd/trksROI/*.nii)
      do
      #去除路径和扩展名
      prefix=$(basename $maskFile)
      prefix=${prefix%.nii}  
      #copy mat file and inverseWarped file
      cp $matDir/HCP_to_T1_to_DTI_b0_1InverseWarp.nii.gz $wd/
      cp $matDir/HCP_to_T1_to_DTI_b0_0GenericAffine.mat $wd/
      #prepare transform files
      inputImage=$maskFile
      outputImage="$wd/trksROI/mni152Space/${prefix}ToMNI.nii"
      referenceImage="$wd/$patient.nii"
      antsApplyTransforms -d 3 -i $inputImage \
                           -o $outputImage \
                           -r $referenceImage \
                           -t ["$wd/HCP_to_T1_to_DTI_b0_0GenericAffine.mat",1] \
                           -t "$wd/HCP_to_T1_to_DTI_b0_1InverseWarp.nii.gz"
      done

      echo "transform finished"
      # 应用到fMRI的beta图，提取Mean value
      if [ -f $wd/stats.txt ]; then
         rm $wd/stats.txt
      fi
      echo "tractName meanBeta" >> $wd/stats.txt
      for maskFile in $(ls $wd/trksROI/mni152Space/*.nii)
         do
         #去除路径、扩展名和前缀
         prefix=$(basename $maskFile)
         prefix=${prefix%_cleanedToMNI.nii}
         prefix=${prefix#binary_mask_}
         echo "current tract is: ${patient}'s ${prefix}"
         betaImage=$wd/${patient}.nii
         meanBeta=$(mrstats -mask $maskFile $betaImage -output mean)
         echo "$prefix $meanBeta" >> $wd/stats.txt
      done
  fi
done

