# Quaternion and Octonion Mathematics for Spatial Rotations
## Wing Folding System - Mathematical Foundations

### Table of Contents
1. [Quaternion Basics](#quaternion-basics)
2. [Quaternion Operations](#quaternion-operations)
3. [Applications to Wing Rotation](#applications-to-wing-rotation)
4. [Octonion Extensions](#octonion-extensions)
5. [Implementation Considerations](#implementation-considerations)

---

## 1. Quaternion Basics

### 1.1 Definition

A quaternion **q** is a 4-dimensional hypercomplex number:

```
q = w + xi + yj + zk
```

Where:
- **w** = scalar (real) component
- **x, y, z** = vector (imaginary) components
- **i, j, k** = fundamental quaternion units satisfying:
  - i² = j² = k² = ijk = -1
  - ij = k, jk = i, ki = j
  - ji = -k, kj = -i, ik = -j

### 1.2 Geometric Interpretation

For a rotation of angle θ about unit axis **n** = (n_x, n_y, n_z):

```
q = [cos(θ/2), sin(θ/2) · n_x, sin(θ/2) · n_y, sin(θ/2) · n_z]
```

**Key Properties:**
- Unit quaternion: ||q|| = 1 (represents pure rotation)
- Compact representation: 4 numbers vs 9 (rotation matrix)
- No gimbal lock (unlike Euler angles)
- Efficient interpolation (SLERP)

---

## 2. Quaternion Operations

### 2.1 Conjugate

```
q* = w - xi - yj - zk
```

**Property:** q · q* = w² + x² + y² + z² = ||q||²

### 2.2 Multiplication (Hamilton Product)

```c
q₁ ⊗ q₂ = [w₁w₂ - x₁x₂ - y₁y₂ - z₁z₂,
           w₁x₂ + x₁w₂ + y₁z₂ - z₁y₂,
           w₁y₂ - x₁z₂ + y₁w₂ + z₁x₂,
           w₁z₂ + x₁y₂ - y₁x₂ + z₁w₂]
```

**Note:** Non-commutative (q₁ ⊗ q₂ ≠ q₂ ⊗ q₁)

### 2.3 Vector Rotation

To rotate vector **v** by quaternion **q**:

```
v' = q ⊗ v ⊗ q*
```

Where **v** is represented as pure quaternion: [0, v_x, v_y, v_z]

### 2.4 Conversion to Rotation Matrix

```
R = [1-2(y²+z²)   2(xy-wz)     2(xz+wy)  ]
    [2(xy+wz)     1-2(x²+z²)   2(yz-wx)  ]
    [2(xz-wy)     2(yz+wx)     1-2(x²+y²)]
```

### 2.5 SLERP (Spherical Linear Interpolation)

For smooth interpolation between q₁ and q₂:

```
slerp(q₁, q₂, t) = (sin((1-t)θ) / sin(θ)) · q₁ + (sin(tθ) / sin(θ)) · q₂
```

Where:
- θ = arccos(q₁ · q₂)
- t ∈ [0, 1]

---

## 3. Applications to Wing Rotation

### 3.1 Wing Coordinate Frames

**Body Frame (B):**
- Origin: Aircraft center of mass
- x-axis: Forward
- y-axis: Right wing
- z-axis: Down

**Wing Frame (W):**
- Origin: Wing root joint
- x-axis: Along wing chord
- y-axis: Along wing span
- z-axis: Perpendicular to wing surface

### 3.2 Wing Folding Transformation

**Neutral Position:**
```c
q_neutral = [1, 0, 0, 0]  // Identity quaternion
```

**Folded Position:**
```c
θ_fold = fold_angle  // From servo position
axis_fold = [0, 0, 1]  // Rotation about z-axis (vertical)

q_fold = [cos(θ_fold/2), 0, 0, sin(θ_fold/2)]
```

**Progressive Folding (Animation):**
```c
float t = fold_timer / fold_duration;  // Normalized time [0, 1]
quaternion q_current = slerp(q_neutral, q_fold, t);
```

### 3.3 Wing Tip Position Calculation

**Forward Kinematics:**
```c
// Wing structure parameters
float L_humerus = 150.0;  // Upper wing length (mm)
float L_radius = 120.0;   // Lower wing length (mm)

// Joint angles from servos
float theta_shoulder = map(servo_position, 900, 2100, -90, 90);
float theta_elbow = 0;  // Simplified: assume straight wing

// Quaternions for each joint
quaternion q_body = attitude_quaternion;
quaternion q_shoulder = from_axis_angle([0, 0, 1], theta_shoulder);
quaternion q_elbow = from_axis_angle([0, 0, 1], theta_elbow);

// Combined rotation
quaternion q_total = q_body ⊗ q_shoulder ⊗ q_elbow;

// Wing tip position in body frame
vector3 p_local = [L_humerus + L_radius, 0, 0];
vector3 p_body = rotate_vector(p_local, q_total);
```

### 3.4 Differential Aileron Control

**Asymmetric Wing Folding for Roll Control:**

```c
// Right wing
float fold_right = base_fold + aileron_input;
quaternion q_right = from_axis_angle([0, 0, 1], fold_right);

// Left wing (opposite)
float fold_left = base_fold - aileron_input;
quaternion q_left = from_axis_angle([0, 0, 1], fold_left);

// Resulting roll moment
float roll_moment = (fold_right - fold_left) * lift_coefficient * wing_span;
```

---

## 4. Octonion Extensions

### 4.1 Octonion Algebra

Octonions extend quaternions to 8 dimensions:

```
o = e₀ + e₁i₁ + e₂i₂ + e₃i₃ + e₄i₄ + e₅i₅ + e₆i₆ + e₇i₇
```

**Multiplication Table (Fano Plane):**

```
     e₁  e₂  e₃  e₄  e₅  e₆  e₇
e₁   -1  e₄  e₇ -e₂ -e₆  e₅  e₃
e₂  -e₄  -1  e₅  e₁  e₇ -e₃ -e₆
e₃  -e₇ -e₅  -1  e₆ -e₂  e₄  e₁
e₄   e₂ -e₁ -e₆  -1  e₃  e₇ -e₅
e₅   e₆ -e₇  e₂ -e₃  -1  e₁  e₄
e₆  -e₅  e₃ -e₄ -e₇ -e₁  -1  e₂
e₇  -e₃  e₆ -e₁  e₅ -e₄ -e₂  -1
```

**Properties:**
- Non-associative: (a·b)·c ≠ a·(b·c)
- Alternative: (a·a)·b = a·(a·b)
- Division algebra (non-zero elements invertible)

### 4.2 Multi-Body State Representation

**System State Octonion:**

```c
struct OctonionState {
    // Quaternion for body orientation
    float q_body[4];      // [w, x, y, z]
    
    // Wing articulation (2 DOF each)
    float wing_left[2];   // [shoulder, elbow]
    float wing_right[2];  // [shoulder, elbow]
};

// Map to octonion
octonion O_system = {
    q_body[0],      // e₀
    q_body[1],      // e₁
    q_body[2],      // e₂
    q_body[3],      // e₃
    wing_left[0],   // e₄
    wing_left[1],   // e₅
    wing_right[0],  // e₆
    wing_right[1]   // e₇
};
```

### 4.3 Coupled Dynamics

Octonions can represent coupled rotations between body and wings:

```c
// State evolution (simplified)
octonion dO_dt = compute_dynamics(O_system, control_inputs, aerodynamic_forces);

// Integration (e.g., Runge-Kutta 4)
O_system = O_system + dO_dt * dt;

// Extract components
extract_quaternion(O_system, &q_body);
extract_wing_angles(O_system, &wing_left, &wing_right);
```

---

## 5. Implementation Considerations

### 5.1 Arduino Quaternion Library

**Minimal Quaternion Implementation:**

```cpp
struct Quaternion {
    float w, x, y, z;
    
    Quaternion(float w, float x, float y, float z) 
        : w(w), x(x), y(y), z(z) {}
    
    // Normalize to unit quaternion
    void normalize() {
        float mag = sqrt(w*w + x*x + y*y + z*z);
        w /= mag; x /= mag; y /= mag; z /= mag;
    }
    
    // Hamilton product
    Quaternion operator*(const Quaternion& q) const {
        return Quaternion(
            w*q.w - x*q.x - y*q.y - z*q.z,
            w*q.x + x*q.w + y*q.z - z*q.y,
            w*q.y - x*q.z + y*q.w + z*q.x,
            w*q.z + x*q.y - y*q.x + z*q.w
        );
    }
    
    // Conjugate
    Quaternion conjugate() const {
        return Quaternion(w, -x, -y, -z);
    }
};

// Rotate vector
Vector3 rotate(const Vector3& v, const Quaternion& q) {
    Quaternion v_quat(0, v.x, v.y, v.z);
    Quaternion result = q * v_quat * q.conjugate();
    return Vector3(result.x, result.y, result.z);
}

// From axis-angle
Quaternion fromAxisAngle(const Vector3& axis, float angle) {
    float half_angle = angle * 0.5;
    float s = sin(half_angle);
    return Quaternion(cos(half_angle), axis.x*s, axis.y*s, axis.z*s);
}
```

### 5.2 Computational Efficiency

**Quaternion vs Euler Angles:**

| Operation | Euler Angles | Quaternion |
|-----------|-------------|------------|
| Storage | 3 floats | 4 floats |
| Composition | ~60 ops | ~16 ops |
| Rotation | ~25 ops | ~18 ops |
| Interpolation | Complex | SLERP |
| Gimbal Lock | Yes | No |

**Optimization Tips:**
1. Pre-compute sin/cos for common angles
2. Use lookup tables for SLERP
3. Batch quaternion operations
4. Avoid unnecessary normalizations

### 5.3 Integration with Existing Code

**Mapping Servo Commands to Quaternions:**

```cpp
// Current implementation (microseconds to degrees)
float servo_angle_deg = map(servo_pwm, 900, 2100, -90, 90);

// Convert to radians
float servo_angle_rad = servo_angle_deg * PI / 180.0;

// Create quaternion for rotation about z-axis
Quaternion q_servo = fromAxisAngle(Vector3(0, 0, 1), servo_angle_rad);

// Apply to wing position
Vector3 wing_tip_neutral(150, 0, 0);  // 150mm forward
Vector3 wing_tip_actual = rotate(wing_tip_neutral, q_servo);
```

### 5.4 Sensor Fusion with Quaternions

**Complementary Filter:**

```cpp
// Gyroscope integration (prediction)
Quaternion q_pred = q_current * (gyro_rates * dt * 0.5);

// Accelerometer correction
Quaternion q_accel = fromGravity(accel_vector);

// Complementary fusion
float alpha = 0.98;  // Weight toward gyro
q_current = slerp(q_accel, q_pred, alpha);
q_current.normalize();
```

---

## 6. Future Enhancements

### 6.1 Extended Kalman Filter with Quaternions

```cpp
// State: [quaternion(4), angular_velocity(3), position(3), velocity(3)]
// Total: 13 states

// Prediction step
q_next = q + 0.5 * q * omega * dt;
omega_next = omega + alpha_gyro * dt;

// Update with measurements
K = P * H^T * (H * P * H^T + R)^-1;
x = x + K * (z - h(x));
```

### 6.2 Dual Quaternions for Position + Orientation

```cpp
// Combines rotation and translation
struct DualQuaternion {
    Quaternion real;
    Quaternion dual;
};

// Simultaneous rotation and translation
DualQuaternion transform_wing(position, orientation);
```

### 6.3 Neural Network with Quaternion Inputs

```cpp
// Feed quaternion components directly to MLP
float inputs[12] = {
    q.w, q.x, q.y, q.z,          // Orientation
    omega.x, omega.y, omega.z,   // Angular rates
    ...                           // Other features
};

float output = mlp.forward(inputs);
```

---

## References

1. Kuipers, J. B. (1999). *Quaternions and Rotation Sequences*. Princeton University Press.
2. Shoemake, K. (1985). "Animating rotation with quaternion curves". *SIGGRAPH*.
3. Conway, J. H., & Smith, D. A. (2003). *On Quaternions and Octonions*. A K Peters.
4. Trawny, N., & Roumeliotis, S. I. (2005). "Indirect Kalman Filter for 3D Attitude Estimation".
5. Baez, J. C. (2001). "The Octonions". *Bulletin of the American Mathematical Society*.

---

**Document Version:** 1.0  
**Last Updated:** 2025-01-02  
**Classification:** Technical Documentation - Mathematical Foundations
