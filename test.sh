#!/bin/bash
normalList=(PA4 PA5 PA6 PA7 PA8 PA10 PA14 PA15 PA20 PA28)
patientList=(PA17 PA19 PA21 PA22 PA23 PA25 PA26 PA27 PA30 PA31)

# for normal in ${normalList[*]}
# do
#     cp /media/win/MRI_Project/fMRI2021/$normal/stats* /media/win/MRI_Project/fMRI2021/normal_all_6s
# done

for patient in ${patientList[*]}
do
    cp /media/win/MRI_Project/fMRI2021/$patient/stats* /media/win/MRI_Project/fMRI2021/strabismus_all_6s
done





# for patient in ${patientList[*]}
# do
#     echo $patient
#     if [ ! -f "$patient" ] 
#     then
#         cd $patient
#         folderName=$(ls |grep "results.backup")
#         folderName=${folderName%%.*}
#         echo $folderName
#         if [ ! -d "afniProcScript" ]
#         then 
#         #修改afniProcScript文件中的人名为对应被试的名字
#         sed -i "2c set patientName = ${folderName}" afniProcScript
#         echo "finished"
#         fi


        # 查找一些文件并删除
        # ls
        # if [ ! -f "stats*" ] 
        # then
        # rm stats*
        # echo 1
        # fi
        # if [ ! -d "fMRI_process" ] 
        # then
        # mv fMRI_process fMRI_process.backup
        # echo 2
        # fi
        # folderName=$(ls |grep "results.backup")
        # if [ ! -f "$folderName" ] 
        # then   
        # mv $folderName $folderName".backup"
        # echo 3
        # fi
#     fi
#     cd ..
# done