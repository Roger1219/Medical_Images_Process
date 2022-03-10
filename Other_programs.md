### 其他命令（待整理）
1. 3dAFNItoNIFTI 
    ```
    3dAFNItoNIFTI  XXX.BRIK
    ```
    将XXX.BRIK和XXX.HEAD转换成nii文件
2. fslchfiletype 
    ```
    fslchfiletype NIFTI fmri.img
    ```
    将 XXX.img 和 XXX.hdr 转换成nii.gz文件
3. dicomReader.py
    读取dicom格式文件，输出其全部的tag。使用时修改fileName=文件名即可