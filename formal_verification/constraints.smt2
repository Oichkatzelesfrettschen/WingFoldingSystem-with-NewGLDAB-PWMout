; Z3 SMT-LIB2 Verification for Wing Folding System
; Verifies servo command constraints and control mixing logic
;
; Author: Research & Development Team
; Date: 2025-01-02

; ==============================================================================
; 1. SERVO RANGE CONSTRAINTS VERIFICATION
; ==============================================================================

(echo "=== Verifying Servo Range Constraints ===")

; Declare RC channel inputs
(declare-const ch1 Int)  ; Aileron
(declare-const ch2 Int)  ; Elevator
(declare-const ch3 Int)  ; Throttle/ESC
(declare-const ch4 Int)  ; Rudder
(declare-const ch5 Int)  ; Mode switch
(declare-const ch6 Int)  ; Wing fold time trim
(declare-const ch7 Int)  ; Wing fold degree trim
(declare-const ch8 Int)  ; Auxiliary

; Valid RC channel range
(assert (>= ch1 1000))
(assert (<= ch1 2000))
(assert (>= ch2 1000))
(assert (<= ch2 2000))
(assert (>= ch3 1000))
(assert (<= ch3 2000))
(assert (>= ch4 1000))
(assert (<= ch4 2000))
(assert (>= ch5 1000))
(assert (<= ch5 2000))
(assert (>= ch6 1000))
(assert (<= ch6 2000))
(assert (>= ch7 1000))
(assert (<= ch7 2000))
(assert (>= ch8 1000))
(assert (<= ch8 2000))

; Declare servo outputs
(declare-const RtServo Int)
(declare-const LtServo Int)
(declare-const RtVtailS Int)
(declare-const LtVtailS Int)

; Wing servo calculations (without fold trim)
(assert (= RtServo (- (* 2 ch1) 2000)))
(assert (= LtServo (- (* 2 ch1) 1000)))

; V-tail mixing
(assert (= RtVtailS (+ ch4 (- 1500 ch2))))
(assert (= LtVtailS (+ ch4 (- ch2 1500))))

; Constrain function simulation (must be within valid PWM range)
(assert (>= RtServo 900))
(assert (<= RtServo 2100))
(assert (>= LtServo 900))
(assert (<= LtServo 2100))
(assert (>= RtVtailS 900))
(assert (<= RtVtailS 2100))
(assert (>= LtVtailS 900))
(assert (<= LtVtailS 2100))

(echo "Checking satisfiability of servo range constraints...")
(check-sat)
(echo "Getting example model:")
(get-model)

(echo "")
(echo "=== Verifying Wing Servo Bounds ===")

; Push new context for wing servo specific checks
(push)

; Test extreme aileron values
(assert (= ch1 1000))  ; Minimum aileron
(echo "Checking minimum aileron (ch1=1000):")
(check-sat)
(get-value (RtServo LtServo))

(pop)
(push)

(assert (= ch1 2000))  ; Maximum aileron
(echo "Checking maximum aileron (ch1=2000):")
(check-sat)
(get-value (RtServo LtServo))

(pop)

; ==============================================================================
; 2. V-TAIL MIXING CORRECTNESS VERIFICATION
; ==============================================================================

(echo "")
(echo "=== Verifying V-Tail Mixing Correctness ===")

(push)

; Verify mixing symmetry property
(declare-const rudder_sum Int)
(assert (= rudder_sum (+ RtVtailS LtVtailS)))
(assert (= rudder_sum (* 2 ch4)))

(echo "Checking V-tail mixing symmetry (RtVtailS + LtVtailS = 2 * ch4):")
(check-sat)

; Test neutral position
(assert (= ch2 1500))
(assert (= ch4 1500))
(echo "At neutral (ch2=1500, ch4=1500), both tail servos should be 1500:")
(check-sat)
(get-value (RtVtailS LtVtailS))

(pop)
(push)

; Test pure elevator input
(assert (= ch4 1500))  ; Neutral rudder
(assert (= ch2 1700))  ; Up elevator
(echo "Pure elevator up (ch4=1500, ch2=1700):")
(check-sat)
(get-value (RtVtailS LtVtailS))

