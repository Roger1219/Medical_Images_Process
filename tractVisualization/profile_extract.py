import os
import os.path as op
import matplotlib.pyplot as plt
import plotly
import numpy as np
import nibabel as nib
import dipy.data as dpd
from dipy.stats.analysis import afq_profile, gaussian_weights
from dipy.io.streamline import save_tractogram, load_tractogram
from dipy.io.streamline import load_tck
from dipy.io.stateful_tractogram import Space
import pandas as pd
import seaborn as sns
# Assign dtiParameter = "md","fa","ad" or "rd"
dtiParameter = "md"
dtiMifFileName = "_dt_" + dtiParameter + ".mif"
dtiNiiFileName = "_dt_" + dtiParameter + ".nii.gz"


def profile_group(subjList, trackList, group):
    df = pd.DataFrame()
    #process subj data
    for subj in subjList:
        #prepare workdirctory
        wdpath = op.join("/media/win/MRI_Project/DTI_raw/", subj)
        #prepare FA and DTI file
        if not(os.path.exists(op.join(wdpath, subj + dtiNiiFileName))): 
            print(os.system("mrconvert "+ op.join(wdpath, subj + dtiMifFileName ) + " " + op.join(wdpath, subj + dtiNiiFileName)))
        dti_img = nib.load(op.join(wdpath, subj + dtiNiiFileName))
        dti_para = dti_img.get_fdata()

        #Load tract files and extract profile
        trackPath = op.join(wdpath,"trks_202310","cleanTrks")
        for tractName in trackList:
            #This is for previous tract file
            #fulltrackname = subj + tractName
            #This is for the latest tract file
            fulltrackname = tractName
            track = (load_tractogram(op.join(trackPath, fulltrackname), 
                                        dti_img, to_space=Space.VOX))
            trackWeight = gaussian_weights(track.streamlines)
            profile = afq_profile(dti_para, track.streamlines, np.eye(4), weights=trackWeight)
            #create row dataframe
            df_column = pd.DataFrame(profile)
            df_column.columns = ["values"]
            #add name, tractName, nodenum, group
            name_column = pd.DataFrame({"name": [subj] * 100})
            tract_column = pd.DataFrame({"tractName": [tractName.split(".")[0]] * 100})
            node_column = pd.DataFrame({"node": list(range(1,101))})
            group_column = pd.DataFrame({"group": [group] * 100})
            subj_df = pd.concat([node_column, df_column, name_column, tract_column, group_column], axis = 1)
            #add row to the dataframe
            df = pd.concat([df, subj_df], ignore_index=True)
    return df

# Test data
#patientList = np.array(["PA16", "PA17", "PA19"])
#subjList = np.array(["PA4", "PA5", "PA6"])
#tractList = np.array(["fibs_CAL_to_MT_L_cleaned.tck", "fibs_CAL_to_MT_R_cleaned.tck"])

# formal data
patientList = np.array(["PA16", "PA17", "PA19", "PA21", "PA22", "PA23", "PA25", "PA26", "PA27", "PA30", "PA31"])
subjList = np.array(["PA4", "PA5", "PA6", "PA7", "PA8", "PA10", "PA12", "PA15", "PA20", "PA28"])
#tractList = np.array(["_fibs_CAL_to_MT_R_cleaned.tck", "_fibs_MT_R_to_SC_cleaned.tck", "_fibs_PCUN_L_to_PEF_L_cleaned.tck", "_fibs_THA_L_to_SC_cleaned.tck"])
#tractList = np.array(["fibs_CAL_to_MT_R_cleaned.tck", "fibs_THA_L_to_SC_cleaned.tck"])
#获取指定目录下的所有tck文件
tractList = np.array([])
for file in os.listdir("/media/win/MRI_Project/DTI_raw/PA4/trks_202310/cleanTrks"):
    if file.endswith('.tck'):
        tractList = np.append(tractList, file)

df_patient = profile_group(patientList, tractList, "patient")
df_normal = profile_group(subjList, tractList, "normal")
df = pd.concat([df_patient, df_normal], ignore_index=True)
print (df)

# 提取node为10到90的行
filtered_df = df[(df['node'] >= 11) & (df['node'] <= 90)]
# 根据name和actName分组，计算平均值
result_df = filtered_df.groupby(['name', 'tractName', 'group'])['values'].mean().reset_index()
# 重命名列
result_df.columns = ['name', 'tractName', 'group', 'average_value']
# 打印结果
print(result_df)
result_df.to_excel('~/80PercentResult.xlsx', index=False)



