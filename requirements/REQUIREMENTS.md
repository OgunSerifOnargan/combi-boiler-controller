# Requirements: central heating loop

Values are design targets chosen for this project (24 kW heater, 20 degC start, 60 degC setpoint).

| ID | Requirement | Verification | Status |
| --- | --- | --- | --- |
| REQ-CH-001 | From a 20 degC start, the flow temperature reaches 59.9 degC within 150 s | MIL, test_ch_basic | Verified |
| REQ-CH-002 | Overshoot is below 0.5 K | MIL, test_ch_basic | Verified |
| REQ-CH-003 | Steady-state error is below 0.1 K | MIL, test_ch_basic | Verified |
| REQ-CH-004 | The heater command stays within 0 to 24000 W | MIL, test_ch_basic | Verified |
| REQ-CH-005 | After a setpoint step from 50 to 65 degC, the flow temperature reaches 64.9 degC within 120 s with overshoot below 0.5 K | MIL, test_ch_step | Verified |
