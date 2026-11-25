% test_ch_basic.m
% MIL testi: isitma dongusu, REQ-CH-001 ... REQ-CH-004

% --- parametreler (init_params.m ile ayni degerler) ---
C     = 20000;   % J/K
UA    = 100;     % W/K
Tamb  = 20;      % degC
T_amb = 20;      % degC (modeldeki blok bu adi kullaniyor)
tset  = 60;      % degC

% --- gereksinim esikleri ---
T_REACH_MAX   = 150;    % s   (REQ-CH-001)
OVERSHOOT_MAX = 0.5;    % K   (REQ-CH-002)
FINAL_ERR_MAX = 0.1;    % K   (REQ-CH-003)
Q_MIN = 0;              % W   (REQ-CH-004)
Q_MAX = 24000;          % W   (REQ-CH-004)

% --- modeli calistir ---
out = sim('isitici');
t = out.Tlog.Time;
T = out.Tlog.Data;
Q = out.Qlog.Data;

% --- olcumler ---
idx = find(T >= tset - 0.1, 1);
if isempty(idx)
    t_reach = Inf;
else
    t_reach = t(idx);
end
overshoot = max(T) - tset;
final_err = abs(T(end) - tset);
q_lo = min(Q);
q_hi = max(Q);

% --- sonuclar ---
fprintf('\n');
report('REQ-CH-001', t_reach <= T_REACH_MAX, ...
    sprintf('59.9 C ye ulasma suresi = %.1f s (en fazla %d s)', t_reach, T_REACH_MAX));
report('REQ-CH-002', overshoot < OVERSHOOT_MAX, ...
    sprintf('asim = %.3f K (en fazla %.1f K)', overshoot, OVERSHOOT_MAX));
report('REQ-CH-003', final_err < FINAL_ERR_MAX, ...
    sprintf('kalici hata = %.4f K (en fazla %.1f K)', final_err, FINAL_ERR_MAX));
report('REQ-CH-004', q_lo >= Q_MIN - 1e-6 && q_hi <= Q_MAX + 1e-6, ...
    sprintf('Q araligi = %.0f ... %.0f W (izin: %d ... %d W)', q_lo, q_hi, Q_MIN, Q_MAX));
fprintf('\n');

function report(id, ok, text)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
fprintf('%s  %s  %s\n', s, id, text);
end