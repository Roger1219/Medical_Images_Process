1.  extract b=0 from DTI_corrected
2.  create 007_dti_corrected_blank.nii from nifti_header.xml.(nifiti_header.xml is created from 007_dti_corrected_b0.nii.gz)
3. run flirt_registration to registrate 3DT1 to dti_corrected_b0 and make t1toDTI_flirt.mat and 005_3DT1BRAVO_to_dti_b0_1mm.nii.gz
4. registrate MNI_icbm152 to 3DT1_dti_b0 and make MNI_to_3DT1.mat  (in server roger/sub1/result6)
5. transform mat file to 1D file 
6. apply 1D file to the roi files

