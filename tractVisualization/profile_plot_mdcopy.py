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
dtiParameter = "fa"
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
            #fulltrackname = subj + tractName. #For the latest tract file fulltrackname = tractName
            if group == "patient":
                if (subj == "PA27") or (subj == "PA31"):
                    print (subj + "chages left and right")
                    tractName = "fibs_CAL_to_MT_R_cleaned.tck"
                fulltrackname = tractName
                print (subj +"'s fulltrackname = " + fulltrackname)

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
            else:
                fulltrackname1 = tractName
                fulltrackname2 = "fibs_CAL_to_MT_R_cleaned.tck"
                print (subj +"'s fulltrackname = " + fulltrackname1 + " " + fulltrackname2)

                track1 = (load_tractogram(op.join(trackPath, fulltrackname1), md_img, to_space=Space.VOX))
                track2 = (load_tractogram(op.join(trackPath, fulltrackname2), md_img, to_space=Space.VOX))
                trackWeight1 = gaussian_weights(track1.streamlines)
                trackWeight2 = gaussian_weights(track2.streamlines)
                profile1 = afq_profile(md, track1.streamlines, np.eye(4), weights=trackWeight1)
                profile2 = afq_profile(md, track2.streamlines, np.eye(4), weights=trackWeight2)
                #create row dataframe
                df_column1 = pd.DataFrame(profile1)
                df_column1.columns = ["value1"]
                df_column2 = pd.DataFrame(profile2)
                df_column2.columns = ["value2"]
                df_average = pd.DataFrame()
                df_average['values'] = (df_column1['value1'] + df_column2['value2']) / 2
                #df_cache = pd.concat([df_column1,df_column2,df_average], axis = 1)
                #print (df_cache.head)
                #add name, tractName, nodenum, group
                name_column = pd.DataFrame({"name": [subj] * 100})
                tract_column = pd.DataFrame({"tractName": [tractName.split(".")[0]] * 100})
                node_column = pd.DataFrame({"node": list(range(1,101))})
                group_column = pd.DataFrame({"group": [group] * 100})
                subj_df = pd.concat([node_column, df_average, name_column, tract_column, group_column], axis = 1)
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
tractList = np.array(["fibs_CAL_to_MT_L_cleaned.tck"])
df_patient = profile_group(patientList, tractList, "patient")
df_normal = profile_group(subjList, tractList, "normal")
df = pd.concat([df_patient, df_normal], ignore_index=True)
print (df)
#df.to_excel('~/fibs_CAL_to_MT_L_MD.xlsx', index=False)
#result_df = df.groupby(['name', 'tractName', 'group'])['values'].mean().reset_index()
#print (result_df)

# create plots 
#设置生成的图中有imagX行，imagY列
imagX = 1
imagY = 1
fig, ax = plt.subplots(imagX, imagY, constrained_layout=True, sharey="row", figsize=(imagY * 4, imagX * 3))
i = 0
j = 0
for tract in tractList:
    tractName = tract.split(".")[0]
    df_tract = df.query("tractName == @tractName")
    if imagX == 1:
        if imagY == 1:
            subplot = sns.lineplot(data=df_tract, x="node", y="values", hue="group", errorbar=("se", 1))
        else:    
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



