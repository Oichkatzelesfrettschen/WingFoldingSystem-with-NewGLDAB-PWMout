# Wing Folding System with New GLDAB & PPM to PWM Output

[![Build Status](https://github.com/Oichkatzelesfrettschen/WingFoldingSystem-with-NewGLDAB-PWMout/workflows/Build%20and%20Verify/badge.svg)](https://github.com/Oichkatzelesfrettschen/WingFoldingSystem-with-NewGLDAB-PWMout/actions)
[![PlatformIO](https://img.shields.io/badge/PlatformIO-compatible-blue.svg)](https://platformio.org/)
[![License](https://img.shields.io/badge/license-Open%20Source-green.svg)](LICENSE)

## Overview

This system combines a New GLDAB (Glide Lock Detection And Brake) by Arduino with PPM to PWM signal conversion and a biomimetic wing folding mechanism that folds the wings on the upstroke, emulating real avian flight dynamics.

![250129 Wing motion](/image/250129%20Wing%20motion.jpg)


2) This was devised to make it more similar to the flapping of a real bird.

 The wings are folded by combining thin carbon plate parts.

 ![250208 Frame  Falcon141 Folding Wing SystemwithAGLDAB](/image/250208%20Frame%20%20Falcon141%20Folding%20Wing%20SystemwithAGLDAB.jpg)

 For this Ornithopter to fly, wings suitable for this system must be developed.

3) By flipping a switch, you can turn off the folding or keep the wings folded at all times (stoop).

4) The magnet sensor detects when the wings are entering the upstroke, and the servo folds the wings to the specified wing folding level for 1/4 of the flapping period. The wings then spread out by the top of the flapping and continue the downstroke with the wings spread out.

5) By operating the Aileron, one wing is folded, allowing the Ornithopter to turn left or right.

6) The two tail servos are set to Inverted V-tail mixing in the CODE. It moves by operating the Rudder and Elevator, and you can control turning left and right and ascending and descending.

---

## Quick Start

### Building with PlatformIO (Recommended)

```bash
# Install PlatformIO
pip install -U platformio

# Build the firmware
pio run -e uno

# Upload to board
pio run -e uno -t upload

# Monitor serial output
pio device monitor
```

### Building with Make

```bash
# Build firmware
make build-pio

# Upload firmware
make upload-pio

# Run formal verification
make verify

# Clean build artifacts
make clean
```

### Traditional Arduino IDE

1. Open `sketch250209PWMoutAGLDABFoldWingiV-tail2S/sketch250209PWMoutAGLDABFoldWingiV-tail2S.ino`
2. Install Servo library (usually pre-installed)
3. Select your board (Arduino Uno/Mega/Nano)
4. Compile and upload

---

## Documentation

Comprehensive technical documentation is available in the [`docs/`](docs/) directory:

- **[Comprehensive Research Report](docs/COMPREHENSIVE_RESEARCH_REPORT.md)** - Complete R&D analysis including:
  - Mathematical foundations (quaternions, octonions, spatial rotations)
  - Materials science and fluid mechanics
  - Sensor integration and data fusion
  - Machine learning algorithms (MLP, situational awareness)
  - Stability analysis and control theory
  - Formal verification with TLA+ and Z3
  - Build system modernization

- **[Quaternion & Octonion Mathematics](docs/QUATERNION_OCTONION_MATHEMATICS.md)** - Detailed mathematical treatment of spatial rotations

- **[Formal Verification](formal_verification/README.md)** - TLA+ specifications and Z3 SMT constraints

### Key Technical Topics

- **Technical Debt Analysis**: Mathematical quantification of lacunae and debitum technicum
- **Quaternion Rotations**: 3D spatial calculations for wing kinematics
- **Octonion Algebra**: Multi-body dynamics modeling
- **Fluid Mechanics**: Unsteady aerodynamics and wing folding analysis
- **Sensor Fusion**: Kalman filtering and multi-sensor integration
- **MLP Neural Networks**: Adaptive control and situational awareness
- **Stability Analysis**: Longitudinal and lateral-directional stability
- **Formal Methods**: TLA+ and Z3 verification of control logic

---

## System Features

### Core Functionality

**Wing Folding Modes:**
- **Flap with Fold**: Active flapping with upstroke wing folding
- **Flap without Fold**: Continuous flapping with extended wings
- **Stoop Mode**: Continuous wing folding (hunting dive emulation)

**GLDAB (Glide Lock Detection And Brake):**
- Automatic glide mode activation at low throttle
- Motor speed pre-setting for smooth glide transitions
- Hall sensor-based position detection

**Control Features:**
- 8-channel PPM to PWM conversion
- Inverted V-tail mixing for pitch and yaw control
- Adjustable wing fold timing and degree
- Real-time servo control with microsecond precision

---

## How to Operate

Ornithopter can fold its wings like a real bird

1) The wings fold when the wings are upstroke and spread when the wings are downstroke.

