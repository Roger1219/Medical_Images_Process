library(readxl)
library(openxlsx)
library(gplots)
library(tidyr)
#非全自动程序，需要手动运行（normal目前不可提取）

# 读取 Excel 表格
df_IXTsheet <- read_excel("stat202311(ipsilateral).xlsx", sheet = "修改同侧对侧分析")
df_normalSheet <- read_excel("stat202311(ipsilateral).xlsx", sheet = "正常人两侧均值")
IXTClinicalData <- read_excel("clinical_data.xlsx", sheet = "IXT")
NormalClinicalData <-read_excel("clinical_data.xlsx", sheet = "Normal")
# 提取 group 列为 normal、IXT 的内容
df_IXT <- df_IXTsheet[which(df$Group == "Patient"), ]
df_normal <- df_normalSheet

Tck_name <- df_IXT[which(df_IXT$Name == "PA16"), ]$'Tck name'

# 按照 name 列排序
df_IXT <- df_IXT[order(df_IXT$Name), ]
df_normal <- df_normal[order(df_normal$Name), ]

# 提取 FA 列的内容并转置成一行
df_IXT_FA <- df_IXT[, c("Tck name", "FA...3", "Name")]
df_IXT_FA <- spread(df_IXT_FA, key = "Tck name", value = "FA...3")
df_normal_FA <- df_normal[, c("Tck name", "FA...3", "Name")]
df_normal_FA <- spread(df_normal_FA, key = "Tck name", value = "FA...3")
# MD
df_IXT_MD <- df_IXT[, c("Tck name", "MD...8", "Name")]
df_IXT_MD <- spread(df_IXT_MD, key = "Tck name", value = "MD...8")
df_normal_MD <- df_normal[, c("Tck name", "MD...8", "Name")]
df_normal_MD <- spread(df_normal_MD, key = "Tck name", value = "MD...8")
# AD
df_IXT_AD <- df_IXT[, c("Tck name", "AD...10", "Name")]
df_IXT_AD <- spread(df_IXT_AD, key = "Tck name", value = "AD...10")
df_normal_AD <- df_normal[, c("Tck name", "AD...10", "Name")]
df_normal_AD <- spread(df_normal_AD, key = "Tck name", value = "AD...10")
# RD
df_IXT_RD <- df_IXT[, c("Tck name", "RD...11", "Name")]
df_IXT_RD <- spread(df_IXT_RD, key = "Tck name", value = "RD...11")
df_normal_RD <- df_normal[, c("Tck name", "RD...11", "Name")]
df_normal_RD <- spread(df_normal_RD, key = "Tck name", value = "RD...11")

#增加临床数据
df_IXT_AD <- merge(df_IXT_AD, IXTClinicalData, by = "Name", all = FALSE)
df_IXT_FA <- merge(df_IXT_FA, IXTClinicalData, by = "Name", all = FALSE)
df_IXT_MD <- merge(df_IXT_MD, IXTClinicalData, by = "Name", all = FALSE)
df_IXT_RD <- merge(df_IXT_RD, IXTClinicalData, by = "Name", all = FALSE)

df_normal_AD <- merge(df_normal_AD, NormalClinicalData, by = "Name", all = FALSE)
df_normal_FA <- merge(df_normal_FA, NormalClinicalData, by = "Name", all = FALSE)
df_normal_MD <- merge(df_normal_MD, NormalClinicalData, by = "Name", all = FALSE)
df_normal_RD <- merge(df_normal_RD, NormalClinicalData, by = "Name", all = FALSE)

#写入excle
wb <- createWorkbook()
addWorksheet(wb, "IXT_MD")
addWorksheet(wb, "IXT_FA")
addWorksheet(wb, "IXT_AD")
addWorksheet(wb, "IXT_RD")
addWorksheet(wb, "Normal_MD")
addWorksheet(wb, "Normal_FA")
addWorksheet(wb, "Normal_AD")
addWorksheet(wb, "Normal_RD")
writeData(wb, "IXT_MD", df_IXT_MD)
writeData(wb, "IXT_FA", df_IXT_FA)
writeData(wb, "IXT_AD", df_IXT_AD)
writeData(wb, "IXT_RD", df_IXT_RD)
writeData(wb, "Normal_MD", df_normal_MD)
writeData(wb, "Normal_FA", df_normal_FA)
writeData(wb, "Normal_AD", df_normal_AD)
writeData(wb, "Normal_RD", df_normal_RD)
saveWorkbook(wb, file = "DTI_correlation202311.xlsx", overwrite = TRUE)
#write.xlsx(df_IXT_AD, file = "DTI_correlation.xlsx", rowNames = FALSE)

#提取组间比较显著的纤维束
 #IXT组
TrkList <- c("CAL_to_MT_R_cleaned", "PEF_R_to_SC_cleaned", "THA_L_to_SC_cleaned", "sFEF_R_to_SC_cleaned", "DLPFC_L_to_sFEF_L_cleaned", "DLPFC_R_to_sFEF_R_cleaned", "angle", "duration")

