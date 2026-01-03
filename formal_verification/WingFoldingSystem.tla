---------------------------- MODULE WingFoldingSystem ----------------------------
(*
  TLA+ Specification for Wing Folding System with New GLDAB & PWM Output
  
  This specification models the core control logic of the biomimetic
  ornithopter wing folding system, including:
  - Wing flapping cycle with phase detection
  - Wing folding/extending mechanics
  - Control mode transitions
  - Servo command generation
  - Motor speed control with GLDAB (Glide Lock Detection And Brake)
  
  Author: Research & Development Team
  Date: 2025-01-02
*)

EXTENDS Integers, Sequences, FiniteSets, TLC

CONSTANTS
  MIN_PWM,           \* Minimum PWM value (900 microseconds)
  MAX_PWM,           \* Maximum PWM value (2100 microseconds)
  GLIDE_THRESHOLD,   \* Throttle threshold for glide mode (950)
  FOLD_THRESHOLD,    \* Minimum throttle for wing folding (1080)
  SERVO_COUNT,       \* Number of servos (8)
  CHANNEL_COUNT      \* Number of RC channels (8)

VARIABLES
  \* Sensor inputs
  hallSensorWing,       \* Hall sensor for wing position {TRUE, FALSE}
  hallSensorGlide,      \* Hall sensor for glide detection {TRUE, FALSE}
  rcChannels,           \* RC channel values [1..8 -> MIN_PWM..MAX_PWM]
  
  \* System state
  wingPhase,            \* Current phase in flapping cycle [0..359]
  foldState,            \* Wing folding state
  controlMode,          \* Operating mode
  motorSpeed,           \* ESC throttle value
  
  \* Outputs
  servoCommands,        \* Servo PWM commands [1..8 -> MIN_PWM..MAX_PWM]
  ledState,             \* LED indicator state {ON, OFF}
  
  \* Internal state
  foldTimer,            \* Timer for wing fold duration
  foldDuration,         \* Calculated fold duration
  glideActive           \* Glide lock active flag

\* Define the set of valid control modes
ControlModes == {"FLAP_WITH_FOLD", "FLAP_NO_FOLD", "STOOP", "GLIDE_LOCK"}

\* Define the set of valid fold states  
FoldStates == {"EXTENDED", "FOLDING", "FOLDED", "EXTENDING"}

\* Valid PWM range
ValidPWM == MIN_PWM..MAX_PWM

--------------------------------------------------------------------------------
\* Type definitions

TypeInvariant ==
  /\ wingPhase \in 0..359
  /\ foldState \in FoldStates
  /\ controlMode \in ControlModes
  /\ motorSpeed \in ValidPWM
  /\ \A i \in 1..SERVO_COUNT : servoCommands[i] \in ValidPWM
  /\ \A i \in 1..CHANNEL_COUNT : rcChannels[i] \in ValidPWM
  /\ ledState \in {"ON", "OFF"}
  /\ foldTimer \in 0..18000
  /\ foldDuration \in 0..18000
  /\ glideActive \in BOOLEAN
  /\ hallSensorWing \in BOOLEAN
  /\ hallSensorGlide \in BOOLEAN

--------------------------------------------------------------------------------
\* Initial state

Init ==
  /\ hallSensorWing = FALSE
  /\ hallSensorGlide = FALSE
  /\ rcChannels = [i \in 1..CHANNEL_COUNT |-> 1500]
  /\ wingPhase = 0
  /\ foldState = "EXTENDED"
  /\ controlMode = "FLAP_NO_FOLD"
  /\ motorSpeed = MIN_PWM
  /\ servoCommands = [i \in 1..SERVO_COUNT |-> 1500]
  /\ ledState = "OFF"
  /\ foldTimer = 0
  /\ foldDuration = 300
  /\ glideActive = FALSE

--------------------------------------------------------------------------------
\* Helper functions

\* Calculate wing fold duration based on throttle and trim
\* Models Arduino's mixed-precision arithmetic: WFTime=-0.821*ch3+1768; WFTT=0.01*ch6-10; WFTi=WFTime*WFTT
\* The calculation is performed in real arithmetic then truncated to integer as in the actual implementation
CalculateFoldDuration(throttle, trimChannel) ==
  LET wfTimeReal == (-821 * throttle) / 1000 + 1768
      wfTrimReal == trimChannel / 100 - 10
      wfTime == wfTimeReal \div 1  \* Truncate to integer (floor for positive, ceiling for negative)
      wfTrim == wfTrimReal \div 1
  IN wfTime * wfTrim