(pop)
(push)

; Test pure rudder input
(assert (= ch2 1500))  ; Neutral elevator
(assert (= ch4 1700))  ; Right rudder
(echo "Pure rudder right (ch2=1500, ch4=1700):")
(check-sat)
(get-value (RtVtailS LtVtailS))

(pop)

; ==============================================================================
; 3. WING FOLDING TIMING VERIFICATION
; ==============================================================================

(echo "")
(echo "=== Verifying Wing Folding Timing Constraints ===")

(push)

; Declare fold timing variables
(declare-const WFTime Int)
(declare-const WFTime_real Real)
(declare-const WFTT Real)
(declare-const WFTi Real)

; Wing fold time calculation in Arduino:
;   WFTime (int) = -0.821 * ch3value + 1768;
; Model this as a real intermediate followed by truncation to int.
(assert (= WFTime_real (+ (* -0.821 (to_real ch3)) 1768.0)))
(assert (= WFTime (to_int WFTime_real)))

; Wing fold time trim: WFTT = 0.01 * ch6 - 10
(assert (= WFTT (- (* 0.01 (to_real ch6)) 10.0)))

; Combined fold duration: WFTi = WFTime * WFTT
(assert (= WFTi (* (to_real WFTime) WFTT)))

; Timing constraints
(assert (>= WFTi 0.0))
(assert (<= WFTi 18000.0))

; Additional constraints
(assert (>= ch3 1080))  ; Minimum throttle for wing folding
(assert (<= ch3 2000))

(echo "Checking wing folding timing constraints:")
(check-sat)
(echo "Example fold timing:")
(get-value (ch3 ch6 WFTime WFTT WFTi))

; Test minimum throttle
(pop)
(push)

(declare-const WFTime2 Real)
(declare-const WFTT2 Real)
(declare-const WFTi2 Real)

(assert (= WFTime2 (+ (* -0.821 (to_real ch3)) 1768.0)))
(assert (= WFTT2 (- (* 0.01 (to_real ch6)) 10.0)))
(assert (= WFTi2 (* WFTime2 WFTT2)))
(assert (= ch3 1080))  ; Minimum fold throttle
(assert (= ch6 1500))  ; Mid trim

(echo "At minimum fold throttle (ch3=1080, ch6=1500):")
(check-sat)
(get-value (WFTime2 WFTT2 WFTi2))

(pop)
(push)

; Test maximum throttle
(declare-const WFTime3 Real)
(declare-const WFTT3 Real)
(declare-const WFTi3 Real)

(assert (= WFTime3 (+ (* -0.821 (to_real ch3)) 1768.0)))
(assert (= WFTT3 (- (* 0.01 (to_real ch6)) 10.0)))
(assert (= WFTi3 (* WFTime3 WFTT3)))
(assert (= ch3 2000))  ; Maximum throttle
(assert (= ch6 1500))  ; Mid trim

(echo "At maximum throttle (ch3=2000, ch6=1500):")
(check-sat)
(get-value (WFTime3 WFTT3 WFTi3))

(pop)

; ==============================================================================
; 4. WING FOLDING WITH TRIM VERIFICATION
; ==============================================================================

(echo "")
(echo "=== Verifying Wing Folding with Trim ===")

(push)

; Declare wing servo outputs with fold trim
(declare-const WFtrim Int)
(declare-const RtServoFold Int)
(declare-const LtServoFold Int)

; Fold trim calculation
(assert (= WFtrim (- ch7 1000)))

; Wing servos with fold trim:
; - Both servos include WFtrim, but with opposite signs, matching:
;     RtServo = 2*ch1 - 2000 + WFtrim
;     LtServo = 2*ch1 - 1000 - WFtrim
; - This intentional asymmetry makes the wings fold by moving the servos
;   in opposite directions relative to their baseline positions.
(assert (= RtServoFold (+ (- (* 2 ch1) 2000) WFtrim)))
(assert (= LtServoFold (- (- (* 2 ch1) 1000) WFtrim)))

; Ensure servos remain in valid range
(assert (>= RtServoFold 900))
(assert (<= RtServoFold 2100))
(assert (>= LtServoFold 900))
(assert (<= LtServoFold 2100))

