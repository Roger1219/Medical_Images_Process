### DWI文件与处理
1. 转换为nii文件
    ```
    dcm2niix\_afni -f %p\_%s -o ./ ./
    ```
    rawToNii.sh
    * 将脚本拷贝到SE序列文件夹的目录中，运行脚本，会自动在每一个SE文件夹中生成nii图像文件
2. 提取b=700数据
    ```
    3dbucket -prefix ax_dwi1 Axial_DWI_Focus_small_FOV_4.nii[0]
    ```
3. afni画ROI mask 得到  BiMR+orig  和BiLR+orig

4. 统计
    ```
    3dROIstats -mask BiMR+orig Axial\_DWI\_Focus\_small\_FOV\_4.nii
    ```
5. 根据mask导出ROI（为了进一步matlab统计）
    ```
    # 集合时
    3dcalc -a ax_dwi1+orig.BRIK -b BiMR+orig.BRIK.gz -expr a*b -prefix ax_dwi1BiMRatConvergence.nii
    # 休息时
    3dcalc -a ax_dwi1+orig.BRIK -b BiMR+orig.BRIK.gz -expr a*b -prefix ax_dwi1BiMRatRelax.nii
    ```
    ROI_Extract.sh
    * 批量提取所有文件夹中MR、ON、LR的ROI
    
6. Matlab 分析程序

     分别指定放松和集合状态的文件数量，然后从matlab运行rgCalculatorForAll.m文件