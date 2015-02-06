#!/usr/bin/env python
# -*- coding: utf-8 -*-

from utils import book_reader

import numpy as np
import matplotlib.pyplot as py

import scipy.stats

def atom2signal_gabor(book, atom):
    position = atom['params']['t'] / book.fs
    width = atom['params']['scale'] / book.fs
    frequency = atom['params']['f'] * book.fs / 2
    amplitude = atom['params']['amplitude'] / book.ptspmV
    phase = atom['params']['phase']
    return book._gabor(amplitude, position, width, frequency, phase)    

if __name__ == '__main__':
    #b_g = book_reader.BookImporter('./vep/2014.12.17_f_g_mmp1.b')
    #b_g = book_reader.BookImporter('./vep/2014.12.17_f_g_mmp2.b')
    b_g = book_reader.BookImporter('./vep/2014.12.17_f_g_mmp3.b')

    #b_w = book_reader.BookImporter('./vep/2014.12.17_f_w_mmp1.b')
    #b_w = book_reader.BookImporter('./vep/2014.12.17_f_w_mmp2.b')
    b_w = book_reader.BookImporter('./vep/2014.12.17_f_w_mmp3.b')

    '''
    b = BookImporter('nazwa.b')
    b.atoms[99][13] <-- atoms to słownik: najpierw idziesz po kanałach (1-99), 
                        [13] oznacza atom Gabora i jest to lista 200-elementowa 
                        wszystkich parametrów kolejnych atomów.

    Jeśli chodzi o sygnał:
    b.signals[1][90] <-- jest to lista 2-elementowa (dla 1 epoki i 91 kanału):
        b.signals[1][90][0] - aktualny kanał
        b.signals[1][90][1] - sygnał
    '''

    if 0:
        b = b_w
        b = b_g
        for curr_id in b.atoms.keys():
            print curr_id
            signal = b.signals[1][curr_id-1][1]
            atoms = b.atoms[curr_id]

            py.plot(signal)

            atoms[1]['params']['amplitude']

            for atom in atoms[:4]:
                if atom['type'] != 13:
                    print 'unknown atom type:', atom['type']
                    continue

                atom_reconstruction = atom2signal_gabor(b, atom)
                py.plot(atom_reconstruction)
            
            py.show()
    else:
        ampl_w = []
        ampl_g = []
        
        for curr_id in b_g.atoms.keys():
            atoms = b_g.atoms[curr_id]
            ampl_g.append(atoms[1]['params']['amplitude'])
        
        for curr_id in b_w.atoms.keys():
            atoms = b_w.atoms[curr_id]
            ampl_w.append(atoms[1]['params']['amplitude'])

        print np.mean(ampl_w), np.std(ampl_w)
        print np.mean(ampl_g), np.std(ampl_g)

        t, p = scipy.stats.ttest_ind(ampl_w, ampl_g, equal_var=False)
        print "ttest_ind: t = %g  p = %g" % (t, p)

        py.plot(ampl_w)
        py.plot(ampl_g)
        py.show()
