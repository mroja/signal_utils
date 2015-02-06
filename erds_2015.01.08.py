#!/usr/bin/env python
# -*- coding: utf-8 -*-

''' 
    pomiary z dnia 27.01.15, badany Aleks
'''
from __future__ import division

import utils

from obci.analysis.obci_signal_processing import read_manager
from obci.analysis.obci_signal_processing.tags import tags_file_writer as tags_writer
from obci.analysis.obci_signal_processing.tags import tag_utils
import matplotlib.pyplot as py
import numpy as np
import matplotlib.mlab as mlab
import scipy.signal as ss

def compute_specgram(signal,fs):
    NFFT = int(fs)
    w = ss.hamming(NFFT)
    P,f,t = mlab.specgram(signal, NFFT=len(w), Fs=fs, window=w, noverlap=NFFT-1, sides='onesided')
    extent = (t[0]-(NFFT/2)/fs,t[-1]+(NFFT/2)/fs,f[0],f[-1])
    return P,f,t,extent

def cwt(x,MinF,MaxF,Fs,w=7.0,df=0.5):
    T = len(x)/Fs
    M = len(x)
    t = np.arange(0,T,1./Fs)
    freqs = np.arange(MinF,MaxF,df)
    P = np.zeros((len(freqs),M))
    X = np.fft.fft(x)
    for i,f in enumerate(freqs):
        s = T*f/(2*w)
        psi = np.fft.fft(ss.morlet(M, w=w, s=s, complete=True))
        psi /= np.sqrt(np.sum(psi*psi.conj()))    
        tmp = np.fft.fftshift(np.fft.ifft(X*psi))
        P[i,:] = (tmp*tmp.conj()).real
    extent = (0,T,MinF,MaxF)
    return P,freqs,t,extent

def preprocess_data(mgr):
    sig = mgr.get_samples()
    fs = float(mgr.get_param('sampling_frequency'))
    pointsPerMikroV = mgr.get_param('channels_gains')
    b,a = ss.butter(2, np.array([3,49])/(fs*0.5), btype="bandpass")
    for i in xrange(23):
        sig[i] = sig[i]*float(pointsPerMikroV[i])
        sig[i] = ss.filtfilt(b,a,sig[i])
    mgr.set_samples(sig,mgr.get_param('channels_names'))

def hjorth_montage(chosen_channel,montage_channels):
    return chosen_channel - 0.25*(sum(montage_channels,0))

def find_blinks(diode):
    moments = np.where(diode>20000)[0]
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

def load_tags_names(tags):
    names = []
    for tag in tags:
        name = tag['name'].split('.')
        names.append(name[0])
    return names

def find_triggers(emg_left,emg_right,diode,tags,fs):
    b,a = ss.butter(2, 3.0/(fs*0.5), btype="highpass")
    d,c = ss.butter(2, np.array([49,51])/(fs*0.5), btype="bandstop")
    emg_left = ss.filtfilt(d,c,ss.filtfilt(b,a,emg_left))
    emg_right = ss.filtfilt(d,c,ss.filtfilt(b,a,emg_right))
    stimuli = load_tags_names(tags)
    window = int(0.1*fs)
    blinks = find_blinks(diode)
    blinks += int(0.5*fs)       ##how many seconds stimuli lasts
    py.plot(diode,'m')
    [py.axvline(x=i,color='g') for i in blinks]
    # py.show(g
    trig_left = []
    trig_right = []
    # py.figure()
    py.plot(emg_left)
    for idx,b in enumerate(blinks):
        start = b 
        end = int(b+5.5*fs)
        if stimuli[idx] == 'lewo':
            sig_trunc = emg_left[start:end] 
        else:
            sig_trunc = emg_right[start:end]        
        for i in range(0,len(sig_trunc)-window,int(window)):
            s = sig_trunc[i:i+window]
            if i == 0:
                std_ref = np.std(s)
            if np.std(s)/std_ref > 5:
                if stimuli[idx] == 'lewo':
                    trig_left.append(start+i)
                else: 
                    trig_right.append(start+i)
                break       
    [py.axvline(x=i,color='r') for i in trig_left]
    #py.show()
    return np.array(trig_left), np.array(trig_right)

