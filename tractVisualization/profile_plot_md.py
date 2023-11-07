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
        md_img = nib.load(op.join(wdpath, subj + dtiNiiFileName))
        md = md_img.get_fdata()

        #Load tract files and extract profile
        trackPath = op.join(wdpath,"trks_202310","cleanTrks")
        for tractName in trackList:
            #This is for previous tract file
            #fulltrackname = subj + tractName
            #This is for the latest tract file
            fulltrackname = tractName
            track = (load_tractogram(op.join(trackPath, fulltrackname), 
                                        md_img, to_space=Space.VOX))
            trackWeight = gaussian_weights(track.streamlines)
            profile = afq_profile(md, track.streamlines, np.eye(4), weights=trackWeight)
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
# patientList = np.array(["PA16", "PA17", "PA19"])
# subjList = np.array(["PA4", "PA5", "PA6"])
# tractList = np.array(["_fibs_CAL_to_MT_L_cleaned.tck", "_fibs_CAL_to_MT_R_cleaned.tck"])

# formal data
patientList = np.array(["PA16", "PA17", "PA21", "PA22", "PA23", "PA25", "PA26", "PA27", "PA30", "PA31"])
subjList = np.array(["PA4", "PA5", "PA6", "PA7", "PA8", "PA10", "PA12", "PA15", "PA20", "PA28"])
#tractList = np.array(["_fibs_CAL_to_MT_R_cleaned.tck", "_fibs_MT_R_to_SC_cleaned.tck", "_fibs_PCUN_L_to_PEF_L_cleaned.tck", "_fibs_THA_L_to_SC_cleaned.tck"])
tractList = np.array(["fibs_CAL_to_MT_R_cleaned.tck", "fibs_THA_L_to_SC_cleaned.tck"])
#tractList = np.array(["fibs_CAL_to_MT_R_cleaned.tck", "fibs_DLPFC_L_to_sFEF_L_cleaned.tck", "fibs_DLPFC_R_to_sFEF_R_cleaned.tck", "fibs_PEF_R_to_SC_cleaned.tck", "fibs_sFEF_R_to_SC_cleaned.tck", "fibs_THA_L_to_SC_cleaned.tck"])
df_patient = profile_group(patientList, tractList, "patient")
df_normal = profile_group(subjList, tractList, "normal")
df = pd.concat([df_patient, df_normal], ignore_index=True)
print (df)

# create plots 
#设置生成的图中有imagX行，imagY列
imagX = 1
imagY = 2
fig, ax = plt.subplots(imagX, imagY, constrained_layout=True, sharey="row", figsize=(imagY * 4, imagX * 3))
i = 0
j = 0
for tract in tractList:
    tractName = tract.split(".")[0]
    df_tract = df.query("tractName == @tractName")
    if imagX == 1:
        subplot = sns.lineplot(data=df_tract, x="node", y="values", hue="group", errorbar=("se", 1), ax=ax[j])
    if imagX > 1:
        subplot = sns.lineplot(data=df_tract, x="node", y="values", hue="group", errorbar=("se", 1), ax=ax[i,j])
    subplot.set_ylabel(dtiParameter)
    subplot.set_title(tractName)
    if j == imagY - 1:
        i = i + 1 
        j = 0
    else:
        j = j + 1
    sns.move_legend(subplot, loc=0)

#fig = sns.lineplot(data=df, x="node", y="values", hue="group", errorbar=("se", 1))
#sns.move_legend(fig, "upper left")
plt.show()



