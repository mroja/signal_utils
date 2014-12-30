import sys
import time
import random
from PyQt4.QtGui import *
from PyQt4.QtCore import *

NUM_R = 100
NUM_L = 100

START_DELAY = 10000

PRESENTATION_TIME = 3000

DELAY_MIN = 5000
DELAY_MAX = 5500

hands = NUM_R * ['r'] + NUM_L * ['l']
random.shuffle(hands)
hands_idx = -1

start_time = None

app = QApplication(sys.argv)

pixmap_r = QPixmap('arrow-right-green.png')
pixmap_l = QPixmap('arrow-left-green.png')

widget = QWidget()
label = QLabel(widget)
square = QLabel(widget)


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
        print 'Finished'
        QApplication.instance().quit()


def start_procedure():
    global widget, square, start_time
    widget.setFocus(Qt.ActiveWindowFocusReason)
    square.move(0, widget.height() - square.height())
    start_time = time.time()
    print time.strftime("%Y-%m-%d %H:%M:%S")
    print 'start_time: %.12f' % (start_time,)
    show_next_arrow()


label.setAlignment(Qt.AlignCenter)

layout = QVBoxLayout()
layout.setSpacing(0)
layout.addWidget(label)

widget.setLayout(layout)
widget.setAutoFillBackground(True)
p = widget.palette()
p.setColor(widget.backgroundRole(), Qt.gray)
widget.setPalette(p)
widget.setWindowFlags(Qt.CustomizeWindowHint | Qt.WindowStaysOnTopHint)

square.setStyleSheet("QLabel { background-color: white; color: white; }")
square.resize(50, 50)
square.hide()

widget.showFullScreen()
#widget.show()

QTimer.singleShot(START_DELAY, start_procedure)

sys.exit(app.exec_())

