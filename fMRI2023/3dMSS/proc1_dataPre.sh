#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.

pwd="/Volumes/RogerSSD/fMRI2023/result"
wdData="/Volumes/RogerSSD/backup/fMRI2021/results/202206"
folders="PA5 PA6 PA7"

for patient in $folders
  do
    echo $patient
    currentWD=$pwd/$patient

    if [ ! -d $currentWD ]; then
      mkdir $currentWD
    fi

    cp $wdData/$patient/stats*.* $currentWD
  done
