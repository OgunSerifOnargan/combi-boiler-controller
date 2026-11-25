% testdhw.m
% MIL test: DHW controller, REQ-DHW-001 ... REQ-DHW-007 (cold start)

% --- parameters ---
init_params;

% --- requirement thresholds ---
T_REACH_MAX = 40;     % s after tap opens   (REQ-DHW-002)
OVERSHOOT_MAX = 0.5;  % K                   (REQ-DHW-003)
DIP_MAX_NOFF  = 2.5;  % K, FF off           (REQ-DHW-004)
DIP_MAX_FF    = 0.5;  % K, FF on            (REQ-DHW-004)
BAND_MAX      = 3.5;  % K, low-load band    (REQ-DHW-006)

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
    q_bad = any(Q > 1e-6 & Q < Qmindhw - 1e-6);

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
    report('REQ-DHW-007', ~q_bad, ...
        sprintf('%s burner power is 0 or >= %.0f W', tag, Qmindhw));
    fprintf('\n');
end

% ===== test 3: summer, low load (need < Qmin) =====
ffon = 1;
Tin = 25;  Tdhwset = 35;  flowinit = 2.5;  flowfinal = 2.5;
ffgain = ffon*cpw/60*(Tdhwset-Tin);
out = sim('dhwplant');
t = out.Tlog.Time;
T = out.Tlog.Data;
Q = out.Qlog.Data;
w = t >= 40;
band = max(abs(T(w) - Tdhwset));
q_bad = any(Q > 1e-6 & Q < Qmindhw - 1e-6);
starts = sum(diff(Q > 1e-6) == 1);
fprintf('info  [summer] need = %.0f W, Qmin = %.0f W, Tout range after 40 s = %.2f ... %.2f C, %d burner starts in %d s\n', ...
    flowinit/60*cpw*(Tdhwset-Tin), Qmindhw, min(T(w)), max(T(w)), starts, round(t(end)));
report('REQ-DHW-006', band <= BAND_MAX, ...
    sprintf('[summer] Tout stays within +/-%.1f K of setpoint: max deviation = %.2f K', BAND_MAX, band));
report('REQ-DHW-007', ~q_bad, ...
    sprintf('[summer] burner power is 0 or >= %.0f W', Qmindhw));
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end