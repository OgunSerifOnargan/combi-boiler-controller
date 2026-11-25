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



## Domestic hot water (DHW) controller

Flow-through (instantaneous) combi model: plate heat exchanger, Hall flow sensor, no storage.

- **Burner request:** flow switch with hysteresis (on at 2.5 L/min, off at 2.0 L/min).
- **Control:** PI (Kp = 800, Ki = 110, Ts = 0.1 s) plus flow-proportional feed-forward, output limited to 0 ... 24 kW.
- **Anti-windup:** tracking mode on the PI share (`Kt = 3`), so the limit on the sum (PI + FF) is seen by the integrator.
- **Cold start:** plant starts at 20 °C, mains water at 15 °C.
- **Minimum modulation:** burner power is 0 or between `Qmin` (4.8 kW, turndown 1:5) and `Qmax` (24 kW). Below `Qmin` the burner is cycled by a hysteresis relay (off at setpoint + 3 K, on at setpoint - 3 K); the PI integrator is reset while the burner is off or the tap is closed.
- **Solver:** fixed-step (ode1, 0.01 s); the controller runs at Ts = 0.1 s.

Test: `testdhw.m` (REQ-DHW-001 ... 005). Cold start reaches 44.9 °C in 18.3 s (FF on) or 35.7 s (FF off); a flow step from 8 to 10 L/min causes ~2.15 K dip without FF and ~0 K with FF.

## Known limitations

- The heat loss coefficient `UA` of the heating loop is constant. Robustness to ±30 % UA is not verified yet.
- No flow sensor error or noise model yet (flow is assumed exact).
- No transport delay (pipe between combi and tap) and no preheat (keep-warm) mode.
- Plant parameters are lumped estimates, not measured on real hardware.
- Minimum modulation is modelled with a simple hysteresis; no minimum on/off time (anti-cycling) yet. In the low-load test the burner starts 6 times in 120 s and the outlet temperature swings between 37 and 43 °C.
- The PI is tuned for 8 L/min; at very low flow (about 2.5 L/min) the plant gain is higher and cold-start overshoot reaches about 3 K (gain scheduling is planned).