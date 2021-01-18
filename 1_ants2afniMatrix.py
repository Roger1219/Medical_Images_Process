#!/usr/bin/env python
# -*- coding: utf-8 -*-
import numpy as np
import scipy.io as scio
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = 'Personal Information ',epilog = 'Information end ')
    parser.add_argument('-i', '--input', type=str, default='Input.mat', help='Transform matrix generated by ANTs')
    parser.add_argument('-o', '--output', type=str, default='Output.1D', help='Transform matrix used in AFNI')

    args = parser.parse_args()

    data = scio.loadmat(args.input)

    mat=np.concatenate((data['AffineTransform_float_3_3'][0:9].reshape((3,3)), data['AffineTransform_float_3_3'][9:12]),axis=1)
    center = data['fixed']
    v=np.dot(mat[0:3,0:3],-center)+mat[:,3][:,np.newaxis]+center
    matt = np.concatenate((mat[0:3,0:3],v),axis=1)

    np.savetxt(args.output, matt, delimiter='\t')




