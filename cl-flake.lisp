(in-package :cl-user)

(defpackage #:cl-flake
    (:use 
     #:common-lisp
     )
  (:export
   #:instance-id
   #:make-id)
  )

(require :BORDEAUX-THREADS)
(require :LOCAL-TIME)

(in-package :cl-flake)

(defvar instance-id nil
  "You must set instance-id a per lisp vm. You should manage ipaddress to id table.")

(defconstant base-time (local-time:parse-timestring "2014-04-03T20:23:32.809852+09:00"))

(defun get-time-from-base (&aux diff) ;; by milli
  (setf diff (local-time:timestamp-difference (local-time:now) base-time))
  (round (* diff 1000) 1) ;; milli sec.
  )

(defvar local-id 0)
(defvar prev-time 0)
(defvar id-lock (BORDEAUX-THREADS:make-lock))

(defun make-id (&aux
                (id 0) 
                (cur-time))
  (declare (optimize (speed 3)))
  (tagbody retry
     (setf cur-time (get-time-from-base))
     (BORDEAUX-THREADS:with-lock-held (id-lock)
       (cond
         ((= prev-time cur-time)
          (incf local-id)
          (when (<= 4096 local-id)
            (sleep 0.001)
            (go retry)))
         ((< prev-time cur-time)
          (setf local-id 0)
          (setf prev-time cur-time)
          )
         (t
          (error "time is invalid")))))

  (incf id cur-time)
  (setf id (ash id 10))

  (incf id instance-id)
  (setf id (ash id 12))

  (incf id local-id)

  id
  )


;; memo snowflake spec.
;; id is composed of:
;; time - 41 bits (millisecond precision w/ a custom epoch gives us 69 years)
;; configured machine id - 10 bits - gives us up to 1024 machines
;; sequence number - 12 bits - rolls over every 4096 per machine (with protection to avoid rollover in the same ms)
