%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.Load.Name = '007_30dB.DTA';
Opt.Save.Name = '30dB';

Opt.Load.Folder = 'D:\Profile\qse\NREL\2022_march\220331';
Opt.Load.Path = strjoin({Opt.Load.Folder, Opt.Load.Name}, '\');

Opt.Save.Folder = strjoin({Opt.Load.Folder, 'data_analysis'}, '\');
Opt.Save.Name0 = strjoin({Opt.Save.Name, 'p0_baseline'}, '_'); % .png
Opt.Save.Path0 = strjoin({Opt.Save.Folder, Opt.Save.Name0}, '\');
Opt.Save.Name1 = strjoin({Opt.Save.Name, 'p1_phase'}, '_');
Opt.Save.Path1 = strjoin({Opt.Save.Folder, Opt.Save.Name1}, '\');
Opt.Save.Name2 = strjoin({Opt.Save.Name, 'p2_phase_2chs'}, '_');
Opt.Save.Path2 = strjoin({Opt.Save.Folder, Opt.Save.Name2}, '\');
Opt.Save.NameMat = strjoin({Opt.Save.Name, 'BlcPc'}, '_'); % .mat
Opt.Save.PathMat = strjoin({Opt.Save.Folder, Opt.Save.NameMat}, '\');

Opt.Run.Blc = false;
Opt.Run.Pc = false;
Opt.Run.ManualPc = false;
Opt.Run.SaveFig = true;

% Import
[B, Spc, Params] = eprload(Opt.Load.Path);
% DcCurrent = 230;
B = B';
Spc = Spc{1, 1} + 1i*Spc{1, 2};
Spc = Spc';
B = B(15:end); Spc = Spc(15:end);

% Field offset
Boffset = 5.181;
B = (B - Boffset)/10; % mT

%% Baseline correction
Opt.Bc.Range = [1, 200];
Opt.Bc.Range1 = [numel(B) - 200, numel(B)];
Opt.Bc.Order = 2;

if Opt.Run.Blc || ~isfile(strjoin({Opt.Save.PathMat, 'mat'}, '.'))
    [Blc, Bl] = baselineSubtractionPolyfit(B, Spc, Opt.Bc);
else
    BlcPcLoad = load(Opt.Save.PathMat, 'BlcPc');
    Blc = BlcPcLoad.BlcPc.SpcBlc; Bl = BlcPcLoad.BlcPc.Bl;
end

figure()
t = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile, plot(B, real(Spc), B, real(Bl));
xline(B(Opt.Bc.Range(2))); xline(B(Opt.Bc.Range1(1))); 
xlim([min(B) max(B)]);
legend('raw data 0°', 'baseline');
nexttile, plot(B, imag(Spc), B, imag(Bl));
xline(B(Opt.Bc.Range(2))); xline(B(Opt.Bc.Range1(1))); 
xlim([min(B) max(B)]); 
legend('raw data 90°', 'baseline');
nexttile, plot(B, real(Blc)); xlim([min(B) max(B)]);
legend('Blc data 0°');
nexttile, plot(B, imag(Blc)); xlim([min(B) max(B)]);
legend('Blc data 90°');
xlabel(t, 'B0 [mT]', 'Fontsize', 16);
ylabel(t, 'Signal [V]', 'Fontsize', 16);
if Opt.Run.SaveFig
    saveas(t, Opt.Save.Path0, 'png')
end

%% Manual phase correction
if Opt.Run.ManualPc
    model = @(p) Blc * exp(1i*p*pi/180);
    PcArray = zeros(numel(B), 181); % Array of phase corrected data
    for i=0:180
        PcArray(:,i+1) = model(i*1);
    end
    figure()
    h1 = ScrollableAxes('Index', 90 + 67);
    plot(h1, B', -90:90, real(PcArray));
    hold on
    plot(h1, B', -90:90, imag(PcArray));
end

%% Phase correction
if Opt.Run.Pc || ~isfile(strjoin({Opt.Save.PathMat, 'mat'}, '.'))
    [BlcPc, Phase] = correctPhaseMaxima(Blc, 45); % Baseline and phase corrected 
else
    BlcPcLoad = load(Opt.Save.PathMat, 'BlcPc');
    BlcPc = BlcPcLoad.BlcPc.SpcBlcPc; Phase = BlcPcLoad.BlcPc.Phase;
end

f = figure();
plot(B, imag(BlcPc)); xlim([min(B) max(B)]);
xlabel('B0 [mT]', 'Fontsize', 16); ylabel('Signal [V]', 'Fontsize', 16);
if Opt.Run.SaveFig
    saveas(f, Opt.Save.Path1, 'png');
end

f = figure();
plot(B, imag(BlcPc), B, real(BlcPc)); xlim([min(B) max(B)]);
xlabel('B0 [mT]', 'Fontsize', 16); ylabel('Signal [V]', 'Fontsize', 16);
legend('channel 1', 'channel 2');
if Opt.Run.SaveFig
    saveas(f, Opt.Save.Path2, 'png')
end


%% Save everything into a structure
Data.x = B; % Corrected with calibration
Data.BlcPc.Spc = Spc;
Data.BlcPc.Bl = Bl;
Data.BlcPc.SpcBlc = Blc;
Data.BlcPc.SpcBlcPc = BlcPc;
Data.BlcPc.Phase = Phase;
Data.y = imag(BlcPc); % Imaginary part is almost zero everywhere

% If possible, average initial and final value of mwFreq
Data.Exp.mwFreq = Params(1).MWFQ * 1e-09; % GHz
Data.Exp.Range = [min(B) max(B)];

save(Opt.Save.PathMat, '-struct', 'Data') 