#!/bin/bash
#提取afni的Brik文件中的num子集并导出，然后转换成nii格式。
cd /media/win/MRI_Project/fMRI2021/interaction_6S/strabismus
patientList=$(ls |grep "BRIK")
num=7
for patient in $patientList
do
    #extract patient name
    patientName=${patient#*.}
    patientName=${patientName%+*}

    patientName=$patientName$num
    echo $patientName 
    3dbucket -prefix $patientName $patient[$num]
    3dAFNItoNIFTI $patientName+tlrc.BRIK 
    mv $patientName.nii C-R/
    rm $patientName+tlrc.*
done