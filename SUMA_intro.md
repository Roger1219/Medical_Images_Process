SUMA使用教程
1. 配准到标准空间后使用SUMA
2. 下载SUMA文件 https://afni.nimh.nih.gov/pub/dist/tgz/
3. 拷贝SUMA辅助文件到目录，解压缩
4. 将解压缩里面的-urfvol.nii文件做underlay，待输出的结果做overlay在afni打开
5. 打开SUMA：suma -spec suma_MNI152_2009/std.141.MNI152_2009_both.spec -sv MNI152_2009_urfVol.nii &
6. 按 “t” 与afni连接，将结果映射到suma，此时在afni调整就会在suma大脑皮层表面空间对应调整
7. SUMA快捷键：
    1. "a"：取消映射透明；
    2. "."：调整suma大脑皮层显示模式
    3. 鼠标拖动旋转，或方向键。CTRL+方向键，正方位
    4. 鼠标滚轮：放大缩小，“z“和”Z“缩小、放大
    5. “[", "]"显示、隐藏左右大脑半球
    6. CTRL+鼠标左键拖动，同时旋转两个大脑半球，上下调整距离
    7. “m“+方向键：自动旋转，”m“+鼠标拖动：自定义速度方向旋转
    8. CTRL+"r"：保存当前图片
    9. “R“：开始录屏；