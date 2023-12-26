#!/usr/bin/env python
import os
import pandas as pd


wd = "/media/win/MRI_Project/DTI_raw/tractFmriAnalysis"
files = os.listdir(wd)
sumDataframes = pd.DataFrame()
normalList = [4, 5, 6, 7, 8, 10, 12, 15, 20, 28]
patientList = [16, 17, 19, 21, 22, 23, 25, 26, 27, 30, 31]

for folder in files:
    currentDir= os.path.join(wd,folder)
    if os.path.isdir(currentDir):
        print ("current folder is: ", folder)
        statFile=os.path.join(currentDir,"stats.txt")
        currDataframe = pd.read_table(statFile,sep='\ ',engine='python')
        name = folder
        num = name[2:4]
        currDataframe['Name'] = name
        currDataframe.insert(currDataframe.shape[1],'Group','none')
        print(num)
        if int(num) in normalList: 
            currDataframe['Group'] = "Normal"
        elif int(num) in patientList: 
            currDataframe['Group'] = "Patient"
        print(currDataframe)
        sumDataframes = pd.concat([sumDataframes, currDataframe])

print (sumDataframes.head)
sumDataframes = sumDataframes.reset_index()
#sumDataframes = sumDataframes.rename(columns={'index':'Tck name'})

#groupDataframes = sumDataframes.groupby([sumDataframes['Tck name']])
output = os.path.join(wd,"stat202311.xlsx")
sumDataframes.to_excel(output, sheet_name='rawData', index=False)
# meanDataframes.to_excel('normal_stat.xlsx','sumData')




