;; Working on a simple formatting function which produces transforms
;; on C-like function calls in the event that the function call
;; extends beyond 80 chars in length.
;;
;; Example:
;;    some_function(first_argument, second_argument, third_argument);
;;
;;    some_function(
;;      first_argument,
;;      second_argument,
;;      third_argument);
;;
;; It would be nice to be able to go from the second form to the
;; first, as well, if it can be determined that the function would fit
;; on a single line.
;;
;; Steps of functionality:
;;
;;   1. Perform the formatting on the next nearest '(' without
;;   examining column width.
;;
;;   2. Perform the formatting from nearest function call (i.e.
;;   perform as expected when called from within an arg list).
;;
;;   3. Perform the format conditionally on column width (as-needed basis).
;;
;;   4. Perform the format recursively as needed from top-level on down.
;;
;;   5. Consider how to apply this to global auto-formatting for
;;   explicit style violations. (I'm pretty sick of worrying about my
;;   code formatting.)
;;
;;   6. Respect edge cases, such as commas within quotes. We shouldn't
;;   format within quotes.
;;
;;   7. Add configuration options of some kind. This probably requires
;;   some use of semantic units within the program (i.e. how to indent
;;   something).

;; Could use some cleaning up, but hit the very basic level of
;; functionality.
(defun format-function ()
  (interactive)
  (save-excursion
    (search-forward "(")
    (newline)
    (search-backward "(")
    (backward-char)  ; Set point to ".(" rather than "(."
    (let ((beg (point)))
      (forward-list)  ; Jump to matching brace
      (replace-string "," ",\n" nil beg (point))
      ;; Indent the resulting string replace.
      (goto-char beg)
      (forward-list)
      (indent-region beg (point)))))
