% test_ch_low.m
% MIL test: heating loop at low load (mild day), REQ-CH-006 ... REQ-CH-008
% Load needed = UA * (60 - 45) = 1500 W, below Qmin = 2400 W (turndown 1:10)

% --- parameters (all from init_params.m) ---
init_params;

% --- scenario: mild day, constant setpoint ---
Tamb      = 45;
T_amb     = 45;
tset      = 60;
tsetinit  = 60;
tsetfinal = 60;
tstep     = 200;

% --- requirement thresholds ---
BAND_MAX   = 3.5;    % K, after 600 s   (REQ-CH-006)
STARTS_MAX = 25;     % per hour         (REQ-CH-008)
T_SETTLE   = 600;    % s

% --- run the model for one hour ---
out = sim('isitici', 'StopTime', '3600');
t = out.Tlog.Time;
T = out.Tlog.Data;
Q = out.Qlog.Data;

% --- measurements ---
w = t >= T_SETTLE;
band   = max(abs(T(w) - tset));
q_bad  = any(Q > 1e-6 & Q < Qmin - 1e-6);
starts = sum(diff(Q > 1e-6) == 1);

% --- results ---
fprintf('\n');
fprintf('info  need = %.0f W, Qmin = %.0f W, Tout range after %d s = %.2f ... %.2f C\n', ...
    UA*(tset - Tamb), Qmin, T_SETTLE, min(T(w)), max(T(w)));
report('REQ-CH-006', band <= BAND_MAX, ...
    sprintf('temperature within +/-%.1f K of setpoint after %d s: max deviation = %.2f K', BAND_MAX, T_SETTLE, band));
report('REQ-CH-007', ~q_bad, ...
    sprintf('burner power is 0 or >= %.0f W', Qmin));
report('REQ-CH-008', starts <= STARTS_MAX, ...
    sprintf('burner starts in one hour = %d (max %d)', starts, STARTS_MAX));
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end