import sys
import time
import random
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtMultimedia import QSoundEffect


app = QApplication(sys.argv)


snd_intro = QSoundEffect()
snd_left = QSoundEffect()
snd_right = QSoundEffect()
snd_release = QSoundEffect()


snd_intro.setSource(QUrl.fromLocalFile("instrukcja.wav"))
snd_left.setSource(QUrl.fromLocalFile("lewa.wav"))
snd_right.setSource(QUrl.fromLocalFile("prawa.wav"))
snd_release.setSource(QUrl.fromLocalFile("pusc.wav"))


snd_intro.play()
snd_left.play()

sys.exit(app.exec_())

