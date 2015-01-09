#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import time
import random
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtMultimedia import QSoundEffect

NUM_R = 100
NUM_L = 100

START_DELAY = 30000

PRESENTATION_TIME = 10000

DELAY_MIN = 2200
DELAY_MAX = 4200

OUTRO_DURATION = 5000

hands = NUM_R * ['r'] + NUM_L * ['l']
random.shuffle(hands)
hands_idx = -1

start_time = None

app = QApplication(sys.argv)

intro_active = False

snd_intro = QSoundEffect()
snd_left = QSoundEffect()
snd_right = QSoundEffect()
snd_release = QSoundEffect()

widget = QWidget()
square = QLabel(widget)

def load_next_arrow():
    global hands, hands_idx, pixmap_r, pixmap_l, square
    hands_idx += 1
    if hands_idx >= len(hands):
        return False
    if hands[hands_idx] == 'r':
        print 'right'
        snd_right.play()
    elif hands[hands_idx] == 'l':
        print 'left'
        snd_left.play()
    else:
        print 'error...'
    square.show()
    return True


def wait_next():
    global label, show_next_arrow, start_time, snd_release
    curr_time = time.time()
    time_diff = curr_time - start_time
    print 'release %.12f %.12f' % (curr_time, time_diff)
    snd_release.play()
    square.hide()
    interval = random.randint(DELAY_MIN, DELAY_MAX)
    QTimer.singleShot(interval, show_next_arrow)


def show_next_arrow():
    global start_time
    curr_time = time.time()
    time_diff = curr_time - start_time
    print 'show %.12f %.12f' % (curr_time, time_diff)
    if load_next_arrow():
        QTimer.singleShot(PRESENTATION_TIME, wait_next)
    else:
        show_outro()


def start_procedure():
    global widget, square, start_time
    square.move(0, widget.height() - square.height())
    show_next_arrow()


def show_intro():
    global widget, snd_intro, snd_left, snd_right, snd_release, start_time
    snd_intro.setSource(QUrl.fromLocalFile("instrukcja.wav"))
    snd_left.setSource(QUrl.fromLocalFile("lewa.wav"))
    snd_right.setSource(QUrl.fromLocalFile("prawa.wav"))
    snd_release.setSource(QUrl.fromLocalFile("pusc.wav"))
    snd_intro.play()
    widget.setFocus(Qt.ActiveWindowFocusReason)
    widget.activateWindow()
    start_time = time.time()
    print time.strftime("%Y-%m-%d %H:%M:%S")
    print 'start_time: %.12f' % (start_time,)    
    QTimer.singleShot(START_DELAY, start_procedure)


def show_outro():
    print 'Finished' 
    QTimer.singleShot(OUTRO_DURATION, lambda: QApplication.instance().quit())

widget.setAutoFillBackground(True)
p = widget.palette()
p.setColor(widget.backgroundRole(), Qt.black)
widget.setPalette(p)
widget.setWindowFlags(Qt.CustomizeWindowHint | Qt.WindowStaysOnTopHint)

square.setStyleSheet("QLabel { background-color: white; color: white; }")
square.resize(100, 50)
square.hide()

#widget.show()
widget.showFullScreen()

QTimer.singleShot(100, show_intro)

sys.exit(app.exec_())

