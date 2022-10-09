%% Esfit field calibration
clearvars, clear, clc, close all
folder = 'D:\Profile\qse\NREL\2021_Summer\CWEDMR\';
filename = '018_calibration_NaC60_288K.DTA';
[B, Spc, Params] = eprload(strjoin({folder, filename}, ''));
B = B'/10;
Spc = Spc'; 

%% METHOD 1. pepperFieldOffset
% System
Sys.S = 3/2;
Sys.g = 2.00211; % Value from the literature
Sys.A = 15.9173; % MHz
Sys.lw = [0.009 0.0199]; % mT [Gaussian Lorentzian]
Sys.Nucs = 'N';
Sys.FieldOffset = 0.18; % mT

% Parameter ranges
Vary.lw = [0.01 0.01];
Vary.FieldOffset = 0.05;

% Parameters of the experiment
Exp.mwFreq = Params.MWFQ*1e-09; % GHz
Exp.Range = [min(B) max(B)]; % Accepts only [Binit Bfin] and not [Bcenter width]

%% Perform fit
% esfit('pepperFieldOffset', Spc, Sys, Vary, Exp);
[BestVal, yfit] = esfit('pepperFieldOffset', Spc, Sys, Vary, Exp);

figure()
plot(B, Spc, B, yfit);
legend('data', 'bestfit')

%% Save
NatC60.B = B; %mT
NatC60.Spc = Spc;
NatC60.Exp = Exp;
NatC60.Sys = BestVal;
NatC60.yfit = yfit;
NatC60.Vary = Vary;

save(strjoin({folder, '210622_field_calibration.mat'}, ''), 'NatC60')

%%
%{
%% METHOD 2. Difference of g-values
% In this method the g-value is obtained from esfit and then the difference
% between this value and the one from the literature is used to get the
% magnetic field offset.
% System
Sys.S = 3/2;
Sys.g = 2.00211;
Sys.A = 15.9173; % MHz
Sys.lw = [0.009 0.0199]; % mT [Gaussian Lorentzian]
Sys.Nucs = 'N';

% Parameter ranges
Vary.g = 0.002;
Vary.lw = [0.01 0.01];

% Parameters of the experiment
Exp.mwFreq = Params.MWFQ*1e-09; % GHz
Exp.Range = [min(data.B)/10 max(data.B)/10]; % Accepts only [Binit Bfin] and not [Bcenter width]

% Sys2 is to be used if there is another signal, not belonging to NaC60, to 
% be fitted. Fitting this signal is not essential nor interesting and 
% can definitely be avoided.
%{
Sys2.S = 1/2;
Sys2.g = 2.00241;
Sys2.lw = [0.080 0.1597];
Sys2.weight = 63.49;

Vary2.g = 0.001;
Vary2.lw = [0.05 0.05];
Vary2.weight = 10;
%}
%%
esfit('pepper', data.spc, Sys, Vary,  Exp);
% esfit('pepper', data.spc, {Sys, Sys2}, {Vary, Vary2},  Exp);

%% ´
% Manually save the best-fit parameters using the GUI (usual name of the
% structure is: fit1) and store it in SysFit2
SysFit2 = ;

%%
bestfit2 = pepperFieldOffset(SysFit2, Exp);

figure()
plot(data.B, data.spc / ((max(data.spc) - min(data.spc))));
hold on
plot(data.B, bestfit2 / ((max(bestfit2) - min(bestfit2))));
legend('data', 'bestfit')

%% Field Offset
% B_meas = (h * nu) / (mu * g_meas)
% B_lit = (h * nu) / (mu * g_lit)
% dB = B_meas - B_lit = (h * nu / mu) * (1 / g_meas - 1 / g_lit)
FieldOffset2 = planck * Params.MWFQ / bmagn * ...
    (1 / SysFit2.g - 1 / Sys1.g); %mT
%}