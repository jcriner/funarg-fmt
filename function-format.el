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
;;   [X] 1. Perform the formatting on the next nearest '(' without
;;   examining column width.
;;
;;   [X] (still a little fiddly) 2. Perform the formatting from
;;   nearest function call (i.e. perform as expected when called from
;;   within an arg list).
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

;; There's a bit of code--clang-format.el--which takes a superior
;; approach to this for C++ code by integrating with the clang-format
;; tool.
;;
;; This work continues only as I learn and practice Emacs Lisp.

(defun format-function ()
  (interactive)
  (save-excursion
    ;; Note: This version of c-beginning-... does not move to the
    ;; preceding statement if it is as the start of a C statement
    ;; already. Thus, it prevents a stupid bug.
    ;;
    ;; Another note: This results in a new limitation. If we are
    ;; currently in an arg-list, then we will only jump to the start
    ;; of the arg-list, rather than the start of the function call.
    ;; Finally, the start of the function call is not the entirety of
    ;; a statement, if the statement includes an assingment. So this
    ;; is very unpredictable.
    (c-beginning-of-statement-1)
    (search-forward "(")
    (backward-char)  ; Set point to ".(" rather than "(."
    (let ((beg (point)))
      ;; If the next char is CR, then we join things
      (if (= (char-after (+ 1 (point))) 10)
          (progn
            (delete-indentation 1) ; join line up
            (goto-char beg)
            (forward-list)
            (format-function-make-single-line beg (point)))
        ;; Otherwise we split it up.
        (progn 
          (forward-char)
          (newline)
          (goto-char beg)
          (forward-list)  ; Jump to matching brace
          (replace-string "," ",\n" nil beg (point))
          ;; Indent the resulting string replace.
          (goto-char beg)
          (forward-list)
          (indent-region beg (point)))))))


;; TODO: This will be integrated into the behavior of the main
;; formatting so that using the main function "toggles" between the
;; two indentation styles. This is merely the second case.
(defun format-function-make-single-line (p m)
  (interactive "r")
  (let ((boundary (max p m))   ; get the largest of point and mark
        (start (min p m)))     ; get the starting point
    ;; TODO: It'd be nice if this 'search-forward' didn't print messages
    (goto-char start)
    (while (search-forward "," boundary)
      (delete-indentation 1))))
