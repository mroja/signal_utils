#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division

import utils

from obci.analysis.obci_signal_processing import read_manager
import matplotlib.pyplot as py
import numpy as np
import matplotlib.mlab as mlab
import scipy.signal as ss


def preprocess_data(mgr):
    sig = mgr.get_samples()
    fs = float(mgr.get_param('sampling_frequency'))
    pointsPerMikroV = mgr.get_param('channels_gains')
    b,a = ss.butter(2, np.array([3,49])/(fs*0.5), btype="bandpass")
    for i in xrange(23):
        sig[i] = sig[i]*float(pointsPerMikroV[i])
        sig[i] = ss.filtfilt(b,a,sig[i])
    mgr.set_samples(sig,mgr.get_param('channels_names'))


def find_blinks(diode):
    moments = np.where(diode>50000)[0]
    start = []
    start.append(moments[0])
    for i in xrange(1,len(moments)):
        if moments[i]-moments[i-1] > fs:
            start.append(moments[i])
    return np.array(start)


def load_stimuli_file(f_name):
    stimuli = []
    with open(f_name,'r') as f:
        for line in f:
            stimulus = line.split('\n')[0]
            if stimulus == 'right' or stimulus == 'left':
                stimuli.append(stimulus)
    return stimuli


def find_triggers(emg_left,emg_right,diode,triggers_file,fs):
    b,a = ss.butter(2, 3.0/(fs*0.5), btype="highpass")
    emg_left = ss.filtfilt(b,a,emg_left)
    emg_right = ss.filtfilt(b,a,emg_right)
    stimuli = load_stimuli_file(triggers_file)
    window = int(0.1*fs)
    blinks = find_blinks(diode)
    blinks += int(3*fs)
    trig_left = []
    trig_right = []
    # py.figure()
    # py.plot(emg_left)
    for idx,b in enumerate(blinks):
        start = b 
        end = b+5*fs
        if stimuli[idx] == 'left':
            sig_trunc = emg_left[start:end]
        else:
            sig_trunc = emg_right[start:end]        
        for i in range(0,len(sig_trunc)-window,int(window)):
            s = sig_trunc[i:i+window]
            if i == 0:
                std_ref = np.std(s)
            if np.std(s)/std_ref > 5:
                if stimuli[idx] == 'left':
                    trig_left.append(start+i)
                else: 
                    trig_right.append(start+i)
                break       
    # [py.axvline(x=i,color='r') for i in trig_left]
    # py.show()
    return np.array(trig_left), np.array(trig_right)


def cut_signal(signal,triggers,fs):
    frags = np.zeros((len(triggers),int(8*fs)))
    for i,trig in enumerate(triggers):
        try:
            frags[i,:] = signal[int(trig-4*fs):int(trig+4*fs)]
        except ValueError:
            pass
    frags[np.all(frags != 0,axis=1)]
    return frags


def load_data(file_name):
    mgr = read_manager.ReadManager(file_name+'.xml',
                                   file_name+'.raw',
                                   file_name+'.tag')
    fs = float(mgr.get_param('sampling_frequency'))
    print 'Sampling rate: ', fs
    emg_left = mgr.get_channel_samples('EMGL')
    emg_right = mgr.get_channel_samples('EMGR')
    diode = mgr.get_channel_samples('TRIG') 
    preprocess_data(mgr)
    hjorth_C3 = utils.hjorth_montage(mgr.get_channel_samples('C3'),mgr.get_channels_samples(['FC3','C1','C5','CP3']))
    hjorth_C4 = utils.hjorth_montage(mgr.get_channel_samples('C4'),mgr.get_channels_samples(['C6','C2','FC4','CP4']))
    hjorth_CP1 = utils.hjorth_montage(mgr.get_channel_samples('CP1'),mgr.get_channels_samples(['CP3','C1','CPz','P1']))
    hjorth_CP2 = utils.hjorth_montage(mgr.get_channel_samples('CP2'),mgr.get_channels_samples(['CP4','C2','CPz','P2']))
    return emg_left,emg_right,hjorth_C3,hjorth_C4,diode,fs,hjorth_CP1,hjorth_CP2


