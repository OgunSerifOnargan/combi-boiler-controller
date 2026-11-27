% testburner.m
% MIL test: burner gas interface, REQ-BR-001 and REQ-BR-002
% In state Run: Qgas = Qreq/etanom, limited to Qgasmax.
% Outside Run (Idle, PrePurge, Ignition, PostPurge, Wait, Lockout): no gas.

init_params;

TOL_W  = 1;             % W, tolerance of the gas power check
scen   = [60 35];       % degC setpoints: 60 = full load (saturation), 35 = low load (burner cycles)
T_STOP = 1200;

worst       = 0;        % W, largest deviation from the expected gas power in Run
gas_outside = 0;        % W, largest gas power outside Run
qg_max      = 0;        % W, peak gas power
n_run       = 0;        % number of samples in Run that were checked

for i = 1:numel(scen)
    tset      = scen(i);
    tsetinit  = tset;
    tsetfinal = tset;
    out = sim('isitici','StopTime',num2str(T_STOP));

    tg = out.Qgaslog.Time;
    Qg = squeeze(out.Qgaslog.Data);
    Qr = interp1(out.Qlog.Time,  squeeze(out.Qlog.Data),  tg, 'previous', 'extrap');
    St = interp1(out.Stlog.Time, squeeze(out.Stlog.Data), tg, 'previous', 'extrap');

    % samples where the chart has been in Run for at least one sample
    in_run   = (St == 3) & ([0; St(1:end-1)] == 3);
    expected = min(Qr/etanom, Qgasmax);

    if any(in_run)
        worst = max(worst, max(abs(Qg(in_run) - expected(in_run))));
    end
    n_run       = n_run + sum(in_run);
    gas_outside = max([gas_outside; Qg(St ~= 3)]);
    qg_max      = max(qg_max, max(Qg));
end

ok1 = (n_run > 0) && (worst <= TOL_W);
ok2 = (gas_outside <= TOL_W) && (qg_max <= Qgasmax + TOL_W);

fprintf('\n');
report('REQ-BR-001', ok1, sprintf('in Run Qgas = Qreq/etanom (limited), worst deviation = %.3f W (max %d W), %d samples', worst, TOL_W, n_run));
report('REQ-BR-002', ok2, sprintf('no gas outside Run (max %.1f W), peak Qgas = %.0f W (max %d W)', gas_outside, qg_max, Qgasmax));
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end
