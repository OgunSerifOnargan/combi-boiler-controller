% test_ch_low.m
% MIL test of the heating circuit at low load.
% Low flow temperature setpoint (35 degC) in a 20 degC room: the required
% power (about 1.5 kW) is below the minimum burner power Qmin (2.4 kW).
init_params;
tset      = 35;       % degC, low flow temperature setpoint
tsetinit  = 35;
tsetfinal = 35;

TMAX_DEV   = 3.5;     % K, allowed deviation from the setpoint after 600 s
STARTS_MAX = 25;      % burner starts per hour
T_SKIP     = 600;     % s

so = sim('isitici','StopTime','3600');
tl = getlog(so,'Tlog');
ql = getlog(so,'Qlog');
T  = tl.Data(:);  tt = tl.Time(:);
Q  = ql.Data(:);

need = UA*(tset - Tamb);
late = tt >= T_SKIP;
dev  = max(abs(T(late) - tset));
fprintf('info need = %.0f W, Qmin = %.0f W, Tout range after %d s = %.2f ... %.2f C\n', ...
    need, Qmin, T_SKIP, min(T(late)), max(T(late)));
report('REQ-CH-006', dev <= TMAX_DEV, ...
    sprintf('temperature within +/-%.1f K of setpoint after %d s: max deviation = %.2f K', TMAX_DEV, T_SKIP, dev));

ok7 = all(Q < 1e-6 | Q >= Qmin - 1e-6);
report('REQ-CH-007', ok7, sprintf('burner power is 0 or >= %.0f W', Qmin));

starts = sum(diff([0; double(Q > 0)]) == 1);
report('REQ-CH-008', starts <= STARTS_MAX, ...
    sprintf('burner starts in one hour = %d (max %d)', starts, STARTS_MAX));

function report(id, ok, msg)
if ok, s = 'PASS'; else, s = 'FAIL'; end
fprintf('%s %s %s\n', s, id, msg);
end

function ts = getlog(so, name)
try
    ts = so.get(name);
catch
    ts = evalin('base', name);
end
end