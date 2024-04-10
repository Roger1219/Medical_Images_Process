#!/bin/bash

# 设置文件夹路径
fMRIFolder=""
maskFolder=""
outputFile=""

#获取所有mask名称并打印列标题
colName="Subj"
for file in "$maskFolder"/*.nii; do
    maskName="${file%.nii}"
    colName="$colName $maskName"
done
echo $colName >> $outputFile

# 遍历文件夹中的所有.nii文件
for file1 in "$fMRIFolder"/*.nii; do
    # 提取文件名（包括路径）
    inputFile="$file1"
    # 去掉后缀的文件名
    inputName="${file1%.nii}"
    currentRow=$inputName
    #遍历所有mask
    for file2 in "$maskFolder"/*.nii; do
        maskFile="$file2"
        maskName="${file2%.nii}"
        echo "Input File: $inputFile; Mask File: $maskFile"
    done
done




meanValue=$(mrstats  -mask $maskFile -output mean $inputFile)
currentRow="$currentRow $meanValue"

echo $currentRow >> $outputFile


maskFile="r8ROI_iFEF_L.nii"
inputFile="szfALFFMap_N1019.nii"
mrstats  -mask $maskFile -output mean $inputFile