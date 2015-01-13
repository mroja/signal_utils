# -*- coding: utf-8 -*-

from __future__ import print_function, division

import os
import sys
import collections
import numpy as np
import matplotlib.pyplot as py
import matplotlib.gridspec as gridspec
from scipy.signal import filtfilt, butter


class BookImporter(object):

    def __init__(self, book_file):
        """
        Class for reading books from mp5 decomposition.

        Input:
                book_file 				-- string -- book file
        """

        super(BookImporter, self).__init__()

        f = open(book_file, 'rb')
        data, signals, atoms, epoch_s = self._read_book(f)
        self.epoch_s = epoch_s
        self.atoms = atoms
        self.signals = signals
        self.fs = data[5]['Fs']
        self.ptspmV = data[5]['ptspmV']

    def _get_type(self, ident, f):
        if ident == 1:
            com_s = np.fromfile(f, '>u4', count=1)[0]
            if not com_s == 0:  # comment
                return np.dtype([('comment', 'S' + str(com_s))])
            else:
                return None
        elif ident == 2:  # header
            head_s = np.fromfile(f, '>u4', count=1)[0]
            return None
        elif ident == 3:  # www address
            www_s = np.fromfile(f, '>u1', count=1)[0]
            return np.dtype([('www', 'S' + str(www_s))])
        elif ident == 4:  # date
            date_s = np.fromfile(f, '>u1', count=1)[0]
            return np.dtype([('date', 'S' + str(date_s))])
        elif ident == 5:  # signal info
            sig_info_s = np.fromfile(f, '>u1', count=1)[0]
            return np.dtype([('Fs', '>f4'), ('ptspmV', '>f4'),
                             ('chnl_cnt', '>u2')])
        elif ident == 6:  # decomposition info
            dec_info_s = np.fromfile(f, '>u1', count=1)[0]
            return np.dtype([('percent', '>f4'), ('maxiterations', '>u4'),
                             ('dict_size', '>u4'), ('dict_type', '>S1')])
        elif ident == 10:  # dirac
            # return
            atom_s = np.fromfile(f, '>u1', count=1)[0]
            return np.dtype([('modulus', '>f4'), ('amplitude', '>f4'),
                             ('t', '>f4')])
        elif ident == 11:  # gauss
            atom_s = np.fromfile(f, '>u1', count=1)[0]
            return np.dtype([('modulus', '>f4'), ('amplitude', '>f4'),
                             ('t', '>f4'), ('scale', '>f4')])
        elif ident == 12:  # sinus
            atom_s = np.fromfile(f, '>u1', count=1)[0]
            return np.dtype([('modulus', '>f4'), ('amplitude', '>f4'),
                             ('f', '>f4'), ('phase', '>f4')])
        elif ident == 13:  # gabor
            atom_s = np.fromfile(f, '>u1', count=1)[0]
            return np.dtype([('modulus', '>f4'), ('amplitude', '>f4'),
                             ('t', '>f4'), ('scale', '>f4'),
                             ('f', '>f4'), ('phase', '>f4')])
        else:
            return None

    def _get_signal(self, f, epoch_nr, epoch_s):
        sig_s = np.fromfile(f, '>u4', count=1)[0]
        chnl_nr = np.fromfile(f, '>u2', count=1)[0]
        signal = np.fromfile(f, '>f4', count=epoch_s)
        return chnl_nr, signal

    def _get_atoms(self, f):
        atoms = list()
        atoms_s = np.fromfile(f, '>u4', count=1)[0]
        a_chnl_nr = np.fromfile(f, '>u2', count=1)[0]
        ident = np.fromfile(f, '>u1', count=1)
        while ident in [10, 11, 12, 13]:
            atom = np.fromfile(f, self._get_type(ident[0], f), count=1)[0]
            atoms.append({'params': atom, 'type': ident[0]})
            ident = np.fromfile(f, '>u1', count=1)
        f.seek(f.tell() - 1)
        return atoms, a_chnl_nr

    def _read_book(self, f):
        try:
            f = open(f, 'rb')
        except Exception:
            f = f
        version = np.fromfile(f, 'S6', count=1)
        data = {}
        ident = np.fromfile(f, 'u1', count=1)[0]
        ct = self._get_type(ident, f)
        signals = collections.defaultdict(list)
        atoms = collections.defaultdict(list)
        while ident:
            if ct:
                point = np.fromfile(f, ct, count=1)[0]
                data[ident] = point
            elif ident == 7:
                data_s = np.fromfile(f, '>u4', count=1)[0]
                epoch_nr = np.fromfile(f, '>u2', count=1)[0]
                epoch_s = np.fromfile(f, '>u4', count=1)[0]
            elif ident == 8:
                chnl_nr, signal = self._get_signal(f, epoch_nr, epoch_s)
                signals[epoch_nr].append(signal)
            elif ident == 9:
                pl = f.tell()
                atom, a_chnl_nr = self._get_atoms(f)
                atoms[a_chnl_nr] = atom
            ident = np.fromfile(f, '>u1', count=1)
            if ident:
                ident = ident[0]
            ct = self._get_type(ident, f)
        return data, signals, atoms, epoch_s

    def _gabor(self, amplitude, position, scale, afrequency, phase):
        time = np.linspace(0, self.epoch_s / self.fs, self.epoch_s)
        width = scale
        frequency = 2.0 * np.pi * afrequency
        signal = amplitude * \
            np.exp(-np.pi * ((time - position) / width) ** 2) * np.cos(frequency * (time - position) + phase)
        return signal

    def _sinus(self, amplitude, frequency, phase):
        time = np.linspace(0, self.epoch_s / self.fs, self.epoch_s)
        frequency = frequency * 2 * np.pi
        signal = amplitude * np.cos(frequency * time + phase)
        return signal

    def _reconstruct_signal(self, atoms):
        reconstruction = np.zeros(self.epoch_s)
        for atom in (a for a in atoms if a['type'] == 13):
            position = atom['params']['t'] / self.fs
            width = atom['params']['scale'] / self.fs
            frequency = atom['params']['f'] * self.fs / 2
            amplitude = atom['params']['amplitude'] / self.ptspmV
            phase = atom['params']['phase']
            reconstruction = reconstruction + \
                self._gabor(amplitude, position, width, frequency, phase)
        return reconstruction

    def _calculate_map(self, atoms, signal, df, dt, contour=0, f_a=[0, 64.]):
        ''' atoms - dictionary with trials/channels; for each dictionary with
        atoms 4 different atom's types (10,11,12,13-Gabors)'''
        tpr = len(signal)
        f = np.arange(f_a[0], f_a[1], df)
        t = np.arange(0, tpr / self.fs, dt)
        lent = len(t)
        lenf = len(f)
        E = np.zeros((lent, lenf)).T
        t, f = np.meshgrid(t, f)
        sigt = np.arange(0, tpr / self.fs, 1 / self.fs)

        for atom in (a for a in atoms if a['type'] == 13):
            params = atom['params']
            exp1 = np.exp(-2 *
                          (params['scale'] / self.fs) ** (-2) *
                          (t - params['t'] / self.fs) ** 2)
            exp2 = np.exp(-2 * np.pi ** 2 *
                          (params['scale'] / self.fs) ** 2 *
                          (params['f'] * self.fs / 2 - f) ** 2)
            wigners = ((params['amplitude'] / self.ptspmV) ** 2 *
                       (2 * np.pi) ** 0.5 *
                       params['scale'] / self.fs * exp1 * exp2)
            E += params['modulus'] ** 2 * wigners

        for atom in (a for a in atoms if a['type'] == 12):
            params = atom['params']
            amp = params['modulus'] ** 2 * \
                (params['amplitude'] / self.ptspmV) ** 2
            E[:, int(len(f) * params['f'] / (2 * np.pi))] += amp

        for atom in (atom for atom in atoms if atom['type'] == 11):
            params = atom['params']
            exp1 = np.exp(-2 * (params['scale'] / self.fs) ** (-2) *
                          (t - params['t'] / self.fs) ** 2)
            exp2 = np.exp(-2 * np.pi ** 2 *
                          (params['scale'] / self.fs) ** 2 * (-f) ** 2)
            wigners = ((params['amplitude'] / self.ptspmV) ** 2 *
                       (2 * np.pi) ** 0.5 *
                       params['scale'] / self.fs *
                       exp1 * exp2)
            E += params['modulus'] ** 2 * wigners

        for atom in (atom for atom in atoms if atom['type'] == 10):
            params = atom['params']
            amp = (params['modulus'] ** 2) * \
                (params['amplitude'] / self.ptspmV) ** 2
            E[int(lent * params['t'] / tpr)] += amp

        signal_reconstruction = self._reconstruct_signal(atoms)
        return t, f, E, sigt, signal, signal_reconstruction

    def calculate_mean_map(self, df=0.05, dt=1.0 / 128.0, f_a=[0.0, 64.0]):
        N = len(self.atoms.keys())
        tpr = len(self.signals[1][0])
        sigt = np.arange(0, tpr / self.fs, 1 / self.fs)
        for nr, chnl in enumerate(self.atoms.keys()):
            print('calculating...', chnl, 'of', len(self.atoms.keys()))
            t, f, E, sigt_s, signal, signal_reconstruction = self._calculate_map(
                self.atoms[chnl], self.signals[1][nr], df, dt, f_a=f_a)
            try:
                signal_a += signal
                E_a += E
                signal_reconstruction_a += signal_reconstruction
            except Exception as a:
                signal_a = signal
                E_a = E
                signal_reconstruction_a = signal_reconstruction
        signal_a /= N
        signal_reconstruction_a /= N
        E_a /= N
        return t, f, E_a, sigt, signal_a, signal_reconstruction_a

    def draw_map(self, 
            t, f, E_a, 
            sigt, signal_a,
            signal_recontruction_a,
            contour=False):
        fig = py.figure()
        
        gs = gridspec.GridSpec(2, 1, height_ratios=[3, 1])
        
        ax1 = fig.add_subplot(gs[0])
        ax1.set_ylabel(u'Czestosc [Hz]')
        ax1.set_title(sys.argv[-1])
        
        if contour:
            ax1.contour(t, f, E_a)
        else:
            # ax1.pcolor(t, f, E_a)
            ax1.imshow(np.log(E_a + 1), aspect='auto', origin='lower',
                       extent=(t[0, 0], t[-1, -1], f[0, 0], f[-1, -1]))
        
        ax2 = fig.add_subplot(gs[1])
        ax2.plot(sigt, signal_a, 'red')
        ax2.plot(sigt, signal_recontruction_a, 'blue')
        ax2.axvline(x=4, color='r')
        ax2.set_ylabel(u'Amplituda [$\\mu$V]')
        ax2.set_xlabel(u'Czas [s]')

