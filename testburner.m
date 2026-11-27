% test_burner.m
% MIL test: burner gas interface, REQ-BR-001 and REQ-BR-002
% Qgas = Qreq/etanom, limited to 0 ... Qgasmax; burner off means no gas.

init_params;

TOL_W = 1;              % W, tolerance of the gas power check
scen = [60 35];         % degC setpoints: 60 = full load (saturation), 35 = low load (burner cycles)
T_STOP = 1200;

ok1 = true;  ok2 = true;
worst = 0;   qg_max = 0;

for i = 1:numel(scen)
    tset      = scen(i);
    tsetinit  = tset;
    tsetfinal = tset;
    out = sim('isitici','StopTime',num2str(T_STOP));
    tq  = out.Qlog.Time;
    Qr  = squeeze(out.Qlog.Data);
    tg  = out.Qgaslog.Time;
    Qg  = squeeze(out.Qgaslog.Data);
    Qr  = interp1(tq, Qr, tg, 'previous', 'extrap');

    expected = min(Qr/etanom, Qgasmax);
    worst    = max(worst, max(abs(Qg - expected)));
    qg_max   = max(qg_max, max(Qg));
    ok2      = ok2 && all(Qg(Qr <= 0) <= TOL_W);
end
ok1 = worst <= TOL_W;
ok3 = qg_max <= Qgasmax + TOL_W;

fprintf('\n');
report('REQ-BR-001', ok1, sprintf('Qgas = Qreq/etanom (limited), worst deviation = %.3f W (max %d W)', worst, TOL_W));
report('REQ-BR-002', ok2 && ok3, sprintf('no gas when burner is off, peak Qgas = %.0f W (max %d W)', qg_max, Qgasmax));
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end