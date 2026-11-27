% test_hc.m
% MIL test of the heating curve (setpoint mode 2).
% Plant v2 settles slowly (integral time constant Kpch/Kich = 500 s),
% so every run is simulated for 1800 s before the flow temperature is compared with the curve.
init_params;
hcmode = 2;
TOL    = 0.1;   % K
T_STOP = 3000;  % s, simulated time per run

fprintf('--- test_hc ---\n');

% REQ-HC-003: curve well-formed
ok3 = all(diff(hcx) > 0) && all(diff(hcy) <= 0);
report('REQ-HC-003', ok3, 'curve breakpoints and monotonicity');

% REQ-HC-001: steady flow temperature follows the curve
pts = [-15 -5 0 5];
ok1 = true;
for k = 1:numel(pts)
    Toutdoor = pts(k);
    so  = sim('isitici','StopTime',num2str(T_STOP));
    tl  = getlog(so,'Tlog');
    Tend = tl.Data(end);
    ref  = interp1(hcx,hcy,Toutdoor);
    fprintf('  Toutdoor %6.1f -> T %.2f  (curve %.2f)\n',Toutdoor,Tend,ref);
    ok1 = ok1 && abs(Tend-ref) <= TOL;
end
report('REQ-HC-001', ok1, 'flow temperature follows the curve');

% REQ-HC-002: end value held outside the table
Toutdoor = -25;
so  = sim('isitici','StopTime',num2str(T_STOP));
tl  = getlog(so,'Tlog');
fprintf('  Toutdoor -25.0 -> T %.2f  (hcy(1) %.2f)\n',tl.Data(end),hcy(1));
report('REQ-HC-002', abs(tl.Data(end)-hcy(1)) <= TOL, 'end value held, no extrapolation');

% REQ-HC-004: limited to Tflowmax
hcy_backup = hcy;
hcy(1)    = 90;
Toutdoor  = -25;
so  = sim('isitici','StopTime',num2str(T_STOP));
tl  = getlog(so,'Tlog');
fprintf('  curve 90 -> T %.2f  (Tflowmax %.2f)\n',tl.Data(end),Tflowmax);
report('REQ-HC-004', abs(tl.Data(end)-Tflowmax) <= TOL, 'limited to Tflowmax');
hcy = hcy_backup;

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
