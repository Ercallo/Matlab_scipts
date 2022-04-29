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

Opt.Save.Folder = Opt.Load.Folder;
Opt.Save.FitName = strjoin({Opt.Name, 'fit', 'two'}, '_');
Opt.Save.FitPath = strjoin({Opt.Save.Folder, ...
    Opt.Save.FitName}, '/');
Opt.Save.BootName = strjoin({Opt.Name, 'boot', 'two'}, '_');
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
Sys0 = struct('g', 2.008, ...
    'lw', [0 5]); % mT [Gaussian Lorentzian)

Vary0 = struct('g', 0.01, ...
    'lw', Sys0.lw);

Sys1 = struct('g', 2.005, ...
    'lw', [0 2], ...
    'weight', 2);

Vary1 = struct('g', 0.01, ...
    'lw', Sys1.lw, ...
    'weight', Sys1.weight);

Opt.Fit = struct('Method', 'simplex fcn', ... % Nelder/Mead, data as is
    'Scaling', 'lsq', ... % No baseline
    'PrintLevel', 0);

%% Manual initial fit
if Opt.Run.ManualInitialFit
    esfit(@pepper, y, {Sys0, Sys1}, ...
        {Vary0, Vary1}, Exp, [], Opt.Fit);
end

%% Initial fit
if Opt.Run.InitialFit || ...
        ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    [Sys, yfit] = esfit(@pepper, y, Sys0, Vary0, Exp, [], Opt.Fit);
    save(Opt.Save.FitPath, 'Sys', 'yfit', 'Sys0', 'Vary0');
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