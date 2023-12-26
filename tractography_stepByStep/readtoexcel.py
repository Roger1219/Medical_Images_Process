#!/usr/bin/env python
import os
import pandas as pd


pwd = os.getcwd()
files = os.listdir(pwd)
sumDataframes = pd.DataFrame()
normalList = [4, 5, 6, 7, 8, 10, 12, 15, 20, 28]
patientList = [16, 17, 19, 21, 22, 23, 25, 26, 27, 30, 31]

for file in files:
    if os.path.splitext(file)[1] == ".txt":
        print (file)
        currDataframe = pd.read_table(file,sep='\ ',engine='python')
        name = file.split('_',1)
        num = name[0][2:4]
        currDataframe['Name'] = name[0]
        currDataframe.insert(currDataframe.shape[1],'Group','none')
        print(num)
        if int(num) in normalList: 
            currDataframe['Group'] = "Normal"
        elif int(num) in patientList: 
            currDataframe['Group'] = "Patient"
        print(currDataframe)
        sumDataframes = pd.concat([sumDataframes, currDataframe])

print (sumDataframes)


sumDataframes = sumDataframes.reset_index()
sumDataframes = sumDataframes.rename(columns={'index':'Tck name'})

#groupDataframes = sumDataframes.groupby([sumDataframes['Tck name']])

sumDataframes.to_excel('stat202310.xlsx', sheet_name='rawData', index=False)
# meanDataframes.to_excel('normal_stat.xlsx','sumData')




