%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('/home/gianluca/matlab_util'));

% File and Run options
Opt.LName = 'cw10K_100sc';
Opt.LFolder = 'D:\Profile\qse\NREL\2022_spring\20220301\data_analysis';
Opt.LPath = [Opt.LFolder, '\', Opt.LName, '_BlcPc.mat'];

Opt.SFolder = [Opt.LFolder, '\', 'fit_boot'];
Opt.SFitPath = [Opt.SFolder, '\', Opt.LName, '_fit_two.mat'];
Opt.SBootPath = [Opt.SFolder, '\' Opt.LName, '_boot_two.mat'];

Opt.Run.ManualInitialFit = true;
Opt.Run.InitialFit = true;
Opt.Run.Bootstrap = true;
Opt.SaveFig = false;
Opt.nBoot = 5000;

% Import
load(Opt.LPath)
% Exp.Range = Exp.Range + 0.25;

%% Initial parameters, ranges and fit options
Sys0 = struct('g', 2.008, ...
    'lw', [0 3.6]); % mT [Gaussian Lorentzian)

Vary0 = struct('g', 0.008, ...
    'lw', 0.5*Sys0.lw);

Sys1 = struct('g', 2.0045, ...
    'lw', [0 2], ...
    'weight', 8);

Vary1 = struct('g', 0.008, ...
    'lw', Sys1.lw, ...
    'weight', Sys1.weight);

Opt.Fit = struct('Method', 'simplex fcn', ...
    'Scaling', 'lsq', ... % No baseline
    'TolFun', 1e-3, ... % Termination criterion
    'PrintLevel', 0);

% SysInit = {Sys0, Sys1}; VaryInit = {Vary0, Vary1};
SysInit = {Sys1}; VaryInit = {Vary1};


%% Manual initial fit
if Opt.Run.ManualInitialFit
    esfit(@pepper, y, SysInit, VaryInit, Exp, [], Opt.Fit);
end

%% Multi-step fitting
if Opt.Run.InitialFit || ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    [SysFit1, yfit] = esfit(@pepper,y,SysInit,{Vary0,[]},Exp,[],Opt.Fit);
else
    load(Opt.SFitPath);
end

if Opt.Run.InitialFit || ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    [SysFit2, yfit] = esfit(@pepper,y,SysFit1,{[],Vary1},Exp,[],Opt.Fit);
else
    load(Opt.SFitPath);
end
%%
if Opt.Run.InitialFit || ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    [Sys, yfit] = esfit(@pepper, y, SysInit, VaryInit, Exp, [], Opt.Fit);
    save(Opt.SFitPath,'x','yfit','Sys','SysInit','VaryInit','Exp');
else
    load(Opt.SFitPath);
end

FigFit = figure();
plot(x, y, x, yfit); xlim(Exp.Range);
if Opt.SaveFig
    saveas(FigFit, Opt.SFitPath, 'png')
end

%% Bootstrap
if Opt.Run.Bootstrap || ~isfile(strjoin({Opt.Save.BootPath, 'mat'}, '.'))
    r = y - yfit;
    [~, idx] = bootstrp(Opt.nBoot, [], r);
    R = r(idx);
    Y = y + R.';

    FitOpt = Opt.Fit;
    Boot = cell(1, Opt.nBoot);
    parfor i = 1:Opt.nBoot
        y_ = Y(i, :);
        Boot{i} = esfit(@pepper, y_, {Sys0, Sys1}, ...
            {Vary0, Vary1}, Exp, [], FitOpt);
    end
    save(Opt.Save.BootPath, 'Boot');
else
    load(Opt.Save.BootPath);
end

%% Copy all Boot Sys structure into one structure
BootSys0 = Boot{1,1}{1,1};
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