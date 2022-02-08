%% CWEDMR analysis for reverse bias 1V under illumination at 30K
% 1. Baseline correction
% 2. Phase correction
% 3. Fit of Pb0, Db-like
clearvars, close all

%% Import
file0 = dir('001_1p0V_10KHz_3G_30K_10Scan_0Deg_Light.DTA');
file90 = dir('001_1p0V_10KHz_3G_30K_10Scan_90Deg_Light.DTA');
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


% %% Fit 001 30K reverse 1V
% % Dangling Bond:
% Sys.S = 1/2;
% Sys.g = 2.0062;
% Sys.lw = [0.1 1.8];
% 
% Vary.g = 0.01;
% Vary.lw = [0.1 1.8];
% 
% % Fitting the integral of the signal cuts the contribution of the high
% % frequencies. It makes more sense to fit the data as it is.
% FitOpt.Method = 'simplex fcn';
% FitOpt.maxTime = 0.2;
% 
% i = 1;
% Exp.mwFreq = ((9.740239 + 9.74025)/2 + (9.740556 + 9.740585)/2)/2; % GHz
% Exp.Range = [min(data(i).B) max(data(i).B)]; % Accepts only [Binit Bfin] and not [Bcenter width]
% 
% % esfit('pepper', real(data(i).spcFinal), {Sys, Sys1}, {Vary, Vary1},  Exp, [], FitOpt);
% [fit.params, fit.spc] = esfit('pepper', real(data(i).spcFinal), Sys, ...
%     Vary, Exp, [], FitOpt);
% 
% %% Plot 30K reverse 1V
% figure()
% plot(data(i).B*10, real(data(i).spcFinal), data(i).B*10, fit.spc);
% xlim(Exp.Range*10)
% legend('data', 'bestfit');
% xlabel('B0 [G]')
% ylabel('Normalized signal [a.u.]')

%% Fit 30K reverse 1V
% Pb0:
Sys0.S = 1/2;
Sys0.g = 2.0045;
Sys0.lw = [0.086 1.46];

Vary0.g = 0.001;
Vary0.lw = [0.1 1.8];

% Db2:
Sys1.S = 1/2;
Sys1.g = 2.0085;
Sys1.lw = [0.11 2.84];
Sys1.weight = 1;

Vary1.g = 0.001;
Vary1.lw = [0.1 1.8];
Vary1.weight = 1;

FitOpt.Method = 'simplex fcn';
FitOpt.maxTime = 0.2;

Exp.mwFreq = ((9.7402 + 9.7403)/2 + (9.7406 + 9.7406)/2)/2; % GHz
Exp.Range = [min(data.B) max(data.B)];

% esfit('pepper', data(i).spcFinal, ...
%     {Sys0, Sys1}, {Vary0, Vary1},  Exp, [], FitOpt);
[fit.bestVal, fit.spc] = esfit('pepper', data.spcFinal, ...
    {Sys0, Sys1}, {Vary0, Vary1}, Exp, [], FitOpt);

%% Nice looking plots
fit.yfitPb0 = pepper(fit.bestVal{1,1}, Exp);
fit.yfitDb2 = pepper(fit.bestVal{1,2}, Exp);

normFactor = 1/(max(fit.yfitPb0 + fit.yfitDb2) - ...
    min(fit.yfitPb0 + fit.yfitDb2));
fit.yfitPb0 = normFactor * fit.yfitPb0;
fit.yfitDb2 = normFactor * fit.yfitDb2;

figure()
plot(data.B*10, ...
    data.spcFinal/(max(data.spcFinal) - min(data.spcFinal)), 'k');
hold on
plot(data.B*10, fit.yfitPb0, 'Linewidth', 1.3, 'color', [0, 0.4470, 0.7410])
plot(data.B*10, fit.yfitDb2, 'Linewidth', 1.3, 'color', [0, 0.5, 0]);
title('T = 30K')

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
title('T = 30K')
