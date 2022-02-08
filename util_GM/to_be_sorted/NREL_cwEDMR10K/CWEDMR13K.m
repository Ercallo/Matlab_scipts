%% CWEDMR analysis for reverse bias at 13K
% 1. Baseline correction
% 2. Phase correction
% 3. Fit of Phosphorous, Pb0, Db-like
% 4. Double integral
clearvars, close all

%% Import
file0 = dir('011_1p0V_10KHz_1p2G_13K_10Scan_0Deg_Light.DTA');
file90 = dir('011_1p0V_10KHz_1p2G_13K_10Scan_90Deg_Light.DTA');
[data.BRaw, data.spc, data.Params] = eprloadQuad(file0.name, file90.name);
data.title = strrep(strrep(file0.name, '0Deg_', ''), '_', ' ');

%% Field offset 
% Field offset(obtained from NaC60_Field_Calibration in this same 
% folder) and conversion to mT
data.B = (data.BRaw(:) - 5.181)/10;

%% Baseline and phase correction
Opt.range = [1, 200];
Opt.range1 = [numel(data(1).B) - 200, numel(data(1).B)];
Opt.order = 1;

[data.blc, data.bl] = baselineSubtractionPolyfit(data.B, data.spc, Opt);

figure()
subplot(2,2,1)
plot(data.B, real(data.spc), data.B, real(data.bl))
xline(data.B(Opt.range(2)))
xline(data.B(Opt.range1(1)))
xlim([min(data.B) max(data.B)])
legend('raw data 0 deg', 'baseline')
subplot(2,2,3)
plot(data.B, real(data.blc))
xlim([min(data.B) max(data.B)])
legend('blc data 0 deg')
subplot(2,2,2)
plot(data.B, imag(data.spc), data.B, imag(data.bl))
xline(data.B(Opt.range(2)))
xlim([min(data.B) max(data.B)])
xline(data.B(Opt.range1(1)))
legend('raw data 90 deg', 'imaginary part baseline')
subplot(2,2,4)
plot(data.B, imag(data.blc))
xlim([min(data.B) max(data.B)])
legend('blc data 90 deg')
sgtitle(data.title)

%% Phase correction
[data.spcFinalComplex, data.phase] = correctPhase(data.blc);
data.spcFinal = real(data.spcFinalComplex);

figure()
plot(data.B, real(data.spcFinalComplex))
hold on
plot(data.B, imag(data.spcFinalComplex))
xlim([min(data.B) max(data.B)])
legend('real part', 'imaginary part')
title(data.title)

%% Fit
% 31P: 
Sys0.S = 1/2;
Sys0.g = 1.9986;
Sys0.A = 117; % MHz
Sys0.lw = [0.0103 0.6795]; % mT [Gaussian Lorentzian]
Sys0.Nucs = 'P';

Vary0.g = [0.001];
Vary0.lw = [0.001 0.01];

% Pb0:
Sys1.S = 1/2;
Sys1.g = 2.0049;
Sys1.lw = [0.00 1.4383];
Sys1.weight = 1.8;

Vary1.g = 0.01;
Vary1.lw = [0.00 0.5];
Vary1.weight = 3;

% Db2:
Sys2.S = 1/2;
Sys2.g = 2.0048;
Sys2.lw = [4.4 0.0];
Sys2.weight = 1.5;

Vary2.g = 0.006;
Vary2.lw = [0.5 0.0];
Vary2.weight = 1.5;

FitOpt.Method = 'simplex fcn';
FitOpt.maxTime = 1;

Exp.mwFreq = 9.7252; % GHz
Exp.Range = [min(data.B) max(data.B)];

% esfit('pepper', data.spcFinal, ...
%     Sys0, Vary0, Exp, [], FitOpt);
esfit('pepper', data.spcFinal, ... 
    {Sys0, Sys1, Sys2}, {Vary0, Vary1, Vary2}, Exp, [], FitOpt);
% [fit.bestVal, fit.spc] = esfit('pepper', data.spcFinal, ...
%    {Sys0, Sys1, Sys2}, {Vary0, Vary1, Vary2}, Exp, [], FitOpt);

%% Nice looking plots
fit.yfitP = pepper(fit.bestVal{1,1}, Exp);
fit.yfitPb0 = pepper(fit.bestVal{1,2}, Exp);
fit.yfitDb2 = pepper(fit.bestVal{1,3}, Exp);

normFactor = 1/(max(fit.yfitP + fit.yfitPb0 + fit.yfitDb2) - ...
    min(fit.yfitP + fit.yfitPb0 + fit.yfitDb2));
fit.yfitP = normFactor * fit.yfitP;
fit.yfitPb0 = normFactor * fit.yfitPb0;
fit.yfitDb2 = normFactor * fit.yfitDb2;

figure()
plot(data.B*10, ...
    data.spcFinal/(max(data.spcFinal) - min(data.spcFinal)), 'k');
hold on
plot(data.B*10, fit.yfitP,  'Linewidth', 1.3, 'color', [1, 0, 0])
plot(data.B*10, fit.yfitPb0, 'Linewidth', 1.3, 'color', [0, 0.4470, 0.7410])
plot(data.B*10, fit.yfitDb2, 'Linewidth', 1.3, 'color', [0, 0.5, 0]);
title('T = 13K')

legend('data', 'fit Pb0', 'fit db-like defect')
xlabel('B0 [G]', 'FontSize', 14)
ylabel('Normalized signal [a.u.]', 'FontSize', 14)
xlim(Exp.Range*10)

figure()
plot(data.B*10, ...
    data.spcFinal/(max(data.spcFinal) - min(data.spcFinal)), 'k');
hold on
plot(data.B*10, fit.spc/(max(fit.spc) - min(fit.spc)), ...
    'Linewidth', 1.3, 'color', '#D95319')
legend('data', 'fit')
xlabel('B0 [G]', 'FontSize', 14)
ylabel('Normalized signal [a.u.]', 'FontSize', 14)
xlim(Exp.Range*10)
title('T = 13K')

%% Double integral
DI.P = cumtrapz(cumtrapz(fit.yfitP));
DI.nP = DI.P(end);
DI.Pb = cumtrapz(cumtrapz(fit.yfitPb0));
DI.nPb = DI.Db(end);
DI.Db2 = cumtrapz(cumtrapz(fit.yfitDb2));
DI.nDb2 = DI.E(end);

DI.PDb = DI.nP/DI.nDb;
DI.PE = DI.nP/DI.nE;