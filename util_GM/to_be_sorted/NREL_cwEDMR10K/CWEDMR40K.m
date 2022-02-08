%% CWEDMR analysis for the spectrum in reverse bias at 30K.
% The data at 40K is not good: the phase correction is not well performed
% and a lot of parameters are missing in the Parameters.ods file.
% 1. Baseline correction
% 2. Phase correction
% 3. Fit of Dangling bond
clearvars, close all

%% Import
files0degL = dir('004_1p0V_10KHz_3G_40K_10Scan_0Deg_Light.DTA');
files90degL = dir('004_1p0V_10KHz_3G_40K_10Scan_90Deg_Light.DTA');
data = struct();

for i=1:length(files0degL)
    [data(i).BRaw, data(i).spcRaw, data(i).Params] = ...
        eprloadQuad(files0degL(i).name, files90degL(i).name);
    % Field offset (obtained from 20210613/NaC60_Field_Calibration) 
    % and conversion to mT
    data(i).spc = data(i).spcRaw(:);
    data(i).B = (data(i).BRaw(:) - 1.911)/10; 
    newStr = strsplit(files0degL(i).name, {'_', '.'});
    data(i).title = join([newStr(end-1), newStr(2), newStr(5)]);
end

%% Baseline and phase correction
Opt.range = [1, 200];
Opt.range1 = [numel(data(1).B) - 200, numel(data(1).B)];
Opt.order = 2;

for i=1:length(files0degL)
    [data(i).blc, data(i).bl] = ...
        baselineSubtractionPolyfit(data(i).B, data(i).spc, Opt);
    figure()
    subplot(2,2,1)
    plot(data(i).B, real(data(i).spc), data(i).B, real(data(i).bl))
    xline(data(i).B(Opt.range(2)))
    xline(data(i).B(Opt.range1(1)))
    xlim([min(data(i).B) max(data(i).B)])
    legend('raw data 0 deg', 'baseline')
    subplot(2,2,3)
    plot(data(i).B, real(data(i).blc))
    xlim([min(data(i).B) max(data(i).B)]) 
    legend('blc data 0 deg')
    subplot(2,2,2)
    plot(data(i).B, imag(data(i).spc), data(i).B, imag(data(i).bl))
    xline(data(i).B(Opt.range(2)))
    xlim([min(data(i).B) max(data(i).B)])
    xline(data(i).B(Opt.range1(1)))
    legend('raw data 90 deg', 'imaginary part baseline')
    subplot(2,2,4)
    plot(data(i).B, imag(data(i).blc))
    xlim([min(data(i).B) max(data(i).B)])
    legend('blc data 90 deg')
    sgtitle(data(i).title)
end

%% Phase correction
for i=1:length(files0degL)
    [data(i).spcFinal, data(i).phase1] = correctPhase(data(i).blc);
    figure()
    plot(data(i).B, real(data(i).spcFinal))
    hold on
    plot(data(i).B, imag(data(i).spcFinal))
    title(data(i).title)
end

%% Some phase corrections are not good
y = data(1).blc;
model = @(p) y * exp(1i*p*pi/180);
dummy = zeros(numel(data(1).B), 73);
for i=0:72
    dummy(:,i+1) = model(i*5);
end
figure()
h1 = ScrollableAxes();
plot(h1, data(1).B, -36:36, real(dummy));
hold on
plot(h1, data(1).B, -36:36, imag(dummy));

%%
i = 1;
data(i).spcFinal = model(50);
figure()
plot(data(i).B, real(data(i).spcFinal))
hold on
plot(data(i).B, imag(data(i).spcFinal))
title(data(i).title)
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

%% Fit 001 40K reverse 1V
% Dangling Bond:
Sys.S = 1/2;
Sys.g = 2.00475;
Sys.lw = [0.086 1.46];

% Dangling Bond:
Sys1.S = 1/2;
Sys1.g = 2.006;
Sys1.lw = [0.11 2.84];
Sys1.weight = 1;

Vary.g = 0.01;
Vary.lw = [0.1 1.8];

Vary1.g = 0.01;
Vary1.lw = [0.1 1.8];
Vary1.weight = 1;

% Fitting the integral of the signal cuts the contribution of the high
% frequencies. It makes more sense to fit the data as it is.
FitOpt.Method = 'simplex fcn';
FitOpt.maxTime = 0.2;

i = 1;
Exp.mwFreq = ((9.740239 + 9.74025)/2 + (9.740556 + 9.740585)/2)/2; % GHz
Exp.Range = [min(data(i).B) max(data(i).B)]; % Accepts only [Binit Bfin] and not [Bcenter width]

esfit('pepper', real(data(i).spcFinal), {Sys, Sys1}, {Vary, Vary1},  Exp, [], FitOpt);
% [fit.params, fit.spc] = esfit('pepper', real(data(i).spcFinal), {Sys, Sys1}, ...
%    {Vary, Vary1}, Exp, [], FitOpt);

%% Plot 30K reverse 1V
figure()
plot(data(i).B*10, real(data(i).spcFinal), data(i).B*10, fit.spc);
xlim(Exp.Range*10)
legend('data', 'bestfit');
xlabel('B0 [G]')
ylabel('Normalized signal [a.u.]')

%%
yfitDb = pepper(fit.params{1,1}, Exp);
yfitE = pepper(fit.params{1,2}, Exp);

normFactor = 1/(max(yfitDb + yfitE) - min(yfitDb + yfitE));
yfitDb = normFactor * yfitDb;
yfitE = normFactor * yfitE;

figure()
plot(data(i).B*10, real(data(i).spcFinal)/(max(real(data(i).spcFinal)) - min(real(data(i).spcFinal))), 'k');
hold on
plot(data(i).B*10, yfitDb, 'color', [0, 0.4470, 0.7410])
plot(data(i).B*10, yfitE, 'color', [0, 0.5, 0]);
title('T = 30K')
    
legend('data', 'fit Pb0', 'fit db-like defect')
xlabel('B0 [G]', 'FontSize', 14)
ylabel('Normalized signal [a.u.]', 'FontSize', 14)
xlim(Exp.Range*10)

figure()
plot(data(i).B*10, real(data(i).spcFinal)/(max(real(data(i).spcFinal)) - min(real(data(i).spcFinal))), 'k')
hold on
plot(data(i).B*10, fit.spc/(max(fit.spc) - min(fit.spc)), 'color', '#D95319')
legend('data', 'fit')
xlabel('B0 [G]', 'FontSize', 14)
ylabel('Normalized signal [a.u.]', 'FontSize', 14)
xlim(Exp.Range*10)
title('T = 30K')
