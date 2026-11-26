;; no GC during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; faster startup: skip file-name handlers while loading
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; avoid frame flicker/resizing
(setq frame-inhibit-implied-resize t
      package-enable-at-startup nil)
