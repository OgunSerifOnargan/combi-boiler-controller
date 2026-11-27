% test_ch_basic.m
% MIL test: heating loop, REQ-CH-001 ... REQ-CH-004 (no setpoint step)
% Plant v2 (two-node water circuit) with NTC sensor model (lag tauntc, resolution qntc).
% Time requirement is a settling time: after it the flow temperature stays within +/-1 K.

% --- parameters (all from init_params.m) ---
init_params;

% --- scenario: constant setpoint, no step ---
tset      = 60;
tsetinit  = 60;
tsetfinal = 60;
tstep     = 200;
T_STOP    = 1200;       % s, simulated time

% --- requirement thresholds ---
SETTLE_BAND   = 1.0;    % K   (REQ-CH-001) band around the setpoint
T_SETTLE_MAX  = 400;    % s   (REQ-CH-001) must be inside the band from this time on
OVERSHOOT_MAX = 0.5;    % K   (REQ-CH-002)
FINAL_ERR_MAX = 0.1;    % K   (REQ-CH-003)
Q_MIN = 0;              % W   (REQ-CH-004)
Q_MAX = 24000;          % W   (REQ-CH-004)

% --- run the model ---
out = sim('isitici','StopTime',num2str(T_STOP));
t = out.Tlog.Time;
T = out.Tlog.Data;
Q = out.Qlog.Data;

% --- measurements (true flow temperature, not the sensor reading) ---
k_out = find(abs(T - tset) > SETTLE_BAND, 1, 'last');
if isempty(k_out)
    t_settle = 0;
elseif k_out == numel(T)
    t_settle = Inf;
else
    t_settle = t(k_out);
end
k59 = find(T >= tset - 0.1, 1);
if isempty(k59)
    t_59_9 = Inf;
else
    t_59_9 = t(k59);
end
overshoot = max(T) - tset;
final_err = abs(T(end) - tset);
q_lo = min(Q);
q_hi = max(Q);

% --- results ---
fprintf('\n');
fprintf('info  first time at 59.9 C = %.1f s (not a requirement, depends on sensor lag)\n', t_59_9);
report('REQ-CH-001', t_settle <= T_SETTLE_MAX, ...
    sprintf('inside +/-%.1f K of the setpoint from %.1f s on (max %d s)', SETTLE_BAND, t_settle, T_SETTLE_MAX));
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