### DWI文件与处理
1. 转换为nii文件
    ```
    dcm2niix\_afni -f %p\_%s -o ./ ./
    ```
2. 提取b=700数据
    ```
    3dbucket -prefix ax\_dwi1 Axial\_DWI\_Focus\_small\_FOV\_4.nii\[0]`
    ```
3. afni画ROI mask 得到  BiMR+orig  和BiLR+orig

4. 统计
```
3dROIstats -mask BiMR+orig Axial\_DWI\_Focus\_small\_FOV\_4.nii
```
5. 根据mask导出ROI（为了进一步matlab统计）
```
# 集合时
3dcalc -a ax\_dwi1+orig.BRIK -b BiMR+orig.BRIK.gz -expr a\*b -prefix ax\_dwi1BiMRatConvergence.nii
# 休息时
3dcalc -a ax\_dwi1+orig.BRIK -b BiMR+orig.BRIK.gz -expr a\*b -prefix ax\_dwi1BiMRatRelax.nii
```