import os
import os.path as op
import nibabel as nib
import numpy as np

from dipy.io.streamline import load_tck
from dipy.tracking.streamline import transform_streamlines

from fury import actor, window
from fury.colormap import create_colormap

import AFQ.data.fetch as afd
patientName = "PA23"
wdpath = "/media/win/MRI_Project/DTI_raw/" + patientName
fa_img = nib.load(op.join(wdpath, patientName + "_dt_fa.nii.gz"))
fa = fa_img.get_fdata()

trackPath = op.join(wdpath,"trks_202310","cleanTrks")
tracks = []
tracks.append(load_tck(op.join(trackPath, "fibs_CAL_to_MT_L_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_CAL_to_MT_R_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_DLPFC_L_to_sFEF_L_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_DLPFC_R_to_sFEF_R_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_DLPFC_L_to_iFEF_L_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_DLPFC_R_to_iFEF_R_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_DLPFC_L_to_SEF_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_DLPFC_R_to_SEF_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_sFEF_L_to_SC_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_sFEF_R_to_SC_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_iFEF_L_to_SC_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_iFEF_R_to_SC_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_THA_L_to_SC_cleaned.tck"), fa_img))
tracks.append(load_tck(op.join(trackPath, "fibs_THA_R_to_SC_cleaned.tck"), fa_img))


t1_img = nib.load(op.join(wdpath, patientName + "_t1_bet_to_dti_1mm.nii.gz"))
t1 = t1_img.get_fdata()

tracks_t1 = []
for tck in tracks:
    tck.to_rasmm()
    tracks_t1.append(transform_streamlines(tck.streamlines, np.linalg.inv(t1_img.affine)))

tck1_t1 = tracks_t1[0]

# Visualizing bundles with principal direction coloring
def lines_as_tubes(sl, line_width, **kwargs):
    line_actor = actor.line(sl, **kwargs)
    line_actor.GetProperty().SetRenderLinesAsTubes(1)
    line_actor.GetProperty().SetLineWidth(line_width)
    return line_actor

#tck1_actor = lines_as_tubes(tck1_t1, 8)

# Slicer actors
def slice_volume(data, x=None, y=None, z=None):
    slicer_actors = []
    slicer_actor_z = actor.slicer(data)
    if z is not None:
        slicer_actor_z.display_extent(
            0, data.shape[0] - 1,
            0, data.shape[1] - 1,
            z, z)
        slicer_actors.append(slicer_actor_z)
    if y is not None:
        slicer_actor_y = slicer_actor_z.copy()
        slicer_actor_y.display_extent(
            0, data.shape[0] - 1,
            y, y,
            0, data.shape[2] - 1)
        slicer_actors.append(slicer_actor_y)
    if x is not None:
        slicer_actor_x = slicer_actor_z.copy()
        slicer_actor_x.display_extent(
            x, x,
            0, data.shape[1] - 1,
            0, data.shape[2] - 1)
        slicer_actors.append(slicer_actor_x)

    return slicer_actors

slicers = slice_volume(t1, y=120, z=t1.shape[-1]//2+4)


# Making a `scene`

scene = window.Scene()

#scene.add(tck1_actor)


# Visualizing bundles with setting bundle colors
from matplotlib.cm import tab20


tcks_actor = []
#20231129 picture1 setting
list = [1,9,11,13]
colorList = [0,8,10,12]
#20231129 picture2 setting
list = [3,5,7]
colorList = [2,4,6]

j = 0
for i in list:
    tck_actor = lines_as_tubes(tracks_t1[i], 10, colors=tab20.colors[colorList[j]])
    scene.add(tck_actor)
    j = j + 1

#color1 = tab20.colors[18]
#tck1_actor = lines_as_tubes(tck1_t1, 8, colors=color1)
#scene.clear()
#scene.add(tck1_actor)

for slicer in slicers:
    scene.add(slicer)

# Adding ROIs
from dipy.align import resample
ROIPath = op.join(wdpath, "FocuS_ROIs","native_rois")
ROIs= []
ROIs.append(nib.load(op.join(ROIPath,"11ROI_MT_R_to_" + patientName + ".nii.gz")))
ROIs.append(nib.load(op.join(ROIPath,"19ROI_SEF_to_" + patientName + ".nii.gz")))
ROIs.append(nib.load(op.join(ROIPath,"22ROI_SC_to_" + patientName + ".nii.gz")))
#ROIs.append(nib.load(op.join(ROIPath,"21ROI_sFEF_R_to_" + patientName + ".nii.gz")))

surface_color = tab20.colors[0]
surface_colors = [3,7,5,5]
surface_colors = [0,0,0,0]
i = 0
for roi in ROIs:
    roi_xform = resample(roi, t1_img)
    roi_data = roi_xform.get_fdata() > 0 
    roi_actor = actor.contour_from_roi(roi_data,color=tab20.colors[surface_colors[i]],opacity=0.25)
    #scene.add(roi_actor)
    i = i + 1

# waypoint1_xform = resample(waypoint1, t1_img)
# waypoint2_xform = resample(waypoint2, t1_img)
# waypoint3_xform = resample(waypoint2, t1_img)
# waypoint4_xform = resample(waypoint2, t1_img)
# waypoint1_data = waypoint1_xform.get_fdata() > 0
# waypoint2_data = waypoint2_xform.get_fdata() > 0
# waypoint3_data = waypoint2_xform.get_fdata() > 0
# waypoint4_data = waypoint2_xform.get_fdata() > 0


# waypoint1_actor = actor.contour_from_roi(waypoint1_data,color=surface_color,opacity=0.3)
# waypoint2_actor = actor.contour_from_roi(waypoint2_data,color=surface_color,opacity=0.3)
# waypoint2_actor = actor.contour_from_roi(waypoint2_data,color=surface_color,opacity=0.3)
# waypoint2_actor = actor.contour_from_roi(waypoint2_data,color=surface_color,opacity=0.3)
# scene.add(waypoint1_actor)
# scene.add(waypoint2_actor)
# scene.add(waypoint2_actor)
# scene.add(waypoint2_actor)

# Set camera
# 20231129 picuter1 setting
scene.set_camera(position=(320.97, 25.95, 219.28),
   focal_point=(117.04, 117.97, 107.59),
   view_up=(-0.30, -0.93, -0.21))
# 20231129 picuter2 setting
scene.set_camera(position=(-23.32, -81.35, 173.10),
   focal_point=(116.08, 109.36, 91.08),
   view_up=(0.67, -0.65, -0.36))


# Save a picture
#window.record(scene, out_path="right_hemi20231129-1.png", size=(3200,2400), reset_camera=False)
window.record(scene, out_path="right_hemi20231129-2.png", size=(3200,2400), reset_camera=False)

# Show the scene
window.show(scene, size=(3200, 2400), reset_camera=False)
scene.camera_info()
