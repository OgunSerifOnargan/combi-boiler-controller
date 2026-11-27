% test_ch_step.m
% MIL test: REQ-CH-005, setpoint step 50 -> 65 degC at t = 400 s
% Plant v2 with NTC sensor model. The first heat-up to 50 degC needs a few minutes,
% so the step is at 400 s. Time requirement is a settling time (+/-1 K band).

% --- parameters (all from init_params.m) ---
init_params;

% --- scenario: setpoint step ---
tset      = 65;
tsetinit  = 50;
tsetfinal = 65;
tstep     = 400;
T_STOP    = 1200;       % s, simulated time

SETTLE_BAND   = 1.0;    % K, band around the new setpoint (REQ-CH-005)
T_SETTLE_MAX  = 200;    % s after the step (REQ-CH-005)
OVERSHOOT_MAX = 0.5;    % K (REQ-CH-005)
Q_MAX         = 24000;  % W

out = sim('isitici','StopTime',num2str(T_STOP));
t = out.Tlog.Time;
T = out.Tlog.Data;
Q = out.Qlog.Data;

i_pre = find(t >= tstep, 1);
T_pre = T(i_pre);

after = t >= tstep;
ta = t(after);
Ta = T(after);
k_out = find(abs(Ta - tsetfinal) > SETTLE_BAND, 1, 'last');
if isempty(k_out)
    t_settle = 0;
elseif k_out == numel(Ta)
    t_settle = Inf;
else
    t_settle = ta(k_out) - tstep;
end
overshoot = max(Ta) - tsetfinal;
q_peak = max(Q(after));

fprintf('\n');
fprintf('info  temperature at step time = %.2f C (expected about 50)\n', T_pre);
fprintf('info  peak heater power after the step = %.0f W\n', q_peak);
ok = (t_settle <= T_SETTLE_MAX) && (overshoot < OVERSHOOT_MAX) && (q_peak <= Q_MAX + 1e-6);
report('REQ-CH-005', ok, ...
    sprintf('inside +/-%.1f K of 65 C from %.1f s after the step on (max %d s), overshoot = %.3f K (max %.1f K)', ...
    SETTLE_BAND, t_settle, T_SETTLE_MAX, overshoot, OVERSHOOT_MAX));
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end