#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division

import utils

from obci.analysis.obci_signal_processing import read_manager
import matplotlib.pyplot as py
import numpy as np
import matplotlib.mlab as mlab
import scipy.signal as ss

def find_triggers(mgr, tags, fs):
    triggers_w = []
    triggers_g = []
    triggers_r = []
    for tag in tags:
        if tag['name'] == 'white':
            triggers_w.append(int(tag['start_timestamp']*fs))
        elif tag['name'] == 'grey':
            triggers_g.append(int(tag['start_timestamp']*fs))
        elif tag['name'] == 'red':
            triggers_r.append(int(tag['start_timestamp']*fs))
        else:
            print tag['name']
            dupa()
    return triggers_w, triggers_g, triggers_r


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

def filter_data(mgr, selected_channels_idx, freq_lo, freq_hi, fs):
    print 'filtering data...'
    sig = mgr.get_samples()
    
    b, a = ss.butter(2, # Butterworth filter order
                     np.array([freq_lo, freq_hi]) / (0.5 * fs), 
                     btype='bandpass')
    
    for i in selected_channels_idx:
        sig[i] = ss.filtfilt(b, a, sig[i])
    
    mgr.set_samples(sig, mgr.get_param('channels_names'))

def serialize_data(frags,file_name,downsample=True):
    if downsample == True:
        x = np.zeros([frags.shape[1]/4,frags.shape[0]], dtype='<f')
    else:   
        x = np.zeros((frags.T.shape), dtype='<f')
    for i in xrange(frags.T.shape[1]):
        if downsample == True:
            x[:,i] = ss.decimate(frags[i,:],4)
        else:
            x[:,i] = frags[i,:]
    with open(file_name,'wb') as f:
        x.tofile(f)

def plot_maps(P_left,P_right,extent):
    py.figure(figsize=(18,10),dpi=80)
    py.subplot(121)
    im = py.imshow(np.sqrt(P_left),aspect='auto',origin='lower',extent=extent)
    py.axvline(x=4,color='r')
    py.colorbar(im, pad=0.05)
    py.ylabel(u'częstość [Hz]')
    py.xlabel('czas [s]')
    py.title('C4 lewa')
    py.ylim(0,30)
    py.subplot(122)
    im2 = py.imshow(np.sqrt(P_right),aspect='auto',origin='lower',extent=extent)
    py.axvline(x=4,color='r')
    py.xlabel('czas [s]')
    py.title('C3 prawa')
    py.ylim(0,30)
    py.colorbar(im2, pad=0.05)
    # py.savefig('./Data_30-12-14/CP1_CP2.eps')
    # py.savefig('./Data_30-12-14/CP1_CP2.png')
    py.show()

if __name__ == '__main__':
    file_name_1 = utils.get_data_path('vep_2014.12.17/aniaVEP_2014_Dec_17_1746.obci')
    file_name_2 = utils.get_data_path('vep_2014.12.17/aniaVEP2_2014_Dec_17_1754.obci')

    channels = [
        u'F3', u'F1',
        u'Fz',
        u'F2', u'F4', 
        u'FC3', u'FC1',
        u'FCz',
        u'FC2', u'FC4',
        u'C3', u'C1', 
        u'Cz',
        u'C2', # u'X',
        u'PO3', u'PO1', 
        u'POz',
        u'PO2', u'PO4',
        u'O1', 
        u'Oz',
        u'O2',
        u'A1', u'A2'
    ]

    mgr1 = read_manager.ReadManager(file_name_1 + '.xml',
                                    file_name_1 + '.raw',
                                    file_name_1 + '.tag')
    
    mgr2 = read_manager.ReadManager(file_name_2 + '.xml',
                                    file_name_2 + '.raw',
                                    file_name_2 + '.tag')
    
    mgr1.set_param('channels_names', channels)
    mgr2.set_param('channels_names', channels)
    
    fs1 = float(mgr1.get_param('sampling_frequency'))
    fs2 = float(mgr2.get_param('sampling_frequency'))

    print fs1, fs2
    # print mgr1.get_param('channels_names')
    # print len(mgr2.get_param('channels_names'))

    channels_idx = range(23)

    preprocess_data(mgr1, channels_idx)
    filter_data(mgr1, channels_idx, 5, 35, fs1)

    preprocess_data(mgr2, channels_idx)
    filter_data(mgr2, channels_idx, 5, 35, fs2)

    tags1 = mgr1.get_tags()
    tags2 = mgr2.get_tags()

    trig_1 = find_triggers(mgr1, tags1, fs1)
    trig_2 = find_triggers(mgr2, tags2, fs2)

    print len(trig_1[0]), len(trig_1[1]), len(trig_1[2])
    print len(trig_2[0]), len(trig_2[1]), len(trig_2[2])

    channel_name = 'O1'
    frags_1_w = utils.cut_signal(mgr1.get_channel_samples(channel_name), trig_1[0], int(0.25*fs1), int(0.5*fs1))
    frags_1_g = utils.cut_signal(mgr1.get_channel_samples(channel_name), trig_1[1], int(0.25*fs1), int(0.5*fs1))

    frags_1_w_n = []
    frags_1_g_n = []
    for i in xrange(len(frags_1_w)):
        frags_1_w_n.append(ss.decimate(frags_1_w[i], 2))
    for i in xrange(len(frags_1_g)):
        frags_1_g_n.append(ss.decimate(frags_1_g[i], 2))
    
    frags_1_w = np.array(frags_1_w_n)
    frags_1_g = np.array(frags_1_g_n)

    frags_2_w = utils.cut_signal(mgr2.get_channel_samples(channel_name), trig_2[0], int(0.25*fs2), int(0.5*fs2))
    frags_2_g = utils.cut_signal(mgr2.get_channel_samples(channel_name), trig_2[1], int(0.25*fs2), int(0.5*fs2))

    frags_w = np.concatenate((frags_1_w, frags_2_w))
    frags_g = np.concatenate((frags_1_g, frags_2_g))

    frags_w_avg = np.mean(frags_w, axis=0)
    frags_g_avg = np.mean(frags_g, axis=0)

    py.figure()
    py.plot(frags_w_avg)
    py.plot(frags_g_avg, 'r')
    py.show()
    
    # now fragments use 512 Hz sampling rate

    utils.serialize_fragments(frags_w, 'vep/2014.12.17_f_w.dat', 4)
    utils.serialize_fragments(frags_g, 'vep/2014.12.17_f_g.dat', 4)

    # mean_map_right_C3,extent = compute_maps(frags_right,fs)
    # mean_map_left_C4,extent = compute_maps(frags_left,fs)

    # plot_maps(mean_map_left_C4,mean_map_right_C3,extent)
