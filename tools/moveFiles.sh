#!/bin/bash
set -e

dirA="/media/roger/Roger SSD/backup/fMRI2021/results/202206"
dirB="/media/win/MRI_Project/DTI_raw/tractFmriAnalysis"
for folder in $(ls "${dirA}")
  do
   echo ${folder}
   targetFolder="${dirB}/${folder}"
   echo ${targetFolder}
   if [ ! -d ${targetFolder} ]; then
        mkdir -p ${targetFolder}
   fi
   cp "${dirA}"/${folder}/*.BRIK ${targetFolder}/
   cp "${dirA}"/${folder}/*.HEAD ${targetFolder}/
   # 提取第7个subbrick 并转换成nii格式
   3dbucket -prefix "${targetFolder}/${folder}-7" "${targetFolder}/*.BRIK[7]"
   3dAFNItoNIFTI -prefix "${targetFolder}/${folder}" "${targetFolder}/${folder}-7*.BRIK"
  done
