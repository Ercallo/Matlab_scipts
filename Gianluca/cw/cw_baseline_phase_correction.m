%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\Files\soft\software\Matlab'));

% File and Run options
% Opt.Load.Name0 = '013_1p0V_10KHz_3G_25K_10Scan_0Deg_Light.DTA';
% Opt.Load.Name90 = '013_1p0V_10KHz_3G_25K_10Scan_90Deg_Light.DTA';
Opt.LName = '005_cw_11K_1p2mod_12db_10scans.DTA';
Opt.SName = 'cw11K';

Opt.LFolder = 'D:\Profile\qse\Files\_NREL\2022_spring\20220301';
% Opt.Load.Path0 = strjoin({Opt.Load.Folder, Opt.Load.Name0}, '\');
% Opt.Load.Path90 = strjoin({Opt.Load.Folder, Opt.Load.Name90}, '\');
Opt.LPath = [Opt.LFolder, '\', Opt.LName];

Opt.SFolder = [Opt.LFolder, '\', 'data_analysis'];
Opt.SPath = [Opt.SFolder, '\', Opt.SName, '_BlcPc.mat'];

Opt.Run.Blc = true;
Opt.Run.Pc = true;
Opt.Run.ManualPc = true;
Opt.Run.SaveFig = false;

% Import
% [B, Spc, Params] = eprloadQuad(Opt.Load.Path0, Opt.Load.Path90);
[B, Spc, Params] = eprload(Opt.LPath);

B = B(10:end)';
Spc = Spc{1, 1} + 1i*Spc{1, 2};
Spc = Spc(10:end)';

% Field offset
Boffset = 1.91;
B = (B - Boffset)/10; % mT

%% Baseline correction
Opt.Bc.Range = [1, 200];
Opt.Bc.Range1 = [numel(B) - 200, numel(B)];
Opt.Bc.Order = 2;

if Opt.Run.Blc || ~isfile(strjoin({Opt.Save.PathMat, 'mat'}, '.'))
    [Blc, Bl] = baselineSubtractionPolyfit(B, Spc, Opt.Bc);
else
    BlcPcLoad = load(Opt.Save.PathMat, 'BlcPc');
    Spc = BlcPcLoad.BlcPc.Spc;
    Blc = BlcPcLoad.BlcPc.SpcBlc; Bl = BlcPcLoad.BlcPc.Bl;
end

figure()
t = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile, plot(B, real(Spc), 'k', B, real(Bl));
xline(B(Opt.Bc.Range(2))); xline(B(Opt.Bc.Range1(1))); 
xlim([min(B) max(B)]);
legend('raw data 0°', 'baseline');
nexttile, plot(B, imag(Spc), 'k', B, imag(Bl));
xline(B(Opt.Bc.Range(2))); xline(B(Opt.Bc.Range1(1))); 
xlim([min(B) max(B)]); 
legend('raw data 90°', 'baseline');
nexttile, plot(B, real(Blc), 'k'); xlim([min(B) max(B)]);
legend('Blc data 0°');
nexttile, plot(B, imag(Blc), 'k'); xlim([min(B) max(B)]);
legend('Blc data 90°');
xlabel(t, 'Magnetic field [mT]', 'Fontsize', 16);
ylabel(t, 'Signal [V]', 'Fontsize', 16);

if Opt.Run.SaveFig
    Opt.Save.FigName = strjoin({Opt.Save.Name, 'f0_baseline'}, '_'); % .png
    Opt.Save.FigPath = strjoin({Opt.Save.Folder, Opt.Save.FigName}, '\');
    saveas(t, Opt.Save.FigPath, 'png')
end

%% Manual phase correction
if Opt.Run.ManualPc
    model = @(p) Blc * exp(1i*p*pi/180);
    PcArray = zeros(numel(B), 181); % Array of phase corrected data
    for i = -90:90
        PcArray(:,90 + i + 1) = model(i*1);
    end
    figure()
    p0 = 0; % Phase at which the scrollable starts
    h1 = ScrollableAxes('Index', 91 + p0); 
    plot(h1, B', -90:90, real(PcArray));
    hold on
    plot(h1, B', -90:90, imag(PcArray));
end

%% Phase correction
if Opt.Run.Pc || ~isfile(strjoin({Opt.Save.PathMat, 'mat'}, '.'))
    % Baseline and phase corrected (BlcPc) spectrum
    [BlcPc, Phase] = correctPhaseMaxima(Blc, -85);
else
    BlcPcLoad = load(Opt.Save.PathMat, 'BlcPc');
    BlcPc = BlcPcLoad.BlcPc.SpcBlcPc; Phase = BlcPcLoad.BlcPc.Phase;
end

f = figure();
plot(B, real(BlcPc), 'k', B, imag(BlcPc)); xlim([min(B) max(B)]);
xlabel('Magnetic field [mT]', 'Fontsize', 16); ylabel('Signal [V]', 'Fontsize', 16);
legend('channel 1', 'channel 2');
if Opt.Run.SaveFig
    Opt.Save.FigName = strjoin({Opt.Save.Name, 'f1_phase_2chs'}, '_');
    Opt.Save.FigPath = strjoin({Opt.Save.Folder, Opt.Save.FigName}, '\');
    saveas(f, Opt.Save.FigPath, 'png');
end

f = figure();
plot(B, real(BlcPc), 'k'); xlim([min(B) max(B)]);
xlabel('Magnetic field [mT]', 'Fontsize', 16); ylabel('Signal [V]', 'Fontsize', 16);
if Opt.Run.SaveFig
    Opt.Save.FigName = strjoin({Opt.Save.Name, 'f2_final'}, '_'); % .png
    Opt.Save.FigPath = strjoin({Opt.Save.Folder, Opt.Save.FigName}, '\');
    saveas(f, Opt.Save.FigPath, 'png');
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
Data.Exp.mwFreq = Params(1).MWFQ * 1e-09; % GHz
Data.Exp.Range = [min(B) max(B)];

save(Opt.SPath, '-struct', 'Data') 