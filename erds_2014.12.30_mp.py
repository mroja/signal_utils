#!/usr/bin/env python
# -*- coding: utf-8 -*-

from book_reader import *

if __name__ == '__main__':
	b = BookImporter('./mp5/frags_left_downsampled_smp.b')
	# t, f, E_a, sigt, signal, signal_reconstruction = b._calculate_map(b.atoms[1],b.signals[1][0],0.05,1/128.,f_a=[0,64.])
	t, f, E_a, sigt, signal, signal_reconstruction = b.calculate_mean_map()
	b.draw_map(t, f, E_a, sigt, signal, signal_reconstruction)
	py.show()
