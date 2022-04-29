%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('/home/gianluca/matlab_util'));

% File and Run options
Opt.Name = 'cw20K';
Opt.Load.Folder = ...
    'D:\Profile\qse\NREL\2021_summer\CWEDMR\data_analysis';
Opt.Load.Name = strjoin({Opt.Name, 'BlcPc'}, '_');
Opt.Load.Path = strjoin({Opt.Load.Folder, ...
    Opt.Load.Name}, '/');

Opt.Save.Folder = strjoin({Opt.Load.Folder, 'fit_boot'}, '/');
Opt.Save.FitName = strjoin({Opt.Name, 'fit', 'three'}, '_');
Opt.Save.FitPath = strjoin({Opt.Save.Folder, ...
    Opt.Save.FitName}, '/');
Opt.Save.BootName = strjoin({Opt.Name, 'boot', 'three'}, '_');
Opt.Save.BootPath = strjoin({Opt.Save.Folder, ...
    Opt.Save.BootName}, '/');

Opt.Run.ManualInitialFit = true;
Opt.Run.InitialFit = true;
Opt.Run.Bootstrap = true;
Opt.SaveFig = false;
Opt.nBoot = 5000;

% Import
load(Opt.Load.Path)

%% Initial parameters, ranges and fit options
Sys0 = struct('g', 2.007, ... %2.01347
    'lw', [0 3.6]); % mT [Gaussian Lorentzian)

Vary0 = struct('g', 0.004, ...
    'lw', 0.5*Sys0.lw);

Sys1 = struct('g', 2.0054, ...
    'lw', [0 1.8], ...
    'weight', 0.7);

Vary1 = struct('g', 0.003, ...
    'lw', 0.5*Sys1.lw, ...
    'weight', Sys1.weight);

Sys2 = struct('g', 1.9999, ...
    'lw', [0 1.2], ...
    'weight', 0.2, ...
    'Nucs', '31P', ...
    'A', mt2mhz(4.2));

Vary2 = struct('g', 0.003, ...
    'lw', Sys2.lw, ...
    'weight', Sys2.weight);

Opt.Fit = struct('Method', 'simplex fcn', ... % Nelder/Mead, data as is
    'Scaling', 'lsq', ... % No baseline
    'PrintLevel', 0);

%% Manual initial fit
if Opt.Run.ManualInitialFit
    esfit(@pepper, y, {Sys0, Sys1, Sys2}, ...
        {Vary0, Vary1, Vary2}, Exp, [], Opt.Fit);
end

%% Initial fit
if Opt.Run.InitialFit || ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    [Sys, yfit] = esfit(@pepper, y, {Sys0, Sys1, Sys2}, ...
            {Vary0, Vary1, Vary2}, Exp, [], Opt.Fit);
    save(Opt.Save.FitPath, 'Sys', 'x', 'yfit', 'Sys0', 'Vary0', ...
        'Sys1', 'Vary1', 'Sys2', 'Vary2');
else
    load(Opt.Save.FitPath);
end

FigFit = figure();
plot(x, y, x, yfit); xlim(Exp.Range);
if Opt.SaveFig
    saveas(FigFit, Opt.Save.FitPath, 'png')
end

%% Bootstrap
if Opt.Run.Bootstrap || ...
        ~isfile(strjoin({Opt.Save.BootPath, 'mat'}, '.'))
    r = y - yfit;
    [~, idx] = bootstrp(Opt.nBoot, [], r);
    R = r(idx);
    Y = y + R.';

    FitOpt = Opt.Fit;
    Boot = cell(1, Opt.nBoot);
    parfor i = 1:Opt.nBoot
        y_ = Y(i, :);
        Boot{i} = esfit(@pepper, y_, {Sys0, Sys1, Sys2}, ...
            {Vary0, Vary1, Vary2}, Exp, [], FitOpt);
    end
    save(Opt.Save.BootPath, 'Boot');
else
    load(Opt.Save.BootPath);
end

%% Copy all Boot Sys structure into one structure
BootSys0 = Boot{1};
fields = fieldnames(BootSys0);

for i = 1:numel(fields)
    f = fields{i};
    BootSys0.(f) = repmat(BootSys0.(f), Opt.nBoot, 1);
    for j = 1:Opt.nBoot
        BootSys0.(f)(j, :) = Boot{j}.(f);
    end
end

FigBoot = figure();
subplot(1, 2, 1);
histfit(BootSys0.g);
subplot(1, 2, 2);
histfit(BootSys0.lw(:, 2));
if Opt.SaveFig
    saveas(FigBoot, Opt.Save.BootPath, 'png')
end

save(Opt.Save.BootPath, 'Boot', 'BootSys0', 'Sys0', 'Vary0');