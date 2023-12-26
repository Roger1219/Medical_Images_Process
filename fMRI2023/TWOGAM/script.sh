#!/bin/bash
set -e
# Written by Lin Xia Dec. 15th 2023.

./proc2_afni_procy.sh
./proc3_extractTract.sh
./proc4_3ddeconvolve.sh