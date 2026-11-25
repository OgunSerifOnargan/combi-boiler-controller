% init_params.m  (run once before running the model)
C          = 20000;   % J/K, thermal capacity
UA         = 100;     % W/K, heat loss coefficient
Tamb       = 20;      % degC, ambient temperature
T_amb      = 20;      % degC, same value (block in the model uses this name)

% setpoint scenario (step block in the model)
tset       = 60;      % degC, nominal setpoint
tsetinit   = 60;      % degC, setpoint before the step
tsetfinal  = 60;      % degC, setpoint after the step
tstep      = 200;     % s, time of the step