# -*- coding: utf-8 -*-

from __future__ import print_function, division

import os
import numpy as np
from .maps import compute_maps
from .signal import hjorth_montage, cut_signal
from .mp import serialize_fragments
from .book_reader import BookImporter


def get_data_path(file_name=''):
    path = os.environ.get('SIGNAL_UTILS_DATA_PATH')
    if path is None:
        return os.path.join(os.path.expanduser('~'), 'signal_utils_data', file_name)
    else:
        return os.path.join(path, file_name)


def serialize_fragments_tfstats(frags, file_name):
    print('Saving data for TFStats to file:', file_name)
    data = np.array(frags).T
    print('Data shape:', data.shape)
    print('Data type:', data.dtype)
    with open(file_name, 'wb') as f:
        data.tofile(f)