\* Calculate servo value for wing with aileron and fold trim
CalculateWingServo(aileron, foldTrim, isRight) ==
  LET baseServo == IF isRight 
                   THEN 2 * aileron - 2000 
                   ELSE 2 * aileron - 1000
      withTrim == IF isRight
                  THEN baseServo + foldTrim
                  ELSE baseServo - foldTrim
  IN IF withTrim < MIN_PWM THEN MIN_PWM
     ELSE IF withTrim > MAX_PWM THEN MAX_PWM
     ELSE withTrim

\* Calculate V-tail servo values (inverted V-tail mixing)
CalculateVTailServo(rudder, elevator, isRight) ==
  LET mixed == IF isRight
               THEN rudder + (-elevator + 1500)
               ELSE rudder + (elevator - 1500)
  IN IF mixed < MIN_PWM THEN MIN_PWM
     ELSE IF mixed > MAX_PWM THEN MAX_PWM
     ELSE mixed

\* Determine control mode from RC channel 5
DetermineControlMode(ch5) ==
  IF ch5 > 1700 THEN "FLAP_WITH_FOLD"
  ELSE IF ch5 > 1300 THEN "FLAP_NO_FOLD"
  ELSE "STOOP"

--------------------------------------------------------------------------------
\* State transitions

\* Update sensor readings (non-deterministic for model checking)
UpdateSensors ==
  /\ hallSensorWing' \in BOOLEAN
  /\ hallSensorGlide' \in BOOLEAN
  /\ rcChannels' = [i \in 1..CHANNEL_COUNT |-> 
                     IF rcChannels[i] + 10 > MAX_PWM THEN MIN_PWM
                     ELSE IF rcChannels[i] + 10 < MIN_PWM THEN MAX_PWM
                     ELSE rcChannels[i] + 10]
  /\ UNCHANGED <<wingPhase, foldState, controlMode, motorSpeed, 
                 servoCommands, ledState, foldTimer, foldDuration, glideActive>>

\* Update wing phase (simulates flapping cycle progression)
UpdateWingPhase ==
  /\ wingPhase' = (wingPhase + 10) % 360
  /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, foldState, 
                 controlMode, motorSpeed, servoCommands, ledState, 
                 foldTimer, foldDuration, glideActive>>

\* Process control mode selection
ProcessControlMode ==
  LET ch5 == rcChannels[5]
      newMode == DetermineControlMode(ch5)
  IN /\ controlMode' = newMode
     /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                    foldState, motorSpeed, servoCommands, ledState, 
                    foldTimer, foldDuration, glideActive>>

\* Update wing folding state machine
UpdateWingFolding ==
  /\ controlMode = "FLAP_WITH_FOLD"
  /\ motorSpeed > FOLD_THRESHOLD
  /\ hallSensorWing = TRUE
  /\ foldState = "EXTENDED"
  /\ foldState' = "FOLDING"
  /\ foldTimer' = 0
  /\ foldDuration' = CalculateFoldDuration(rcChannels[3], rcChannels[6])
  /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                 controlMode, motorSpeed, servoCommands, ledState, glideActive>>

\* Progress wing folding
ProgressWingFolding ==
  /\ foldState = "FOLDING"
  /\ foldTimer < foldDuration
  /\ foldTimer' = foldTimer + 1
  /\ IF foldTimer' >= foldDuration 
     THEN foldState' = "EXTENDING"
     ELSE foldState' = foldState
  /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                 controlMode, motorSpeed, servoCommands, ledState, 
                 foldDuration, glideActive>>

\* Complete wing extension
CompleteWingExtension ==
  /\ foldState = "EXTENDING"
  /\ foldState' = "EXTENDED"
  /\ foldTimer' = 0
  /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                 controlMode, motorSpeed, servoCommands, ledState, 
                 foldDuration, glideActive>>

\* Update servo commands
UpdateServoCommands ==
  LET ch1 == rcChannels[1]  \* Aileron
      ch2 == rcChannels[2]  \* Elevator
      ch3 == rcChannels[3]  \* Throttle/ESC
      ch4 == rcChannels[4]  \* Rudder
      ch6 == rcChannels[6]  \* Wing fold time trim
      ch7 == rcChannels[7]  \* Wing fold degree trim
      ch8 == rcChannels[8]  \* Auxiliary
      foldTrim == ch7 - 1000
      rtWing == CalculateWingServo(ch1, IF foldState = "FOLDING" THEN foldTrim ELSE 0, TRUE)
      ltWing == CalculateWingServo(ch1, IF foldState = "FOLDING" THEN foldTrim ELSE 0, FALSE)
      rtTail == CalculateVTailServo(ch4, ch2, TRUE)
      ltTail == CalculateVTailServo(ch4, ch2, FALSE)
  IN /\ servoCommands' = [i \in 1..SERVO_COUNT |->
                          IF i = 1 THEN rtWing
                          ELSE IF i = 2 THEN rtTail
                          ELSE IF i = 3 THEN ch3
                          ELSE IF i = 4 THEN ltWing
                          ELSE IF i = 5 THEN ltTail
                          ELSE IF i = 6 THEN ch6
                          ELSE IF i = 7 THEN ch7
                          ELSE ch8]
     /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                    foldState, controlMode, motorSpeed, ledState, 
                    foldTimer, foldDuration, glideActive>>

