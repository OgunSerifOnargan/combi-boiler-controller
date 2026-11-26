% init_params.m
% Single parameter file for the whole repo.
% Run it before opening or running isitici.slx or dhwplant.slx.

%% ===== common =====
Qmax      = 24000;   % W, maximum burner power (24 kW)
turndown  = 10;      % burner turndown ratio (1:10)
Qmin      = Qmax/turndown;   % W, minimum burner power when burning (2.4 kW)

%% ===== heating circuit (isitici.slx, Controller.slx) =====
% plant (Tamb = room temperature the radiators lose heat to, modes 1 and 2)
C          = 20000;  % J/K, thermal capacity of the heating water
UA         = 100;    % W/K, radiator heat emission coefficient
Tamb       = 20;     % degC, fixed room temperature (modes 1 and 2)
T_amb      = 20;     % degC, same value (heating plant block uses this name)

% setpoint scenario (Step block in isitici.slx, mode 1)
tset       = 60;     % degC, nominal setpoint
tsetinit   = 60;     % degC, setpoint before the step
tsetfinal  = 60;     % degC, setpoint after the step
tstep      = 200;    % s, time of the step

% controller (PID block in Controller.slx)
Kpch       = 1000;   % W/K, proportional gain
Kich       = 5;      % W/(K s), integral gain
Ktch       = 0.005;  % tracking (anti-windup) coefficient
Tsch       = 0.1;    % s, controller sample time

% burner shutoff hysteresis (low load)
Hoffch     = 3;      % K, burner off when T >= setpoint + Hoffch
Honch      = 3;      % K, burner on again when T <= setpoint - Honch

%% ===== setpoint mode =====
hcmode     = 1;      % 1 = fixed setpoint (step block)
% 2 = heating curve (outdoor temperature)
% 3 = room temperature control (curve + room PI)

% outdoor temperature (Sine Wave block): Toutdoor + Toutamp*sin(...)
Toutdoor   = 5;      % degC, daily mean outdoor temperature
Toutamp    = 0;      % degC, daily swing amplitude (0 = constant)
Toutw      = 2*pi/86400;       % rad/s, one period per day
Toutphase  = -2*pi*9/24;       % rad, warmest at 15:00, coldest at 03:00

% heating curve (mode 2 and feed-forward of mode 3)
hcx        = [-15 -5 5 15 20];   % degC, outdoor temperature breakpoints
hcy        = [75 62 49 36 30];   % degC, flow temperature setpoints
Tflowmin   = 30;     % degC, lower limit of the flow temperature setpoint
Tflowmax   = 75;     % degC, upper limit of the flow temperature setpoint

% room temperature control (mode 3)
Troomset   = 21;     % degC, room temperature setpoint
Troom0     = 20;     % degC, initial room temperature
UAh        = 190;    % W/K, house heat loss to outside
Croom      = 2e6;    % J/K, thermal capacity of the house (time constant ~2 h)
Kpr        = 10;     % K/K, room PI proportional gain (flow K per room K)
Kir        = 0.002;  % K/(K s), room PI integral gain
Ktr        = 0.5;    % tracking (anti-windup) coefficient of the room PI
Tsr        = 1;      % s, room PI sample time

%% ===== domestic hot water (dhwplant.slx) =====
% plant
Cdhw      = 4000;    % J/K, thermal capacity of the heat exchanger water
Tin       = 15;      % degC, cold mains water temperature
Tstart    = 20;      % degC, initial temperature (cold start)
cpw       = 4186;    % J/(kg K), specific heat of water
Tdhwset   = 45;      % degC, DHW setpoint

% flow scenario (L/min)
topen     = 5;       % s, tap opens
tflow     = 60;      % s, flow changes
flowinit  = 8;       % L/min after tap opens
flowfinal = 10;      % L/min after tflow

% flow switch (Relay block)
flowon    = 2.5;     % L/min, burner request on
flowoff   = 2.0;     % L/min, burner request off

% controller
Kpdhw     = 800;
Kidhw     = 110;
Ktdhw     = 3;       % tracking gain
ffon      = 1;       % 1 = feed-forward on, 0 = off
ffgain    = ffon*cpw/60*(Tdhwset-Tin);   % W per (L/min)
Qmaxdhw   = Qmax;    % W
Qmindhw   = Qmin;    % W

% burner shutoff hysteresis (low load)
Hoff      = 3;       % K, burner off when Tout >= Tdhwset + Hoff
Hon       = 3;       % K, burner on again when Tout <= Tdhwset - Hon