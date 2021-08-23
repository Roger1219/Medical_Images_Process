import numpy as np
import pandas as pd

#read excel file
name = 'LXY' 
rgFile = pd.read_excel(name+'.xlsx', sheet_name='Sheet1')


# make new row for different DTI parameters
def creatNewRow(row):
    newRow = pd.DataFrame(columns = ['left iFEF','left sFEF','left PEF','right iFEF','right sFEF','right PEF','left PEF to left iFEF','left PEF to left sFEF','right PEF to right iFEF','right FEF to right sFEF',' '])
    newSequence = ['iFEF_left_TO_cerebellum_left','sFEF_left_TO_cerebellum_left','PEF_left_TO_cerebellum_left','iFEF_right_TO_cerebellum_right','sFEF_right_TO_cerebellum_right','PEF_right_TO_cerebellum_right','PEF_left_TO_iFEF_left','PEF_left_TO_sFEF_left','PEF_right_TO_iFEF_right','PEF_right_TO_sFEF_right']
    list = []
    for i in range(0,len(newSequence)):
        list.append(row[newSequence[i]])
    list.append('')
    newRow.loc[1]=list
    return newRow

# extract different parameters using creatNewRow function

qaRow = rgFile.iloc[19]
newQaRow = creatNewRow(qaRow)

faRow = rgFile.iloc[21]
newFaRow = creatNewRow(faRow)

mdRow = rgFile.iloc[22]
newMdRow = creatNewRow(mdRow)

adRow = rgFile.iloc[23]
newAdRow = creatNewRow(adRow)

rdRow = rgFile.iloc[24]
newRdRow = creatNewRow(rdRow)
#merge all paramerters
nameColumn = pd.DataFrame({'name':[name]},index = [1])
result = pd.concat([nameColumn,newQaRow,newFaRow,newMdRow,newAdRow,newRdRow], axis=1)
print(result)
result.to_excel(name+'_resutl.xlsx')

