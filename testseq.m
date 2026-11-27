% testseq.m
% MIL test: burner sequence and protection (BurnerSequence chart), REQ-BS-001 ... REQ-BS-008
% Faults are injected through the Step blocks flameok (time tflamefail) and rst (time trst)
% and through temporary changes of Tstb, Tsmax, Hoffch, Honch and tminon.
% init_params is run before every scenario, so every scenario starts from the defaults.
% State numbers (Stlog): 0 Idle, 1 PrePurge, 2 Ignition, 3 Run, 4 PostPurge, 5 Wait, 6 Lockout.
% Fault numbers (Fltlog): 0 none, 1 over-temperature, 2 sensor fault, 3 ignition failure, 4 flame loss.

TOL = 0.25;     % s, timing tolerance (two chart samples)

%% scenario 1: normal start sequence (REQ-BS-001)
init_params; tset = 60; tsetinit = 60; tsetfinal = 60;
out = sim('isitici','StopTime','30');
[tc, sc] = changes(out.Stlog);
d_pre = NaN; d_ign = NaN; ok = false;
if numel(sc) >= 4
    d_pre = tc(3) - tc(2);
    d_ign = tc(4) - tc(3);
    ok = isequal(sc(1:4).', [0 1 2 3]) && abs(d_pre - tprepurge) <= TOL && abs(d_ign - tflame) <= TOL;
end
report('REQ-BS-001', ok, sprintf('start order Idle > PrePurge > Ignition > Run, pre-purge %.1f s (%.0f), flame proving %.1f s (%.0f)', ...
    d_pre, tprepurge, d_ign, tflame));

%% scenario 2: no flame from the start, ignition failure (REQ-BS-002)
init_params; tset = 60; tsetinit = 60; tsetfinal = 60;
tflamefail = 0;
out = sim('isitici','StopTime','40');
[tc, sc] = changes(out.Stlog);
fl = squeeze(out.Fltlog.Data);
n_ign = sum(sc == 2);
gas = max(squeeze(out.Qgaslog.Data));
ok = isequal(sc.', [0 1 2 1 2 1 2 6]) && fl(end) == 3 && n_ign == nmax && gas <= 1;
report('REQ-BS-002', ok, sprintf('%d ignition attempts (max %d), then lockout, fault = %d (expected 3), gas = %.0f W', ...
    n_ign, nmax, fl(end), gas));

%% scenario 3: flame lost while running (REQ-BS-003)
init_params; tset = 60; tsetinit = 60; tsetfinal = 60;
tflamefail = 300;
out = sim('isitici','StopTime','330');
t_lock = first_time(out.Stlog, 6);
fl = squeeze(out.Fltlog.Data);
tg = out.Qgaslog.Time; qg = squeeze(out.Qgaslog.Data);
gas_after = max([0; qg(tg >= t_lock + 0.5)]);
ok = ~isnan(t_lock) && (t_lock - tflamefail) <= 1 && fl(end) == 4 && gas_after <= 1;
report('REQ-BS-003', ok, sprintf('flame lost at %d s, lockout after %.2f s (max 1 s), fault = %d (expected 4), gas after lockout = %.0f W', ...
    tflamefail, t_lock - tflamefail, fl(end), gas_after));

%% scenario 4 and 5: fast cycling, anti-cycling and minimum burn time (REQ-BS-004, REQ-BS-005)
init_params; tset = 35; tsetinit = 35; tsetfinal = 35;
Hoffch = 0.5; Honch = 0.5;       % narrow hysteresis: the controller asks for a start very often
tminon = 100;                    % longer than the natural burn time (about 45 s) so the hold is active
out = sim('isitici','StopTime','1200');
[tc, sc] = changes(out.Stlog);
gaps = []; ondur = [];
for j = 2:numel(sc)
    if sc(j) == 4 && sc(j-1) == 3                 % Run ended, gas closed
        ondur(end+1) = tc(j) - tc(j-1);           %#ok<AGROW>
        nxt = find(sc(j+1:end) == 2, 1);          % next time the gas valve opens
        if ~isempty(nxt), gaps(end+1) = tc(j+nxt) - tc(j); end   %#ok<AGROW>
    end
end
ok4 = numel(gaps) >= 2 && all(gaps >= tminoff - TOL);
ok5 = numel(ondur) >= 2 && all(ondur >= tminon - TOL);
report('REQ-BS-004', ok4, sprintf('gas stays closed at least %d s between burns: shortest %.1f s over %d cycles', ...
    tminoff, min([gaps Inf]), numel(gaps)));
report('REQ-BS-005', ok5, sprintf('burn time at least %d s: shortest %.1f s over %d burns', ...
    tminon, min([ondur Inf]), numel(ondur)));

%% scenario 6: over-temperature limit lowered to 50 degC (REQ-BS-006)
init_params; tset = 60; tsetinit = 60; tsetfinal = 60;
Tstb = 50;
out = sim('isitici','StopTime','600');
t_lock = first_time(out.Stlog, 6);
fl = squeeze(out.Fltlog.Data);
tg = out.Qgaslog.Time; qg = squeeze(out.Qgaslog.Data);
gas_after = max([0; qg(tg >= t_lock + 0.5)]);
ok = ~isnan(t_lock) && fl(end) == 1 && gas_after <= 1;
report('REQ-BS-006', ok, sprintf('over-temperature (limit %d degC) lockout at %.1f s, fault = %d (expected 1), gas after lockout = %.0f W', ...
    Tstb, t_lock, fl(end), gas_after));

%% scenario 7: sensor reading above its valid range (REQ-BS-007)
init_params; tset = 60; tsetinit = 60; tsetfinal = 60;
Tsmax = 40;                      % valid range lowered, the flow temperature leaves it while heating up
out = sim('isitici','StopTime','600');
t_lock = first_time(out.Stlog, 6);
fl = squeeze(out.Fltlog.Data);
tg = out.Qgaslog.Time; qg = squeeze(out.Qgaslog.Data);
gas_after = max([0; qg(tg >= t_lock + 0.5)]);
ok = ~isnan(t_lock) && fl(end) == 2 && gas_after <= 1;
report('REQ-BS-007', ok, sprintf('sensor fault (valid up to %d degC) lockout at %.1f s, fault = %d (expected 2), gas after lockout = %.0f W', ...
    Tsmax, t_lock, fl(end), gas_after));

%% scenario 8: reset leaves the lockout (REQ-BS-008)
init_params; tset = 60; tsetinit = 60; tsetfinal = 60;
tflamefail = 300; trst = 330;
out = sim('isitici','StopTime','340');
t = out.Stlog.Time; s = squeeze(out.Stlog.Data);
t_lock = first_time(out.Stlog, 6);
k_exit = find(t >= trst & s ~= 6, 1);
if isempty(k_exit), t_exit = NaN; else, t_exit = t(k_exit); end
ok = ~isnan(t_lock) && ~isnan(t_exit) && (t_exit - trst) <= 0.5;
report('REQ-BS-008', ok, sprintf('locked at %.1f s, reset at %d s, lockout left after %.2f s (max 0.5 s)', ...
    t_lock, trst, t_exit - trst));
fprintf('\n');

function [tc, sc] = changes(ts)
% times and values of the logged state at every change
t = ts.Time; s = squeeze(ts.Data);
idx = [1; find(diff(s) ~= 0) + 1];
tc = t(idx); sc = s(idx);
tc = tc(:); sc = sc(:);
end

function t0 = first_time(ts, value)
% first time the logged signal has the given value, NaN if it never does
s = squeeze(ts.Data);
k = find(s == value, 1);
if isempty(k), t0 = NaN; else, t0 = ts.Time(k); end
end

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end
