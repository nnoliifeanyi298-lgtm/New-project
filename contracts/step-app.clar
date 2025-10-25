;; step-app
;; Clarity contract for a decentralized fitness tracking platform

(define-data-var step-counter uint u0)

(define-map step-logs {id: uint}
  {user: principal,
   steps: uint,
   date: (string-ascii 20),
   status: (string-ascii 10)})

;; Log daily steps
(define-public (log-steps (steps uint) (date (string-ascii 20)))
  (begin
    (asserts! (> steps u0) (err u1))
    (asserts! (> (len date) u0) (err u2))
    (let
      (
        (id (var-get step-counter))
      )
      (map-set step-logs {id: id}
        {user: tx-sender,
         steps: steps,
         date: date,
         status: "logged"})
      (var-set step-counter (+ id u1))
      (ok id)
    )
  )
)

;; Verify step log
(define-public (verify-steps (id uint))
  (match (map-get? step-logs {id: id})
    log
    (if (is-eq (get status log) "logged")
      (begin
        (map-set step-logs {id: id}
          {user: (get user log),
           steps: (get steps log),
           date: (get date log),
           status: "verified"})
        (ok "Steps verified")
      )
      (err u3)) ;; not logged
    (err u4)) ;; log not found
)

;; Challenge a step log
(define-public (challenge-steps (id uint))
  (match (map-get? step-logs {id: id})
    log
    (if (and (is-eq (get status log) "logged") (is-eq tx-sender (get user log)))
      (begin
        (map-set step-logs {id: id}
          {user: (get user log),
           steps: (get steps log),
           date: (get date log),
           status: "challenged"})
        (ok "Steps challenged")
      )
      (err u5)) ;; not logged or not user
    (err u6)) ;; log not found
)