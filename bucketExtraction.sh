#!/bin/bash
set -e

echo 'This shell for procedures before afni drawing ROIs'

numOfFiles=$(ls -l|grep "^d"| wc -l)

echo $numOfFiles
for folder in $(ls)
  do
  if [ -d $folder ]
     then
     echo $folder
     cd $folder
      for file in $(ls) 
      do
      if [ -d $file ] 
            then
            cd $file
            echo $file
            bvalFile=$(ls |grep "bval")
            echo $bvalFile
            num=${bvalFile%.*}
            num=${num##*_}
            3dbucket -prefix ax_dwi1 Axial_DWI_Focus_small_FOV_$num.nii[0]
            cd ..
            fi
      done
      cd ..
      fi
done
