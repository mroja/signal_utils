# -*- coding: utf-8 -*-

from __future__ import print_function, division

import numpy as np
import scipy.signal as ss

def serialize_fragments(frags, file_name, downsampling_factor=1):
    if downsampling_factor == 1:
        x = np.zeros(frags.T.shape, dtype='<f')
    else:
        x = np.zeros((frags.shape[1] / downsampling_factor, 
                      frags.shape[0]), 
                     dtype='<f')

    for i in xrange(frags.T.shape[1]):
        if downsampling_factor != 1:
            x[:,i] = ss.decimate(frags[i,:], downsampling_factor)
        else:
            x[:,i] = frags[i,:]
    
    with open(file_name, 'wb') as f:
        x.tofile(f)
    print('Serialized array shape: ', x.shape)

