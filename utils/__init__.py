# -*- coding: utf-8 -*-

from __future__ import print_function, division

import os
from .maps import compute_maps
from .signal import hjorth_montage, cut_signal
from .mp import serialize_fragments

def get_data_path(file_name):
    path = os.environ.get('SIGNAL_UTILS_DATA_PATH')
    if path is None:
        return os.path.join(os.path.expanduser('~'), 'signal_utils_data', file_name)
    else:
        return os.path.join(path, file_name)

