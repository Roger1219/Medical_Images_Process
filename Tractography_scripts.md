
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
