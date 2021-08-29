#!/bin/bash

echo 'This shell for procedures before afni drawing ROIs'

numOfFiles=$(ls -l|grep "^d"| wc -l)

echo $numOfFiles


for file in `ls` 
  do
   if [ -d $file ] 
      then
	cd $file
	echo $file
	dcm2niix_afni -f %p_%s -o "./" "./"
	cd ..
      fi
  done
