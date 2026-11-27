# Requirements

All requirements are verified by automated model-in-the-loop (MIL) tests. Run `init_params` once, then run the test script named in the last column. Each test prints `PASS` or `FAIL` per requirement ID.

Common assumptions: maximum burner power Qmax = 24 kW, turndown 1:10 (minimum burner power Qmin = 2.4 kW), controller sample time Ts = 0.1 s. The temperature the controller sees is the sensor reading (first order lag 5 s, resolution 0.1 K).

## Heating circuit (CH)

Two-node plant: heat exchanger water Chx = 10 kJ/K and radiator Crad = 100 kJ/K, water mass flow 0.25, radiator power law with Krad = 35.2 and exponent 1.3 (assumptions, see README). The room is a dynamic house model (Croom = 2 MJ/K, UAh = 190 W/K, outdoor temperature 5 °C) with an initial room temperature of 20 °C; it moves only slowly during the short tests. Controller: PI, Kp = 3000, Ki = 6.

Settling is judged with a band (the flow temperature stays inside +/-1 K of the setpoint from the settling time on). The time at which the reading first touches 59.9 °C is only printed as information, because it depends on the sensor lag and quantisation.

| ID | Requirement | Test |
|---|---|---|
| REQ-CH-001 | From a cold start (20 °C) the flow temperature stays inside +/-1 K of the setpoint (60 °C) from a time of at most 400 s on. The time includes the burner start sequence of about 6 s. | test_ch_basic.m |
| REQ-CH-002 | Overshoot over the setpoint is less than 0.5 K. | test_ch_basic.m |
| REQ-CH-003 | Steady-state error is less than 0.1 K. | test_ch_basic.m |
| REQ-CH-004 | Heater power stays within 0 ... 24 kW. | test_ch_basic.m |
| REQ-CH-005 | After a setpoint step from 50 °C to 65 °C the flow temperature stays inside +/-1 K of 65 °C from at most 200 s after the step on, overshoot less than 0.5 K, heater power at most 24 kW. | test_ch_step.m |
| REQ-CH-006 | At low load (required power below Qmin: flow temperature setpoint 35 °C in a room of 20 °C, about 1.5 kW needed) the temperature stays within +/-3.5 K of the setpoint after 600 s. The request is switched off at setpoint + 3 K and on again at setpoint - 3 K. | test_ch_low.m |
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

## Burner interface (BR)

Gas power Qgas = Qreq / etanom (etanom = 0.975), limited to Qgasmax = 24.6 kW. Heat power Qheat = eta(Tret) * Qgas with eta from a lookup over the return temperature (1.02 at 30 °C, 0.975 at 55 °C and 80 °C). Tolerance of the gas power check: 1 W.

| ID | Requirement | Test |
|---|---|---|
| REQ-BR-001 | In state Run the gas power equals Qreq / etanom, limited to Qgasmax, within 1 W (full load and low load scenario). | testburner.m |
| REQ-BR-002 | Outside state Run (Idle, PrePurge, Ignition, PostPurge, Wait, Lockout) the gas power is 0 W (at most 1 W), and the gas power never exceeds Qgasmax. | testburner.m |

## Burner sequence and protection (BS)

Stateflow chart `BurnerSequence`, sample time 0.1 s. Parameters: prepurge 5 s, flame proving 1 s, ignition safety time 3 s, at most 3 ignition attempts, postpurge 10 s, minimum off time 60 s, minimum on time 30 s, over-temperature limit Tstb = 95 °C, valid sensor range -20 ... 130 °C. Faults are injected by the flame signal (`tflamefail`), the reset (`trst`) and by changing parameters for the scenario. Timing tolerance: 0.25 s (two samples).

| ID | Requirement | Test |
|---|---|---|
| REQ-BS-001 | A start request runs the sequence Idle, PrePurge, Ignition, Run. Pre-purge lasts 5 s and flame proving 1 s (within 0.25 s). | testseq.m |
| REQ-BS-002 | If no flame is detected, ignition is attempted at most 3 times, then the chart goes to Lockout with fault 3; gas is 0 W throughout. | testseq.m |
| REQ-BS-003 | If the flame is lost in Run, the chart goes to Lockout within 1 s with fault 4 and the gas is closed. | testseq.m |
| REQ-BS-004 | Anti-cycling: after a burn the gas valve stays closed for at least the minimum off time (60 s), even when the controller requests heat again immediately. Scenario: low load with narrow hysteresis (0.5 K) that forces fast cycling. | testseq.m |
| REQ-BS-005 | Minimum burn time: a burn lasts at least `tminon`. The scenario sets `tminon` to 100 s, longer than the natural burn time of about 45 s, so the hold is active. | testseq.m |
| REQ-BS-006 | If the flow temperature exceeds the limit Tstb, the chart goes to Lockout with fault 1 and the gas is closed. Scenario: Tstb lowered to 50 °C. The decision is based on the sensor reading. | testseq.m |
| REQ-BS-007 | If the flow temperature reading leaves the valid range, the chart goes to Lockout with fault 2 and the gas is closed. Scenario: Tsmax lowered to 40 °C. | testseq.m |
| REQ-BS-008 | A reset (`rst > 0`) leaves Lockout within 0.5 s. | testseq.m |

## Not covered yet

Pump overrun, frost protection, edge-triggered reset with a reset counter, independent safety sensor, flame sensor model. See the "Known limitations" section in the README.
