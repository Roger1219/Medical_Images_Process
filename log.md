1.  STEP1
      - extract b=0 from 007_DTIrhimsize128_corrected.nii.gz as 007_DTIrhimsize128_corrected_b0.nii
      - creat XML file from 007_DTIrhimsize128_corrected_b0.nii
      - mannuly modify XML file
2.  STEP2
      - create  007_DTIrhimsize128_corrected_blank.nii from nifti_header.xml.(nifiti_header.xml is created from  007_DTIrhimsize128_corrected_b0.nii.gz)
3. STEP3
     - run flirt_registration to registrate 3DT1 to dti_corrected_b0 and make t1toDTI_flirt.mat and 006_3DT1BRAVO_to_dti_b0_1mm.nii.gz. Make  bet mask of 006_3DT1BRAVO_to_dti_b0_1mm.nii.gz
4. STEP4
     - registrate MNI_icbm152 to 006_3DT1BRAVO_to_dti_b0_1mm  and make MNI_to_3DT1.mat  (in server ~/roger/sub)
     ```
     scp *** root@*******
     ```
     - transform mat file to 1D file 
5. STEP5
     - apply 1D file to the roi files

- All scripts are saved in "tractrography_stepByStep" folder