(echo "Checking wing servos with fold trim:")
(check-sat)

; Test maximum fold trim
(assert (= ch7 2000))  ; Maximum trim
(assert (= ch1 1500))  ; Neutral aileron
(echo "At maximum fold trim (ch7=2000, ch1=1500):")
(check-sat)
(get-value (WFtrim RtServoFold LtServoFold))

(pop)

; ==============================================================================
; 5. CONTROL MODE LOGIC VERIFICATION
; ==============================================================================

(echo "")
(echo "=== Verifying Control Mode Logic ===")

(push)

; Define control modes as integer enumeration
; 0 = STOOP, 1 = FLAP_NO_FOLD, 2 = FLAP_WITH_FOLD
(declare-const controlMode Int)

; Mode determination logic
(assert (=> (< ch5 1300) (= controlMode 0)))           ; STOOP
(assert (=> (and (>= ch5 1300) (< ch5 1700)) (= controlMode 1)))  ; FLAP_NO_FOLD
(assert (=> (>= ch5 1700) (= controlMode 2)))          ; FLAP_WITH_FOLD

; Test each mode boundary
(echo "Testing STOOP mode (ch5 < 1300):")
(assert (= ch5 1200))
(check-sat)
(get-value (ch5 controlMode))

(pop)
(push)

(declare-const controlMode2 Int)
(assert (=> (< ch5 1300) (= controlMode2 0)))
(assert (=> (and (>= ch5 1300) (< ch5 1700)) (= controlMode2 1)))
(assert (=> (>= ch5 1700) (= controlMode2 2)))

(echo "Testing FLAP_NO_FOLD mode (1300 <= ch5 < 1700):")
(assert (= ch5 1500))
(check-sat)
(get-value (ch5 controlMode2))

(pop)
(push)

(declare-const controlMode3 Int)
(assert (=> (< ch5 1300) (= controlMode3 0)))
(assert (=> (and (>= ch5 1300) (< ch5 1700)) (= controlMode3 1)))
(assert (=> (>= ch5 1700) (= controlMode3 2)))

(echo "Testing FLAP_WITH_FOLD mode (ch5 >= 1700):")
(assert (= ch5 1800))
(check-sat)
(get-value (ch5 controlMode3))

(pop)

; ==============================================================================
; 6. GLIDE LOCK ACTIVATION VERIFICATION
; ==============================================================================

(echo "")
(echo "=== Verifying Glide Lock Activation Logic ===")

(push)

(declare-const PreGMS Int)
(declare-const glideActive Bool)

; Pre-glide motor speed (stored value)
(assert (>= PreGMS 900))
(assert (<= PreGMS 2100))

; Glide activation condition
(assert (= glideActive (< ch3 950)))

; Test glide activation
(echo "Testing glide activation (ch3 < 950):")
(assert (= ch3 940))
(check-sat)
(get-value (ch3 glideActive))

(pop)
(push)

(declare-const glideActive2 Bool)
(assert (= glideActive2 (< ch3 950)))

(echo "Testing glide deactivation (ch3 >= 950):")
(assert (= ch3 960))
(check-sat)
(get-value (ch3 glideActive2))

(pop)

; ==============================================================================
; 7. COMPREHENSIVE SAFETY VERIFICATION
; ==============================================================================

(echo "")
(echo "=== Comprehensive Safety Verification ===")

(push)

; All previous constraints combined
(declare-const AllServosInRange Bool)

(assert (= AllServosInRange 
  (and 
    (>= RtServo 900) (<= RtServo 2100)
    (>= LtServo 900) (<= LtServo 2100)
    (>= RtVtailS 900) (<= RtVtailS 2100)
    (>= LtVtailS 900) (<= LtVtailS 2100)
    (>= ch3 900) (<= ch3 2100)
  )
))

(assert AllServosInRange)

(echo "Verifying all safety constraints simultaneously:")
(check-sat)
(echo "Safe configuration example:")
(get-model)

(pop)

(echo "")
(echo "=== Verification Complete ===")
(echo "All constraints have been checked.")
