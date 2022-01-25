clearvars;
rng('default'); % for reproducible random numbers (only for demonstration)
addpath('functions');

%% Script parameters
Opt.Snr = 50;
Opt.NumBoot = 1000;
Opt.RunInitialFit = false;
Opt.RunBootstrap = true;
Opt.CacheInitialFit = 'tmp_initial_fit.mat';
Opt.CacheBootstrap = 'tmp_bootstrap.mat';

% The "real" spin system.
Sys.S = 0.5;
Sys.g = 2.0055;
Sys.lw = [0.0, 1.5];
    
% Experimental parameters.
Exp.mwFreq = 9.6;
Exp.Range = round(mhz2mt(Exp.mwFreq*1e3, Sys.g) + 15*max(Sys.lw) * [-1 1]);
Exp.nPoints = 4096;
Exp.Harmonic = 0;

% The "guessed" spin system and fitting ranges.
Sys0.S = 0.5;
Sys0.g = gfree;
Sys0.lw = 1.0 * [0 1];
Vary.g = 0.01;
Vary.lw = Sys0.lw;

% Fit options.
Opt.Fit.Method = 'simplex fcn'; % Nelder/Mead, data as is
Opt.Fit.Scaling = 'lsq'; % no baseline

%% Generate data
x = linspace(min(Exp.Range), max(Exp.Range), Exp.nPoints);
y = pepper(Sys, Exp);
y = addnoise(y, Opt.Snr, 'n');

%% Run fit
if Opt.RunInitialFit || ~isfile(Opt.CacheInitialFit)
    [Sys, yfit] = esfit(@pepper, y, Sys0, Vary, Exp, [], Opt.Fit);
    save(Opt.CacheInitialFit, 'Sys', 'yfit');
else
    load(Opt.CacheInitialFit);
end

figure(2); clf;
plot(x, y, x, yfit);

%% Run bootstrap iterations
if Opt.RunBootstrap || ~isfile(Opt.CacheBootstrap)
    r = y - yfit;
    [~, idx] = bootstrp(Opt.NumBoot, [], r);
    R = r(idx);
    Y = y + R.';

    FitOpt = Opt.Fit;
    Boot = cell(1, Opt.NumBoot);
    parfor i = 1:Opt.NumBoot
        y_ = Y(i, :);
        Boot{i} = esfit(@pepper, y_, Sys0, Vary, Exp, [], FitOpt);
    end
    save(Opt.CacheBootstrap, 'Boot');
else
    load(Opt.CacheBootstrap);
end

%% Copy all Boot Sys structure into one structure
BootSys = Boot{1};
BootSys = rmfield(BootSys, 'S');
BootCi = BootSys;
fields = fieldnames(BootSys);
for i = 1:numel(fields)
    f = fields{i};
    BootSys.(f) = repmat(BootSys.(f), Opt.NumBoot, 1);
    for j = 1:Opt.NumBoot
        BootSys.(f)(j, :) = Boot{j}.(f);
    end
    BootCi.(f) = bootstrapCIBca(BootSys.(f), Sys.(f), 0.95);
end

figure(1); clf;
subplot(1, 3, 1);
histfit(BootSys.g);
subplot(1, 3, 2);
histfit(BootSys.lw(:, 1));
subplot(1, 3, 3);
histfit(BootSys.lw(:, 2));

% figure(1); clf;
% plot(x, y, x, yfit, x, y - yfit, x, Y);