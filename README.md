# Combi boiler controller

A Simulink model of the control software of a combi boiler (heating circuit and domestic hot water), built step by step as a learning and portfolio project. The scope is the control software only (controllers, burner modulation, setpoint generation, requirements, tests); no hardware design.

Everything is built by hand in Simulink and verified by automated model-in-the-loop (MIL) tests with traceable requirement IDs (see `requirements/REQUIREMENTS.md`).

## Repository content

| File | Purpose |
|---|---|
| `init_params.m` | Single parameter file for all models and tests |
| `isitici.slx` | Heating circuit: setpoint source (fixed or heating curve), controller reference model, thermal plant |
| `Controller.slx` | Heating controller (model reference) |
| `dhwplant.slx` | Domestic hot water: flow-through plant and controller |
| `test_ch_basic.m` | MIL test, heating, REQ-CH-001 ... 004 |
| `test_ch_step.m` | MIL test, heating setpoint step, REQ-CH-005 |
| `test_ch_low.m` | MIL test, heating at low load, REQ-CH-006 ... 008 |
| `test_hc.m` | MIL test, heating curve, REQ-HC-001 ... 004 |
| `testdhw.m` | MIL test, domestic hot water, REQ-DHW-001 ... 007 |
| `requirements/REQUIREMENTS.md` | Requirements with IDs |

## How to run

Requirements: MATLAB and Simulink (developed in MATLAB Online). Stateflow and code generation products are not used yet.

```matlab
init_params          % define all parameters in the base workspace
test_ch_basic        % heating, steady setpoint
test_ch_step         % heating, setpoint step
test_ch_low          % heating, low load
test_hc              % heating curve
testdhw              % domestic hot water
```

Each test prints `PASS` or `FAIL` per requirement. The tests call `init_params` themselves and then override the scenario values, so they can be run in any order. After a test, run `init_params` again before simulating a model by hand.

## Design overview

### Heating circuit

- Plant: lumped thermal model, `C dT/dt = Q - UA (T - Troom)`.
- Controller: discrete PI (Kp = 1000, Ki = 5, Ts = 0.1 s) with external saturation `Qmin ... Qmax` and tracking anti-windup.
- Low load: if the required power is below `Qmin` the burner is cycled by a hysteresis relay (off at setpoint + 3 K, on at setpoint - 3 K). The PI integrator is reset while the burner is off.

### Heating curve (outdoor temperature compensation)

- The flow temperature setpoint is looked up from the outdoor temperature in a table (`hcx`, `hcy`, linear interpolation, end values held outside the table) and limited to `Tflowmin ... Tflowmax`.
- A switch (`hcon`) selects between the heating curve and the fixed setpoint, so the original tests keep running unchanged.
- The curve is a feed-forward element: the outdoor temperature announces the heat demand before the room cools down.

### Domestic hot water

- Plant: flow-through heat exchanger, `Cdhw dT/dt = Q - m_dot cp (T - Tin)`, flow-dependent, cold start.
- Burner request: relay with hysteresis on the flow (on at 2.5 L/min, off at 2.0 L/min).
- Controller: PI (Kp = 800, Ki = 110) plus flow-proportional feed-forward, output limited to `Qmin ... Qmax`, tracking anti-windup (Kt = 3).
- Low load: same hysteresis and PI reset as in the heating circuit.
- Solver: fixed-step (ode1, 0.01 s); the controller runs at Ts = 0.1 s.

### Minimum modulation

Burner power is either 0 or between `Qmin = Qmax / turndown` and `Qmax` (default turndown 1:10, Qmax = 24 kW). `turndown` is a parameter in `init_params.m`.

## Test results (current)

| Area | Result |
|---|---|
| Heating, 20 -> 60 °C | reaches 59.9 °C in 123.1 s, overshoot 0.000 K, steady-state error 0.0000 K |
| Heating, step 50 -> 65 °C | reaches 64.9 °C in 99.9 s after the step, overshoot 0.000 K, peak power 18 kW |
| Heating, low load (1.5 kW) | temperature 57 ... 63 °C, about 16 burner starts per hour |
| Heating curve | outdoor -15 / -5 / 0 / +5 °C give 75.00 / 62.00 / 55.50 / 49.00 °C (error 0.000 K); clip and limit verified |
| DHW, cold start, feed-forward off | 44.9 °C in 35.7 s, no overshoot, 2.15 K dip at the 8 -> 10 L/min flow step |
| DHW, cold start, feed-forward on | 44.9 °C in 18.2 s, overshoot 0.08 K, no dip at the flow step |
| DHW, low load (1.7 kW) | temperature 32 ... 38 °C (setpoint 35 °C), 3 burner starts in 120 s |

## Known limitations

- The heat loss coefficient `UA` is constant. Robustness against +/-30 % UA is not verified yet.
- No flow sensor error or noise model; flow is assumed exact.
- No transport delay (pipe between the boiler and the tap) and no preheat (keep-warm) mode.
- Minimum modulation is modelled with a simple hysteresis; there is no minimum on/off time (anti-cycling) yet.
- Stuck zone at low load: when the required heating power is slightly below `Qmin` and the setpoint is about 41 ... 44 °C, the burner stays on at `Qmin` and never reaches the shutoff threshold; the temperature settles up to 3 K above the setpoint. Planned fix: burner request state machine with minimum on/off time and an excess-temperature integral criterion.
- With turndown 1:5 the heating scenario (load 4 kW < Qmin 4.8 kW) cycles the burner; the default is 1:10.
- The PI of the hot water controller is tuned for 8 L/min. At very low flow the plant gain is higher and the cold-start overshoot reaches about 3 K (gain scheduling is planned).
- Setpoint sources: only the fixed flow temperature and the heating curve are implemented. Room temperature control (cascade) and a user shift / room influence on the curve are not.
- Plant parameters are lumped estimates and not measured on real hardware.

## Planned

Room temperature control (cascade) as third setpoint mode, user shift and room influence on the heating curve, burner request and burner sequence state machines (Stateflow), protection and mode manager, pump modes, fault codes, C++ implementation with unit tests and back-to-back comparison against the model, continuous integration.