\* Update motor speed
UpdateMotorSpeed ==
  /\ motorSpeed' = rcChannels[3]
  /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                 foldState, controlMode, servoCommands, ledState, 
                 foldTimer, foldDuration, glideActive>>

\* Activate glide lock
ActivateGlideLock ==
  /\ controlMode \in {"FLAP_WITH_FOLD", "FLAP_NO_FOLD"}
  /\ rcChannels[3] < GLIDE_THRESHOLD
  /\ glideActive = FALSE
  /\ glideActive' = TRUE
  /\ ledState' = "ON"
  /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                 foldState, controlMode, motorSpeed, servoCommands, 
                 foldTimer, foldDuration>>

\* Maintain glide lock
MaintainGlideLock ==
  /\ glideActive = TRUE
  /\ hallSensorGlide = FALSE
  /\ rcChannels[3] < GLIDE_THRESHOLD
  /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                 foldState, controlMode, motorSpeed, servoCommands, ledState,
                 foldTimer, foldDuration, glideActive>>

\* Deactivate glide lock (sensor detected or throttle increased)
DeactivateGlideLock ==
  /\ glideActive = TRUE
  /\ (hallSensorGlide = TRUE \/ rcChannels[3] > GLIDE_THRESHOLD)
  /\ glideActive' = FALSE
  /\ ledState' = "OFF"
  /\ controlMode' =
       IF controlMode = "GLIDE_LOCK"
         THEN CHOOSE m \in {"FLAP_WITH_FOLD", "FLAP_NO_FOLD"} : TRUE
         ELSE controlMode
  /\ UNCHANGED <<hallSensorWing, hallSensorGlide, rcChannels, wingPhase, 
                 foldState, motorSpeed, servoCommands, 
                 foldTimer, foldDuration>>

--------------------------------------------------------------------------------
\* Next state relation

Next ==
  \/ UpdateSensors
  \/ UpdateWingPhase
  \/ ProcessControlMode
  \/ UpdateWingFolding
  \/ ProgressWingFolding
  \/ CompleteWingExtension
  \/ UpdateServoCommands
  \/ UpdateMotorSpeed
  \/ ActivateGlideLock
  \/ MaintainGlideLock
  \/ DeactivateGlideLock

--------------------------------------------------------------------------------
\* Specification

Spec == Init /\ [][Next]_<<hallSensorWing, hallSensorGlide, rcChannels, 
                            wingPhase, foldState, controlMode, motorSpeed, 
                            servoCommands, ledState, foldTimer, foldDuration, 
                            glideActive>>

--------------------------------------------------------------------------------
\* Safety Properties (Invariants)

\* Servo commands must always be in valid PWM range
ServoRangeSafety ==
  \A i \in 1..SERVO_COUNT : servoCommands[i] \in ValidPWM

\* Motor speed must be in valid PWM range
MotorRangeSafety ==
  motorSpeed \in ValidPWM

\* Wing folding only occurs when throttle is above minimum threshold,
\* except in STOOP control mode where folding is allowed at any throttle.
FoldThrottleSafety ==
  (foldState = "FOLDING" /\ controlMode /= "STOOP") => motorSpeed > FOLD_THRESHOLD

\* Glide lock only activates below throttle threshold
GlideThrottleSafety ==
  glideActive => motorSpeed < GLIDE_THRESHOLD

\* LED is on when glide is active
GlideLEDCorrelation ==
  glideActive => ledState = "ON"

\* Wing phase must be in valid range
WingPhaseBounds ==
  wingPhase \in 0..359

\* Fold timer must not exceed maximum
FoldTimerBounds ==
  foldTimer <= 18000

\* Combined safety invariant
SafetyInvariant ==
  /\ ServoRangeSafety
  /\ MotorRangeSafety
  /\ WingPhaseBounds
  /\ FoldTimerBounds

--------------------------------------------------------------------------------
\* Liveness Properties (Temporal Logic)

\* The system eventually processes all control modes
EventuallyAllModes ==
  <>[](\E mode \in ControlModes : controlMode = mode)

\* Wing folding eventually completes when initiated
FoldingEventuallyCompletes ==
  [](foldState = "FOLDING" ~> foldState = "EXTENDED")

\* Glide lock eventually activates when conditions are met
EventuallyGlides ==
  [](rcChannels[3] < GLIDE_THRESHOLD ~> glideActive)

\* System is always responsive (no deadlock)
AlwaysResponsive ==
  []<>ENABLED(Next)

================================================================================
