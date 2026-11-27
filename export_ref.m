% export_ref.m
% Exports reference data of the BurnerSequence chart for the C++ back-to-back test.
% For every scenario the inputs and outputs of the chart are logged at the chart sample
% time and written to cpp/refdata/ref_<scenario>.csv (one row per sample), together with
% the parameters used (cpp/refdata/ref_<scenario>_params.csv).
% Temporary To Workspace blocks are added to the model and removed again. Do not save the
% model while they exist (the script removes them itself at the end).

mdl  = 'isitici';
blk  = [mdl '/BurnerSequence'];
outdir = fullfile(pwd, 'cpp', 'refdata');
if ~exist(outdir, 'dir'), mkdir(outdir); end

init_params;
load_system(mdl);

% names of the chart inputs and outputs, in port order
rt = sfroot;
ch = rt.find('-isa', 'Stateflow.Chart', 'Path', blk);
dd = ch.find('-isa', 'Stateflow.Data');
inN = {}; inP = []; outN = {}; outP = [];
for k = 1:numel(dd)
    if strcmp(dd(k).Scope, 'Input'),  inN{end+1}  = dd(k).Name; inP(end+1)  = dd(k).Port; end %#ok<AGROW>
    if strcmp(dd(k).Scope, 'Output'), outN{end+1} = dd(k).Name; outP(end+1) = dd(k).Port; end %#ok<AGROW>
end
[~, i1] = sort(inP);  inN  = inN(i1);
[~, i2] = sort(outP); outN = outN(i2);
fprintf('chart inputs : %s\n', strjoin(inN, ', '));
fprintf('chart outputs: %s\n', strjoin(outN, ', '));

% temporary logging blocks on the chart ports
ph  = get_param(blk, 'PortHandles');
pos = get_param(blk, 'Position');
tmpBlocks = {}; tmpLines = [];
sig = [inN, outN];
for k = 1:numel(sig)
    tw = [mdl '/tmp_ref_' sig{k}];
    add_block('simulink/Sinks/To Workspace', tw, 'VariableName', ['ref_' sig{k}], ...
        'SaveFormat', 'Timeseries', 'SampleTime', '0.1', ...
        'Position', [pos(3)+80, pos(2)-60+30*k, pos(3)+140, pos(2)-40+30*k]);
    tmpBlocks{end+1} = tw; %#ok<AGROW>
    twp = get_param(tw, 'PortHandles');
    if k <= numel(inN)
        ln  = get_param(ph.Inport(k), 'Line');
        src = get_param(ln, 'SrcPortHandle');
    else
        src = ph.Outport(k - numel(inN));
    end
    tmpLines(end+1) = add_line(mdl, src, twp.Inport(1)); %#ok<AGROW>
end
cleanup = onCleanup(@() local_cleanup(mdl, tmpLines, tmpBlocks));

% parameters written next to every scenario
pnames = {'Tsch','tprepurge','tflame','tignsafety','nmax','tpostpurge','tminoff','tminon', ...
          'Tstb','Tlimit','dTmax','Tsmin','Tsmax','Qmin','Qmax'};

% scenarios: name, setup code, stop time
sc = {
  'normal',     'tset=60; tsetinit=60; tsetfinal=60;',                                       400
  'ignfail',    'tset=60; tsetinit=60; tsetfinal=60; tflamefail=0;',                          40
  'flamelost',  'tset=60; tsetinit=60; tsetfinal=60; tflamefail=300; trst=330;',             400
  'cycling',    'tset=35; tsetinit=35; tsetfinal=35; Hoffch=0.5; Honch=0.5; tminon=100;',   1200
  'overtemp',   'tset=60; tsetinit=60; tsetfinal=60; Tstb=50;',                              120
  'sensorrng',  'tset=60; tsetinit=60; tsetfinal=60; Tsmax=40;',                             100
};

for s = 1:size(sc, 1)
    init_params;
    eval(sc{s, 1+1});
    out = sim(mdl, 'StopTime', num2str(sc{s, 3}));
    n = inf; cols = cell(1, numel(sig));
    for k = 1:numel(sig)
        ts = out.get(['ref_' sig{k}]);
        cols{k} = double(squeeze(ts.Data(:)));
        n = min(n, numel(cols{k}));
        t = ts.Time(:);
    end
    M = zeros(n, numel(sig) + 1);
    M(:, 1) = t(1:n);
    for k = 1:numel(sig), M(:, k+1) = cols{k}(1:n); end

    f = fopen(fullfile(outdir, ['ref_' sc{s,1} '.csv']), 'w');
    fprintf(f, 'time,%s\n', strjoin(sig, ','));
    fprintf(f, [repmat('%.10g,', 1, numel(sig)) '%.10g\n'], M.');
    fclose(f);

    f = fopen(fullfile(outdir, ['ref_' sc{s,1} '_params.csv']), 'w');
    for k = 1:numel(pnames)
        fprintf(f, '%s,%.10g\n', pnames{k}, evalin('base', pnames{k}));
    end
    fclose(f);
    fprintf('%-10s %6d samples written\n', sc{s,1}, n);
end
init_params;

function local_cleanup(mdl, lines, blocks)
for k = 1:numel(lines)
    try, delete_line(lines(k)); catch, end
end
for k = 1:numel(blocks)
    try, delete_block(blocks{k}); catch, end
end
end
