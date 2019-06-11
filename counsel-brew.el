;;; counsel-brew.el --- Ivy UI for OSX Homebrew -*- lexical-binding: t; -*-

;; Author: Reed Mullanix <reedmullanix@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.1") (ivy "2.8.6"))
;; Keywords: ivy, counsel, brew

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'ivy)

(defun counsel-brew-list ()
  "List all possible packages to install."
  (let ((packages (split-string (with-temp-buffer (call-process "brew" nil t nil "desc" "-s" "") (buffer-string)) "\n")))
    (mapcar (lambda (package) (cons package (car (split-string package ":")))) packages)))

(defun counsel-brew-command (cmd package)
  "Run brew command CMD on PACKAGE."
  (let ((brew-buffer (get-buffer-create "*Brew*")))
    (progn
      (with-current-buffer brew-buffer
        (erase-buffer)
        (async-shell-command (format "brew %s %s" cmd (cdr package)) brew-buffer)))))

(defun counsel-brew-transformer (package)
  "Ivy transformer for a given PACKAGE."
  (put-text-property (string-match-p ": " package) (length package) 'face 'font-lock-doc-face package)
  package)

;;;###autoload
(defun counsel-brew ()
  "Install a brew application via the ivy interface."
  (interactive)
  (ivy-read "Install Application: " (counsel-brew-list)
            :action (lambda (package) (counsel-brew-command "install" package))
            :caller 'counsel-brew))

(ivy-set-actions
 'counsel-brew
 '(("n" (lambda (package) (counsel-brew-command "info" package)) "info")
   ("p" (lambda (package) (counsel-brew-command "upgrade" package)) "upgrade")
   ("r" (lambda (package) (counsel-brew-command "reinstall" package)) "reinstall")
   ("u" (lambda (package) (counsel-brew-command "uninstall" package)) "uninstall")))

(ivy-set-display-transformer 'counsel-brew 'counsel-brew-transformer)


(provide 'counsel-brew)

;;; counsel-brew.el ends here
