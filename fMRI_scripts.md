### fMRI任务的结果处理与分析
1. DICOM原始文件转换成nii文件
    ```
    uniq_images IM*[0123456789] > uniq_image_list.txt
    Dimon -infile_list uniq_image_list.txt \
	-gert_create_dataset	\
	-gert_write_as_nifti	\
	-gert_to3d_prefix T1.3D	\
	-gert_outdir ..		\
	-dicom_org		\
	-use_last_elem		\
	-save_details Dimon.details	\
	-gert_quit_on_err  
    \rm uniq_image_list.txt
    ```
    dicomToNii

2. 进行fMRI任务分析
    1. 使用脚本生成分析脚本（推荐使用这种方法）
        fMRI_make_analysis_scripts
    2. 直接修改分析脚本
        1. 设定subj为被试姓名
        2. 在同目录下准备文件：
            * 结构像： T1_3D.nii
            * 功能像： epi_r1.nii, epi_r2.nii.......
        3. 在同目录下stimuli 里准备记录了刺激开始时间的txt文件，如：relax.txt，有几个epi文件，就有几行
        4. 在run the regression analysis部分，有几个epi，就有几个stim_times，BLOK（6，1）,6代表刺激的持续时间，跟txt文件中的时间有关；
        * 文件：fMRI_process
    
3. 进行组分析（比较多个被试的任务结果）
    ```
    3dttest++ -prefix AAA -AminusB -paired \
	  -mask BBB				\
	  -setA Convergence				\
	  	LS "$dirA/stats.LuoSha+tlrc[1]"		\
	  -setB Relax					\
		LS "$dirA/stats.LuoSha+tlrc[4]"	
    ```
    备注：  
        1. `-resid q+tlrc`  
        Output the residuals into a dataset with prefix 'q'.    
        2. `-ACF`   
        If residuals are saved, also compute the ACF parameters from them using program 3dFHWMx --for further use in 3dClustSim (which must be run separately).     
        3. `-Clustsim`  
        直接生成cluster level的结果，在afni直接可以看到 
    * 文件：fMRI_analysis    

4. 进行多重比较检验（计算voxie数量及其检验效能）
    1. 3dFWHMx  
        ```
        3dFWHMx -detrend -mask AAA    \
            -acf BBB.1D               \
            CCC
        ```
        其中，AAA是是全脑msk，一般是full_mask.$subj+tlrc；BBB是输出的结果文件，CCC是输入的文件（残差，从上一步 -resid q得到）。
        结果得到4个数字(a,b,c,r），用与下一步计算
    2. 3dClustSim   
        ```
        3dClustSim -mask AAA -acf a b c > clustsim.txt
        ```
        其中，AAA是全脑mask，同上一步，a,b,c是上一步结果的前3个数，将结果输出到clustsim.txt中
    3. 3dttest++    
        * 在3dttest++中加入 -Clustsim 参数即可直接生成 
4. whereami -omask MASKFILE.brik    
    提供MASKFILE 的解剖定位信息