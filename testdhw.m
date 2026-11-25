% testdhw.m
% MIL test: DHW controller, REQ-DHW-001 ... REQ-DHW-005 (cold start)

% --- parameters ---
Cdhw    = 4000;   Tin = 15;   Tstart = 20;   cpw = 4186;
Tdhwset = 45;
topen   = 5;      tflow = 60;
flowon  = 2.5;    flowoff = 2.0;
Kpdhw   = 800;    Kidhw = 110;   Ktdhw = 3;
Qmaxdhw = 24000;

% --- requirement thresholds ---
T_REACH_MAX = 40;     % s after tap opens   (REQ-DHW-002)
OVERSHOOT_MAX = 0.5;  % K                   (REQ-DHW-003)
DIP_MAX_NOFF  = 2.5;  % K, FF off           (REQ-DHW-004)
DIP_MAX_FF    = 0.5;  % K, FF on            (REQ-DHW-004)

fprintf('\n');

% ===== test 1: low flow, burner must stay off =====
ffon = 1;  ffgain = ffon*cpw/60*(Tdhwset-Tin);
flowinit = 1.5;  flowfinal = 1.5;
out = sim('dhwplant');
Q = out.Qlog.Data;
report('REQ-DHW-001', max(abs(Q)) < 1e-6, ...
    sprintf('flow %.1f L/min < %.1f: max Q = %.1f W (must be 0)', flowinit, flowoff, max(abs(Q))));

% ===== test 2: normal flow, FF off and FF on =====
flowinit = 8;  flowfinal = 10;
for ffon = [0 1]
    ffgain = ffon*cpw/60*(Tdhwset-Tin);
    out = sim('dhwplant');
    t = out.Tlog.Time;
    T = out.Tlog.Data;
    Q = out.Qlog.Data;

    pre  = t >= topen & t < tflow;
    post = t >= tflow;

    idx = find(pre & T >= Tdhwset - 0.1, 1);
    if isempty(idx)
        t_reach = Inf;
    else
        t_reach = t(idx) - topen;
    end
    overshoot = max(T(pre)) - Tdhwset;
    dip = Tdhwset - min(T(post));
    q_hi = max(Q);

    if ffon == 1
        dipmax = DIP_MAX_FF;
    else
        dipmax = DIP_MAX_NOFF;
    end
    tag = sprintf('[ff=%d]', ffon);

    report('REQ-DHW-002', t_reach <= T_REACH_MAX, ...
        sprintf('%s time to 44.9 C = %.1f s (max %d s)', tag, t_reach, T_REACH_MAX));
    report('REQ-DHW-003', overshoot < OVERSHOOT_MAX, ...
        sprintf('%s overshoot = %.3f K (max %.1f K)', tag, overshoot, OVERSHOOT_MAX));
    report('REQ-DHW-004', dip < dipmax, ...
        sprintf('%s dip after flow step = %.2f K (max %.1f K)', tag, dip, dipmax));
    report('REQ-DHW-005', q_hi <= Qmaxdhw + 1e-6, ...
        sprintf('%s peak Q = %.0f W (max %d W)', tag, q_hi, Qmaxdhw));
    fprintf('\n');
end

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end