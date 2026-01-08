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
  '(("KEXP - Alternative Seattle" . ("Indie rock from Seattle. Features live in-studio sessions." . "http://live-mp3-128.kexp.org/kexp128.mp3"))
    ("BigFM LoFi Focus" . ("Lo-Fi Hip Hop for concentration." . "https://audiotainment-sw.streamabc.net/atsw-lofifocus-mp3-128-3757575?sABC=695q4317%230%2390s44171p4s2q49r5r761424ro37387q%23enqvboebjfre&aw_0_1st.playerid=radiobrowser&amsparams=playerid:radiobrowser;skey:1767719703"))
    ("FreeCodeCamp Focus" . ("24/7 instrumentals for focus." . "https://coderadio-admin-v2.freecodecamp.org/listen/coderadio/radio.mp3"))
    ("Nordic Lodge - Chillout" . ("Copenhagen-based downtempo and lounge." . "http://radio.streemlion.com:1160/stream"))
    ("101 Smooth Jazz" .("Instrumental smooth jazz." . "http://www.101smoothjazz.com/101-smoothjazz.m3u"))
    ("NPR" . ("US public radio news and talk." . "https://npr-ice.streamguys1.com/live.mp3"))
    ("Arcade Radio" . (" Classic video game soundtracks." . "https://server10.reliastream.com/proxy/arcaderadio?mp=/stream2"))
    ("The Current" . ("Indie rock and pop from Minnesota Public Radio." . "https://current.stream.publicradio.org/kcmp.mp3"))
    ("Rokit Science Fiction" . ("Old time radio (sci-fi)." . "http://streaming05.liveboxstream.uk:8110/"))
    ("History Radio" . ("Literature, speeches, and audiobooks." . "https://stream.radiojar.com/6bmecgg3wd5tv"))
    )
  "My list of radio stations.")

;; In Progress
;; Based on https://andersmurphy.com/2024/03/31/emacs-streaming-radio-with-emms.html
(use-package emms
  :ensure t
  :after (:all ivy ivy-rich)
  :bind (("C-c M-m p" . emms-pause)
	 ("C-c M-m r" . ivy-choose-and-play-radio-station))
  :init
  (defvar ik:active-radio-station nil "The currently chosen radio station.")
  (defvar ik:already-inited-music-p nil "If music has already been setup.")
  (defun ivy-choose-and-play-radio-station ()
    "Choose a radio station to play."
    (interactive)
    (unless ik:already-inited-music-p
      (setup-ivy-rich-radio)
      (setq ik:already-inited-music-p t))
    (ivy-read "Station: "
	      ik:radio-stations
	      :require-match t
	      :preselect ik:active-radio-station
	      :action (lambda (station)
			(setq ik:active-radio-station (car station))
			(emms-play-streamlist (cddr station)))))
  (defun setup-ivy-rich-radio ()
    "Setup the `ivy-rich' support for my radio."
    (defun ivy-rich--ivy-choose-and-play-radio-station-extract-name (candidate)
      "Show the name for the given CANDIDATE."
      candidate)
    (defun ivy-rich--ivy-choose-and-play-radio-station-extract-description (candidate)
      "Show the description for the given CANDIDATE."
      (car (alist-get candidate ik:radio-stations nil nil #'string=)))
    (setopt ivy-rich-display-transformers-list
	    (append
	     '(ivy-choose-and-play-radio-station
	       (:columns
		((ivy-rich--ivy-choose-and-play-radio-station-extract-name (:width 0.15))
		 (ivy-rich--ivy-choose-and-play-radio-station-extract-description (:width 0.80 :face font-lock-doc-face)))))
	     ivy-rich-display-transformers-list))
    (ivy-rich-reload))
  :config
  (emms-minimalistic)
  (setq emms-player-list '(emms-player-mpv))
  (setq emms-repeat-playlist t)
  (defvar emms-source-file-default-directory)
  (setq emms-source-file-default-directory "~/Music/"))


(provide 'ik-music)
;;; ik-music.el ends here