def cut_signal(signal,triggers,fs):
    frags = np.zeros((len(triggers),int(9*fs)/4))
    for i,trig in enumerate(triggers):
        try:
            x = signal[int(trig-5*fs):int(trig+4*fs)]
            frags[i,:] = ss.decimate(x,4)
        except ValueError:
            pass
    frags[np.all(frags != 0,axis=1)]
    return frags

def compute_maps(frags,fs):
    tf_maps = []
    for frag in frags:
        P,f,t,extent = compute_specgram(frag,fs)
        # P,f,t,extent = cwt(frag,1,256,fs)
        tf_maps.append(np.log(P+1))
    P = np.mean(np.array(tf_maps),0)
    return P,extent

def load_data(file_name):
    mgr = read_manager.ReadManager(file_name+'.xml',
                                   file_name+'.raw',
                                   file_name+'.tag')
    channels = [u'FC3',u'FC1',u'FCz',u'FC2',u'FC4',u'C5',u'C3',u'C1',u'Cz',u'C2',
                u'C4',u'C6',u'CP5',u'CP3',u'CP1',u'CPz',u'CP2',u'CP4',u'CP6',u'P1',u'P2',u'A1',u'A2',u'EMGL',u'EMGR',u'TRIG']
    mgr.set_param('channels_names',channels)
    fs = float(mgr.get_param('sampling_frequency'))
    emg_left = mgr.get_channel_samples('EMGL')
    emg_right = mgr.get_channel_samples('EMGR')
    diode = mgr.get_channel_samples('TRIG') 
    preprocess_data(mgr)
    tags = mgr.get_tags()
    hjorth_C3 = hjorth_montage(mgr.get_channel_samples('C3'),mgr.get_channels_samples(['FC3','C1','C5','CP3']))
    hjorth_C4 = hjorth_montage(mgr.get_channel_samples('C4'),mgr.get_channels_samples(['C6','C2','FC4','CP4']))
    hjorth_CP1 = hjorth_montage(mgr.get_channel_samples('CP1'),mgr.get_channels_samples(['CP3','C1','CPz','P1']))
    hjorth_CP2 = hjorth_montage(mgr.get_channel_samples('CP2'),mgr.get_channels_samples(['CP4','C2','CPz','P2']))
    return emg_left,emg_right,hjorth_C3,hjorth_C4,diode,fs,hjorth_CP1,hjorth_CP2,tags

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
    py.figure(figsize=(18,8),dpi=80)
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
    # py.savefig('./Data_30-12-14/C3_C4.eps')
    # py.savefig('./Data_30-12-14/C3_C4.png')
    py.show()

def plot_maps_expanded(P_left_C3,P_left_C4,P_right_C3,P_right_C4,extent):
    py.figure(figsize=(18,10),dpi=80)
    py.subplot(221)
    im = py.imshow(P_left_C3,aspect='auto',origin='lower',extent=extent)
    py.axvline(x=2,color='r')
    py.colorbar(im, pad=0.05)
    py.ylabel(u'częstość [Hz]')
    py.xlabel('czas [s]')
    py.title('C3 lewa')
    py.ylim(0,40)
    py.subplot(222)
    im2 = py.imshow(P_left_C4,aspect='auto',origin='lower',extent=extent)
    py.axvline(x=2,color='r')
    py.xlabel('czas [s]')
    py.title('C4 lewa')
    py.ylim(0,40)
    py.colorbar(im2, pad=0.05)
    py.subplot(223)
    im = py.imshow(P_right_C3,aspect='auto',origin='lower',extent=extent)
    py.axvline(x=2,color='r')
    py.colorbar(im, pad=0.05)
    py.ylabel(u'częstość [Hz]')
    py.xlabel('czas [s]')
    py.title('C3 prawa')
    py.ylim(0,40)
    py.subplot(224)
    im = py.imshow(P_right_C4,aspect='auto',origin='lower',extent=extent)
    py.axvline(x=2,color='r')
    py.colorbar(im, pad=0.05)
    py.ylabel(u'częstość [Hz]')
    py.xlabel('czas [s]')
    py.title('C4 prawa')
    py.ylim(0,40)
    # py.savefig('./Data_30-12-14/C3_C4.eps')
    # py.savefig('./Data_30-12-14/C3_C4.png')
    py.show()

