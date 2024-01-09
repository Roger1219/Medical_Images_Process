#!/usr/bin/env python
import os
import pandas as pd
# Written by Lin Xia Dec. 15th 2023.

normalList = [4, 5, 6, 7, 8, 10, 15, 20, 28]
patientList = [16, 17, 21, 22, 23, 25, 26, 27, 30, 31]
allList = normalList + patientList

pwd = os.getcwd()
files = os.listdir(pwd)
sumDataframes = pd.DataFrame(columns=['name','tract','convergence','relax','rest','group'])

for num in allList:
    patientFolder = f'PA{num}'
    pwd = os.path.join('/Volumes/RogerSSD/fMRI2023/TWOGAM', patientFolder, 'result20240104', '1dstat')
    # 遍历每一个文件，寻找stat开头和.1d结尾的文件
    for fileName in os.listdir(pwd):
        currentDataframe = pd.DataFrame(columns=['name','tract','convergence','relax','rest','group'])
        if fileName.startswith('stat') and fileName.endswith('.1D'):
            print (patientFolder, fileName)
            # 提取tractname 和 3个刺激的beta值
            currentFile = os.path.join(pwd, fileName)
            with open(currentFile, 'r') as file:
                lines = file.readlines()
                # Warning! Pls make sure the line you need in the result file!!!!
                numbers = [float(line.strip()) for line in lines[8:11]]
                print(f'Numbers from lines 11-13: {numbers}')
            tractName = fileName.split('_',1)[1]
            tractName = tractName.split('.1D',1)[0]
            #将提取的数据存入dataframe
            currentDataframe = pd.DataFrame({'name': [patientFolder],
                                 'tract': [tractName],
                                 'convergence': [numbers[0]],
                                 'relax': [numbers[1]],
                                 'rest': [numbers[2]],
                                 'group':['']})
            if int(num) in normalList: 
                currentDataframe['group'] = "Normal"
            elif int(num) in patientList: 
                currentDataframe['group'] = "Patient"
            # print (currentDataframe)
            sumDataframes = pd.concat([sumDataframes, currentDataframe],ignore_index=True)

print(sumDataframes)

excel_file_path = '/Volumes/RogerSSD/fMRI2023/TWOGAM/Result_merge2.xlsx'
sumDataframes.to_excel(excel_file_path, index=False)
