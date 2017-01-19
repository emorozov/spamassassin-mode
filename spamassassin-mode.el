;;; spamassassin-mode.el --- spamassassin rules editing commands for Emacs

;;; Copyright (C) 2004 Eugene Morozov <eugene.morozov@gmail.com>

;; Author: Eugene Morozov <eugene.morozov@gmail.com>
;; Maintainer: Eugene Morozov <eugene.morozov@gmail.com>
;; Keywords: spamassassin

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; This mode is largerly based on m4-mode. It is useable in its
;; current state but font-lock code is far from perfect.

;; To Do's:

;; * Improve font-lock code (highlite rule names in meta rules,
;;   deal with quotes somehow
;; * Make last argument for spamassassin-assassin-file be the default
;;   argument for the next invocation
;; * Strip existing SpamAssassin markup in spamassassin-assassin-file
;;   before invoking SpamAssassin

(defvar spamassassin-mode-syntax-table nil
  "Syntax table in use in spamassassin-mode buffers.")

(define-skeleton spamassassin-body-rule-skeleton
  "Inserts a SpamAssassin body rule skeleton."
  "Rule name: "
  "body " str " //i\n"
  "score " str " 1.0\n"
  "describe " str " Description\n")

(define-skeleton spamassassin-header-rule-skeleton
  "Inserts a SpamAssassin header rule skeleton."
  "Rule name: "
  "header " str " Header =~ //i\n"
  "score " str " 1.0\n"
  "describe " str " Description\n")

(define-skeleton spamassassin-meta-rule-skeleton
  "Inserts a SpamAssassin meta rule skeleton."
  "Rule name: "
  "meta " str "\n"
  "score " str " 1.0\n"
  "describe " str " Description\n")

(defvar spamassassin-mode-abbrev-table
  (let ((ac abbrevs-changed))
    (define-abbrev-table 'spamassassin-mode-abbrev-table ())
    (define-abbrev spamassassin-mode-abbrev-table "bdy" ""
      'spamassassin-body-rule-skeleton)
    (define-abbrev spamassassin-mode-abbrev-table "hdr" ""
      'spamassassin-header-rule-skeleton)
    (define-abbrev spamassassin-mode-abbrev-table "mta" ""
      'spamassassin-meta-rule-skeleton)
    (setq abbrevs-changed ac)
    spamassassin-mode-abbrev-table)
  "Abbrev table for use in spamassassin-mode buffers.")

(if spamassassin-mode-syntax-table
    ()
  (setq spamassassin-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?# "<" spamassassin-mode-syntax-table)
  (modify-syntax-entry ?\n ">" spamassassin-mode-syntax-table)
  (modify-syntax-entry ?\f ">" spamassassin-mode-syntax-table)
  ;; Quotes doesn't mean something special in spamassassin configuration
  ;; and treating them as punctuation simplifies my font-lock efforts
  (modify-syntax-entry ?\" "." spamassassin-mode-syntax-table)
  (modify-syntax-entry ?_ "_" spamassassin-mode-syntax-table))

(defconst spamassassin-font-lock-keywords
  (eval-when-compile
      (list
       '("^[ \t]*\\(rawbody\\|body\\|uri\\|full\\)\\>[ \t]*\\([A-Za-z0-9_]+\\)?[ \t]*\\(/\\(\\(?:\\\\.\\|[^/]\\)*\\)/\\)?\\(\\sw+\\)?"
         (1 font-lock-keyword-face) (2 font-lock-function-name-face nil t) (3 font-lock-constant-face nil t) (4 font-lock-string-face t t) (5 font-lock-type-face nil t))
       '("^[ \t]*\\(header\\)\\>[ \t]*\\([A-Za-z0-9_]+\\)?[ \t]*\\([-A-Za-z0-9_]+\\)?[ \t]*\\(?:=~\\)?[ \t]*\\(/\\(\\(?:\\\\.\\|[^/]\\)*\\)/\\)?\\(\\sw+\\)?"
         (1 font-lock-keyword-face) (2 font-lock-function-name-face nil t) (3 font-lock-type-face nil t) (4 font-lock-constant-face nil t) (5 font-lock-string-face t t) (6 font-lock-type-face nil t))
       '("^[ \t]*\\(uridnsbl\\|describe\\|score\\|meta\\)\\>[ \t]*\\([A-Za-z0-9_]+\\)?"
         (1 font-lock-keyword-face) (2 font-lock-function-name-face nil t))
       '("^[ \t]*\\(tflags\\)[ \t]*\\([A-Za-z0-9_]+\\)?[ \t]*\\(\\(\\(net\\|nice\\|userconf\\|learn\\|noautolearn\\)[ \t]*\\)*\\)"
         (1 font-lock-keyword-face) (2 font-lock-function-name-face nil t) (3 font-lock-builtin-face nil t))
       '("^[ \t]*\\(test\\)[ \t]*\\([A-Za-z0-9_]+\\)?[ \t]*\\(ok\\|fail\\)?"
         (1 font-lock-keyword-face) (2 font-lock-function-name-face) (3 font-lock-constant-face))
       (cons (regexp-opt '("require_version" "version_tag" "def_whitelist_from_rcvd" "whitelist_from_rcvd" "unwhitelist_from" "unwhitelist_from_rcvd" "whitelist_from" "blacklist_from" "unblacklist_from" "whitelist_to" "more_spam_to" "all_spam_to" "blacklist_to" "required_score" "required_hits" "rewrite_header" "fold_headers" "add_header" "remove_header" "clear_headers" "report_safe_copy_headers" "report_safe" "report_charset" "report" "clear_report_template" "report_contact" "report_hostname" "unsafe_report" "clear_unsafe_report_template" "spamtrap" "clear_spamtrap_template" "ok_languages" "ok_locales" "use_dcc" "dcc_timeout" "dcc_body_max" "dcc_fuz1_max" "dcc_fuz2_max" "use_pyzor" "pyzor_timeout" "pyzor_max" "clear_trusted_networks" "clear_internal_networks" "trusted_networks" "internal_networks" "use_razor2" "razor_timeout" "use_bayes" "skip_rbl_checks" "rbl_timeout" "check_mx_attempts" "check_mx_delay" "bayes_ignore_from" "bayes_ignore_to" "dns_available" "use_hashcash" "hashcash_accept" "hashcash_doublespend_path" "hashcash_doublespend_file_mode" "auto_whitelist_factor" "auto_whitelist_db_modules" "bayes_auto_learn" "bayes_auto_threshold_nonspam" "bayes_auto_threshold_spam" "bayes_ignore_header" "bayes_min_ham_num" "bayes_min_spam_num" "bayes_learn_during_report" "bayes_sql_override_username" "pyzor_options" "allow_user_rules" "razor_config" "pyzor_path" "dcc_home" "dcc_dccifd_path" "dcc_path" "dcc_options" "use_auto_whitelist" "auto_whitelist_factory" "auto_whitelist_path" "auto_whitelist_file_mode" "bayes_path" "bayes_file_mode" "bayes_use_hapaxes" "bayes_use_chi2_combining" "bayes_journal_max_size" "bayes_expiry_max_db_size" "bayes_auto_expire" "bayes_learn_to_journal" "bayes_store_module" "bayes_sql_dsn" "bayes_sql_username" "bayes_sql_password" "user_awl_dsn" "user_awl_sql_username" "user_awl_sql_password" "user_awl_sql_table" "user_scores_dsn" "user_scores_ldap_username" "user_scores_ldap_password" "user_scores_sql_username" "user_scores_sql_password" "loadplugin" "ifplugin" "endif" "lang" "uridnsbl_timeout") 'words)
             'font-lock-builtin-face)
       ))
  "Default font-lock-keyword-face for `spamassassin mode'.")

(defcustom spamassassin-mode-hook nil
  "*Hook called by `spamassassin-mode'."
  :type 'hook
  :group 'spamassassin)

(defvar spamassassin-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-t" 'spamassassin-assassin-file)
    (define-key map "\C-c\C-l" 'spamassassin-lint-rules)
    (define-key map "\C-c\C-c" 'comment-region)
    map))

(require 'easymenu)
(easy-menu-define spamassassin-menu spamassassin-mode-map "Menu for the SpamAssassin mode"
  '("SpamAssassin"
    ["Assassin file" spamassassin-assassin-file]
    ["Lint rules" spamassassin-lint-rules]))

;;;###autoload
(defun spamassassin-mode ()
  "A major mode to edit SpamAssassin rules.
\\{spamassassin-mode-map}
"
  (interactive)
  (kill-all-local-variables)
  (use-local-map spamassassin-mode-map)
  (setq local-abbrev-table spamassassin-mode-abbrev-table)

  (make-local-variable 'comment-start)
  (setq comment-start "#")

  (make-local-variable 'font-lock-defaults)
  (setq major-mode 'spamassassin-mode
        mode-name "SpamAssassin"
        font-lock-defaults '(spamassassin-font-lock-keywords nil))
  (set-syntax-table spamassassin-mode-syntax-table)
  (if (featurep 'easymenu)
      (easy-menu-add spamassassin-menu))
  (abbrev-mode)
  (run-hooks 'spamassassin-mode-hook))

(defun spamassassin-lint-rules (&optional debug)
  "Runs `spamassassin --lint' to lint the rules. Currently
spamassassin cannot check only one file, so it will lint your rules
only if they're located in one of the places where spamassassin looks
for them. Prefix arg runs spamassassin in debug mode."
  (interactive)
  (let ((spamassassin-command "spamassassin --lint"))
    (if debug
        (setq spamassassin-command (concat spamassassin-command " -D")))
    (shell-command spamassassin-command)))

;; Regex-opt program can be found here:
;; http://bisqwit.iki.fi/source/regexopt.html
(defun spamassassin-optimize-regexp (start end)
  "Filter selection through regex-opt program."
  (interactive "r")
  (shell-command-on-region start end
                           (concat "regex-opt "
                                   (shell-quote-argument (buffer-substring start end)))
                           t t))

(defun spamassassin-assassin-file (filename &optional debug)
  "Filters specified file through the spamassassin. Prefix arg runs
spamassassin in debug mode."
  (interactive "f")
  (let ((spamassassin-command "spamassassin -t"))
    (if debug
        (setq spamassassin-command (concat spamassassin-command " -D")))
    (setq spamassassin-command
          (concat spamassassin-command "< " filename))
    (shell-command spamassassin-command)))

(provide 'spamassassin-mode)
