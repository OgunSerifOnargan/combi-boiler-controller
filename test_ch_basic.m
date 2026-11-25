% test_ch_basic.m
% MIL test: heating loop, REQ-CH-001 ... REQ-CH-004 (no setpoint step)

% --- parameters ---
C     = 20000;   % J/K
UA    = 100;     % W/K
Tamb  = 20;      % degC
T_amb = 20;      % degC
tset  = 60;      % degC

% --- scenario: constant setpoint, no step ---
tsetinit  = 60;
tsetfinal = 60;
tstep     = 200;

% --- requirement thresholds ---
T_REACH_MAX   = 150;    % s   (REQ-CH-001)
OVERSHOOT_MAX = 0.5;    % K   (REQ-CH-002)
FINAL_ERR_MAX = 0.1;    % K   (REQ-CH-003)
Q_MIN = 0;              % W   (REQ-CH-004)
Q_MAX = 24000;          % W   (REQ-CH-004)

% --- run the model ---
out = sim('isitici');
t = out.Tlog.Time;
T = out.Tlog.Data;
Q = out.Qlog.Data;

% --- measurements ---
idx = find(T >= tset - 0.1, 1);
if isempty(idx)
    t_reach = Inf;
else
    t_reach = t(idx);
end
overshoot = max(T) - tset;
final_err = abs(T(end) - tset);
q_lo = min(Q);
q_hi = max(Q);

% --- results ---
fprintf('\n');
report('REQ-CH-001', t_reach <= T_REACH_MAX, ...
    sprintf('time to 59.9 C = %.1f s (max %d s)', t_reach, T_REACH_MAX));
report('REQ-CH-002', overshoot < OVERSHOOT_MAX, ...
    sprintf('overshoot = %.3f K (max %.1f K)', overshoot, OVERSHOOT_MAX));
report('REQ-CH-003', final_err < FINAL_ERR_MAX, ...
    sprintf('steady-state error = %.4f K (max %.1f K)', final_err, FINAL_ERR_MAX));
report('REQ-CH-004', q_lo >= Q_MIN - 1e-6 && q_hi <= Q_MAX + 1e-6, ...
    sprintf('Q range = %.0f ... %.0f W (allowed %d ... %d W)', q_lo, q_hi, Q_MIN, Q_MAX));
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end