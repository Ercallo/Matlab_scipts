%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.File.Load.Folder = ...
    'D:\Profile\qse\NREL\2022_march\20220311';
Opt.File.Load.Name0 = '005_cw_10K_1p2mod_30db_10scans.DTA';
% Opt.File.Load.Name90 = '004_1p0V_10KHz_3G_40K_10Scan_90Deg_Light.DTA';
Opt.File.Load.Path0 = strjoin({Opt.File.Load.Folder, ...
    Opt.File.Load.Name0}, '\');
% Opt.File.Load.Path90 = strjoin({Opt.File.Load.Folder, 
%     Opt.File.Load.Name90}, '\');

Opt.File.Name = 'cw10K_30db';
Opt.File.Save.Folder = ...
    Opt.File.Load.Folder;
Opt.File.Save.Name0 = strjoin({Opt.File.Name, 'p1_Spc_Bl'}, '_'); % .png
Opt.File.Save.Path0 = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name0}, '\');
Opt.File.Save.Name1 = strjoin({Opt.File.Name, 'p2_Blc_two_sig'}, '_');
Opt.File.Save.Path1 = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name1}, '\');
Opt.File.Save.Name2 = strjoin({Opt.File.Name, 'p3_Blc'}, '_');
Opt.File.Save.Path2 = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name2}, '\');
Opt.File.Save.Name3 = strjoin({Opt.File.Name, 'BlcPc'}, '_'); % .mat
Opt.File.Save.Path3 = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name3}, '\');

Opt.Run.Blc = true;
Opt.Run.Pc = true;
Opt.Run.ManualPc = true;
Opt.Run.SaveFig = true;

% Import
[B, Spc, Params] = eprload(Opt.File.Load.Path0);
% DcCurrent = 230;
B = B';
Spc = Spc{1, 1} + 1i*Spc{1, 2};
Spc = Spc';
B = B(10:end); Spc = Spc(10:end);

% Field offset
Boffset = 5.181;
B = (B - Boffset)/10; % mT

%% Baseline correction
Opt.BlcOpt.Range = [1, 200];
Opt.BlcOpt.Range1 = [numel(B) - 200, numel(B)];
Opt.Bc.Order = 1;

if Opt.Run.Blc || ...
    ~isfile(strjoin({Opt.File.Save.Path, 'mat'}, '.'))
    [Blc, Bl] = baselineSubtractionPolyfit(B, Spc, Opt.Bc);
else
    dummy = load(Opt.File.Save.Path, 'BlcPc');
    Blc = dummy.BlcPc.SpcBlc; Bl = dummy.BlcPc.Bl;
end

figure()
t = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile, plot(B, real(Spc), B, real(Bl));
xline(B(Opt.BlcOpt.Range(2))); xline(B(Opt.BlcOpt.Range1(1))); 
xlim([min(B) max(B)]);
legend('raw data 0°', 'baseline');
nexttile, plot(B, imag(Spc), B, imag(Bl));
xline(B(Opt.BlcOpt.Range(2))); xline(B(Opt.BlcOpt.Range1(1))); 
xlim([min(B) max(B)]); 
legend('raw data 90°', 'baseline');
nexttile, plot(B, real(Blc)); xlim([min(B) max(B)]);
legend('Blc data 0°');
nexttile, plot(B, imag(Blc)); xlim([min(B) max(B)]);
legend('Blc data 90°');
xlabel(t, 'B0 [mT]', 'Fontsize', 16);
ylabel(t, 'Signal [V]', 'Fontsize', 16);
if Opt.Run.SaveFig
    saveas(t, Opt.File.Save.Path0, 'png')
end

%% Manual phase correction
if Opt.Run.ManualPc
    model = @(p) Blc * exp(1i*p*pi/180);
    dummy = zeros(numel(B), 181);
    for i=0:180
        dummy(:,i+1) = model(i*1);
    end
    figure()
    h1 = ScrollableAxes();
    plot(h1, B', 0:180, real(dummy));
    hold on
    plot(h1, B', 0:180, imag(dummy));
end

%% Phase correction
if Opt.Run.Pc ||  ...
        ~isfile(strjoin({Opt.File.Save.Path, 'mat'}, '.'))
    [BlcPc, Phase] = correctPhase(Blc); % Baseline and phase corrected 
else
    dummy = load(Opt.File.Save.Path, 'BlcPc');
    BlcPc = dummy.BlcPc.SpcBlcPc; Phase = dummy.BlcPc.Phase;
end
f = figure();
plot(B, real(BlcPc), B, imag(BlcPc)); xlim([min(B) max(B)]);
xlabel('B0 [mT]', 'Fontsize', 16); ylabel('Signal [V]', 'Fontsize', 16);
legend('channel 1', 'channel 2');
if Opt.Run.SaveFig
    saveas(f, Opt.File.Save.Path1, 'png')
end

f = figure();
plot(B, real(BlcPc)); xlim([min(B) max(B)]); xlim([min(B) max(B)]);
xlabel('B0 [mT]', 'Fontsize', 16); ylabel('Signal [V]', 'Fontsize', 16);
if Opt.Run.SaveFig
    saveas(f, Opt.File.Save.Path2, 'png');
end

%% Save everything into a structure
Data.x = B; % Corrected with calibration
Data.BlcPc.Spc = Spc;
Data.BlcPc.Bl = Bl;
Data.BlcPc.SpcBlc = Blc;
Data.BlcPc.SpcBlcPc = BlcPc;
Data.BlcPc.Phase = Phase;
Data.y = real(BlcPc); % Imaginary part is almost zero everywhere

% If possible, average initial and final value of mwFreq
Data.Exp.mwFreq = Params(1).MWFQ * 1e-09;
Data.Exp.Range = [min(B) max(B)];

save(Opt.File.Save.Path3, '-struct', 'Data') 