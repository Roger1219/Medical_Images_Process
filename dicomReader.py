from fileinput import filename
import pydicom as pd
fileName = "IM0"

dcmData = pd.read_file(fileName)
 
#根据tag值获取element,然后获取值
dcmElement = dcmData.get_item([0x0028, 0x1051])
print(dcmElement.value.decode())
 
#直接使用属性名
print(dcmData.WindowWidth)
 
#遍例dicom的tag值
for key in dcmData.dir():
    if key == "PixelData":
        continue
 
    value = getattr(dcmData, key, '')
    print("%s: %s" % (key, value))
