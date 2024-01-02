library(readxl)
library(dplyr)
library(car)
library(openxlsx)

setwd("/Users/roger/Documents/科研/IXT_DTI_research/20231229_fMRI结果")

# 读取 Excel 表，确定比较哪一列的数据，分组信息在group列
excelName <- "同侧对侧比较Result.xlsx"
examineColumnName <- "rest"

df <- read_excel(excelName, sheet = "Sheet1")
tracts <- unique(df$tract)
#将待检验的列存入examineColumn
df$examineColumn <- df[[examineColumnName]]

#only for test
tractName <- "CAL_to_MT_R"
subdf <- subset(df, tract==tractName)

result_df <- data.frame()
for (tractName in tracts) {
  # 提取每一个tractName 进行双样本t检验
  subdf <- subset(df, tract==tractName)
  normalGroup <- subset(subdf, group=='Normal')
  patientGroup <- subset(subdf, group=='Patient')
  pvalue <- 0
  levenePvalue <- 0
  NormalityPvalue <- 0
  NormalSW <- 0
  PatientSW <- 0
  
  #SW小样本正态性检验
  norSWResult <-shapiro.test(normalGroup$examineColumn)$p.value
  patSWResult <-shapiro.test(patientGroup$examineColumn)$p.value
  #判断正态分布
  if (norSWResult > 0.05 && patSWResult > 0.05) {
    #若正态分布，进一步判断方差齐性
    leveneTestResult <- leveneTest(examineColumn~ group, data = subdf)
    levenePvalue <- leveneTestResult['group','Pr(>F)']
    if (levenePvalue > 0.05) {
      #方差齐，进行双样本t检验
      t_resut <- t.test(examineColumn~ group, data = subdf, var.equal = TRUE)
      pvalue = t_resut$p.value
      method = "two-sapmle t-test"
    } else {
      #方差不齐，进行welch矫正的双样本t检验
      t_resut <- t.test(examineColumn~ group, data = subdf, var.equal = FALSE)
      pvalue = t_resut$p.value
      method = "welch-corretect t-test"
    }
  } else {
    #非正态分布，进行mann-whitney U 检验
    wilcoxTestResult <- wilcox.test(examineColumn~ group, data = subdf)
    pvalue = wilcoxTestResult$p.value
    method = "mann-whitney test"
    leveneTestResult <- leveneTest(examineColumn~ group, data = subdf)
    levenePvalue <- leveneTestResult['group','Pr(>F)']
  }
  # 结果保存到t
  result_df <- rbind(result_df, data.frame(tract = tractName, pvalue = pvalue, method = method, 
                                               NormalSW = norSWResult, PatientSW = patSWResult, 
                                               NormalityPvalue = levenePvalue))
  
}



#保存
# 创建一个数据框（假设这是你的数据框）

# 指定保存的文件路径
excel_file_path <- excelName
sheet_name <- examineColumnName

# 检查文件是否存在
if (file.exists(excel_file_path)) {
  # 如果文件存在，打开文件
  wb <- loadWorkbook(excel_file_path)
} else {
  # 如果文件不存在，创建一个新文件
  wb <- createWorkbook()
}

# 将数据框保存到 Sheet1
addWorksheet(wb, sheetName = sheet_name)
writeData(wb, sheet = sheet_name, x = result_df, startCol = 1, startRow = 1)

# 保存工作簿到文件
saveWorkbook(wb, file = excel_file_path, overwrite = TRUE)

# 提示保存成功
cat("Data saved to", excel_file_path, "\n")


