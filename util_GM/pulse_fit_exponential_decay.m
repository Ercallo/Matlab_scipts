%% General script for fit of pEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.LName = 'p20K';
Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\PEDMR\data_analysis';
Opt.LPath = [Opt.LFolder, '\', Opt.LName, '_Blc.mat'];

Opt.SFolder = Opt.LFolder;
Opt.SPath = [Opt.SFolder, '\', Opt.LName, '_exp_fit.mat'];

Opt.SaveFig = false;

% Import
load(Opt.LPath);

%%
[tLen, BLen] = size(z);

tInit = 600;
tIdx = 1:tLen >= tInit; % No background signal influence

BIdx = B == B;

tF = t(tIdx); BF = B(BIdx); zF = z(tIdx, BIdx); % Quantities for fit
ScrollableLayout(tF, BF, zF);

%% Exponential fit of decays for every B value
% Fit function: y = a*exp(-x(tau)).
p0 = 5000; % Initial value of tau
Opt.OptExpFit = optimset('display', 'off');
zfit = zF; % Fit decays
% [TauF, AmpF] = deal(zeros(Fwhm + 1, 1)); % Fit params
[TauF, AmpF] = deal(zeros(BLen, 1));

% for i=1:(Fwhm + 1)
for i=1:BLen
    TauF(i) = lsqnonlin(@(p) zF(:, i) - lmdivideExp(tF, zF(:, i), p), ...
         p0, [],[], Opt.OptExpFit);
    
    % Get the amplitude for the fit result.
    [zfit(:, i), AmpF(i)] = lmdivideExp(tF, zF(:,i), TauF(i));
end
%%
ScrollableLayout(tF, BF, zF, struct('zfit', zfit, 'hfit', 'h4'));

%% 
[Bp, BpIdx] = max(z(tInit, :)); % Peak in B-domain
Fwhm = 30;
BpRange = BpIdx + Fwhm/2*[-1 1];

BIdx = (1:BLen <= BpRange(2)) & (1:BLen >= BpRange(1));
TauMean = mean(TauF(BIdx));


%%
Data = load(Opt.LPath);
Data.ExpFit.BpRange = BpRange;
Data.ExpFit.tInit = tInit;
Data.ExpFit.zfit = zfit;
Data.ExpFit.TauF = TauF;
Data.ExpFit.AmpF = AmpF;
Data.ExpFit.TauMean = TauMean;

save(Opt.SPath, '-struct', 'Data');

%% Linear/non-linear fitting model
function [yfit, amplitude] = lmdivideExp(x, y, tau)
% First calculate the exponential without scaling, then fit the linear
% scaling parameter.
yfit = exp(-x/tau);
amplitude = yfit(:) \ y(:); % Solve linear equation: yfit * amplitude = y.
yfit = yfit * amplitude;
end