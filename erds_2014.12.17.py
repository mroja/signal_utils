#!/usr/bin/env python
# -*- coding: utf-8 -*-

import utils

import numpy as np
import scipy.signal as ss

import matplotlib.pyplot as py
import matplotlib.mlab as mlab

from obci.analysis.obci_signal_processing import read_manager


def preprocess_data(mgr, selected_channels_idx):
    print 'preprocessing data...'
    sig = mgr.get_samples()
    fs = float(mgr.get_param('sampling_frequency'))
    pointsPerMicroV = [float(x) for x in mgr.get_param('channels_gains')]
    referenceSignal = 0.5 * (mgr.get_channel_samples('A1') + mgr.get_channel_samples('A2'))

    #print 'Channels: {}'.format(', '.join(mgr.get_param('channels_names')))
    #print 'Sig shape: {}'.format(sig.shape)
    #print 'Sampling frequency: {}'.format(fs)
    #print 'Channel gains: {}'.format(pointsPerMicroV)

    for i in selected_channels_idx:
        sig[i] -= referenceSignal
        sig[i] *= pointsPerMicroV[i]
    
    mgr.set_samples(sig, mgr.get_param('channels_names'))

def filter_data(mgr, selected_channels_idx, freq_lo, freq_hi):
    print 'filtering data...'
    sig = mgr.get_samples()
    
    b, a = ss.butter(2, # Butterworth filter order
                     np.array([freq_lo, freq_hi]) / (0.5 * fs), 
                     btype='bandpass')
    
    for i in selected_channels_idx:
        sig[i] = ss.filtfilt(b, a, sig[i])
    
    mgr.set_samples(sig, mgr.get_param('channels_names'))

def find_triggers(emg_signal_r, emg_signal_l, tags, fs, tag_name=None):
    b, a = ss.butter(2, 3.0 / (0.5 * fs), btype='highpass')
    emg_signal_r = ss.filtfilt(b, a, emg_signal_r)
    emg_signal_l = ss.filtfilt(b, a, emg_signal_l)

    tag_window_len = int(5 * fs)
    window_len = 60 # int(0.5 * fs)
    print 'tag_window_len:', tag_window_len
    print 'window_len:', window_len

    triggers = []
    for tag in tags:
        if tag_name is not None and tag['name'] != 'reakcja':
            continue
        #print tag

        start = int(tag['start_timestamp'] * fs)
        end = int(tag['start_timestamp'] * fs + tag_window_len)

        sig = emg_signal_r[start:end]
        for i in xrange(0, len(sig) - window_len, int(window_len)):
            s = sig[i:i + window_len]
            if i == 0:
                std_ref = np.std(s)
            if np.std(s) / std_ref > 3:
                triggers.append(start + i)
                break
        else:
            print 'left hand detection'
            sig = emg_signal_l[start:end]
            for i in xrange(0, len(sig) - window_len, int(window_len)):
                s = sig[i:i + window_len]
                if i == 0:
                    std_ref = np.std(s)
                if np.std(s) / std_ref > 3:
                    triggers.append(start + i)
                    break

    f, axarr = py.subplots(2, sharex=True)
    axarr[0].plot(emg_signal_r)
    for t in triggers:
        axarr[0].axvline(x=t, color='r')
    axarr[1].plot(emg_signal_l)
    for t in triggers:
        axarr[1].axvline(x=t, color='r')        
    py.show()
    
    return np.array(triggers)


if __name__ == '__main__':
    mode = 0
    mode = 1

    if mode == 0:
        file_name = utils.get_data_path('erds_2014.12.17/ania1_2014_Dec_17_1625.obci') # prawa reka
    elif mode == 1:
        file_name = utils.get_data_path('erds_2014.12.17/ania2_2014_Dec_17_1638.obci') # dwie rece
    else:
        print 'bad hand'
        sys.exit()

    mgr = read_manager.ReadManager(file_name + '.xml',
                                   file_name + '.raw',
                                   file_name + '.tag')
    
    channels = [
        u'F3', u'F1',
        u'Fz',
        u'F2', u'F4', 
        u'FC3', u'FC1', 
        u'FCz',
        u'FC2', u'FC4',
        u'C3', u'C1',
        u'Cz', 
        u'C2', u'C4',
        u'CP3', u'CP1',
        u'CPz', 
        u'CP2', u'CP4',
        u'O1', u'O2',
        u'A1', u'A2',
        u'EMG25', u'EMG26'
    ]
    
    mgr.set_param('channels_names', channels)
    fs = float(mgr.get_param('sampling_frequency'))
    #print 'Sampling rate: {}'.format(fs)
    
    channels_idx = range(24)
    preprocess_data(mgr, channels_idx)
    filter_data(mgr, channels_idx, 5, 35)

    hjorth_C1 = utils.hjorth_montage(
    	mgr.get_channel_samples('C1'), 
    	mgr.get_channels_samples(['C3', 'Cz', 'FC1', 'CP1'])
    )

    hjorth_C2 = utils.hjorth_montage(
    	mgr.get_channel_samples('C2'), 
    	mgr.get_channels_samples(['C4', 'Cz', 'FC2', 'CP2'])
    )

    tags = mgr.get_tags()
    #print tags

    emg25 = mgr.get_channel_samples('EMG25')  # prawa reka
    emg26 = mgr.get_channel_samples('EMG26')  # lewa reka

    if mode == 0:
        triggers = find_triggers(emg25, emg26, tags, fs, 'reakcja')
    elif mode == 1:
        triggers = find_triggers(emg25, emg26, tags, fs)
    print triggers

    before = 4
    after = 5
    frags = utils.cut_signal(hjorth_C1, triggers, int(before*fs), int(after*fs))

    print 'Computing maps...'
    mean_map, extent = utils.compute_maps(frags, fs)

    py.figure()
    py.imshow(mean_map, aspect='auto', origin='lower', extent=extent)
    #py.ylim([0, 40])
    py.axvline(x=before, color='r')
    py.colorbar()
    py.ylabel('Freq [Hz]')
    py.xlabel('Time [s]')
    py.show()

