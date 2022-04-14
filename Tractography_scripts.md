
### DTI追踪相关处理脚本

1. 将一个1d矩阵转化为它的逆矩阵（用来反向变换）
	```
	cat_matvec -ONELINE Sub1_BSQ_0GenericAffine.1D -I >Sub1_BSQ_0GenericAffine_inv_warp.1D
	```
	make_inv_warp1D

2. 根据矩阵对图像进行线性、非线性变换
	* 进行逆变换
		```
		3dNwarpApply -prefix mni152_to_Sub1.nii.gz -source 'mni_icbm152_t1*.nii' -master 005_3DT1BRAVO.nii.gz -nwarp 'Sub1_BSQ_1InverseWarp.nii.gz Sub1_BSQ_0GenericAffine_inv_warp.1D'
		# -prefix 生成文件后缀
		# -source 被变换的文件
		# -master 输出的数据的坐标格式
		# -nwarp 用来变换的矩阵文件
		```
		或者：
		```
		3dNwarpApply -prefix mni152_to_Sub1.nii.gz -source 'mni_icbm152_t1*.nii' -master 005_3DT1BRAVO.nii.gz -nwarp 'Sub1_BSQ_1InverseWarp.nii.gz INV(Sub1_BSQ_0GenericAffine.1D)'
		```
		3d_inverse_warp
	* 进行正变换
		```
		name=`ls 007*.nii.gz`
		echo $name
		parallel 3dNwarpApply -prefix {.}_MNI_icbm_152.nii.gz -source {} -master Sub1_BSQ_fwd_warped.nii.gz -nwarp 'Sub1_BSQ_1Warp.nii.gz Sub1_BSQ_0GenericAffine.1D' ::: $name
		```
		3dNwarp
3. 使用ANTs配准
	* prefix 生成文件的前缀
	* fixed 用来配准的模版
	* moving 待配准的文件
	* base_mask_SyN 用来配准的模版的全脑mask
	* ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS  设置使用几个cpu核心计算
		```
		export ANTSPATH=/opt/ANTs/bin/
    	export PATH=${ANTSPATH}:$PATH
		```
		有的需要先设置路径
	ANTs
4. 将mat格式的矩阵转换为1D格式
	需要 1_ants2afniMatrix.py 脚本
	```
	1_ants2afniMatrix.py -i IndiSpace_to_2009c_0GenericAffine.mat -o IndiSpace_to_2009c_0GenericAffine.1D
	```
	matTo1D
5. 使用bet去除结构像颅骨
	```
	bet 005_3DT1BRAVO.nii.gz 005_3DT1BRAVO_bet.nii.gz -f 0.3 -m
	# -f 去颅骨的程度，越大去的越多，0～1，默认0.5
	# -m 生成bet和mask文件
	# -g 去颅骨时上下的比例，-1～1，默认0，越大上方保留的越少，下方保留的越多
	```
	makeMask
6. 从dti提取b=0的图像（用于配准）
	```
    dwiextract -bzero -fslgrad 007_DTI.bvec 007_DTI.bval 007_DTI_corrected.nii.gz - | mrmath -axis 3 - mean 007_DTI_corrected_b0.nii 
	```
	extract_b0_XML
7. 用flirt进行刚体配准（6自由度）
	```
	refer_image=007_DTI_b0.nii
	input_image=005_3DT1BRAVO
	out_image="$input_image"_to_dti

	# register to a reference and make a mat file
	flirt -ref $refer_image -in "$input_image".nii.gz -out "$out_image"_2mm.nii.gz -dof 6 -omat t1ToDTI_flirt.mat

	# use the mat file to re-register with the same voxel size in the reference (This reference is not for registration)
	flirt -ref "$input_image".nii.gz -in "$input_image".nii.gz -out "$out_image"_1mm.nii.gz -applyxfm -init t1ToDTI_flirt.mat
	```
	flirt_registration

8. 按照xml格式导出nifti文件的header
	```
	fslhd -x 007_DTI_b0.nii > 007_DTI_nifti_header.xml
	```
	修改007_DTI_nifti_header.xml，如果要改成voxel size=1,则把ndim改为3，nx,ny,nz分别扩大为原来2倍，nt=1,dx,dy,dz,dt=1，然后sto_xyz_matrix中的2改为1；

9. 根据xml格式的nifti header创建一个空的nii文件（用来配准时指定输出文件的分辨率，像素大小等）
	```
	fslcreatehd 007_DTI_nifti_header.xml 007_DTI_blank.nii.gz
	```
	然后将第7点中的第二个flirt的-ref参数改为007_DTI_blank.nii.gz，再运行第7点程序，可以得到2个配准后的文件，其中_2mm是3DT1在DTI原始空间的结果，_1mm是3DT1配准后在原T1空间的结果

10. 从dsi_studio追踪的tract的报告里提取qa，fa，rd等参数进行统计：extractExcel.py
11. 将原始dicom文件转换成nii格式，并创建bval和bvec文件   
    ```
	dcm2niix_afni ..
	```
12. 使用epi_reg 将DTI（b=0）和T1进行配准（见epi_reg）   
	1. 先运行 epi_reg 将b0向T1配准，并得到mat文件
	2. 对mat进行逆变换
	3. 将逆变换得到的mat应用于T1，得到T1_to_DTI_b0