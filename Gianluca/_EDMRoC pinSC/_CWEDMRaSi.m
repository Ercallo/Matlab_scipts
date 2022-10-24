clearvars, close all

%% Import
files0deg = dir('*_0deg.DTA');
files90deg = dir('*_90deg.DTA');
data = struct();

% The measurements at 1p1V, 1p2V, 1p3V were performed twice, therefore the
% measurements 006, 007, 008 can be ignored (they show a worst signal)
files0deg = [files0deg(1:5); files0deg(9:end)];
files90deg = [files90deg(1:5); files90deg(9:end)];

for i=1:length(files0deg)
    [data(i).B, data(i).spcRaw, data(i).Params] = ...
        eprloadQuad(files0deg(i).name, files90deg(i).name);
    % Field offset (obtained from 013_calibration_NC60 in this same folder)
    % and conversion to mT
    data(i).B = (data(i).B - 1.763)/10; 
    newStr = strsplit(files0deg(i).name, '_');
    data(i).title = newStr(2);
end

%% Baseline and phase correction
Opt.range = [1, 90];
Opt.range1 = [910, 1024];
Opt.order = 1;

for i=1:length(files0deg)
    [data(i).blc, data(i).bl] = ...
        baselineSubtractionPolyfit(data(i).B, data(i).spcRaw, Opt);
    figure()
    title(data(i).title)
    subplot(2,2,1)
    plot(data(i).B, real(data(i).spcRaw), data(i).B, real(data(i).bl))
    xline(data(i).B(Opt.range(2)))
    xline(data(i).B(Opt.range1(1)))
    legend('raw data 0 deg', 'baseline')
    subplot(2,2,3)
    plot(data(i).B, real(data(i).blc))
    legend('blc data 0 deg')
    subplot(2,2,2)
    plot(data(i).B, imag(data(i).spcRaw), data(i).B, imag(data(i).bl))
    xline(data(i).B(Opt.range(2)))
    xline(data(i).B(Opt.range1(1)))
    legend('raw data 90 deg', 'imaginary part baseline')
    subplot(2,2,4)
    plot(data(i).B, imag(data(i).blc))
    legend('blc data 90 deg')
end

%% Phase correction
for i=1:length(files0deg)
    [data(i).spc, data(i).phase] = correctPhase(data(i).blc);
    figure()
    plot(data(i).B, real(data(i).spc))
    % hold on
    % plot(data(i).B, imag(data(i).spc))
    title(data(i).title)
    xlabel('B0 [G]', 'FontSize', 12)
    ylabel('Signal [a.u.]', 'FontSize', 12)
    xlim([data(i).B(1), data(i).B(end)])
end

%% Some phase corrections are not good
y = data(5).blc;
model = @(p) y * exp(1i*p*pi/180);
dummy = zeros(numel(data(1).B), 73);
for i=0:72
    dummy(:,i+1) = model(i*5);
end
figure('visible', 'off')
h1 = ScrollableAxes();
plot(h1, data(5).B, -36:36, real(dummy));
hold on
plot(h1, data(5).B, -36:36, imag(dummy));

%% Fit
% Dangling Bond
Sys.S = 1/2;
Sys.g = [2.0079 2.0061 2.0034];% Value from the literature
Sys.gStrain = [0.0054 0.0022 0.0018];
Sys.A = [151 269]; % MHz
% Sys.lw = [0.7522 1.0291]; % mT [Gaussian Lorentzian]
Sys.lw = [0.7522 1.0291];
Sys.Nucs = 'Si';

% VBT
Sys1.S = 1/2;
Sys1.g = [2.0140 2.0124 2.0047];
Sys1.gStrain = [0.0086 0.0039 0.0025];
% Sys1.lw = [0.6 0.87];
Sys1.lw = [0.6 0.87];
Sys1.weight = 1;

% Sys.S = 1/2;
% Sys.g = [2.0146 2.0045 2.0044]; % Value from the literature
% Sys.A = [151 269]; % MHz
% Sys.lw = [1.009 0.8851]; % mT [Gaussian Lorentzian]
% Sys.Nucs = 'Si';

% Vary.g = [0.01, 0.01, 0.01];
Vary.lw = [0.2 0.2];
Vary.gStrain = [0.001 0.001 0.001];
% Vary.A = [50 50];

% Vary1.g = [0.01, 0.01, 0.01];
Vary1.lw = [0.2 0.2];
Vary1.gStrain = [0.001 0.001 0.001];
Vary1.weight = 1;
% Vary1.A = [50 50];


for i=6:6
    % Parameters of the experiment
    Exp.mwFreq = 9.6055875; % GHz
    Exp.Range = [min(data(i).B) max(data(i).B)]; % Accepts only [Binit Bfin] and not [Bcenter width]
    esfit('pepper', real(data(i).spc), {Sys, Sys1}, {Vary, Vary1},  Exp);
end

%% Symulation
Exp.Range = [320 360];
pepper(Sys, Exp)