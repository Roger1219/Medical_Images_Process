#!/bin/bash

# 设置文件夹路径
fMRIFolder="/media/mripc/Data2/MRI/2018XTfMRI/wd9/HC"
maskFolder="/media/mripc/Data2/MRI/2018XTfMRI/wd9/3mm"
outputFile="/media/mripc/Data2/MRI/2018XTfMRI/wd9/resutls.txt"

#检查outputFile是否存在
if [ -f $outputFile ]; then 
    rm $outputFile
fi

#获取所有mask名称并打印列标题
colName="Subj"
for file in "$maskFolder"/*.nii; do
    maskName="${file%.nii}"
    maskName="${maskName##*/}"
    colName="$colName $maskName"
done
echo $colName >> $outputFile

# 遍历文件夹中的所有.nii文件
for file1 in "$fMRIFolder"/*.nii; do
    # 提取文件名（包括路径）
    inputFile="$file1"
    # 去掉后缀的文件名
    inputName="${file1%.nii}"
    inputName="${inputName##*/}"
    currentRow=$inputName
    #遍历所有mask
    for file2 in "$maskFolder"/*.nii; do
        maskFile="$file2"
        maskName="${file2%.nii}"
        # echo "Input File: $inputFile; Mask File: $maskFile"
        meanValue=$(mrstats  -mask $maskFile -output mean $inputFile)
        currentRow="$currentRow $meanValue"
    done
    echo $currentRow >> $outputFile
done