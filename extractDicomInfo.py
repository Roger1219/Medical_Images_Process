#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 14 22:46:44 2025

@author: roger
"""

import pydicom
import os
from datetime import datetime

def read_dicom_info(dicom_path):
    """
    读取DICOM文件并提取相关信息
    参数:
        dicom_path: DICOM文件路径
    返回:
        包含提取信息的字典
    """
    try:
        # 读取DICOM文件
        ds = pydicom.dcmread(dicom_path)
        
        # 初始化结果字典
        info = {}
        
        # 提取被试信息
        info['Patient Info'] = {
            'Patient ID': getattr(ds, 'PatientID', 'N/A'),
            'Patient Name': str(getattr(ds, 'PatientName', 'N/A')),
            'Patient Birth Date': getattr(ds, 'PatientBirthDate', 'N/A'),
            'Patient Sex': getattr(ds, 'PatientSex', 'N/A'),
            'Patient Age': getattr(ds, 'PatientAge', 'N/A')
        }
        
        # 提取扫描参数
        info['Scan Parameters'] = {
            'Manufacturer': getattr(ds, 'Manufacturer', 'N/A'),
            'Model': getattr(ds, 'ManufacturersModelName', 'N/A'),
            'Magnetic Field Strength': str(getattr(ds, 'MagneticFieldStrength', 'N/A')) + ' T',
            'Sequence Name': getattr(ds, 'SequenceName', 'N/A'),
            'TR (Repetition Time)': str(getattr(ds, 'RepetitionTime', 'N/A')) + ' ms',
            'TE (Echo Time)': str(getattr(ds, 'EchoTime', 'N/A')) + ' ms',
            'Flip Angle': str(getattr(ds, 'FlipAngle', 'N/A')) + '°',
            'Slice Thickness': str(getattr(ds, 'SliceThickness', 'N/A')) + ' mm',
            'FOV': f"{getattr(ds, 'Rows', 'N/A')}x{getattr(ds, 'Columns', 'N/A')}"
        }
        
        # 提取扫描时间信息
        info['Scan Time'] = {
            'Study Date': getattr(ds, 'StudyDate', 'N/A'),
            'Study Time': getattr(ds, 'StudyTime', 'N/A'),
            'Acquisition DateTime': getattr(ds, 'AcquisitionDateTime', 'N/A')
        }
        
        # 提取协议信息
        info['Protocol Info'] = {
            'Protocol Name': getattr(ds, 'ProtocolName', 'N/A'),
            'Series Description': getattr(ds, 'SeriesDescription', 'N/A'),
            'Study Description': getattr(ds, 'StudyDescription', 'N/A')
        }
        
        return info
    
    except Exception as e:
        print(f"Error reading DICOM file: {str(e)}")
        return None

def print_dicom_info(info):
    """格式化打印DICOM信息"""
    if not info:
        return
    
    print("\n=== DICOM Information ===")
    for section, data in info.items():
        print(f"\n{section}:")
        for key, value in data.items():
            print(f"  {key}: {value}")

def main():
    # 指定DICOM文件路径或目录
    dicom_path = input("请输入DICOM文件路径或包含DICOM文件的目录: ")
    
    if os.path.isdir(dicom_path):
        # 如果是目录，处理第一个DICOM文件
        for file in os.listdir(dicom_path):
            if file.lower().endswith('.dcm'):
                full_path = os.path.join(dicom_path, file)
                info = read_dicom_info(full_path)
                print_dicom_info(info)
                break
    else:
        # 处理单个文件
        info = read_dicom_info(dicom_path)
        print_dicom_info(info)

if __name__ == "__main__":
    # 确保已安装pydicom库
    try:
        import pydicom
    except ImportError:
        print("请先安装pydicom库: pip install pydicom")
        exit()
    
    main()