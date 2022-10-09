%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.LName = 'cw10K_100sc';
% Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\CWEDMR\data_analysis';
Opt.LFolder = 'D:\Profile\qse\NREL\2022_spring\20220301\data_analysis';
Opt.LPath = [Opt.LFolder, '\', Opt.LName, '_BlcPc.mat'];

Opt.SFolder = [Opt.LFolder, '\', 'fit_boot'];
Opt.SFitPath = [Opt.SFolder, '\', Opt.LName, '_fit_three.mat'];
Opt.SBootPath = [Opt.SFolder, '\' Opt.LName, '_boot_three.mat'];

Opt.Run.ManualInitialFit = true;
Opt.Run.InitialFit = true;
Opt.Run.Bootstrap = true;
Opt.SaveFig = false;
Opt.nBoot = 5000;

% Import
load(Opt.LPath)
Exp.Range = Exp.Range;
% load([Opt.LFolder, '\cwFieldOffset.mat'], [Opt.LName, '_BOffset']);
% Exp.Range = Exp.Range - cw10K_BOffset;

%% Initial parameters, ranges and fit options
Sys0 = struct('g', 2.003, ... %2.01347
    'lw', [0 2.5], ...
    'weight', 10); % mT [Gaussian Lorentzian)

Vary0 = struct('g', 0.01, ...
    'lw', Sys0.lw);

Sys1 = struct('g', 2.004, ...
    'lw', [0 1.2], ...
    'weight', 0.8);

Vary1 = struct('g', 0.005, ...
    'lw', 0.5*Sys1.lw, ...
    'weight', Sys1.weight);

Sys2 = struct('g', 1.9975, ...
    'lw', [0 0.4], ...
    'weight', 1, ...
    'Nucs', '31P', ...
    'A', mt2mhz(4.2));

Vary2 = struct('g', 0.01, ...
    'lw', 0.7*Sys2.lw, ...
    'weight', Sys2.weight);

Opt.Fit = struct('Method', 'simplex fcn', ... 
    'Scaling', 'lsq', ... % No baseline
    'TolFun', 1e-3, ... % Termination criterion
    'PrintLevel', 0);


% SysInit = {Sys0, Sys1, Sys2}; VaryInit = {Vary0, Vary1, Vary2};
SysInit = {Sys0, Sys2}; VaryInit = {Vary0, Vary2};
% SysInit = Sys0; VaryInit = Vary0;


%%
figure()
tiledlayout(2,1)
nexttile, plot(x, pep3, x, DInt3)
nexttile, plot(x, pep2 + pep1, x, DInt12)

%% Multi-step fitting
if Opt.Run.InitialFit || ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    % [SysFit1,yfit1]= 
    % sys = 
    esfit(@pepper,y,SysInit, VaryInit,Exp,[],Opt.Fit);
else
    load(Opt.Save.FitPath);
end
% figure(); plot(x,y,x,yfit1)
%%
figure()
[pepy, F] = scaleY(pepper(sys,Exp), y);
plot(x,y,x,pepy)
hold on
plot(x,F*pepper(sys{1,1}, Exp), 'k');
plot(x,F*pepper(sys{1,2}, Exp), 'r');
%%
if Opt.Run.InitialFit || ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    % [SysFit2,yfit2]=
    esfit(@pepper,y, SysFit1 , {Vary0, [], []},Exp,[],Opt.Fit);
else
    load(Opt.Save.FitPath);
end
% figure(); plot(x,y-yfit1,x,yfit2)
%%
if Opt.Run.InitialFit || ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    [SysFit3,yfit]=esfit(@pepper,y,SysFit2,{[],Vary1,[]},Exp,[],Opt.Fit);
else
    load(Opt.Save.FitPath);
end
figure(); plot(x,y,x,yfit)
%%
if Opt.Run.InitialFit || ~isfile(strjoin({Opt.Save.FitPath, 'mat'}, '.'))
    [Sys, yfit] = esfit(@pepper, y, SysInit, VaryInit, Exp, [], Opt.Fit);
    save(Opt.SFitPath,'x','yfit','Sys','SysInit','VaryInit','Exp');
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
%%
Sys = fit1.Sys;
yfit = fit1.fitSpec;
save(Opt.SFitPath,'x','yfit','Sys','SysInit','VaryInit','Exp');

%%
function varargout = scaleY(y, ref)
% Scale y to the same amplitude pp as ref
    ppAmpRef = max(ref) - min(ref);
    ppAmpY = max(y) - min(y);
    propFactor = ppAmpRef/ppAmpY;
    scaledY = propFactor*y;
    if nargout == 1
        varargout{1} = scaledY;
    else
        varargout{1} = scaledY; varargout{2} = propFactor;
    end
end