2) The magnet sensor detects when the wings are at their lowest position, and the wings are folded for 1/4 of a flapping cycle, and when the wings are downstroke, the wings are spread and swung down.

The time the wings are folded can be adjusted. Ch 6

The length of time the wings are folded is longer when the flapping frequency is low and shorter when the flapping frequency is high.

3) Stoop (stoop posture) can be switched on ch5.

There are three modes---Wing Folding mode, No Wing Folding Mode, Stoop mode

4) The degree of folding of the wings can be adjusted. CH7

5) NewGLDAB is built in, so the wings can be easily fixed in the gliding position.

6) The tail can be operated with two servos to control the Inverted V-tail.





##  Falcon141 Folding Wing System : Flap test ( with Making photos)

https://www.youtube.com/watch?v=LzfnhL0PMvs

## Falcon141 Folding Wing System : Flap test 2 with Wing Membrane

https://www.youtube.com/watch?v=vdpKn6cjO1Q

## List of Falcon141 Folding Wing System

https://www.youtube.com/playlist?list=PLErvdRrwWuPolGrbgrTzQfxIgkow6od_m


## Wiring

 ![250126 FoldingWingSystemwithPWMout&Arduino GLDAB](/image/250126%20FoldingWingSystemwithPWMout&Arduino%20GLDAB.jpg)


##  reference : 

New GLDAB by Arduino with convert PPM to PWM signal output 

https://github.com/KazuKaku/New-GLDAB-Arduino-with-PWM-output

A Novel Actuation Strategy for an Agile Bioinspired FWAV Performing a Morphing-Coupled Wingbeat Pattern 

https://ieeexplore.ieee.org/document/9849140

## My YouTube channel 
 Various Ornithopters have been uploaded.
