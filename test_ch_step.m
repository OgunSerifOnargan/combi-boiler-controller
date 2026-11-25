% test_ch_step.m
% MIL test: REQ-CH-005, setpoint step 50 -> 65 degC at t = 200 s

% --- parameters (all from init_params.m) ---
init_params;

% --- scenario: setpoint step ---
tset      = 65;
tsetinit  = 50;
tsetfinal = 65;
tstep     = 200;

T_REACH_MAX   = 120;    % s after the step (REQ-CH-005)
OVERSHOOT_MAX = 0.5;    % K (REQ-CH-005)
Q_MAX         = 24000;  % W

out = sim('isitici');
t = out.Tlog.Time;
T = out.Tlog.Data;
Q = out.Qlog.Data;

i_pre = find(t >= tstep, 1);
T_pre = T(i_pre);

after = t >= tstep;
idx = find(after & T >= tsetfinal - 0.1, 1);
if isempty(idx)
    t_reach = Inf;
else
    t_reach = t(idx) - tstep;
end
overshoot = max(T(after)) - tsetfinal;
q_peak = max(Q(after));

fprintf('\n');
fprintf('info  temperature at step time = %.2f C (expected about 50)\n', T_pre);
fprintf('info  peak heater power after the step = %.0f W\n', q_peak);
ok = (t_reach <= T_REACH_MAX) && (overshoot < OVERSHOOT_MAX) && (q_peak <= Q_MAX + 1e-6);
report('REQ-CH-005', ok, ...
    sprintf('reaches 64.9 C in %.1f s after the step (max %d s), overshoot = %.3f K (max %.1f K)', ...
    t_reach, T_REACH_MAX, overshoot, OVERSHOOT_MAX));
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end