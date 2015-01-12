#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import time
import random
from PyQt4.QtGui import *
from PyQt4.QtCore import *

NUM_R = 100
NUM_L = 100

START_DELAY = 5000

PRESENTATION_TIME = 3000

DELAY_MIN = 5000
DELAY_MAX = 5500

OUTRO_DURATION = 10000

hands = NUM_R * ['r'] + NUM_L * ['l']
random.shuffle(hands)
hands_idx = -1

start_time = None

app = QApplication(sys.argv)

intro_active = False

class Window(QWidget):
    def keyPressEvent(self, event):
        global intro_active
        #print 'key', event.key(), intro_active
        if intro_active and event.key() == 32:
            #print 'hiding intro'
            hide_intro()

pixmap_r = QPixmap('arrow-right-green.png')
pixmap_l = QPixmap('arrow-left-green.png')

widget = Window()
label = QLabel(widget)
square = QLabel(widget)
intro_text = QLabel(widget)
outro_text = QLabel(widget)

intro_text.setText(u"""
    <h1 style="font-size: 30px;">
        Witaj na badaniu!
    </h1>
    <p>&nbsp;</p>
    <p style="font-size: 30px;">
        Na ekranie wyświetlana będzie strzałka wskazująca 
        prawą lub lewą rękę. Po jej zgaśnięciu wykonaj 
        ruch do góry dwoma palcami tej ręki: wskazującym 
        i środkowym. Ruch wykonaj nie odrywając dłoni od 
        stołu.
    </p>
    <p>&nbsp;</p>
    <p style="font-size: 30px;">Aby rozpocząć naciśnij spację.</p>
    <p>&nbsp;</p>    
    <p style="font-size: 30px;">
        Powodzenia!
    </p>
""")

outro_text.setText(u"<h1 style=\"font-size: 26px;\">Dziękujemy za udział w badaniu.</h1>")


def load_next_arrow():
    global hands, hands_idx, pixmap_r, pixmap_l, label, square
    hands_idx += 1
    if hands_idx >= len(hands):
        return False
    if hands[hands_idx] == 'r':
        print 'right'
        label.setPixmap(pixmap_r)
    elif hands[hands_idx] == 'l':
        print 'left'
        label.setPixmap(pixmap_l)
    else:
        print 'error...'
    square.show()
    return True


def wait_next():
    global label, show_next_arrow, start_time
    curr_time = time.time()
    time_diff = curr_time - start_time
    print 'hide %.12f %.12f' % (curr_time, time_diff)
    label.setPixmap(QPixmap())
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
    start_time = time.time()
    print time.strftime("%Y-%m-%d %H:%M:%S")
    print 'start_time: %.12f' % (start_time,)
    show_next_arrow()


def show_intro():
    global widget, intro_text, intro_active
    widget.setFocus(Qt.ActiveWindowFocusReason)
    widget.activateWindow()
    margin = int(0.15 * widget.width())
    intro_text.move(margin, 0)
    intro_text.resize(widget.width() - 2 * margin, widget.height())
    intro_text.show()
    intro_active = True
    # wait for key


def hide_intro():
    global intro_active
    intro_active = False    
    intro_text.hide()
    p = widget.palette()
    p.setColor(widget.backgroundRole(), Qt.gray)
    widget.setPalette(p)
    QTimer.singleShot(START_DELAY, start_procedure)


def show_outro():
    print 'Finished'
    outro_text.move(0, 0)
    outro_text.resize(widget.width(), widget.height())
    outro_text.show()    
    QTimer.singleShot(OUTRO_DURATION, lambda: QApplication.instance().quit())


label.setAlignment(Qt.AlignCenter)
intro_text.setAlignment(Qt.AlignCenter)
intro_text.setWordWrap(True) 
outro_text.setAlignment(Qt.AlignCenter)

layout = QVBoxLayout()
layout.setSpacing(0)
layout.addWidget(label)

widget.setLayout(layout)
widget.setAutoFillBackground(True)
p = widget.palette()
p.setColor(widget.backgroundRole(), Qt.white)
widget.setPalette(p)
widget.setWindowFlags(Qt.CustomizeWindowHint | Qt.WindowStaysOnTopHint)

square.setStyleSheet("QLabel { background-color: white; color: white; }")
square.resize(50, 50)
square.hide()

intro_text.hide()
outro_text.hide()

widget.showFullScreen()
#widget.show()

QTimer.singleShot(500, show_intro)

sys.exit(app.exec_())
