\version "2.18.2"

\header {
  snippet-title = "Print (irregularly) changing meters"
  snippet-author = "Urs Liska"
  snippet-description = \markup {
    This snippet allows you to print a list of time signatures
    indicating (irregularly) changing meters.
  }
  % add comma-separated tags to make searching more effective:
  tags = "polymetrics, time signature"
  % is this snippet ready?  See meta/status-values.md
  status = "unfinished, buggy"


  %{
    TODO:
    - Complete documentation
    - incorporate \fractionList to LilyPond
      and once that's finished use a version switch that only
      defines the function with earlier LilyPond versions.#

    - Check the sublists for validity:
      - one number: issue a warning
      - more than two numbers
  %}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%
% here goes the snippet: %
%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is the core function that should go into LilyPond
% It's recommended in Behind Bars to use hyphen
% between time signatures for irregular alternation,
% but we want that to be optional
fractionList =
#(define-scheme-function (parser location timesigs) (list?)
   (_i "A list of time signature markups to override TimeSignature.stencil with
in order to indicate irregularly changing meters.  If the first list element is
#t then hyphens are printed between the time signatures.")
   (let* ((hyphen (and (boolean? (car timesigs))
                       (car timesigs)))         ;; #t if the first list element is #t
          (used-signatures
           (if hyphen
               (cdr timesigs)
               timesigs)))                      ;; timesigs stripped of a possible boolean
     (lambda (grob)
       (grob-interpret-markup grob
         #{
           \markup \override #'(baseline-skip . 0)
           \number
           #(map (lambda (x)
                   #{ \markup {
                     \center-column #(map number->string x)
                     #(if hyphen
                          (if (eq? x (last timesigs))
                              ""
                              (markup
                               #:line
                               (#:override
                                (cons (quote thickness) 3.4)
                                (#:draw-line (cons 0.9 0)))))
                          "")
                      }
                   #}) used-signatures)
         #}))))

% This is a function to make it more accessible in standard cases
alternatingTimeSignatures =
#(define-music-function (parser location timesigs) (list?)
   (let* ((hyphen (and (boolean? (car timesigs))
                       (car timesigs)))         ;; #t if the first list element is #t
          (used-signatures (if hyphen
                               (cdr timesigs)
                               timesigs))
          (first-effective-timesig
           (cons
            (caar used-signatures)
            (cadar used-signatures))))
     #{
       \once \override Score.TimeSignature.stencil = \fractionList #timesigs
       \time #first-effective-timesig
     #}))
