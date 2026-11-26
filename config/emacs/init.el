;;; init.el --- personal config  -*- lexical-binding: t; -*-
;; ---------- Startup / GC ----------
(setq
 gc-cons-threshold (* 50 1000 1000)
 gc-cons-percentage 0.6)

(add-hook
 'emacs-startup-hook (lambda () (setq gc-cons-percentage 0.1)))

(setq text-mode-ispell-word-completion nil)
(setq use-short-answers t)
(setq org-capture-bookmark nil)
;; safety net: strip it from any text-derived buffer (Org included)
(add-hook
 'text-mode-hook
 (lambda ()
   (remove-hook
    'completion-at-point-functions #'ispell-completion-at-point
    t)))

;; ---------- Quiet warnings ----------
(setq
 native-comp-async-report-warnings-errors nil
 warning-minimum-level
 :error)

(setq browse-url-browser-function 'browse-url-xdg-open)

;; Keep Emacs' auto-generated customizations out of this file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file t))

;; ---------- Packages (must come first) ----------
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'ghostel)
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)

;; ---------- Fonts (guarded: a missing font can't abort init) ----------
(defvar efs/default-font-size 110) ; 110 = 11pt
(defvar efs/default-variable-font-size 120)

(defun my/set-font (face family &rest args)
  "Set FACE to FAMILY with ARGS, only if FAMILY is installed."
  (when (member family (font-family-list))
    (apply #'set-face-attribute face nil :font family args)))

(defun my/apply-fonts (&optional frame)
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (my/set-font 'default "JetBrainsMono Nerd Font"
                   :weight 'normal
                   :height efs/default-font-size)
      (my/set-font 'fixed-pitch "JetBrainsMono Nerd Font"
                   :height efs/default-font-size)
      (my/set-font 'variable-pitch "SF Pro"
                   :height efs/default-variable-font-size
                   :weight 'regular))))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/apply-fonts)
  (my/apply-fonts))

;; ---------- Basics ----------
(setq
 inhibit-startup-message t
 auto-save-default nil
 make-backup-files nil
 visible-bell nil
 use-dialog-box nil)

;; Use the system trash
(setq
 delete-by-moving-to-trash t
 dired-recursive-deletes 'top)

(setq save-interprogram-paste-before-kill t)

;; SCROLLING (browser-like)
(setq
 scroll-conservatively 101
 mouse-wheel-follow-mouse t
 mouse-wheel-progressive-speed nil
 fast-but-imprecise-scrolling t ; skip fontifying lines you fly past
 redisplay-skip-fontification-on-input t ; don't fontify while you're scrolling
 jit-lock-defer-time 0)

(pixel-scroll-precision-mode 1)
(setq
 pixel-scroll-precision-interpolate-mice t
 pixel-scroll-precision-interpolate-page t
 pixel-scroll-precision-large-scroll-height 200.0
 pixel-scroll-precision-interpolation-total-time 0.12 ; short, snappy ease-out
 pixel-scroll-precision-interpolation-factor 3.0)


(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t) ; also refresh Dired

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(savehist-mode 1)
(auto-save-visited-mode 1)
(show-paren-mode 1)

;; Indentation: spaces, 2 wide
(setq-default
 indent-tabs-mode nil
 tab-width 2)

;; Line numbers (off in terminals, org, etc.)
(setq
 display-line-numbers-type 'relative
 display-line-numbers-exempt-modes
 '(org-mode
   term-mode
   shell-mode
   eshell-mode
   ghostel-mode
   dashboard-mode
   minibuffer-mode))

(defvar my/no-number-modes
  '(org-mode
    term-mode shell-mode eshell-mode ghostel-mode dashboard-mode))

(defun my/clean-line-numbers ()
  "Turn line numbers off in every open buffer whose mode is listed."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (apply #'derived-mode-p my/no-number-modes)
        (display-line-numbers-mode 0)))))

(global-display-line-numbers-mode 1)
(my/clean-line-numbers) ; runs after every eval-buffer too

;; and for any new buffer of those modes
(dolist (hook
         '(org-mode-hook
           term-mode-hook
           shell-mode-hook
           eshell-mode-hook
           ghostel-mode-hook
           dashboard-mode-hook
           org-agenda-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode 0))))

;; Close the terminal's window when its buffer is killed (shell exited)
;; and there's more than one window.
(defun my/ghostel-close-window-on-kill ()
  (add-hook 'kill-buffer-hook
            (lambda ()
              (when-let ((win (get-buffer-window (current-buffer))))
                (when (> (count-windows) 1)
                  (delete-window win))))
            nil t))
(add-hook 'ghostel-mode-hook #'my/ghostel-close-window-on-kill)

;; ---------- Built-in completion (no packages) ----------
(setopt
 tab-always-indent 'complete
 read-buffer-completion-ignore-case t
 read-file-name-completion-ignore-case t
 completion-auto-help t
 completions-detailed t
 completion-auto-select 'second-tab
 completion-cycle-threshold nil
 completions-format 'vertical
 completions-sort 'historical
 completions-max-height 10
 completion-show-help nil
 completion-styles '(basic partial-completion substring initials))

(keymap-set
 minibuffer-local-map "C-p" #'minibuffer-previous-completion)
(keymap-set minibuffer-local-map "C-n" #'minibuffer-next-completion)

;; ---------- Theme ----------
(setq
 modus-themes-common-palette-overrides
 '((border-mode-line-active unspecified)
   (border-mode-line-inactive unspecified)
   (bg-paren-match bg-magenta-intense)
   (underline-paren-match unspecified))
 modus-themes-italic-constructs t
 modus-themes-bold-constructs t)

(add-to-list 'custom-theme-load-path user-emacs-directory)
(defvar my/themes '(my-ink my-paper)) ; dark, light

(defun my/toggle-theme ()
  "Toggle between the dark and light theme."
  (interactive)
  (load-theme (if (memq (car my/themes) custom-enabled-themes)
                  (cadr my/themes)
                (car my/themes))
              t))

(global-set-key (kbd "C-S-t") #'my/toggle-theme)

(advice-add
 'load-theme
 :before
 (lambda (&rest _) (mapc #'disable-theme custom-enabled-themes)))

(load-theme (car my/themes) t)
;; ---------- Icons + modeline ----------
(setq inhibit-compacting-font-caches t)

(use-package
 nerd-icons
 :custom (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package
 nerd-icons-dired
 :ensure t
 :hook (dired-mode . nerd-icons-dired-mode))

(use-package
 doom-modeline
 :demand t
 :config
 (setq
  doom-modeline-height 25
  doom-modeline-bar-width 3
  doom-modeline-icon t
  doom-modeline-modal-icon nil
  doom-modeline-major-mode-icon t
  doom-modeline-buffer-file-name-style 'file-name
  doom-modeline-buffer-encoding nil ; hide UTF-8 clutter
  doom-modeline-vcs-max-length 20
  doom-modeline-hud nil)
 (doom-modeline-mode 1))

(with-eval-after-load 'doom-modeline
  (doom-modeline-def-segment
   my-space
   (propertize "   " 'face 'mode-line)) ; add or remove spaces to taste

  (doom-modeline-def-modeline
   'my-main
   '(bar
     modals
     buffer-info
     my-space
     remote-host
     buffer-position
     selection-info)
   '(matches misc-info project-name vcs check major-mode my-space))

  (doom-modeline-set-modeline 'my-main 'default))

(defun my/style-modeline-matches (&rest _)
  (set-face-attribute 'doom-modeline-panel nil
                      :inherit 'doom-modeline-info
                      :weight 'bold
                      :background 'unspecified
                      :foreground 'unspecified))

(add-hook 'enable-theme-functions #'my/style-modeline-matches)
(my/style-modeline-matches)

;; ---------- Misc packages ----------
(which-key-mode 1) ; built in since Emacs 30: shows key hints

(use-package
 rainbow-delimiters
 :hook (prog-mode . rainbow-delimiters-mode))

;; ---------- Recent files ----------
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-saved-items 200)
(run-at-time
 nil (* 5 60)
 (lambda ()
   (let ((inhibit-message t))
     (recentf-save-list))))

(defun my/recentf-find ()
  "Pick a recent file with minibuffer completion."
  (interactive)
  (find-file (completing-read "Recent file: " recentf-list nil t)))

;; ---------- Evil (vim keys) ----------
(use-package
 evil
 :demand t
 :init
 (setq
  evil-want-integration t
  evil-want-keybinding nil
  evil-want-C-u-scroll t
  evil-want-C-i-jump nil
  evil-undo-system 'undo-redo
  evil-search-module 'evil-search) ; / n N like vim
 :config (evil-mode 1)
 ;; paste with C-y and Ctrl+Shift+V
 (define-key evil-insert-state-map (kbd "C-y") #'yank)
 (define-key evil-insert-state-map (kbd "C-S-v") #'yank)
 (define-key evil-normal-state-map (kbd "C-S-v") #'yank)
 (define-key evil-ex-completion-map (kbd "C-S-v") #'yank))

(use-package anzu :demand t :config (global-anzu-mode 1))

(use-package evil-anzu :after (evil anzu) :demand t)

(use-package
 evil-collection
 :after evil
 :demand t
 :config (evil-collection-init))

(defun my/reload-config ()
  "Reload init.el."
  (interactive)
  (load-file user-init-file)
  (message "Reloaded %s" user-init-file))

;; Esc clears search highlight
(defun my/esc-clear-highlight ()
  (interactive)
  (evil-ex-nohighlight)
  (keyboard-quit))

(with-eval-after-load 'evil
  (define-key
   evil-normal-state-map (kbd "<escape>") #'my/esc-clear-highlight))

;; kill ring (d, y, x, c) no longer touches the system clipboard
(setq
 select-enable-clipboard nil
 select-enable-primary nil)

(defun my/clipboard-copy ()
  (interactive)
  (when (use-region-p)
    (gui-set-selection
     'CLIPBOARD
     (buffer-substring-no-properties (region-beginning) (region-end)))
    (deactivate-mark)))

(defun my/clipboard-paste ()
  (interactive)
  (insert (or (gui-get-selection 'CLIPBOARD) "")))

(keymap-global-set "C-S-c" #'my/clipboard-copy)
(keymap-global-set "C-S-v" #'my/clipboard-paste)
(with-eval-after-load 'evil
  (define-key evil-visual-state-map (kbd "C-S-c") #'my/clipboard-copy)
  (define-key
   evil-insert-state-map (kbd "C-S-v") #'my/clipboard-paste)
  (define-key
   evil-normal-state-map (kbd "C-S-v") #'my/clipboard-paste)
  (define-key
   evil-ex-completion-map (kbd "C-S-v") #'my/clipboard-paste))


(with-eval-after-load 'savehist
  (setq savehist-additional-variables
        (delete 'evil-ex-history savehist-additional-variables))
  (add-to-list 'savehist-ignored-variables 'evil-ex-history))

;; ---------- Terminal (ghostel) ----------
(use-package
 ghostel
 :ensure t
 :commands ghostel
 :config
 ;; Keys that should reach Emacs instead of the terminal
 (dolist (k
          '("C-S-<left>"
            "C-S-<right>"
            "C-S-<up>"
            "C-S-<down>"
            "C-S-c"
            "M-o"
            "C-S-v"))
   (add-to-list 'ghostel-keymap-exceptions k))

 ;; Window navigation straight from the terminal buffer
 (define-key ghostel-mode-map (kbd "C-S-<left>") #'windmove-left)
 (define-key ghostel-mode-map (kbd "C-S-<right>") #'windmove-right)
 (define-key ghostel-mode-map (kbd "C-S-<up>") #'windmove-up)
 (define-key ghostel-mode-map (kbd "C-S-<down>") #'windmove-down)

 ;; Copy / paste: reuse whatever ghostel binds C-y to for pasting
 (let ((paste (lookup-key ghostel-mode-map (kbd "C-y"))))
   (when (commandp paste)
     (define-key ghostel-mode-map (kbd "C-S-v") paste)))
 (define-key ghostel-mode-map (kbd "C-S-c") #'kill-ring-save))

(defun my/ghostel-right ()
  "Open ghostel in a pane on the right."
  (interactive)
  (select-window (split-window-right))
  (ghostel))

(defun my/ghostel-bottom ()
  "Open ghostel in a pane at the bottom."
  (interactive)
  (select-window (split-window-below -12))
  (ghostel))

(global-set-key (kbd "C-S-<left>") #'windmove-left)
(global-set-key (kbd "C-S-<right>") #'windmove-right)
(global-set-key (kbd "C-S-<up>") #'windmove-up)
(global-set-key (kbd "C-S-<down>") #'windmove-down)

;; ---------- SPC leader ----------
(use-package
 general
 :after evil
 :demand t
 :config
 (general-create-definer
  my/leader
  :states '(normal visual motion)
  :keymaps 'override
  :prefix "SPC")

 (my/leader
  "f"
  '(:ignore t :which-key "file")

  "b"
  '(:ignore t :which-key "buffer")
  "bb"
  #'switch-to-buffer
  "bk"
  #'kill-current-buffer

  "w"
  '(:ignore t :which-key "window")
  "wv"
  #'split-window-right
  "ws"
  #'split-window-below
  "wd"
  #'delete-window

  "t"
  '(:ignore t :which-key "terminal")
  "tt"
  #'ghostel
  "tr"
  #'my/ghostel-right
  "tb"
  #'my/ghostel-bottom

  "T"
  '(:ignore t :which-key "toggle")
  "Tt"
  #'my/toggle-theme

  "e"
  '(:ignore t :which-key "eval")
  "eb"
  #'eval-buffer ; SPC e b: evaluate the current buffer
  "er"
  #'my/reload-config ; SPC e r: reload your whole init.el
  "ee"
  #'eval-last-sexp)) ; SPC e e: evaluate the form before the cursor

(keymap-global-set "C-=" #'text-scale-increase)
(keymap-global-set "C-+" #'text-scale-increase)
(keymap-global-set "C--" #'text-scale-decrease)
(keymap-global-set
 "C-0"
 (lambda ()
   (interactive)
   (text-scale-set 0))) ; reset

;; Priority faces: the theme (my-paper) colors them, these are the fallbacks
(defface my/priority-a '((t (:inherit error :weight bold)))
  "Priority A.")
(defface my/priority-b '((t (:inherit warning :weight bold)))
  "Priority B.")
(defface my/priority-c '((t (:inherit success :weight bold)))
  "Priority C.")
(defface my/priority-d '((t (:inherit font-lock-keyword-face)))
  "Priority D.")
(defface my/priority-e '((t (:inherit shadow)))
  "Priority E.")

;; ---------- Org ----------
(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1)
  ;; stable line-number column
  (setq-local
   display-line-numbers-width 4
   display-line-numbers-grow-only t))

(use-package
 org
 :init (setq org-hide-emphasis-markers t)

 :hook (org-mode . efs/org-mode-setup)

 :config (setq org-ellipsis " ▾")

 (setq org-agenda-start-with-log-mode t)
 (setq org-log-done 'time)
 (setq org-log-into-drawer t)

 (setq org-agenda-files '("~/Org/Tasks.org" "~/Org/Birthdays.org"))

 (setq org-todo-keywords
       '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
         (sequence
          "BACKLOG(b)"
          "PLAN(p)"
          "READY(r)"
          "ACTIVE(a)"
          "REVIEW(v)"
          "WAIT(w@/!)"
          "HOLD(h)"
          "|"
          "COMPLETED(c)"
          "CANC(k@)")))

 (setq org-refile-targets
       '(("Archive.org" :maxlevel . 1) ("Tasks.org" :maxlevel . 1)))

 ;; Save Org buffers after refiling!
 (advice-add 'org-refile :after 'org-save-all-org-buffers)

 (setq org-tag-alist
       '((:startgroup)
         ;; Put mutually exclusive tags here
         (:endgroup)
         ("@errand" . ?E)
         ("@home" . ?H)
         ("@work" . ?W)
         ("agenda" . ?a)
         ("planning" . ?p)
         ("publish" . ?P)
         ("batch" . ?b)
         ("note" . ?n)
         ("idea" . ?i)))

 ;; Priorities: letters A..E, default E, colored
 (setq
  org-priority-highest ?A
  org-priority-lowest ?E
  org-priority-default ?E)
 (setq org-priority-faces
       '((?A . my/priority-a)
         (?B . my/priority-b)
         (?C . my/priority-c)
         (?D . my/priority-d)
         (?E . my/priority-e)))

 ;; Configure custom agenda views
 (setq org-agenda-custom-commands
       '(("d" "Dashboard"
          ((agenda "" ((org-deadline-warning-days 7)))
           (todo "NEXT" ((org-agenda-overriding-header "Next Tasks")))
           (tags-todo
            "agenda/ACTIVE"
            ((org-agenda-overriding-header "Active Projects")))))

         ("n" "Next Tasks"
          ((todo
            "NEXT" ((org-agenda-overriding-header "Next Tasks")))))

         ("W" "Work Tasks" tags-todo "+work-email")

         ;; Low-effort next actions
         ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
          ((org-agenda-overriding-header "Low Effort Tasks")
           (org-agenda-max-todos 20)
           (org-agenda-files org-agenda-files)))

         ("w" "Workflow Status"
          ((todo
            "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
           (todo
            "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
           (todo
            "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
           (todo
            "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
           (todo
            "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
           (todo
            "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
           (todo
            "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
           (todo
            "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

 (setq
  org-capture-templates
  `(("t" "Tasks / Org")
    ("tt"
     "Task"
     entry
     (file+olp "~/Org/Tasks.org" "Inbox")
     "* TODO %?\n  %U\n  %a\n  %i"
     :empty-lines 1)

    ("j" "Journal Entries")
    ("jj"
     "Journal"
     entry
     (file+olp+datetree "~/Org/Journal.org")
     "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
     :clock-in
     :clock-resume
     :empty-lines 1)
    ("jm"
     "Meeting"
     entry
     (file+olp+datetree "~/Org/Journal.org")
     "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
     :clock-in
     :clock-resume
     :empty-lines 1)

    ("i" "Ideas")
    ("ii"
     "Quick idea"
     entry
     (file+olp+datetree "~/Org/Ideas.org")
     "* %? :idea:"
     :empty-lines 1)

    ("ip"
     "Project idea"
     entry
     (file+headline "~/Org/Ideas.org" "Projects")
     "* %^{Title} :idea:project:\n  %U\n  %^{What is it?}\n\n  %?"
     :empty-lines 1)

    ("p"
     "Plans"
     entry
     (file+olp+datetree "~/Org/Plans.org")
     "* %? :plan:"
     :empty-lines 1)

    ("n"
     "Note"
     entry
     (file "~/Org/Notes.org")
     "* %^{Title}                                                                                                                         %U :note:\n  %?"
     :empty-lines 1)

    ("w" "Workflows")
    ("we"
     "Checking Email"
     entry
     (file+olp+datetree "~/Org/Journal.org")
     "* Checking Email :email:\n\n%?"
     :clock-in
     :clock-resume
     :empty-lines 1)

    ("m" "Metrics Capture")
    ("mw"
     "Weight"
     table-line
     (file+headline "~/Org/Metrics.org" "Weight")
     "| %U | %^{Weight} | %^{Notes} |"
     :kill-buffer t)))

 ;; Replace list hyphen with dot
 (font-lock-add-keywords
  'org-mode
  '(("^ *\\([-]\\) " (0 (prog1 ()
          (compose-region (match-beginning 1) (match-end 1) "•"))))))

 ;; Fixed-pitch where it matters
 (set-face-attribute 'org-block nil
                     :foreground 'unspecified
                     :inherit 'fixed-pitch)
 (set-face-attribute 'org-table nil :inherit '(shadow fixed-pitch))
 (set-face-attribute 'org-formula nil :inherit 'fixed-pitch)
 (set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch))
 (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
 (set-face-attribute 'org-special-keyword nil
                     :inherit '(font-lock-comment-face fixed-pitch))
 (set-face-attribute 'org-meta-line nil
                     :inherit '(font-lock-comment-face fixed-pitch))
 (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
 (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
 (set-face-attribute 'line-number-current-line nil
                     :inherit 'fixed-pitch))

(use-package
 org-bullets
 :after org
 :hook (org-mode . org-bullets-mode)
 :custom (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq
   visual-fill-column-width 100
   visual-fill-column-center-text t)
  (visual-fill-column-mode 1))
(setq line-move-visual t)
(with-eval-after-load 'evil
  (define-key
   evil-normal-state-map (kbd "<down>") #'evil-next-visual-line)
  (define-key
   evil-normal-state-map (kbd "<up>") #'evil-previous-visual-line))

(use-package
 visual-fill-column
 :hook (org-mode . efs/org-mode-visual-fill))

;; ---------- Follow system light/dark (Noctalia) ----------
(require 'dbus)

(defun my/load-theme-exclusive (theme)
  (unless (eq theme (car custom-enabled-themes))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme theme t)))

(defun my/apply-system-scheme (value)
  "VALUE is the portal color-scheme: 1 = dark, 2 = light, 0 = no preference."
  (pcase (car (flatten-tree value))
    (1 (my/load-theme-exclusive (car my/themes))) ; dark
    (2 (my/load-theme-exclusive (cadr my/themes))))) ; light

(defun my/sync-system-scheme ()
  (ignore-errors
    (my/apply-system-scheme
     (dbus-call-method
      :session
      "org.freedesktop.portal.Desktop"
      "/org/freedesktop/portal/desktop"
      "org.freedesktop.portal.Settings"
      "Read"
      "org.freedesktop.appearance"
      "color-scheme"))))

(ignore-errors
  (dbus-register-signal
   :session
   "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop"
   "org.freedesktop.portal.Settings"
   "SettingChanged"
   (lambda (namespace key value)
     (when (and (equal namespace "org.freedesktop.appearance")
                (equal key "color-scheme"))
       (my/apply-system-scheme value)))))

(my/sync-system-scheme) ; match system at startup
(add-hook 'server-after-make-frame-hook #'my/sync-system-scheme)

;; ---------- Nix ----------
(use-package nix-mode :mode "\\.nix\\'")

;; Format on save with nixfmt
(use-package nixfmt :hook (nix-mode . nixfmt-on-save-mode))

;; LSP via eglot (built in)
(use-package
 eglot
 :ensure nil
 :hook (nix-mode . eglot-ensure)
 :config
 (add-to-list 'eglot-server-programs '(nix-mode . ("nixd"))))

;; ---------- Completion UI ----------
(use-package
 vertico
 :init (vertico-mode 1)
 :custom
 (vertico-cycle t)
 (vertico-count 12))

(use-package
 orderless
 :custom (completion-styles '(orderless basic))
 (completion-category-overrides
  '((file (styles basic partial-completion)))))

(use-package marginalia :init (marginalia-mode 1))

(use-package
 corfu
 :demand t
 :custom
 (corfu-auto t)
 (corfu-auto-delay 0)
 (corfu-auto-prefix 1)
 (corfu-cycle t)
 (corfu-preselect 'first)
 :bind
 (:map
  corfu-map
  ("TAB" . corfu-complete)
  ("<tab>" . corfu-complete)
  ("RET" . nil))
 :init
 (global-corfu-mode -1)) ; make sure global is off

;; code only
(add-hook 'prog-mode-hook #'corfu-mode)

(use-package cape)

;; file paths in code buffers too
(defun my/prog-capf ()
  (add-hook 'completion-at-point-functions #'cape-file 91 t))
(add-hook 'prog-mode-hook #'my/prog-capf)

;; popup at point in prose buffers too
(add-hook 'text-mode-hook #'corfu-mode)

(defun my/text-capf ()
  "Offer words from open buffers while typing prose."
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90 t)
  (add-hook 'completion-at-point-functions #'cape-file 91 t))
(add-hook 'text-mode-hook #'my/text-capf)

(add-hook 'org-mode-hook
          (lambda ()
            (corfu-mode -1)
            (remove-hook 'completion-at-point-functions #'cape-dabbrev
                         t)
            (remove-hook 'completion-at-point-functions #'cape-file
                         t))
          t) ; append, so it runs after text-mode-hook

(use-package
 consult
 :custom
 (consult-preview-key 'any) ; preview instantly, no debounce
 (consult-narrow-key "<")
 ;; live search (ripgrep/grep/fd): update on every keystroke
 (consult-async-min-input 1) ; start searching after 1 char (default 3)
 (consult-async-input-debounce 0) ; default 0.2
 (consult-async-input-throttle 0) ; default 0.5
 (consult-async-refresh-delay 0) ; default 0.2
 :config
 (consult-customize
  consult-ripgrep
  consult-grep
  consult-git-grep
  consult-buffer
  consult-recent-file
  consult-theme
  :preview-key '(:debounce 0.0 any)))

(with-eval-after-load 'general
  (my/leader
   "SPC"
   #'consult-buffer ; SPC SPC  buffers + recent files + bookmarks
   "fg"
   #'consult-ripgrep ; SPC f g  live grep across the project
   "ff"
   #'consult-fd ; SPC f f  find files with fd
   "fr"
   #'consult-recent-file ; SPC f r  recent files
   "s" '(:ignore t :which-key "search") "ss"
   #'consult-line ; SPC s s  search the current buffer
   "si"
   #'consult-imenu ; SPC s i  jump to heading/function
   "so"
   #'consult-outline ; SPC s o  org headings
   "oc"
   #'org-capture ; SPC o c  all templates
   "Tc"
   #'consult-theme)) ; SPC T c  pick a theme with live preview

;; ---------- Dired ----------
(use-package
 dired
 :ensure nil
 :commands (dired dired-jump)
 :bind (("C-x C-j" . dired-jump))
 :custom (dired-listing-switches "-agho --group-directories-first")
 (dired-kill-when-opening-new-dired-buffer t) ; no pile-up of dired buffers
 (dired-auto-revert-buffer t)) ; refresh when you revisit the buffer

(with-eval-after-load 'dired
  (with-eval-after-load 'evil
    (evil-define-key
     'normal
     dired-mode-map
     "h"
     #'dired-up-directory
     "l"
     #'dired-find-file)))

(with-eval-after-load 'general
  (my/leader
   "fh"
   (lambda ()
     (interactive)
     (dired "~"))))

(use-package
 dired-hide-dotfiles
 :hook (dired-mode . dired-hide-dotfiles-mode)
 :config
 (evil-collection-define-key
  'normal 'dired-mode-map "H" 'dired-hide-dotfiles-mode))

;; ---------- Dashboard ----------
(defface my/dashboard-menu-face
  '((t (:inherit shadow))) ; grey in both dark and light themes
  "Face for dashboard menu entries.")

;; menu entries: (icon label display-key leader-key action)
(defvar my/dashboard-menu
  (list
   (list
    "nf-oct-home" "Open home" "SPC f h" "fh"
    (lambda ()
      (interactive)
      (dired "~")))
   (list
    "nf-oct-light_bulb" "Open ideas" "SPC i" "i"
    (lambda ()
      (interactive)
      (find-file "~/Org/Ideas.org")))
   (list
    "nf-oct-file" "Recent files" "SPC f r" "fr" #'consult-recent-file)
   (list
    "nf-oct-calendar" "Open org-agenda" "SPC o A" "oA"
    (lambda ()
      (interactive)
      (org-agenda nil "a")))
   (list
    "nf-oct-repo"
    "Open project"
    "SPC p p"
    "pp"
    #'project-switch-project)
   (list
    "nf-oct-bookmark"
    "Jump to bookmark"
    "SPC RET"
    "RET"
    #'bookmark-jump)
   (list
    "nf-oct-gear" "Open config" "SPC f P" "fP"
    (lambda ()
      (interactive)
      (find-file user-init-file)))))

;; register the leader keys used by the menu
(with-eval-after-load 'general
  (my/leader
   "i"
   (lambda ()
     (interactive)
     (find-file "~/Org/Ideas.org"))
   "o"
   '(:ignore t :which-key "open")
   "oA"
   #'org-agenda
   "p"
   '(:ignore t :which-key "project")
   "pp"
   #'project-switch-project
   "RET"
   #'bookmark-jump
   "fP"
   (lambda ()
     (interactive)
     (find-file user-init-file))))

(defun my/dashboard-insert-menu (&rest _)
  (let* ((label-w 38)
         (key-w 8)
         (total (+ 3 label-w key-w))
         (margin (max 0 (/ (- (window-body-width) total) 2))))
    (dolist (it my/dashboard-menu)
      (pcase-let ((`(,icon ,label ,shown ,_key ,fn) it))
        (insert (make-string margin ?\s))
        (insert-text-button (concat
                             (nerd-icons-octicon icon)
                             "  "
                             (string-pad label label-w))
                            'face
                            'my/dashboard-menu-face
                            'mouse-face
                            'highlight
                            'follow-link
                            t
                            'action
                            (lambda (_) (call-interactively fn)))
        (insert
         (propertize shown 'face 'my/dashboard-menu-face) "\n\n")))))

;; no line numbers on the dashboard (they shift the centering)
(add-hook
 'dashboard-mode-hook (lambda () (display-line-numbers-mode 0)))

(use-package
 dashboard
 :demand t
 :custom
 (dashboard-startup-banner
  "/home/chris/nixos-dotfiles/config/emacs/emacs.txt")
 (dashboard-center-content t)
 (dashboard-vertically-center-content t)
 (dashboard-icon-type 'nerd-icons)
 (dashboard-set-footer nil)
 (dashboard-startupify-list
  '(dashboard-insert-banner
    dashboard-insert-newline
    dashboard-insert-newline
    my/dashboard-insert-menu
    dashboard-insert-newline
    dashboard-insert-init-info))
 (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
 :config (dashboard-setup-startup-hook))

;; re-center the dashboard when the window is resized (debounced)
(defvar my/dashboard-resize-timer nil)

(defun my/dashboard-refresh-on-resize (&rest _)
  (when (timerp my/dashboard-resize-timer)
    (cancel-timer my/dashboard-resize-timer))
  (setq my/dashboard-resize-timer
        (run-with-idle-timer
         0.15 nil
         (lambda ()
           (when-let ((win (get-buffer-window "*dashboard*" t)))
             (with-selected-window win
               (dashboard-refresh-buffer)))))))

(add-hook
 'window-size-change-functions #'my/dashboard-refresh-on-resize)

;; ---------- Appointments (appt) ----------
(require 'appt)

(setq
 appt-time-msg-list nil
 appt-display-interval 5 ; re-remind every 5 min
 appt-message-warning-time 15 ; start warning 15 min before
 appt-display-mode-line t) ; show "15 min" countdown in modeline

(appt-activate 1)

;; load agenda entries into appt now, and refresh daily + on save
(org-agenda-to-appt)
(run-at-time "00:01" (* 24 60 60) #'org-agenda-to-appt)
(add-hook
 'after-save-hook
 (lambda ()
   (when (and (derived-mode-p 'org-mode)
              (member
               (buffer-file-name)
               (mapcar #'expand-file-name org-agenda-files)))
     (org-agenda-to-appt))))

(setq appt-disp-window-function
      (lambda (min-to-app _new-time msg)
        (call-process "notify-send"
                      nil
                      0
                      nil
                      "Appointment"
                      (format "%s in %s min" msg min-to-app))))
(setq appt-delete-window-function #'ignore)

;; ---------- GC tuning ----------
(use-package
 gcmh
 :diminish gcmh-mode
 :custom (gcmh-idle-delay 5)
 (gcmh-high-cons-threshold (* 64 1024 1024)) ; 64mb
 :config (gcmh-mode 1))

;; read process output in bigger chunks (helps LSP, terminals)
(setq read-process-output-max (* 1024 1024)) ; 1mb

;;; --- Formatters (Elisp, Lua, KDL) ---------------------------------

;; Lua + KDL via apheleia
(use-package
 apheleia
 :diminish apheleia-mode
 :config
 (setf (alist-get 'kdlfmt apheleia-formatters)
       '("kdlfmt" "format" "-"))
 (setf (alist-get 'my/kdl-mode apheleia-mode-alist) 'kdlfmt)
 (setf (alist-get 'lua-mode apheleia-mode-alist) 'stylua)
 (setf (alist-get 'lua-ts-mode apheleia-mode-alist) 'stylua)
 ;; elisp is handled by elisp-autofmt below, so keep apheleia out of it
 (setq apheleia-mode-alist
       (assq-delete-all
        'emacs-lisp-mode
        (assq-delete-all 'lisp-data-mode apheleia-mode-alist)))
 (apheleia-global-mode +1))

;; Elisp formatter
(use-package
 elisp-autofmt
 :hook (emacs-lisp-mode . elisp-autofmt-mode)
 :custom (elisp-autofmt-on-save-p 'always))

(use-package lua-mode :mode "\\.lua\\'")

;; tree-sitter
(use-package
 treesit-auto
 :demand t
 :custom (treesit-auto-install 'prompt)
 :config
 (treesit-auto-add-to-auto-mode-alist 'all)
 (global-treesit-auto-mode))
(setq treesit-font-lock-level 4)

;;; --- KDL mode (Emacs 30 has no working one) ------------------------

(defvar my/kdl-indent 4)

(defvar my/kdl-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    (modify-syntax-entry ?\" "\"" st)
    (modify-syntax-entry ?- "_" st)
    (modify-syntax-entry ?_ "_" st)
    st))

(defun my/kdl-indent-line ()
  (interactive)
  (let ((indent 0)
        (closing
         (save-excursion
           (back-to-indentation)
           (looking-at-p "}"))))
    (save-excursion
      (forward-line -1)
      (while (and (not (bobp)) (looking-at-p "^[ \t]*$"))
        (forward-line -1))
      (setq indent (current-indentation))
      (end-of-line)
      (when (eq (char-before) ?{)
        (setq indent (+ indent my/kdl-indent))))
    (when closing
      (setq indent (max 0 (- indent my/kdl-indent))))
    (let ((pos (- (point-max) (point))))
      (indent-line-to indent)
      (when (> (- (point-max) pos) (point))
        (goto-char (- (point-max) pos))))))

(define-derived-mode
 my/kdl-mode prog-mode "KDL"
 :syntax-table my/kdl-syntax-table
 (setq-local
  comment-start "// "
  comment-end ""
  indent-line-function #'my/kdl-indent-line
  indent-tabs-mode nil
  electric-indent-chars '(?\n ?\}))
 (setq-local font-lock-defaults
             '((("^[ \t]*\\([a-zA-Z_][a-zA-Z0-9_-]*\\)"
                 1
                 font-lock-keyword-face)
                ("\\<\\(true\\|false\\|null\\)\\>"
                 .
                 font-lock-constant-face)
                ("\\<[0-9.]+\\>" . font-lock-constant-face)))))

;; Keep this LAST so nothing (treesit-auto, kdl-mode package) overrides it
(setq auto-mode-alist (rassq-delete-all 'kdl-mode auto-mode-alist))
(add-to-list 'auto-mode-alist '("\\.kdl\\'" . my/kdl-mode))

(defface my/checkbox-done '((t (:inherit shadow :weight bold)))
  "Face for the [X] box of a checked item.")

(defface my/checkbox-done-text
  '((t (:inherit shadow :strike-through t)))
  "Face for the text of a checked item.")

(with-eval-after-load 'org
  (font-lock-add-keywords
   'org-mode
   '(("^[ \t]*\\(?:[-+*]\\|[0-9]+[.)]\\)[ \t]+\\(?:\\[@[0-9]+\\][ \t]*\\)?\\(\\[X\\]\\)\\(.*\\)$"
      (1 'my/checkbox-done t)
      (2 'my/checkbox-done-text t)))
   t))

;; ---------- Window hydra ----------
(use-package hydra)
(use-package ace-window) ; provides ace-swap-window

(defun my/split-window-vertically-and-switch ()
  "Split below and move to the new window."
  (interactive)
  (select-window (split-window-below)))

(defun my/split-window-horizontally-and-switch ()
  "Split right and move to the new window."
  (interactive)
  (select-window (split-window-right)))

(defun my/resize-window (dir &optional step)
  "Move the nearest border of the current window toward DIR."
  (let ((step (or step 3)))
    (ignore-errors
      (pcase dir
        ('left
         (if (window-in-direction 'right)
             (shrink-window-horizontally step)
           (enlarge-window-horizontally step)))
        ('right
         (if (window-in-direction 'right)
             (enlarge-window-horizontally step)
           (shrink-window-horizontally step)))
        ('up
         (if (window-in-direction 'below)
             (shrink-window step)
           (enlarge-window step)))
        ('down
         (if (window-in-direction 'below)
             (enlarge-window step)
           (shrink-window step)))))))

(defun my/resize-left ()
  (interactive)
  (my/resize-window 'left))
(defun my/resize-right ()
  (interactive)
  (my/resize-window 'right))
(defun my/resize-up ()
  (interactive)
  (my/resize-window 'up))
(defun my/resize-down ()
  (interactive)
  (my/resize-window 'down))

(defhydra
 my/hydra-window
 (:hint nil)
 "
Movement      ^Split^            ^Switch^        ^Resize^
----------------------------------------------------------------
_M-<left>_  <   _/_ vertical      _b_uffer        _<left>_  <
_M-<right>_ >   _-_ horizontal    _f_ind file     _<down>_  \u2193
_M-<up>_    \u2191   _m_aximize        _s_wap          _<up>_    \u2191
_M-<down>_  \u2193   _c_lose           _[_backward     _<right>_ >
_q_uit          _e_qualize        _]_forward     ^
^               ^               _X_ill         ^
"
 ;; Movement
 ("M-<left>" windmove-left)
 ("M-<down>" windmove-down)
 ("M-<up>" windmove-up)
 ("M-<right>" windmove-right)

 ;; Split / manage
 ("-" my/split-window-vertically-and-switch)
 ("/" my/split-window-horizontally-and-switch)
 ("c" evil-window-delete)
 ("d" evil-window-delete)
 ("m" delete-other-windows)
 ("e" balance-windows)

 ;; Switch
 ("b" consult-buffer)
 ("f" find-file)
 ("P" project-find-file)
 ("s" ace-swap-window)
 ("[" previous-buffer)
 ("]" next-buffer)
 ("X" kill-current-buffer)

 ;; Resize
 ("<left>" my/resize-left)
 ("<right>" my/resize-right)
 ("<down>" my/resize-down)
 ("<up>" my/resize-up)

 ("H" my/resize-left)
 ("L" my/resize-right)
 ("J" my/resize-down)
 ("K" my/resize-up)
 ("q" nil))

;; open it with SPC w . or M-o
(with-eval-after-load 'general
  (my/leader "w." #'my/hydra-window/body))

(general-define-key
 :states '(normal insert visual motion emacs)
 :keymaps
 'override
 "M-o"
 #'my/hydra-window/body)

;; ---------- Magit ----------
(use-package
 magit
 :commands (magit-status magit-dispatch magit-file-dispatch)
 :custom
 ;; show magit in the current window instead of splitting
 (magit-display-buffer-function
  #'magit-display-buffer-same-window-except-diff-v1)
 ;; word-level highlights inside changed lines
 (magit-diff-refine-hunk t)
 ;; ask before discarding with a single keypress less
 (magit-save-repository-buffers 'dontask))

(with-eval-after-load 'general
  (my/leader
   "g"
   '(:ignore t :which-key "git")
   "gg"
   #'magit-status
   "gd"
   #'magit-dispatch
   "gf"
   #'magit-file-dispatch
   "gl"
   #'magit-log-buffer-file ; history of the current file
   "gb"
   #'magit-blame-addition))
