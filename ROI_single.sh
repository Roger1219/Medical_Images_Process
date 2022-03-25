#!/bin/bash

#This shell is for extract ROI in a single folder


foderNum=9
rgFilePrefix='SE'
type="Relax"
seq=3

rgFileName=$rgFilePrefix$foderNum
   
   echo $rgFileName
   
   #for BiLR
   3dcalc -a ./$rgFileName/ax_dwi1+orig.BRIK -b ./$rgFileName/BiLR+orig.BRIK.gz -expr a*b -prefix ./$rgFileName/ax_dwi1BiLRat$type$seq.nii
   3dcalc -a ./$rgFileName/ax_dwi1+orig.BRIK -b ./$rgFileName/BiLR+orig.BRIK.gz -expr a*b -prefix ./ax_dwi1BiLRat$type$seq.nii

   #for BiON
   3dcalc -a ./$rgFileName/ax_dwi1+orig.BRIK -b ./$rgFileName/BiON+orig.BRIK.gz -expr a*b -prefix ./$rgFileName/ax_dwi1BiONat$type$seq.nii
   3dcalc -a ./$rgFileName/ax_dwi1+orig.BRIK -b ./$rgFileName/BiON+orig.BRIK.gz -expr a*b -prefix ./ax_dwi1BiONat$type$seq.nii

   #for BiMR
   3dcalc -a ./$rgFileName/ax_dwi1+orig.BRIK -b ./$rgFileName/BiMR+orig.BRIK.gz -expr a*b -prefix ./$rgFileName/ax_dwi1BiMRat$type$seq.nii
   3dcalc -a ./$rgFileName/ax_dwi1+orig.BRIK -b ./$rgFileName/BiMR+orig.BRIK.gz -expr a*b -prefix ./ax_dwi1BiMRat$type$seq.nii

