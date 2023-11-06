import pandas as pd

# 读取Excel文件
df = pd.read_excel('./tractVisualization/test.xlsx')

# 提取node为10到90的行
filtered_df = df[(df['node'] >= 11) & (df['node'] <= 90)]

# 根据name和actName分组，计算平均值
result_df = filtered_df.groupby(['name', 'tractName', 'group'])['values'].mean().reset_index()

# 重命名列
result_df.columns = ['name', 'tractName', 'group', 'average_value']

# 打印结果
print(result_df)
