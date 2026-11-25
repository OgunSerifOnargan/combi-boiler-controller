# Combi boiler controller (Simulink)

Model-based design of a combi boiler control software, built step by step with requirements, automated tests and a documented design.

This is a simulation project. It is not a certified safety product and the plant parameters are typical values, not measurements.

## Current status

| Part | State |
| --- | --- |
| Central heating loop: PI control with back-calculation anti-windup | Done |
| Discrete-time controller, 0.1 s sample time | Done |
| Plant and controller split, controller as referenced model | Done |
| MIL tests for REQ-CH-001 to REQ-CH-004 | Passing |
| Setpoint step test (REQ-CH-005) | Passing |
| Domestic hot water mode, pump logic, burner sequence (Stateflow), protection layer | Planned |
| C++ implementation with back-to-back verification, CI | Planned |

## Model

The plant is a lumped thermal model of the water mass:

```
C * dT/dt = Q - UA * (T - Tamb)
```

- C = 20000 J/K, UA = 100 W/K, Tamb = 20 degC
- Heater limit: 0 to 24000 W

The controller is a PI controller (Kp = 1000, Ki = 5) with back-calculation anti-windup (Kb = Ki/Kp = 0.005) and a 0.1 s sample time. Kp and Ki place the controller zero on the plant pole, which gives a first-order closed loop with a time constant of about 20 s when the heater is not saturated.

## Files

- `isitici.slx`: top-level model (plant, setpoint, logging)
- `Controller.slx`: controller as a referenced model
- `test_ch_basic.m`: automated MIL test for REQ-CH-001 to REQ-CH-004
- `init_params.m`: model parameters
- `test_ch_step.m`: automated MIL test for REQ-CH-005 (setpoint step 50 to 65 degC)
- `requirements/REQUIREMENTS.md`: requirements and verification status

## Run the tests

In MATLAB, from the repository folder:

```matlab
init_params
test_ch_basic
```

Run `test_ch_step` as well for REQ-CH-005. Expected output: four PASS lines from `test_ch_basic` and one from `test_ch_step`.
