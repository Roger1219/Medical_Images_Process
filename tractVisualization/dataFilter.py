import pandas as pd

# 读取Excel文件
df = pd.read_excel('/Users/roger/Documents/科研/IXT_DTI_research/202311结果（80percent）/statNodes.xlsx')

# 提取node为10到90的行
filtered_df = df[(df['node'] >= 11) & (df['node'] <= 90)]

# 根据name和tractName分组，计算平均值,以下两种方法均可
result_df = filtered_df.groupby(['name', 'tractName', 'group'])[['MD', 'FA', 'AD', 'RD']].mean().reset_index()
result_df1 = filtered_df.groupby(['name', 'tractName', 'group']).agg({'MD':'mean','FA':'mean','AD':'mean','RD':'mean'})
result_df2 = result_df1.reset_index()
# 重命名列
#result_df.columns = ['name', 'tractName', 'group', 'average_value']

# 打印结果
print(result_df2)

with pd.ExcelWriter('/Users/roger/Documents/科研/IXT_DTI_research/202311结果（80percent）/statNodes.xlsx',
                    mode='a', engine='openpyxl') as writer:
    result_df.to_excel(writer, sheet_name='Sheet3', index=False)

