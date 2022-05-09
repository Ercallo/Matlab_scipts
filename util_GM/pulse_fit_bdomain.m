%% General script for fit of pEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.LName = 'p20K';
Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\PEDMR\data_analysis';
Opt.LPath = [Opt.LFolder, '\', Opt.LName, '_exp_fit.mat'];

Opt.SFolder = Opt.LFolder;
Opt.SPath = [Opt.SFolder, '\', Opt.LName, '_bdomain_fit.mat'];

Opt.SaveFig = false;

% Import
load(Opt.LPath); 
y = ExpFit.zfit; % The exponential fit that will be esfitted

%%
[tLen, BLen] = size(y);

tInit = 600;
tIdx = 1:tLen >= tInit; % No background signal influence

BIdx = B == B;

tF = t(tIdx); BF = B(BIdx); yF = y(tIdx, BIdx); % Quantities for fit
ScrollableLayout(tF, BF, yF);

%%
Sys0 = struct('g', 2.005, ...
    'lw', [0 1.5]);

Vary0 = struct('g', 0.004, ...
    'lw', Sys0.lw);

Opt.Fit = struct('Method', 'simplex fcn', ... 
    'Scaling', 'lsq', ... % No baseline
    'TolFun', 1e-3, ... % Termination criterion
    'PrintLevel', 0);

%%
yfit = y;
Sys = esfit(@pepper, yF(i, :), Sys0, Vary0, Exp, [], Opt.Fit);
Sys = repmat(Sys, tLen - tInit, 1);
% for i=1:tLen - tInit
for i = 1:tLen - tInit
    [Sys(i), yfit(i, :)] =  esfit(@pepper, yF(i, :), Sys0, Vary0, Exp, [], Opt.Fit);
end

%%
ScrollableLayout(tF, BF, yF, struct('zfit', yfit(1:40, :), 'hfit', 'h1'));