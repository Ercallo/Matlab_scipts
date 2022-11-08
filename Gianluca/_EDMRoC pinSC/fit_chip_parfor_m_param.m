%% Fit of baseline and phase corrected data EDMR-on-chip

clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\Files\soft\software\Matlab'));

Opt.LFolder = 'D:\Profile\qse\Files\_EDMRoC pinSC\New chip';
Opt.SFolder = 'D:\Profile\qse\Files\_EDMRoC pinSC\Images';

%% Start of expansion to every spectrum
cw = load([Opt.LFolder, '\cwEDMR_chip.mat']);
ncw = numel(cw.cwStruct) - 1; % V = 1.6V is omitted

% Spin systems
SysDb = struct(g = [2.0079 2.0061 2.0034], ...
    gStrain = [0.0054 0.0022 0.0018], ...
    lw = [0 1.3], ...
    Nucs = 'Si', A = [151 269], ...
    FieldOffset = -1.2);
VaryDb = struct( ...
    lw = SysDb.lw, ...
    FieldOffset = 2);

SysV = struct(g = 2.01, ...
    gStrain = 0.0098, ...
    lw = [0. 0.55], ...
    weight = 0.3);
VaryV = struct( ...
    lw = SysV.lw, ...
    weight = SysV.weight);

Exp.mwFreq = 14; % GHz
Exp.nPoints = numel(xRaw_);

Sys = SysDb;
Vary = VaryDb;

%% Initial fit
xRaw_ = cw.x(:, 1); y_ = cw.y(:,1);
Exp.Range = [min(xRaw_) max(xRaw_)];
Fit= esfit(y_, @pepperFieldOffset, {Sys, Exp}, {Vary});

%%
NUM_M_PARAMS = 12;
par = repmat(...
    struct(xRaw = cw.x(:, 1), x = cw.x(:, 1), ...
           y = cw.y(:,1), Fit = Fit), ...
    12, ncw);
%%
for im = 1:NUM_M_PARAMS
    for icw = 1:ncw
        par(im, icw).xRaw = cw.x;
        par(im, icw).y = cw.y;
    end
end

%% Field offset for fit with two spin systems
wbar = waitbar(0, 'Performing least-square fitting', ...
    'Name', 'esfit in progress');
for icw = 1:ncw
    xRaw_ = par(1, icw).xRaw; y_ = par(1, icw).y;
    Exp.Range = [min(xRaw_) max(xRaw_)];
    FitSlice = par(:, icw).Fit;
    parfor im = 1:NUM_M_PARAMS
        Fit_ = esfit(y_, @pepperFieldOffset, {Sys, Exp}, {Vary});
        FitSlice(im) = Fit_;

        waitbar(icw/ncw + im/NUM_M_PARAMS, wbar)
    end
    for im = 1:NUM_M_PARAMS
        par(im, icw).Fit = FitSlice(im);
    end
end
delete(wbar)
%%
Opt.SFolder = 'D:\Profile\qse\Files\_EDMRoC pinSC\New chip';
% saveStr = input('Export data to .mat file? y/n\n', 's');
saveStr = 'y';
if strcmp(saveStr, 'y')
    save([Opt.SFolder, '\fit_chip_parfor_m_param'], 'par');
    % exportgraphics(gcf, [Opt.SFolder, '/2022-06-17 cwEDMR forward bias.png'])
else
    disp('Data not exported')
end