def tag_writer(times, filename):
    writer = tags_writer.TagsFileWriter(filename+'.tag')
    for k in times.keys():
        for i in times[k]:
            tag = tag_utils.pack_tag_to_dict(i, i+1,k)
            writer.tag_received(tag)
    writer.finish_saving(0.0)

if __name__ == '__main__':
    emg_left,emg_right,hjorth_C3,hjorth_C4,diode,fs,hjorth_CP1,hjorth_CP2,tags = load_data(utils.get_data_path('erds_2015.02.14/alex2_2015_Jan_27_1313.obci'))
    trig_left,trig_right = find_triggers(emg_left,emg_right,diode,tags,fs)
    frags_right_C3_1 = cut_signal(hjorth_C3,trig_right,fs)
    frags_left_C4_1 = cut_signal(hjorth_C4,trig_left,fs)
    frags_right_C4_1 = cut_signal(hjorth_C4,trig_right,fs)
    frags_left_C3_1 = cut_signal(hjorth_C3,trig_left,fs)

    emg_left,emg_right,hjorth_C3,hjorth_C4,diode,fs,hjorth_CP1,hjorth_CP2,tags = load_data(utils.get_data_path('erds_2015.02.14/alex2_2015_Jan_27_1355.obci'))
    trig_left,trig_right = find_triggers(emg_left,emg_right,diode,tags,fs)
    frags_right_C3_2 = cut_signal(hjorth_C3,trig_right,fs)
    frags_left_C4_2 = cut_signal(hjorth_C4,trig_left,fs)
    frags_right_C4_2 = cut_signal(hjorth_C4,trig_right,fs)
    frags_left_C3_2 = cut_signal(hjorth_C3,trig_left,fs)

    new_fs = fs/4

    frags_right_C3 = np.concatenate((frags_right_C3_1,frags_right_C3_2),axis=0)
    frags_left_C4 = np.concatenate((frags_left_C4_1,frags_left_C4_2),axis=0)
    frags_right_C4 = np.concatenate((frags_right_C4_1,frags_right_C4_2),axis=0)
    frags_left_C3 = np.concatenate((frags_left_C3_1,frags_left_C3_2),axis=0)

    # d = {'left':[],'right':[]}
    # d['left'] = trig_left/fs
    # d['right'] = trig_right/fs
    # tag_writer(d,'30-12-14_alex_01')

    utils.serialize_fragments_tfstats(frags_right_C3, 'frags_right_C3.dat')
    utils.serialize_fragments_tfstats(frags_left_C4, 'frags_left_C4.dat')
    utils.serialize_fragments_tfstats(frags_right_C4, 'frags_right_C4.dat')
    utils.serialize_fragments_tfstats(frags_left_C3, 'frags_left_C3.dat')

    mean_map_right_C3,extent = compute_maps(frags_right_C3,new_fs)
    mean_map_left_C4,extent = compute_maps(frags_left_C4,new_fs)
    mean_map_right_C4,extent = compute_maps(frags_right_C4,new_fs)
    mean_map_left_C3,extent = compute_maps(frags_left_C3,new_fs)

    plot_maps_expanded(np.sqrt(np.log(mean_map_left_C3+1)),np.sqrt(np.log(mean_map_left_C4+1)),np.sqrt(np.log(mean_map_right_C3+1)),np.sqrt(np.log(mean_map_right_C4+1)),extent)

    # plot_maps(mean_map_right_C4,mean_map_right_C3,extent)

