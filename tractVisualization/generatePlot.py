import os.path as op
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
#读取表格
df = pd.read_excel('/Users/roger/Documents/科研/IXT_DTI_research/202311结果（80percent）/test1.xlsx')
#需要生成图像的tract列表
tractList = np.array(["fibs_CAL_to_MT_R_cleaned.tck", "fibs_THA_L_to_SC_cleaned.tck"])
tractList = np.array(["fibs_sFEF_R_to_SC_cleaned.tck", "fibs_DLPFC_R_to_sFEF_R_cleaned.tck"])

# create plots 
#设置生成的图中有imagX行，imagY列
imagX = 1
imagY = 2
#指定输出的指标： FA, MD, AD, RD中的一个
dtiPara = "AD"
fig, ax = plt.subplots(imagX, imagY, constrained_layout=True, sharey="row", figsize=(imagY * 4, imagX * 3))
i = 0
j = 0
for tract in tractList:
    tractName = tract.split(".")[0]
    df_tract = df.query("tractName == @tractName")
    if imagX == 1:
        subplot = sns.lineplot(data=df_tract, x="node", y=dtiPara, hue="group", errorbar=("se", 1), ax=ax[j])
    if imagX > 1:
        subplot = sns.lineplot(data=df_tract, x="node", y=dtiPara, hue="group", errorbar=("se", 1), ax=ax[i,j])
    subplot.set_ylabel(dtiPara)
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