def serialize_data(frags,file_name,downsample=False):
    if downsample == True:
        x = np.zeros([frags.shape[1]/4,frags.shape[0]], dtype='<f')
    else:   
        x = np.zeros((frags.T.shape), dtype='<f')
    for i in xrange(frags.T.shape[1]):
        if downsample == True:
            x[:,i] = ss.decimate(frags[i,:],4)
        else:
            x[:,i] = frags[i,:]
    print 'Serialized data shape: ', x.shape
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

def plot_maps_expanded(P_left_C3,P_left_C4,P_right_C3,P_right_C4,extent):
    py.figure(figsize=(18,10),dpi=80)
    py.subplot(221)
    im = py.imshow(P_left_C3,aspect='auto',origin='lower',extent=extent)
    py.axvline(x=4,color='r')
    py.colorbar(im, pad=0.05)
    py.ylabel(u'częstość [Hz]')
    py.xlabel('czas [s]')
    py.title('C3 lewa')
    py.ylim(0,40)
    py.subplot(222)
    im2 = py.imshow(P_left_C4,aspect='auto',origin='lower',extent=extent)
    py.axvline(x=4,color='r')
    py.xlabel('czas [s]')
    py.title('C4 lewa')
    py.ylim(0,40)
    py.colorbar(im2, pad=0.05)
    py.subplot(223)
    im = py.imshow(P_right_C3,aspect='auto',origin='lower',extent=extent)
    py.axvline(x=4,color='r')
    py.colorbar(im, pad=0.05)
    py.ylabel(u'częstość [Hz]')
    py.xlabel('czas [s]')
    py.title('C3 prawa')
    py.ylim(0,40)
    py.subplot(224)
    im = py.imshow(P_right_C4,aspect='auto',origin='lower',extent=extent)
    py.axvline(x=4,color='r')
    py.colorbar(im, pad=0.05)
    py.ylabel(u'częstość [Hz]')
    py.xlabel('czas [s]')
    py.title('C4 prawa')
    py.ylim(0,40)
    # py.savefig('./Data_30-12-14/C3_C4.eps')
    # py.savefig('./Data_30-12-14/C3_C4.png')
    py.show()   

if __name__ == '__main__':
    emg_left,emg_right,hjorth_C3,hjorth_C4,diode,fs,hjorth_CP1,hjorth_CP2 = load_data(utils.get_data_path('erds_2014.12.30/30-12-14_alex_01'))

    trig_left,trig_right = find_triggers(emg_left,emg_right,diode,utils.get_data_path('erds_2014.12.30/trigger.txt'),fs)

    frags_right_C3 = cut_signal(hjorth_C3, trig_right, fs)
    frags_left_C4 = cut_signal(hjorth_C4, trig_left, fs)
    frags_left_C3 = cut_signal(hjorth_C3, trig_left, fs)
    frags_right_C4 = cut_signal(hjorth_C4, trig_right, fs)

    print "sampling_frequency:", fs

    utils.serialize_fragments_tfstats(frags_right_C3, 'frags_right_C3.dat')
    utils.serialize_fragments_tfstats(frags_left_C4, 'frags_left_C4.dat')
    utils.serialize_fragments_tfstats(frags_right_C4, 'frags_right_C4.dat')
    utils.serialize_fragments_tfstats(frags_left_C3, 'frags_left_C3.dat')

    mean_map_right_C3,extent = utils.compute_maps(frags_right_C3,fs)
    mean_map_left_C4,extent = utils.compute_maps(frags_left_C4,fs)
    mean_map_right_C4,extent = utils.compute_maps(frags_right_C4,fs)
    mean_map_left_C3,extent = utils.compute_maps(frags_left_C3,fs)

    plot_maps_expanded(np.sqrt(np.log(mean_map_left_C3+1)),np.sqrt(np.log(mean_map_left_C4+1)),np.sqrt(np.log(mean_map_right_C3+1)),np.sqrt(np.log(mean_map_right_C4+1)),extent)

    # plot_maps(mean_map_left_C4,mean_map_right_C3,extent)
