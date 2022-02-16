%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.File.Name = 'cw40K';
Opt.File.Load.Folder = ...
    'D:\Profile\qse\NREL\2021_Summer\CWEDMR\data_analysis';
Opt.File.Load.Name = strjoin({Opt.File.Name, 'BlcPc'}, '_');
Opt.File.Load.Path = strjoin({Opt.File.Load.Folder, ...
    Opt.File.Load.Name}, '\');

Opt.File.Save.Folder = Opt.File.Load.Folder;
Opt.File.Save.FitName = strjoin({Opt.File.Load.Name, 'fit'}, '_');
Opt.File.Save.FitPath = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.FitName}, '\');
Opt.File.Save.BootName = strjoin({Opt.File.Load.Name, 'boot'}, '_');
Opt.File.Save.FitPath = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.BootName}, '\');

Opt.Run.InitialFit = true;
Opt.Run.Bootstrap = true;
Opt.nBoot = 100;

% Import
load(Opt.File.Load.Path)

%% Initial parameters, ranges and fit options
Sys0.g = 2.008;
Sys0.lw = [0 2]; % mT [Gaussian Lorentzian]

Vary0.g = 0.01;
Vary0.lw = Sys0.lw;

Opt.Fit.Method = 'simplex fcn'; % Nelder/Mead, data as is
Opt.Fit.Scaling = 'lsq'; % no baseline
Opt.Fit.PrintLevel = 0;

%% Initial fit
if Opt.Run.InitialFit || ~isfile(Opt.File.Save.FitPath)
    [Sys, yfit] = esfit(@pepper, y, Sys0, Vary0, Exp, [], Opt.Fit);
    save(Opt.File.Save.FitPath, 'Sys', 'yfit', 'Sys0', 'Vary0');
else
    load(Opt.File.Save.FitPath);
end

%% Bootstrap
if Opt.Run.Bootstrap || ~isfile(Opt.File.Save.BootPath)
    r = y - yfit;
    [~, idx] = bootstrp(Opt.nBoot, [], r);
    R = r(idx);
    Y = y + R.';

    FitOpt = Opt.Fit;
    Boot = cell(1, Opt.nBoot);
    parfor i = 1:Opt.nBoot
        y_ = Y(i, :);
        Boot{i} = esfit(@pepper, y_, Sys0, Vary, Exp, [], FitOpt);
    end
    save(Opt.File.Save.BootPath, 'Boot');
else
    load(Opt.File.Save.BootPath);
end

%% Copy all Boot Sys structure into one structure
BootSys = Boot{1};
fields = fieldnames(BootSys);

for i = 1:numel(fields)
    f = fields{i};
    BootSys.(f) = repmat(BootSys.(f), Opt.nBoot, 1);
    for j = 1:Opt.nBoot
        BootSys.(f)(j, :) = Boot{j}.(f);
    end
end

figure();
subplot(1, 2, 1);
histfit(BootSys.g);
subplot(1, 2, 2);
histfit(BootSys.lw(:, 2));

save(Opt.File.Save.BootPath, 'Boot', 'BootSys0', 'Sys0', 'Vary0');