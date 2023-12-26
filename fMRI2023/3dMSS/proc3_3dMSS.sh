#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.

# 3dMSS程序示例
inputDir="/Volumes/RogerSSD/fMRI2023/result/3dMSS"
outputDir="/Volumes/RogerSSD/fMRI2023/result/3dMSS"


3dMSS -prefix $outputDir/MSS -jobs 10 \
      -mrr 's(age)+s(TR,by=grp)' \
      -qVars 'age, TR' \
      -mask $inputDir/mask_group.nii \
      -prediction $outputDir/pred.txt \
      -dataTable $inputDir/data.txt
