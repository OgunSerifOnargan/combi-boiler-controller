% init_params.m
% Single parameter file for the whole repo.
% Run it before opening or running isitici.slx or dhwplant.slx.

%% ===== common =====
Qmax      = 24000;   % W, maximum burner power (24 kW)
turndown  = 10;      % burner turndown ratio (1:10)
Qmin      = Qmax/turndown;   % W, minimum burner power when burning (2.4 kW)

%% ===== burner: gas power and efficiency (Burner subsystem in isitici.slx) =====
% datasheet Bosch Condens 7000i W 24 kW: gas input max 24.6 kW, efficiency 0.975 at 80/60, about 1.02 at 50/30 (Hi)
etanom     = 0.975;  % -, efficiency the controller assumes (80/60 operating point), Qgas = Qreq/etanom
Qgasmax    = 24600;  % W, maximum gas power (24.6 kW, datasheet)
etax       = [30 55 80];        % degC, return temperature breakpoints
etay       = [1.02 0.975 0.975];% -, efficiency: 0.975 above the dew point (about 55 degC), rises to 1.02 at 30 degC (condensing), assumption between the datasheet points

%% ===== burner sequence and protection (BurnerSequence chart in isitici.slx) =====
% all times and limits are assumptions (typical orders of magnitude), not from the datasheet
tprepurge    = 5;     % s, pre-purge: fan runs, gas closed
tflame       = 1;     % s, time until the flame signal is proven after ignition
tignsafety   = 3;     % s, ignition safety time: gas closes if no flame by then
nmax         = 3;     % -, ignition attempts before lockout (fault 3)
tpostpurge   = 10;    % s, post-purge: fan runs, gas closed
tminoff      = 60;    % s, anti-cycling: minimum time between burner stop and next start
tminon       = 30;    % s, minimum burn time after a start
tpumpoverrun = 180;   % s, pump keeps running after the burner stopped
Tstb         = 95;    % degC, over-temperature limit: lockout (fault 1)
Tlimit       = 90;    % degC, soft limit: burner power is reduced above this flow temperature
dTmax        = 30;    % K, maximum flow-return temperature difference, power is limited above it
Tsmin        = -20;   % degC, sensor reading below this is treated as a sensor fault (fault 2)
Tsmax        = 130;   % degC, sensor reading above this is treated as a sensor fault (fault 2)

% inputs from the outside world, used for fault injection in tests (1e9 s = never happens)
tflamefail   = 1e9;   % s, time the flame signal drops to 0 (0 = no flame from the start, ignition failure)
trst         = 1e9;   % s, time the reset input goes to 1

%% ===== heating circuit (isitici.slx, Controller.slx) =====
% plant v2: two-node model (boiler heat exchanger Tf, radiator circuit Tr)
Chx        = 10000;  % J/K, thermal capacity of the boiler heat exchanger (water + metal), assumption
Crad       = 100000; % J/K, thermal capacity of the radiators and pipes (about 24 L water), assumption
mdot       = 0.25;   % kg/s, heating water mass flow of the pump (15 L/min), assumption
Krad       = 35.2;   % W/K^nrad, radiator heat emission coefficient (sized for 4 kW at mean 58 degC / room 20 degC)
nrad       = 1.3;    % radiator exponent (typical 1.2 ... 1.4)
Tamb       = 20;     % degC, initial room temperature and initial water temperature

% flow temperature sensor (NTC, between Plant and Controller)
tauntc     = 5;      % s, thermal time constant of the sensor, assumption (datasheets: 1.5 ... 8 s)
qntc       = 0.1;    % K, resolution of the temperature reading (ADC step), assumption

% legacy plant v1 values (not used by plant v2, kept until test_ch_low is updated)
C          = 20000;  % J/K, v1 lumped capacity
UA         = 100;    % W/K, v1 radiator coefficient
T_amb      = 20;     % degC, legacy duplicate of Tamb

% setpoint scenario (Step block in isitici.slx, mode 1)
tset       = 60;     % degC, nominal setpoint
tsetinit   = 60;     % degC, setpoint before the step
tsetfinal  = 60;     % degC, setpoint after the step
tstep      = 200;    % s, time of the step

% controller (PID block in Controller.slx)
Kpch       = 3000;   % W/K, proportional gain (retuned for plant v2)
Kich       = 6;      % W/(K s), integral gain (retuned for plant v2)
Ktch       = 0.005;  % tracking (anti-windup) coefficient
Tsch       = 0.1;    % s, controller sample time

% burner shutoff hysteresis (low load)
Hoffch     = 3;      % K, burner off when T >= setpoint + Hoffch
Honch      = 3;      % K, burner on again when T <= setpoint - Honch

%% ===== setpoint mode =====
hcmode     = 1;      % 1 = fixed setpoint (step block)
                     % 2 = heating curve (outdoor temperature)
                     % 3 = room temperature control (curve + room PI)

% outdoor temperature (Clock + Fcn): Toutdoor + Toutamp*sin(...)
Toutdoor   = 5;      % degC, daily mean outdoor temperature
Toutamp    = 0;      % degC, daily swing amplitude (0 = constant)

% heating curve (mode 2 and feed-forward of mode 3)
hcx        = [-15 -5 5 15 20];   % degC, outdoor temperature breakpoints
hcy        = [75 62 49 36 30];   % degC, flow temperature setpoints
Tflowmin   = 30;     % degC, lower limit of the flow temperature setpoint
Tflowmax   = 75;     % degC, upper limit of the flow temperature setpoint

% room model (always active) and room temperature control (mode 3)
Troomset   = 21;     % degC, room temperature setpoint
UAh        = 190;    % W/K, house heat loss to outside
Croom      = 2e6;    % J/K, thermal capacity of the house (time constant about 2 h)
Kpr        = 10;     % K/K, room PI proportional gain (flow K per room K)
Kir        = 0.002;  % K/(K s), room PI integral gain
Ktr        = 0.5;    % tracking (anti-windup) coefficient of the room PI
Tsr        = 1;      % s, room PI sample time

%% ===== domestic hot water (dhwplant.slx) =====
Cdhw      = 4000;    % J/K, heat exchanger water capacity
Tin       = 15;      % degC, mains water temperature
Tstart    = 20;      % degC, initial outlet temperature
cpw       = 4186;    % J/(kg K), specific heat of water
Tdhwset   = 45;      % degC, hot water setpoint
topen     = 5;       % s, tap opens
tflow     = 60;      % s, flow step time
flowinit  = 8;       % L/min, flow after the tap opens
flowfinal = 10;      % L/min, flow after the flow step
flowon    = 2.5;     % L/min, burner request on
flowoff   = 2.0;     % L/min, burner request off
Kpdhw     = 800;     % W/K, proportional gain
Kidhw     = 110;     % W/(K s), integral gain
Ktdhw     = 3;       % tracking coefficient
ffon      = 1;       % 1 = flow feed-forward on
ffgain    = ffon*cpw/60*(Tdhwset-Tin);   % W per L/min
Qmaxdhw   = Qmax;    % W
Qmindhw   = Qmin;    % W
Hoff      = 3;       % K, burner off at setpoint + Hoff
Hon       = 3;       % K, burner on at setpoint - Hon
