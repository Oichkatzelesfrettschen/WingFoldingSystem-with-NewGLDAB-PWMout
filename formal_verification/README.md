# Formal Verification

This directory contains formal specifications and verification tools for the Wing Folding System.

## Contents

### TLA+ Specifications

- **WingFoldingSystem.tla** - Complete TLA+ specification of the control system
- **WingFoldingSystem.cfg** - Model checking configuration

### Z3 SMT Constraints

- **constraints.smt2** - SMT-LIB2 constraints for servo and control logic verification

### Makefile

- **Makefile** - Automated verification workflow

## Quick Start

### Prerequisites

**For Z3 verification:**
```bash
# Ubuntu/Debian
sudo apt-get install z3

# macOS
brew install z3

# Windows
# Download from: https://github.com/Z3Prover/z3/releases
```

**For TLA+ verification:**
```bash
# Download tla2tools.jar
wget https://github.com/tlaplus/tlaplus/releases/download/v1.7.1/tla2tools.jar

# Requires Java
sudo apt-get install default-jre
```

### Running Verification

**Run Z3 verification (recommended):**
```bash
make verify-z3
```

**Run TLA+ model checking:**
```bash
make verify-tla
```

**Run all verifications:**
```bash
make verify
```

### Clean outputs:
```bash
make clean
```

## What is Verified?

### Safety Properties

1. **Servo Range Safety**: All servo commands are within valid PWM range [900, 2100]μs
2. **Motor Speed Safety**: ESC throttle is within valid range
3. **Wing Phase Bounds**: Wing phase angle is always [0, 359] degrees
4. **Fold Timer Bounds**: Fold timer doesn't exceed maximum value
5. **Glide Throttle Safety**: Glide lock only activates below throttle threshold
6. **Fold Throttle Safety**: Wing folding only occurs above minimum throttle

### Functional Correctness

1. **V-tail Mixing**: Verifies inverted V-tail mixing equations
2. **Wing Servo Calculations**: Validates aileron to servo position mapping
3. **Wing Folding Timing**: Checks fold duration calculations
4. **Control Mode Logic**: Verifies mode selection based on RC channel 5
5. **Glide Lock Activation**: Validates glide lock trigger conditions

### Liveness Properties

1. **Folding Completion**: Wing folding eventually completes
2. **System Responsiveness**: System is always responsive (no deadlock)
3. **Mode Transitions**: All control modes are reachable

## TLA+ Specification Overview

The TLA+ specification models:

- **State Variables**: Wing phase, fold state, control mode, motor speed, servo commands, etc.
- **Actions**: Sensor updates, wing phase progression, control mode selection, servo updates
- **Invariants**: Type correctness, safety properties
- **Temporal Properties**: Liveness guarantees

### State Machine

```
Control Modes:
- FLAP_WITH_FOLD: Active flapping with upstroke folding
- FLAP_NO_FOLD: Active flapping without folding
- STOOP: Continuous wing folding (dive mode)
- GLIDE_LOCK: Motor-assisted glide

Fold States:
- EXTENDED: Wings fully extended
- FOLDING: Wings actively folding
- FOLDED: Wings fully folded
- EXTENDING: Wings returning to extended position
```

## Z3 SMT Verification

The Z3 verification checks:

1. **Servo Range Constraints**: Ensures servo calculations stay within bounds
2. **V-tail Mixing Correctness**: Validates mixing equations
3. **Wing Folding Timing**: Checks timing calculations
4. **Control Mode Logic**: Verifies mode determination
5. **Glide Lock Logic**: Validates activation conditions
6. **Comprehensive Safety**: All constraints simultaneously

### Example Z3 Output

```
=== Verifying Servo Range Constraints ===
Checking satisfiability of servo range constraints...
sat
Getting example model:
(model
  (define-fun ch1 () Int 1500)
  (define-fun RtServo () Int 1000)
  (define-fun LtServo () Int 2000)
  ...
)
```

## Integration with CI/CD

The formal verification is integrated into the GitHub Actions workflow:

```yaml
- name: Run Z3 verification
  run: |
    cd formal_verification
    make verify-z3
```

## Extending the Verification

### Adding New Properties to TLA+

1. Edit `WingFoldingSystem.tla`
2. Add new invariant or temporal property
3. Update `WingFoldingSystem.cfg` to check the property
4. Run TLC model checker

### Adding New Z3 Constraints

1. Edit `constraints.smt2`
2. Declare new variables and assertions
3. Add check-sat and get-model commands
4. Run Z3 solver

## Interpreting Results

### TLA+ Results

- **No errors**: All properties verified for reachable states
- **Invariant violation**: Shows counterexample trace
- **Temporal property violation**: Shows infinite behavior violating property

### Z3 Results

- **sat**: Constraints are satisfiable (property holds)
- **unsat**: Constraints are unsatisfiable (error detected)
- **unknown**: Solver timeout or resource limit

## References

- [TLA+ Home](https://lamport.azurewebsites.net/tla/tla.html)
- [TLA+ Hyperbook](https://learntla.com/)
- [Z3 GitHub](https://github.com/Z3Prover/z3)
- [SMT-LIB Standard](http://smtlib.cs.uiowa.edu/)

## Troubleshooting

### TLA+ Issues

**Problem**: "Java not found"
```bash
sudo apt-get install default-jre
```

**Problem**: "tla2tools.jar not found"
```bash
wget https://github.com/tlaplus/tlaplus/releases/download/v1.7.1/tla2tools.jar
```

### Z3 Issues

**Problem**: "Z3 command not found"
```bash
# Check if Z3 is installed
which z3

# Install if missing
sudo apt-get install z3
```

**Problem**: Verification timeout
- Reduce state space in constraints
- Increase Z3 timeout: `z3 -T:300 constraints.smt2`

## Contact

For questions about formal verification:
- Open an issue in the GitHub repository
- Refer to the comprehensive research report in `docs/`

---

**Last Updated:** 2025-01-02
