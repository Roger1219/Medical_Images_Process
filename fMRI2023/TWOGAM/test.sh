#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.
3dDeconvolve -force_TR 2.4 \
             -input epi01_CAL_to_MT_L.1D\' epi02_CAL_to_MT_L.1D\'     \
             -jobs 4                                            \
             -polort A                                           \
             -censor motion1_${patientName}_censor.1D             \
             -num_stimts 3                                                        \
             -local_times                                                         \
             -stim_times 1 Convergence.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,10)'               \
             -stim_label 1 convergence                                            \
             -stim_times 2 Relax.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,10)'                     \
             -stim_label 2 relax                                                  \
             -stim_times 3 Rest.txt 'TWOGAM(5.1849,1.4339,0.0446,1.0352,665.5736,8)'                       \
             -stim_label 3 rest                                                   \
             -gltsym 'SYM: convergence + relax'                                   \
             -glt_label 1 C+R                                                     \
             -gltsym 'SYM: convergence - relax'                                   \
             -glt_label 2 C-R                                                     \
             -fout -tout -bout -x1D X.xmat.1D -xjpeg X.jpg                              \
             -x1D_uncensored X.nocensor.xmat.1D                                   \
             -errts errts                                          \
             -bucket stats > stats_details