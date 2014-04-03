(in-package :cl-user)
(asdf:defsystem :cl-flake
  :version 1.0
  :description "Unique ID generator. This is inspired by twitter's snowflake."
  :author "d.n. <strobolights@gmail.com>"
  :depends-on (:BORDEAUX-THREADS :LOCAL-TIME)
  :components
  ((:file "cl-flake")
   ))
  
