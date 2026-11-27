# Requirements

All requirements are verified by automated model-in-the-loop (MIL) tests. Run `init_params` once, then run the test script named in the last column. Each test prints `PASS` or `FAIL` per requirement ID.

Common assumptions: maximum burner power Qmax = 24 kW, turndown 1:10 (minimum burner power Qmin = 2.4 kW), controller sample time Ts = 0.1 s.

## Heating circuit (CH)

Lumped model: heating water thermal capacity C = 20 kJ/K, radiator heat emission coefficient UA = 100 W/K. The room is a dynamic house model (Croom = 2 MJ/K, UAh = 190 W/K, outdoor temperature 5 °C) with an initial room temperature of 20 °C; it moves only slowly during the short tests.

| ID | Requirement | Test |
|---|---|---|
| REQ-CH-001 | From a cold start (20 °C) the flow temperature reaches 59.9 °C within 150 s (setpoint 60 °C). | test_ch_basic.m |
| REQ-CH-002 | Overshoot over the setpoint is less than 0.5 K. | test_ch_basic.m |
| REQ-CH-003 | Steady-state error is less than 0.1 K. | test_ch_basic.m |
| REQ-CH-004 | Heater power stays within 0 ... 24 kW. | test_ch_basic.m |
| REQ-CH-005 | After a setpoint step from 50 °C to 65 °C the flow temperature reaches 64.9 °C within 120 s, overshoot less than 0.5 K, heater power at most 24 kW. | test_ch_step.m |
| REQ-CH-006 | At low load (required power below Qmin: flow temperature setpoint 35 °C in a room of 20 °C, about 1.5 kW needed) the temperature stays within +/-3.5 K of the setpoint after 600 s. The burner is switched off at setpoint + 3 K and on again at setpoint - 3 K. | test_ch_low.m |
| REQ-CH-007 | Burner power is either 0 W or at least Qmin. | test_ch_low.m |
| REQ-CH-008 | At low load the burner starts at most 25 times per hour. | test_ch_low.m |

## Setpoint modes and heating curve (HC)

The flow temperature setpoint is selected by the parameter `hcmode`: 1 = fixed setpoint, 2 = heating curve, 3 = room temperature control (see RM). The curve looks up the flow temperature from the outdoor temperature (table with linear interpolation, end values held outside the table) and limits it to Tflowmin ... Tflowmax. The HC tests run with `hcmode = 2`.

| ID | Requirement | Test |
|---|---|---|
| REQ-HC-001 | With the heating curve enabled, the flow temperature setpoint follows the curve (linear interpolation between breakpoints): the steady-state flow temperature equals the curve value within 0.1 K (outdoor -15, -5, 0, +5 °C). | test_hc.m |
| REQ-HC-002 | Outside the table range the end value is held (no extrapolation): outdoor -25 °C gives the value at the lowest breakpoint. | test_hc.m |
| REQ-HC-003 | The curve is well-formed: breakpoints strictly increasing, flow temperature non-increasing with rising outdoor temperature. | test_hc.m |
| REQ-HC-004 | The flow temperature setpoint is limited to Tflowmin ... Tflowmax regardless of the curve values. | test_hc.m |

## Room temperature control (RM)

Mode 3 (`hcmode = 3`): cascade of the heating curve (feed-forward) and a room PI. Scenario: room setpoint 21 °C, initial room temperature 21 °C, outdoor temperature 5 °C with a daily swing of +/-4 °C (maximum at 15:00), simulated time 24 h, evaluation after the first 2 h.

| ID | Requirement | Test |
|---|---|---|
| REQ-RM-001 | With the nominal house (UAh = 190 W/K) the room temperature stays within 0.3 K of the room setpoint over the 24 h scenario. | test_room.m |
| REQ-RM-002 | With a house that loses 30 % more heat (UAh x 1.3) the room temperature stays within 0.8 K of the room setpoint. | test_room.m |
| REQ-RM-003 | In the nominal 24 h scenario the burner starts at most 20 times. | test_room.m |

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