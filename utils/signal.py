# -*- coding: utf-8 -*-

from __future__ import print_function, division

import numpy as np


def hjorth_montage(channel, avg_channels):
    assert(len(avg_channels) > 0)
    assert(len(avg_channels.shape) > 1)
    assert(len(channel) == len(avg_channels[0]))
    print('Performing Hjort montage (averaging {} channels)...'.format(len(avg_channels)))
    return channel - 0.25 * np.sum(avg_channels, axis=0)


def cut_signal(signal, triggers, samples_before, samples_after=None):
    print("cutting signal (triggers number: {})...".format(len(triggers)))
    if samples_after is None:
        samples_after = samples_before
    signal_length = len(signal)
    frags = []
    for i, trig in enumerate(triggers):
        pos_from = int(trig - before)
        pos_to = int(trig + after)
        if pos_from < 0:
            print('cut_signal: frag pos_from: {}, skipping...'.format(pos_from))
            continue
        elif pos_to > signal_length:
            print('cut_signal: frag pos_to: {}, skipping...'.format(pos_to))
            continue
        frags.append(signal[pos_from:pos_to])
    return frags

