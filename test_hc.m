% test_hc.m
% MIL test: heating curve (outdoor temperature compensation), REQ-HC-001 ... REQ-HC-004

% --- parameters (all from init_params.m) ---
init_params;
hcon = 1;

% --- requirement thresholds ---
TOL = 0.1;      % K, steady-state tolerance

fprintf('\n');

% ===== REQ-HC-003: curve data check (no simulation) =====
mono = all(diff(hcx) > 0) && all(diff(hcy) <= 0);
report('REQ-HC-003', mono, ...
    'breakpoints strictly increasing, flow temperature non-increasing with outdoor temperature');

% ===== REQ-HC-001: setpoint follows the curve (including an interpolated point) =====
tout_list = [-15 -5 0 5];
for k = 1:numel(tout_list)
    Toutdoor = tout_list(k);
    expected = interp1(hcx, hcy, Toutdoor);
    out = sim('isitici', 'StopTime', '600');
    T = out.Tlog.Data;
    err = abs(T(end) - expected);
    report('REQ-HC-001', err < TOL, ...
        sprintf('outdoor %+.0f C: flow temperature = %.2f C (curve %.2f C, error %.3f K)', ...
        Toutdoor, T(end), expected, err));
end

% ===== REQ-HC-002: outside the table the end value is held (clip) =====
Toutdoor = -25;
expected = hcy(1);
out = sim('isitici', 'StopTime', '600');
T = out.Tlog.Data;
err = abs(T(end) - expected);
report('REQ-HC-002', err < TOL, ...
    sprintf('outdoor %+.0f C (below table): flow temperature = %.2f C (end value %.2f C)', ...
    Toutdoor, T(end), expected));

% ===== REQ-HC-004: setpoint is limited to Tflowmin ... Tflowmax =====
hcy_saved = hcy;
hcy(1) = 90;                 % curve value above the limit
Toutdoor = -15;
out = sim('isitici', 'StopTime', '600');
T = out.Tlog.Data;
err = abs(T(end) - Tflowmax);
report('REQ-HC-004', err < TOL, ...
    sprintf('curve asks 90 C, limit %.0f C: flow temperature = %.2f C', Tflowmax, T(end)));
hcy = hcy_saved;
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end