(https://www.youtube.com/@BZH07614)

## My Website of ornithopter
 (http://kakutaclinic.life.coocan.jp/HabatakE.htm)

## Request site for production of Kazu Ornithpter
(http://kakutaclinic.life.coocan.jp/KOrniSSt.html)

---

## Build System & Continuous Integration

### Modern Build Infrastructure

This project includes a modernized build system with:

- **PlatformIO**: Cross-platform build system with dependency management
- **Makefile**: Automated build, test, and verification workflows
- **GitHub Actions**: Continuous integration and automated testing
- **Formal Verification**: TLA+ and Z3 integration for correctness proofs

### Build Targets

```bash
make build-pio        # Build firmware
make upload-pio       # Upload to Arduino
make monitor-pio      # Start serial monitor
make test             # Run verification tests
make verify           # Run formal verification
make docs             # Generate documentation
make clean            # Clean build artifacts
```

### Continuous Integration

The CI pipeline automatically:
- Builds firmware for multiple Arduino boards (Uno, Mega, Nano)
- Runs static analysis (cppcheck, PlatformIO check)
- Executes formal verification (Z3 SMT solver)
- Validates documentation
- Checks code formatting

---

## Formal Verification

### TLA+ Model Checking

The system behavior is formally specified in TLA+ to verify:
- **Safety Properties**: Servo ranges, motor speeds, timing bounds
- **Liveness Properties**: System responsiveness, task completion
- **Invariants**: Type correctness, state machine validity

### Z3 Theorem Proving

Mathematical constraints are verified using Z3 SMT solver:
- Servo range constraints
- V-tail mixing correctness
- Wing folding timing calculations
- Control mode logic
- Glide lock activation conditions

**Run verification:**
```bash
cd formal_verification
make verify-z3
```

See [formal_verification/README.md](formal_verification/README.md) for details.

---

## Technical Architecture

### Hardware Components

- **Microcontroller**: Arduino Uno/Mega/Nano (ATmega328P/2560)
- **Sensors**: Hall effect sensors (wing position, glide detection)
- **Actuators**: 8x servo motors (wings, tail surfaces)
- **Input**: PPM receiver (8 channels)
- **Output**: PWM servo signals, ESC control

### Software Architecture

```
┌─────────────────────────────────────────┐
│         PPM Input Processing            │
│  (8-channel RC receiver interface)      │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Control Mode State Machine         │
│  FLAP_WITH_FOLD | FLAP_NO_FOLD |       │
│       STOOP | GLIDE_LOCK                │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Wing Folding Controller            │
│  - Phase detection (Hall sensors)       │
│  - Timing calculation                   │
│  - Servo position computation           │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         Output Generation               │
│  - Servo PWM signals                    │
│  - V-tail mixing                        │
│  - ESC throttle control                 │
└─────────────────────────────────────────┘
```

### Control Flow

1. **Input**: Read PPM channels from RC receiver
2. **Mode Selection**: Determine operating mode from Ch5
3. **Sensor Reading**: Check Hall sensors for wing position
4. **Calculation**: Compute servo positions, fold timing, V-tail mixing
5. **Output**: Write PWM signals to servos and ESC
6. **GLDAB**: Monitor for glide lock conditions

---

## 🧮 Mathematical Foundations

### Quaternion Rotations

Wing orientation and rotations are mathematically modeled using quaternions:

```
q = w + xi + yj + zk
```

For rotation of angle θ about axis **n**:
```
q = [cos(θ/2), sin(θ/2)·n_x, sin(θ/2)·n_y, sin(θ/2)·n_z]
```

**Benefits:**
- No gimbal lock
- Efficient interpolation (SLERP)
- Compact representation
- Stable numerical properties

### V-tail Mixing

Inverted V-tail control uses mixing matrix:

```
[δ_right]   [1  -1] [δ_rudder  ]
[δ_left ] = [1   1] [δ_elevator]
```

Implementation:
```c
RtV-tailS = ch4 + (-ch2 + 1500);  // Rudder - Elevator
LtV-tailS = ch4 + (ch2 - 1500);   // Rudder + Elevator
```

### Wing Folding Dynamics

Fold timing based on flapping frequency:
```
WFTime = -0.821 × throttle + 1768
WFTT = 0.01 × trim - 10
WFTi = WFTime × WFTT
```

See [docs/QUATERNION_OCTONION_MATHEMATICS.md](docs/QUATERNION_OCTONION_MATHEMATICS.md) for complete mathematical treatment.

---

## Future Enhancements

### Planned Features

**Sensor Integration:**
- [ ] IMU (gyroscope + accelerometer) for attitude estimation
- [ ] Barometric pressure sensor for altitude
- [ ] Airspeed sensor (Pitot tube)
- [ ] Temperature and humidity sensors

**Control Algorithms:**
- [ ] Extended Kalman Filter for sensor fusion
- [ ] MLP neural network for adaptive control
- [ ] Model Predictive Control (MPC)
- [ ] Online learning and adaptation

**Communication:**
- [ ] MAVLink telemetry protocol
- [ ] Ground station integration
- [ ] Real-time data logging
- [ ] Parameter tuning interface

**Analysis:**
- [ ] Hardware-in-the-loop (HIL) simulation
- [ ] CFD validation of aerodynamics
- [ ] Flight test data analysis
- [ ] Performance optimization

---

## Contributing

Contributions are welcome! Areas for contribution:

- **Documentation**: Improve clarity, add examples
- **Testing**: Unit tests, integration tests, HIL simulation
- **Features**: New sensors, algorithms, communication protocols
- **Optimization**: Performance improvements, memory usage
- **Formal Verification**: Extended TLA+ specifications, additional Z3 proofs

---

## 📄 License

This project is open source. See LICENSE file for details.

---

## Acknowledgments

- Original GLDAB concept: [New GLDAB Arduino with PWM output](https://github.com/KazuKaku/New-GLDAB-Arduino-with-PWM-output)
- PPM Reader library: Aapo Nikkilä, Dmitry Grigoryev
- Research reference: [A Novel Actuation Strategy for an Agile Bioinspired FWAV](https://ieeexplore.ieee.org/document/9849140)
- TLA+ and Z3 communities for formal methods tools

---

**Project Status**: Active Development  
**Version**: 1.0  
**Last Updated**: 2025-01-02

