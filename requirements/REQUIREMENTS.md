# Requirements

All requirements are verified by automated model-in-the-loop (MIL) tests. Run `init_params` once, then run the test script named in the last column. Each test prints `PASS` or `FAIL` per requirement ID.

Common assumptions: maximum burner power Qmax = 24 kW, turndown 1:10 (minimum burner power Qmin = 2.4 kW), controller sample time Ts = 0.1 s.

## Heating circuit (CH)

Lumped model: heating water thermal capacity C = 20 kJ/K, heat loss coefficient UA = 100 W/K, room temperature 20 °C.

| ID | Requirement | Test |
|---|---|---|
| REQ-CH-001 | From a cold start (20 °C) the flow temperature reaches 59.9 °C within 150 s (setpoint 60 °C). | test_ch_basic.m |
| REQ-CH-002 | Overshoot over the setpoint is less than 0.5 K. | test_ch_basic.m |
| REQ-CH-003 | Steady-state error is less than 0.1 K. | test_ch_basic.m |
| REQ-CH-004 | Heater power stays within 0 ... 24 kW. | test_ch_basic.m |
| REQ-CH-005 | After a setpoint step from 50 °C to 65 °C the flow temperature reaches 64.9 °C within 120 s, overshoot less than 0.5 K, heater power at most 24 kW. | test_ch_step.m |
| REQ-CH-006 | At low load (load below Qmin, e.g. room 45 °C) the temperature stays within +/-3.5 K of the setpoint after 600 s. The burner is switched off at setpoint + 3 K and on again at setpoint - 3 K. | test_ch_low.m |
| REQ-CH-007 | Burner power is either 0 W or at least Qmin. | test_ch_low.m |
| REQ-CH-008 | At low load the burner starts at most 25 times per hour. | test_ch_low.m |

## Heating curve (HC)

Outdoor temperature compensation: the flow temperature setpoint is looked up from the outdoor temperature (table with linear interpolation, end values held outside the table) and limited to Tflowmin ... Tflowmax. A switch selects between the curve and the fixed setpoint.

| ID | Requirement | Test |
|---|---|---|
| REQ-HC-001 | With the heating curve enabled, the flow temperature setpoint follows the curve (linear interpolation between breakpoints): the steady-state flow temperature equals the curve value within 0.1 K (outdoor -15, -5, 0, +5 °C). | test_hc.m |
| REQ-HC-002 | Outside the table range the end value is held (no extrapolation): outdoor -25 °C gives the value at the lowest breakpoint. | test_hc.m |
| REQ-HC-003 | The curve is well-formed: breakpoints strictly increasing, flow temperature non-increasing with rising outdoor temperature. | test_hc.m |
| REQ-HC-004 | The flow temperature setpoint is limited to Tflowmin ... Tflowmax regardless of the curve values. | test_hc.m |

## Domestic hot water (DHW)

Flow-through (instantaneous) model without storage: heat exchanger water capacity Cdhw = 4 kJ/K, mains water 15 °C, setpoint 45 °C, cold start at 20 °C.

| ID | Requirement | Test |
|---|---|---|
| REQ-DHW-001 | Below the flow threshold (2.0 L/min) the burner power is 0 W. The burner request switches on at 2.5 L/min and off at 2.0 L/min (hysteresis). | testdhw.m |
| REQ-DHW-002 | After the tap opens (8 L/min) the outlet temperature reaches 44.9 °C within 40 s. | testdhw.m |
| REQ-DHW-003 | Overshoot after the tap opens is less than 0.5 K. | testdhw.m |
| REQ-DHW-004 | When the flow increases from 8 to 10 L/min the temperature dip is at most 2.5 K without feed-forward and at most 0.5 K with feed-forward. | testdhw.m |
| REQ-DHW-005 | Burner power never exceeds 24 kW. | testdhw.m |
| REQ-DHW-006 | At low load (required power below Qmin, e.g. mains 25 °C, setpoint 35 °C, 2.5 L/min) the outlet temperature stays within +/-3.5 K of the setpoint after 40 s. The burner is switched off at setpoint + 3 K and on again at setpoint - 3 K. | testdhw.m |
| REQ-DHW-007 | Burner power is either 0 W or at least Qmin. | testdhw.m |

## Not covered yet

See the "Known limitations" section in the README.