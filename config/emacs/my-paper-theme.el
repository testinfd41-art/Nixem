;;; my-paper-theme.el --- A warm, high-contrast light theme  -*- lexical-binding: t; -*-

;; Palette notes: warm off-white paper background, near-black ink,
;; accents chosen to read well on the background.

;;; Code:

(deftheme my-paper
  "Warm paper-like light theme with readable accents.")

(let* ((bg "#fdfdfd") ; near-white
       (bg-alt "#f4f4f5") ; blocks, popups, inactive modeline
       (bg-hl "#e9e9ec") ; current line, selected candidate
       (bg-region "#d6e2f5") ; selection
       (border "#dcdce0")
       (fg "#2b2b33") ; ink
       (fg-muted "#6b6f7b")
       (fg-faint "#a9a9b3") ; line numbers
       (comment "#72727c")

       (red "#b3261e")
       (todo "#f78c00")
       (orange "#F58905")
       (gold "#7d5e00")
       (green "#29ba50")
       (teal "#0b6e7a")
       (blue "#2a5db0")
       (purple "#7a3fb0")
       (magenta "#a8286f")

       (hl-yellow "#f4d77a") ; isearch
       (hl-soft "#f0e2a8") ; lazy highlight
       (add-bg "#dff0df")
       (del-bg "#f8dcdc")
       (chg-bg "#e6e8f5"))

  (custom-theme-set-faces
   'my-paper

   ;; --- Basics ---
   `(default ((t (:background ,bg :foreground ,fg))))
   `(cursor ((t (:background ,fg))))
   `(region ((t (:background ,bg-region :extend t))))
   `(secondary-selection ((t (:background ,bg-hl :extend t))))
   `(highlight ((t (:background ,bg-hl))))
   `(hl-line ((t (:background ,bg-alt :extend t))))
   `(shadow ((t (:foreground ,fg-muted))))
   `(fringe ((t (:background ,bg :foreground ,fg-faint))))
   `(vertical-border ((t (:foreground ,border))))
   `(window-divider ((t (:foreground ,border))))
   `(window-divider-first-pixel ((t (:foreground ,border))))
   `(window-divider-last-pixel ((t (:foreground ,border))))
   `(internal-border ((t (:background ,bg :foreground ,bg))))
   `(child-frame-border
     ((t (:background ,border :foreground ,border))))
   `(minibuffer-prompt ((t (:foreground ,blue :weight bold))))
   `(link ((t (:foreground ,blue :underline t))))
   `(link-visited ((t (:foreground ,purple :underline t))))
   `(button ((t (:foreground ,blue :underline t))))
   `(tooltip ((t (:background ,bg-alt :foreground ,fg))))
   `(trailing-whitespace ((t (:background ,del-bg))))
   `(escape-glyph ((t (:foreground ,orange))))
   `(homoglyph ((t (:foreground ,orange))))
   `(header-line ((t (:background ,bg-alt :foreground ,fg))))
   `(error ((t (:foreground ,red :weight bold))))
   `(warning ((t (:foreground ,orange :weight bold))))
   `(success ((t (:foreground ,green :weight bold))))

   ;; --- Line numbers ---
   `(line-number ((t (:foreground ,fg-faint :background ,bg))))
   `(line-number-current-line
     ((t (:foreground ,fg :background ,bg :weight bold))))

   ;; --- Mode line ---
   `(mode-line ((t (:background ,bg-hl :foreground ,fg))))
   `(mode-line-inactive
     ((t (:background ,bg-alt :foreground ,fg-muted))))
   `(mode-line-emphasis ((t (:foreground ,blue :weight bold))))
   `(mode-line-highlight ((t (:background ,bg-region))))
   `(mode-line-buffer-id ((t (:weight bold))))

   ;; --- Search / matching ---
   `(isearch
     ((t (:background ,hl-yellow :foreground ,fg :weight bold))))
   `(isearch-fail ((t (:background ,del-bg :foreground ,red))))
   `(lazy-highlight ((t (:background ,hl-soft :foreground ,fg))))
   `(match ((t (:background ,hl-soft :foreground ,fg :weight bold))))
   `(show-paren-match
     ((t (:background "#cfe3d0" :foreground ,fg :weight bold))))
   `(show-paren-mismatch
     ((t (:background ,del-bg :foreground ,red :weight bold))))
   `(completions-common-part ((t (:foreground ,blue :weight bold))))
   `(completions-first-difference
     ((t (:foreground ,magenta :weight bold))))

   ;; --- Font lock ---
   `(font-lock-keyword-face ((t (:foreground ,purple))))
   `(font-lock-function-name-face ((t (:foreground ,blue))))
   `(font-lock-variable-name-face ((t (:foreground ,orange))))
   `(font-lock-string-face ((t (:foreground ,green))))
   `(font-lock-doc-face ((t (:foreground ,comment :slant italic))))
   `(font-lock-comment-face
     ((t (:foreground ,comment :slant italic))))
   `(font-lock-comment-delimiter-face
     ((t (:foreground ,comment :slant italic))))
   `(font-lock-type-face ((t (:foreground ,teal))))
   `(font-lock-constant-face ((t (:foreground ,magenta))))
   `(font-lock-builtin-face ((t (:foreground ,teal :weight bold))))
   `(font-lock-preprocessor-face ((t (:foreground ,purple))))
   `(font-lock-warning-face ((t (:foreground ,orange :weight bold))))
   `(font-lock-negation-char-face ((t (:foreground ,red))))
   `(font-lock-regexp-grouping-construct
     ((t (:foreground ,orange :weight bold))))
   `(font-lock-regexp-grouping-backslash
     ((t (:foreground ,magenta :weight bold))))

   ;; --- Org ---
   `(org-level-1 ((t (:foreground ,blue :weight bold))))
   `(org-level-2 ((t (:foreground ,purple :weight bold))))
   `(org-level-3 ((t (:foreground ,teal :weight bold))))
   `(org-level-4 ((t (:foreground ,orange))))
   `(org-level-5 ((t (:foreground ,green))))
   `(org-level-6 ((t (:foreground ,magenta))))
   `(org-level-7 ((t (:foreground ,blue))))
   `(org-level-8 ((t (:foreground ,purple))))
   ;; leading stars hidden by painting them in the background color
   `(org-hide ((t (:foreground ,bg :background ,bg))))
   `(org-indent ((t (:inherit org-hide))))
   `(org-document-title ((t (:foreground ,fg :weight bold))))
   `(org-document-info ((t (:foreground ,fg-muted))))
   `(org-document-info-keyword ((t (:foreground ,comment))))
   `(org-todo ((t (:foreground ,todo :weight bold))))
   `(org-done ((t (:foreground ,green :weight bold))))
   `(org-headline-done ((t (:foreground ,fg-muted))))
   `(org-date ((t (:foreground ,teal :underline nil))))
   `(org-sexp-date ((t (:foreground ,teal))))
   `(org-tag ((t (:foreground ,fg-muted :weight normal))))
   `(org-link ((t (:inherit link))))
   `(org-code ((t (:foreground ,magenta :background ,bg-alt))))
   `(org-verbatim ((t (:foreground ,green :background ,bg-alt))))
   `(org-block ((t (:background ,bg-alt :extend t))))
   `(org-block-begin-line
     ((t (:foreground ,comment :background ,bg-hl :extend t))))
   `(org-block-end-line
     ((t (:foreground ,comment :background ,bg-hl :extend t))))
   `(org-quote ((t (:slant italic :background ,bg-alt :extend t))))
   `(org-table ((t (:foreground ,blue))))
   `(org-formula ((t (:foreground ,orange))))
   `(org-meta-line ((t (:foreground ,comment))))
   `(org-special-keyword ((t (:foreground ,comment))))
   `(org-drawer ((t (:foreground ,comment))))
   `(org-property-value ((t (:foreground ,fg-muted))))
   `(org-checkbox ((t (:foreground ,blue :weight bold))))
   ;; checked items: light grey, struck through
   `(org-checkbox-done-text
     ((t (:foreground ,fg-faint :strike-through t))))
   `(my/checkbox-done ((t (:foreground ,fg-faint :weight bold))))
   `(my/checkbox-done-text
     ((t (:foreground ,fg-faint :strike-through t))))
   `(org-ellipsis ((t (:foreground ,fg-muted :underline nil))))
   `(org-footnote ((t (:foreground ,blue))))
   `(org-scheduled ((t (:foreground ,green))))
   `(org-scheduled-today ((t (:foreground ,green :weight bold))))
   `(org-scheduled-previously ((t (:foreground ,orange))))
   `(org-upcoming-deadline ((t (:foreground ,orange))))
   `(org-imminent-deadline ((t (:foreground ,red :weight bold))))
   `(org-warning ((t (:foreground ,orange :weight bold))))
   `(org-agenda-structure ((t (:foreground ,blue :weight bold))))
   `(org-agenda-date ((t (:foreground ,teal :weight bold))))
   `(org-agenda-date-today
     ((t (:foreground ,blue :weight bold :underline t))))
   `(org-agenda-date-weekend ((t (:foreground ,purple :weight bold))))
   `(org-agenda-done ((t (:foreground ,green))))
   `(org-time-grid ((t (:foreground ,fg-muted))))
   `(org-agenda-current-time ((t (:foreground ,red :weight bold))))

   ;; --- Org priorities (faces are defined in init.el) ---
   `(org-priority ((t (:foreground ,fg-muted))))
   `(my/priority-a
     ((t (:foreground ,red :background ,del-bg :weight bold))))
   `(my/priority-b ((t (:foreground ,orange :weight bold))))
   `(my/priority-c ((t (:foreground ,gold :weight bold))))
   `(my/priority-d ((t (:foreground ,teal))))
   `(my/priority-e ((t (:foreground ,fg-muted))))

   ;; --- Dired ---
   `(dired-directory ((t (:foreground ,blue :weight bold))))
   `(dired-header ((t (:foreground ,purple :weight bold))))
   `(dired-symlink ((t (:foreground ,teal))))
   `(dired-marked ((t (:foreground ,magenta :weight bold))))
   `(dired-flagged ((t (:foreground ,red :weight bold))))
   `(dired-ignored ((t (:foreground ,fg-muted))))
   `(dired-perm-write ((t (:foreground ,orange))))

   ;; --- Vertico / Orderless / Consult / Marginalia ---
   `(vertico-current
     ((t (:background ,bg-hl :extend t :weight bold))))
   `(vertico-group-title ((t (:foreground ,purple :weight bold))))
   `(vertico-group-separator
     ((t (:foreground ,border :strike-through t))))
   ;; matched words: white on blue
   `(orderless-match-face-0
     ((t (:foreground "#ffffff" :background ,blue :weight bold))))
   `(orderless-match-face-1
     ((t (:foreground "#ffffff" :background ,blue :weight bold))))
   `(orderless-match-face-2
     ((t (:foreground "#ffffff" :background ,blue :weight bold))))
   `(orderless-match-face-3
     ((t (:foreground "#ffffff" :background ,blue :weight bold))))
   `(consult-highlight-match
     ((t (:foreground "#ffffff" :background ,blue :weight bold))))
   `(consult-preview-match
     ((t (:foreground "#ffffff" :background ,blue))))
   `(consult-file ((t (:foreground ,blue))))
   `(consult-line-number ((t (:foreground ,fg-faint))))
   `(consult-grep-context ((t (:foreground ,comment))))
   `(marginalia-documentation
     ((t (:foreground ,comment :slant italic))))
   `(marginalia-file-name ((t (:foreground ,fg-muted))))

   ;; --- Corfu ---
   `(corfu-default ((t (:background ,bg-alt :foreground ,fg))))
   `(corfu-current ((t (:background ,bg-region :foreground ,fg))))
   `(corfu-bar ((t (:background ,blue))))
   `(corfu-border ((t (:background ,border))))
   `(corfu-annotations ((t (:foreground ,fg-muted))))

   ;; --- Evil / anzu / which-key ---
   `(evil-ex-lazy-highlight ((t (:inherit lazy-highlight))))
   `(evil-ex-search ((t (:inherit isearch))))
   `(anzu-mode-line ((t (:foreground ,magenta :weight bold))))
   `(anzu-mode-line-no-match ((t (:foreground ,red :weight bold))))
   `(which-key-key-face ((t (:foreground ,blue :weight bold))))
   `(which-key-command-description-face ((t (:foreground ,fg))))
   `(which-key-group-description-face ((t (:foreground ,purple))))
   `(which-key-separator-face ((t (:foreground ,fg-muted))))

   ;; --- Doom modeline ---
   `(doom-modeline-bar ((t (:background ,blue))))
   `(doom-modeline-bar-inactive ((t (:background ,bg-alt))))
   `(doom-modeline-info ((t (:foreground ,green :weight bold))))
   `(doom-modeline-warning ((t (:foreground ,orange :weight bold))))
   `(doom-modeline-urgent ((t (:foreground ,red :weight bold))))
   `(doom-modeline-buffer-file ((t (:foreground ,fg :weight bold))))
   `(doom-modeline-buffer-modified
     ((t (:foreground ,red :weight bold))))
   `(doom-modeline-project-dir ((t (:foreground ,blue :weight bold))))
   `(doom-modeline-buffer-path ((t (:foreground ,blue))))

   ;; --- Dashboard ---
   `(dashboard-banner-logo-title ((t (:foreground ,fg-muted))))
   `(dashboard-text-banner ((t (:foreground ,fg-muted))))
   `(dashboard-heading ((t (:foreground ,purple :weight bold))))

   ;; --- Rainbow delimiters ---
   `(rainbow-delimiters-depth-1-face ((t (:foreground ,blue))))
   `(rainbow-delimiters-depth-2-face ((t (:foreground ,purple))))
   `(rainbow-delimiters-depth-3-face ((t (:foreground ,teal))))
   `(rainbow-delimiters-depth-4-face ((t (:foreground ,orange))))
   `(rainbow-delimiters-depth-5-face ((t (:foreground ,green))))
   `(rainbow-delimiters-depth-6-face ((t (:foreground ,magenta))))
   `(rainbow-delimiters-depth-7-face ((t (:foreground ,blue))))
   `(rainbow-delimiters-depth-8-face ((t (:foreground ,purple))))
   `(rainbow-delimiters-depth-9-face ((t (:foreground ,teal))))
   `(rainbow-delimiters-unmatched-face
     ((t (:foreground ,red :weight bold))))

   ;; --- Diff ---
   `(diff-added
     ((t (:background ,add-bg :foreground ,green :extend t))))
   `(diff-removed
     ((t (:background ,del-bg :foreground ,red :extend t))))
   `(diff-changed ((t (:background ,chg-bg :extend t))))
   `(diff-refine-added ((t (:background "#b9e0b9"))))
   `(diff-refine-removed ((t (:background "#f0b8b8"))))
   `(diff-header ((t (:background ,bg-alt :foreground ,fg))))
   `(diff-file-header
     ((t (:background ,bg-hl :foreground ,fg :weight bold))))
   `(diff-hunk-header ((t (:background ,chg-bg :foreground ,blue))))

   ;; --- Terminal colors (ansi-color) ---
   `(ansi-color-black ((t (:foreground ,fg :background ,fg))))
   `(ansi-color-red ((t (:foreground ,red :background ,red))))
   `(ansi-color-green ((t (:foreground ,green :background ,green))))
   `(ansi-color-yellow ((t (:foreground ,gold :background ,gold))))
   `(ansi-color-blue ((t (:foreground ,blue :background ,blue))))
   `(ansi-color-magenta
     ((t (:foreground ,magenta :background ,magenta))))
   `(ansi-color-cyan ((t (:foreground ,teal :background ,teal))))
   `(ansi-color-white ((t (:foreground ,bg-hl :background ,bg-hl))))))

(provide-theme 'my-paper)

;;; my-paper-theme.el ends here
