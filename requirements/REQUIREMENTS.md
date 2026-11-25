# Requirements: central heating loop

Values are design targets chosen for this project (24 kW heater, 20 degC start, 60 degC setpoint).

| ID | Requirement | Verification | Status |
| --- | --- | --- | --- |
| REQ-CH-001 | From a 20 degC start, the flow temperature reaches 59.9 degC within 150 s | MIL, test_ch_basic | Verified |
| REQ-CH-002 | Overshoot is below 0.5 K | MIL, test_ch_basic | Verified |
| REQ-CH-003 | Steady-state error is below 0.1 K | MIL, test_ch_basic | Verified |
| REQ-CH-004 | The heater command stays within 0 to 24000 W | MIL, test_ch_basic | Verified |
| REQ-CH-005 | After a setpoint step from 50 to 65 degC, the flow temperature reaches 64.9 degC within 120 s with overshoot below 0.5 K | MIL, test_ch_step | Verified |

## Domestic hot water (DHW)

Soğuk başlangıç (20 °C), kombi sıcak su ayar değeri 45 °C, şebeke suyu 15 °C.

| ID | Requirement | Test |
|---|---|---|
| REQ-DHW-001 | Debi 2,0 L/dk altındayken brülör gücü 0 W olmalıdır (eşik histerezisi: açma 2,5, kapama 2,0 L/dk). | testdhw.m |
| REQ-DHW-002 | Musluk açıldıktan sonra çıkış sıcaklığı 40 s içinde 44,9 °C'ye ulaşmalıdır. | testdhw.m |
| REQ-DHW-003 | Musluk açıldıktan sonra aşım 0,5 K'den az olmalıdır. | testdhw.m |
| REQ-DHW-004 | Debi 8'den 10 L/dk'ya çıktığında sıcaklık düşüşü: FF kapalıyken en fazla 2,5 K, FF açıkken en fazla 0,5 K. | testdhw.m |
| REQ-DHW-005 | Brülör gücü hiçbir zaman 24 kW'ı aşmamalıdır. | testdhw.m |