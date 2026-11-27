% test_room.m
% MIL test of the room temperature control (setpoint mode 3) over a 24 h day.
% Outdoor temperature swings 1 ... 9 degC (warmest 15:00, coldest 03:00).
init_params;
hcmode   = 3;
Troomset = 21;
Tamb     = Troomset;      % house starts at the setpoint (initial room temperature)
Toutdoor = 5;             % degC, daily mean
Toutamp  = 4;             % degC, daily swing
tstop    = num2str(24*3600);

T_SKIP     = 2*3600;      % s, ignore the start-up transient
ERR_NOM    = 0.3;         % K
ERR_LEAKY  = 0.8;         % K
STARTS_MAX = 20;          % burner starts in 24 h
runinfo    = 1;           % 1 = also run the curve-only comparison (slower)

fprintf('--- test_room (24 h) ---\n');

% nominal house
UAh = 190;
so  = sim('isitici','StopTime',tstop);
tr  = getlog(so,'Trlog');
q   = getlog(so,'Qlog');
err1   = max(abs(tr.Data(tr.Time >= T_SKIP) - Troomset));
starts = sum(diff(double(q.Data(:) > 0)) == 1);
fprintf('  nominal: max room error %.3f K, room %.2f ... %.2f, burner starts %d\n', ...
    err1, min(tr.Data(tr.Time >= T_SKIP)), max(tr.Data(tr.Time >= T_SKIP)), starts);
report('REQ-RM-001', err1 <= ERR_NOM, 'room within 0.3 K of setpoint over the day (nominal house)');
report('REQ-RM-003', starts <= STARTS_MAX, 'burner starts in 24 h <= 20');

% leaky house (UAh +30 %)
UAh = 190*1.3;
so  = sim('isitici','StopTime',tstop);
tr  = getlog(so,'Trlog');
err2 = max(abs(tr.Data(tr.Time >= T_SKIP) - Troomset));
fprintf('  UAh +30 %%: max room error %.3f K\n', err2);
report('REQ-RM-002', err2 <= ERR_LEAKY, 'room within 0.8 K of setpoint (30 % more house loss)');

% information: curve only (mode 2)
if runinfo
    hcmode = 2;
    for f = [1.0 1.3]
        UAh = 190*f;
        so  = sim('isitici','StopTime',tstop);
        tr  = getlog(so,'Trlog');
        fprintf('  info: curve only, UAh x%.1f: max room error %.2f K\n', f, ...
            max(abs(tr.Data(tr.Time >= T_SKIP) - Troomset)));
    end
end

function report(id, ok, msg)
if ok, s = 'PASS'; else, s = 'FAIL'; end
fprintf('%s  %s  %s\n', s, id, msg);
end

function ts = getlog(so, name)
try
    ts = so.get(name);
catch
    ts = evalin('base', name);
end
end