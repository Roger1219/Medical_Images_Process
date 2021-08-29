#!/bin/bash

echo 'This shell for BiLR procedures after afni drawing ROIs'

rgFilePrefix='SE'

relaxStart=2
relaxEnd=4
converStart=5
converEnd=7

# For LR
## For relax
for ii in $(seq $relaxStart $relaxEnd)
  do
   number=$(($ii-$relaxStart+1))
   rgFileName=$rgFilePrefix$ii
   echo $rgFileName
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiLR+orig.BRIK.gz -expr a*b -prefix "./"$rgFileName/ax_dwi1BiLRatRelax$number.nii
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiLR+orig.BRIK.gz -expr a*b -prefix "./"ax_dwi1BiLRatRelax$number.nii
  done


## For Convergence
for ii in $(seq $converStart $converEnd)
  do
   number=$(($ii-$converStart+1))
   rgFileName=$rgFilePrefix$ii
   echo $rgFileName
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiLR+orig.BRIK.gz -expr a*b -prefix "./"$rgFileName/ax_dwi1BiLRatConvergence$number.nii
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiLR+orig.BRIK.gz -expr a*b -prefix "./"ax_dwi1BiLRatConvergence$number.nii
  done


# For MR
## For relax
for ii in $(seq $relaxStart $relaxEnd)
  do
   number=$(($ii-$relaxStart+1))
   rgFileName=$rgFilePrefix$ii
   echo $rgFileName
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiMR+orig.BRIK.gz -expr a*b -prefix "./"$rgFileName/ax_dwi1BiMRatRelax$number.nii
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiMR+orig.BRIK.gz -expr a*b -prefix "./"ax_dwi1BiMRatRelax$number.nii
  done


## For Convergence
for ii in $(seq $converStart $converEnd)
  do
   number=$(($ii-$converStart+1))
   rgFileName=$rgFilePrefix$ii
   echo $rgFileName
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiMR+orig.BRIK.gz -expr a*b -prefix "./"$rgFileName/ax_dwi1BiMRatConvergence$number.nii
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiMR+orig.BRIK.gz -expr a*b -prefix "./"ax_dwi1BiMRatConvergence$number.nii
  done


# For ON

## For relax
for ii in $(seq $relaxStart $relaxEnd)
  do
   number=$(($ii-$relaxStart+1))
   rgFileName=$rgFilePrefix$ii
   echo $rgFileName
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiON+orig.BRIK.gz -expr a*b -prefix "./"$rgFileName/ax_dwi1BiONatRelax$number.nii
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiON+orig.BRIK.gz -expr a*b -prefix "./"ax_dwi1BiONatRelax$number.nii
  done


## For Convergence
for ii in $(seq $converStart $converEnd)
  do
   number=$(($ii-$converStart+1))
   rgFileName=$rgFilePrefix$ii
   echo $rgFileName
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiON+orig.BRIK.gz -expr a*b -prefix "./"$rgFileName/ax_dwi1BiONatConvergence$number.nii
   3dcalc -a "./"$rgFileName/ax_dwi1+orig.BRIK -b "./"$rgFileName/BiON+orig.BRIK.gz -expr a*b -prefix "./"ax_dwi1BiONatConvergence$number.nii
  done

