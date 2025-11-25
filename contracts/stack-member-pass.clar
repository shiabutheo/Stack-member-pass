(define-data-var admin principal tx-sender)

;; Membership record structure
(define-map memberships
  {user: principal}
  {
    tier: uint,
    expires-at: (optional uint),
    transferable: bool,
    active: bool
  }
)

;; ----------------------------
;; HELPER CHECKS
;; ----------------------------

(define-private (only-admin)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok true)
  )
)

(define-private (is-valid (m {tier: uint, expires-at: (optional uint), transferable: bool, active: bool}))
  (match (get expires-at m)
    expires-at-value (ok (and (get active m) (> expires-at-value stacks-block-height)))
    (ok (get active m))
  )
)

;; ----------------------------
;; ADMIN FUNCTIONS
;; ----------------------------

;; Transfer admin ownership
(define-public (set-admin (new-admin principal))
  (begin
    (unwrap! (only-admin) (err u100))
    (var-set admin new-admin)
    (ok true)
  )
)

;; Issue or update membership
(define-public (set-membership
    (user principal)
    (tier uint)
    (expires-at (optional uint))
    (transferable bool)
  )
  (begin
    (unwrap! (only-admin) (err u100))
    (map-set memberships
      {user: user}
      {
        tier: tier,
        expires-at: expires-at,
        transferable: transferable,
        active: true
      }
    )
    (ok true)
  )
)

;; Revoke membership
(define-public (revoke-membership (user principal))
  (begin
    (unwrap! (only-admin) (err u100))
    (let ((m (map-get? memberships {user: user})))
      (asserts! (is-some m) (err u101))
      (map-set memberships
        {user: user}
        (merge (unwrap! m (err u101)) {active: false})
      )
      (ok true)
    )
  )
)

;; Upgrade or downgrade membership tier
(define-public (update-tier (user principal) (new-tier uint))
  (begin
    (unwrap! (only-admin) (err u100))
    (let ((m (map-get? memberships {user: user})))
      (asserts! (is-some m) (err u101))
      (map-set memberships
        {user: user}
        (merge (unwrap! m (err u101)) {tier: new-tier})
      )
      (ok true)
    )
  )
)

;; Extend membership duration
(define-public (extend-membership (user principal) (new-exp (optional uint)))
  (begin
    (unwrap! (only-admin) (err u100))
    (let ((m (map-get? memberships {user: user})))
      (asserts! (is-some m) (err u101))
      (map-set memberships
        {user: user}
        (merge (unwrap! m (err u101)) {expires-at: new-exp})
      )
      (ok true)
    )
  )
)

;; ----------------------------
;; TRANSFERS (If Allowed)
;; ----------------------------

(define-public (transfer-membership (recipient principal))
  (let (
        (m (map-get? memberships {user: tx-sender}))
       )
    (asserts! (is-some m) (err u101))
    (let ((mem (unwrap! m (err u101))))
      ;; Must be active and transferable
      (asserts! (get active mem) (err u102))
      (asserts! (get transferable mem) (err u103))
      ;; Prevent self-transfer
      (asserts! (not (is-eq recipient tx-sender)) (err u104))

      ;; Transfer membership to recipient
      ;; Sender loses membership
      (map-set memberships {user: tx-sender} (merge mem {active: false}))

      ;; Recipient receives same membership attributes
      (map-set memberships
        {user: recipient}
        {
          tier: (get tier mem),
          expires-at: (get expires-at mem),
          transferable: (get transferable mem),
          active: true
        }
      )
      (ok true)
    )
  )
)

;; ----------------------------
;; READ-ONLY VIEWS
;; ----------------------------

;; Check if user is an active member
(define-read-only (is-member (user principal))
  (let (
        (m (map-get? memberships {user: user}))
       )
    (match m
      membership (unwrap! (is-valid membership) false)
      false
    )
  )
)

;; Get membership tier
(define-read-only (get-tier (user principal))
  (let ((m (map-get? memberships {user: user})))
    (match m
      mem (ok (get tier mem))
      (ok u0)
    )
  )
)

;; Get full membership record
(define-read-only (get-membership (user principal))
  (map-get? memberships {user: user})
)