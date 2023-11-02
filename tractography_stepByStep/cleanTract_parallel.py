#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os.path as op
import os
import nibabel as nib
import AFQ.segmentation as seg
from dipy.io.streamline import save_tractogram, load_tractogram
from dipy.io.stateful_tractogram import Space
from dipy.io.stateful_tractogram import StatefulTractogram

import logging
logging.basicConfig(level=logging.INFO)

import argparse
from multiprocessing import Pool
import datetime

# Function to clean tract using distance_threshold and length_threshold
def clean_tract(input_data):
    num, tract_file, patientName, dtiIMG, distance_threshold, length_threshold, output_folder = input_data
    tractName = os.path.basename(tract_file)
    tractPrefix = os.path.splitext(tractName)[0]
    print(f"No.{num}: Processing: " + tractName)
    # Load files
    tractFile = load_tractogram(tract_file, dtiIMG, to_space=Space.VOX) # import tck files 
    print(f"Tract: {tractPrefix}".ljust(40) + f"Before cleaning: {len(tractFile)} streamlines")
    # Clean the tract
    newFibers = seg.clean_bundle(tractFile, distance_threshold=distance_threshold, length_threshold=length_threshold)
    print(f"Tract: {tractPrefix}".ljust(40) + f"After cleaning: {len(newFibers)} streamlines")
    #save log file
    logString = patientName + "\t" + tractPrefix +"\t" + str(len(tractFile)) +"\t"+ str(len(newFibers)) + "\n"
    with open(op.join(trks_dir, "log.txt"), "a") as file:
        file.write(logString)
    
    # Save the cleaned tract
    sft = StatefulTractogram(newFibers.streamlines, dtiIMG, Space.VOX)
    sft.to_rasmm()
    outputName = tractPrefix + "_cleaned.tck"
    save_tractogram(sft, op.join(output_folder, outputName), bbox_valid_check=False)

if __name__ == "__main__":
    # Prepare for I/O
    parser = argparse.ArgumentParser(description='cleaned the tracts')
    parser.add_argument('-i', '--input', type=str, default='', help="the current patient name")
    parser.add_argument('-f', '--trkfolder', type=str, default='', help="the folder name with trks")

    args = parser.parse_args()
    patientName = args.input
    trkFolder = args.trkfolder
    print(patientName)
    input_dt = 2.2
    input_lt = 2.2

    # Prepare for files
    workdirectory = op.join(os.getcwd(),patientName)
    trks_dir = op.join(workdirectory, trkFolder)
    dtiName = patientName + "_dti_biascorr.nii.gz"
    dtiIMG = nib.load(op.join(workdirectory, dtiName))

    # Make output folder
    output_folder = op.join(trks_dir, 'cleanTrks')
    if not op.exists(output_folder):
        os.makedirs(output_folder)
    #prepare for log file
    datetime = datetime.datetime.now()
    logString = "Subject" + "\t" + "Tract Name" +"\t" + "before streamlines" +"\t"+ "after streamlines" + "\n"
    with open(op.join(trks_dir, "log.txt"), "a") as file:
        file.write(str(datetime) + "Start cleaning tracts" "\n")
        file.write(logString)

    # Collect input data for parallel processing
    input_data_list = []
    num=0
    for file in os.listdir(trks_dir):
        if op.isfile(op.join(trks_dir, file)) and file != (patientName + "_fibs_200k_angle45_maxlen200_act.tck") and file.endswith(".tck"):
            num=num+1
            input_data = (num, op.join(trks_dir, file), patientName, dtiIMG, input_dt, input_lt, output_folder)
            input_data_list.append(input_data)

    # Start parallel processing
    with Pool() as pool:
        pool.map(clean_tract, input_data_list)