df_IXT_MD_extract <-df_IXT_MD[, TrkList]
df_IXT_FA_extract <-df_IXT_FA[, TrkList]
df_IXT_AD_extract <-df_IXT_AD[, TrkList]
df_IXT_RD_extract <-df_IXT_RD[, TrkList]

#把新增的内容保存到DTI_correlation.xlsx中
wb <- loadWorkbook("DTI_correlation202310.xlsx")
addWorksheet(wb, "IXT_MD_extract")
writeData(wb, sheet = "IXT_MD_extract", df_IXT_MD_extract)
addWorksheet(wb, "IXT_FA_extract")
writeData(wb, sheet = "IXT_FA_extract", df_IXT_FA_extract)
addWorksheet(wb, "IXT_AD_extract")
writeData(wb, sheet = "IXT_AD_extract", df_IXT_AD_extract)
addWorksheet(wb, "IXT_RD_extract")
writeData(wb, sheet = "IXT_RD_extract", df_IXT_RD_extract)

saveWorkbook(wb,"DTI_correlation202310.xlsx", overwrite = TRUE)

 #Normal组
TrkList <- c("CAL_to_MT_R_cleaned", "PEF_R_to_SC_cleaned", "THA_L_to_SC_cleaned", "sFEF_R_to_SC_cleaned", "DLPFC_L_to_sFEF_L_cleaned", "DLPFC_R_to_sFEF_R_cleaned")

df_normal_MD_extract <-df_normal_MD[, TrkList]
df_normal_FA_extract <-df_normal_FA[, TrkList]
df_normal_AD_extract <-df_normal_AD[, TrkList]
df_normal_RD_extract <-df_normal_RD[, TrkList]
#把新增的内容保存到DTI_correlation.xlsx中
wb <- loadWorkbook("DTI_correlation202310.xlsx")
addWorksheet(wb, "Normal_MD_extract")
writeData(wb, sheet = "Normal_MD_extract", df_normal_MD_extract)
addWorksheet(wb, "Normal_FA_extract")
writeData(wb, sheet = "Normal_FA_extract", df_normal_FA_extract)
addWorksheet(wb, "Normal_AD_extract")
writeData(wb, sheet = "Normal_AD_extract", df_normal_AD_extract)
addWorksheet(wb, "Normal_RD_extract")
writeData(wb, sheet = "Normal_RD_extract", df_normal_RD_extract)

saveWorkbook(wb,"DTI_correlation202310.xlsx", overwrite = TRUE)


#计算相关系数


# 获取数据框中的列名
df_cache <- df_IXT_FA
df_cache$Name <- NULL
IXT_FA_result <- compute_correlation_matrix(df_cache)
#print(IXT_FA_result$r_matrix)
rownames(IXT_FA_result$r_matrix) <- colnames(df_cache)
colnames(IXT_FA_result$r_matrix) <- colnames(df_cache)
rownames(IXT_FA_result$p_matrix) <- colnames(df_cache)
colnames(IXT_FA_result$p_matrix) <- colnames(df_cache)


heatmap(IXT_FA_result$r_matrix[rev(colnames(df_cache)),], 
        Colv = NA, Rowv = NA, 
        scale = "none", 
        col = colorRampPalette(c("blue", "white", "red"))(100),
        main = "Correlation Coefficients (r)")

heatmap(IXT_FA_result$p_matrix(rev(colnames(df_cache))), 
        Colv = NA, Rowv = NA, 
        scale = "none", 
        col = colorRampPalette(c("red", "blue"))(100),
        main = "p-values")








# 定义一个函数，用于生成相关系数矩阵
compute_correlation_matrix <- function(df) {
  # 获取数据框中的列名
  col_names <- colnames(df)
  
  # 初始化空的结果矩阵
  r_matrix <- matrix(0, nrow = length(col_names), ncol = length(col_names))
  p_matrix <- matrix(0, nrow = length(col_names), ncol = length(col_names))
  
  # 设置行标题和列标题
  rownames(r_matrix) <- col_names
  colnames(r_matrix) <- col_names
  rownames(p_matrix) <- col_names
  colnames(p_matrix) <- col_names
  
  # 遍历所有列的组合，并计算相关系数 r 和 p 值
  for (i in 1:(length(col_names)-1)) {
    for (j in (i+1):length(col_names)) {
      col1 <- df[[col_names[i]]]
      col2 <- df[[col_names[j]]]
      
      # 计算相关系数 r 和 p 值
      cor_result <- cor.test(col1, col2)
      
      # 将结果存入矩阵中
      r_matrix[i, j] <- cor_result$estimate
      r_matrix[j, i] <- cor_result$estimate
      p_matrix[i, j] <- cor_result$p.value
      p_matrix[j, i] <- cor_result$p.value
    }
  }
  
  # 返回结果矩阵
  list(r_matrix = r_matrix, p_matrix = p_matrix)
}