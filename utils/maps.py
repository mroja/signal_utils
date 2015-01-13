# -*- coding: utf-8 -*-

from __future__ import print_function, division

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

def compute_maps(frags, fs, use_cwt=False):
    tf_maps = []
    for frag in frags:
        if use_cwt:
            P, f, t, extent = cwt(frag, 1, 256, fs)
        else:
            P, f, t, extent = compute_specgram(frag,fs)
        tf_maps.append(P)
    P = np.mean(np.array(tf_maps), 0)
    return P, extent

