;;; ik-music.el --- Music Configuration              -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
;; Keywords: local, multimedia

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; My Emacs music configuration. I want to listen to the radio at work.

;;; Code:

(defvar ik:radio-stations
  '(("KEXP - Alternative Seattle" . "http://live-mp3-128.kexp.org/kexp128.mp3")
    ("BigFM LoFi Focus" . "https://audiotainment-sw.streamabc.net/atsw-lofifocus-mp3-128-3757575?sABC=695q4317%230%2390s44171p4s2q49r5r761424ro37387q%23enqvboebjfre&aw_0_1st.playerid=radiobrowser&amsparams=playerid:radiobrowser;skey:1767719703")
    ("FreeCodeCamp Focus" . "https://coderadio-admin-v2.freecodecamp.org/listen/coderadio/radio.mp3")
    ("Nordic Lodge - Chillout" . "http://radio.streemlion.com:1160/stream")
    ("101 Smooth Jazz" . "http://www.101smoothjazz.com/101-smoothjazz.m3u")
    ("NPR" . "https://npr-ice.streamguys1.com/live.mp3")
    ("Arcade Radio" . "https://server10.reliastream.com/proxy/arcaderadio?mp=/stream2")
    ("The Current" . "https://current.stream.publicradio.org/kcmp.mp3")
    ("Rokit Science Fiction" . "http://streaming05.liveboxstream.uk:8110/")
    ("History Radio" . "https://stream.radiojar.com/6bmecgg3wd5tv")
    )
  "My list of radio stations.")

;; In Progress
;; Based on https://andersmurphy.com/2024/03/31/emacs-streaming-radio-with-emms.html
(use-package emms
  :ensure t
  :bind (("C-c M-m p" . emms-pause)
	 ("C-c M-m r" . choose-and-play-radio-station))
  :init
  (defun choose-and-play-radio-station ()
    "Choose a radio station to play."
    (interactive)
    (ivy-read "Station: "
	      ik:radio-stations
	      :require-match t
	      :action (lambda (station)
			(emms-play-streamlist (cdr station)))))
  :config
  (emms-minimalistic)
  (setq emms-player-list '(emms-player-mpv))
  (emms-playing-time-display-mode nil)
  (setq emms-repeat-playlist t)
  (defvar emms-source-file-default-directory)
  (setq emms-source-file-default-directory "~/Music/"))

(provide 'ik-music)
;;; ik-music.el ends here
