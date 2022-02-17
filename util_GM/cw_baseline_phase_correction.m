%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('/home/gianluca/matlab_util'));

% File and Run options
Opt.File.Load.Folder = ...
    '/home/gianluca/matlab_util/util_GM/to_be_sorted/NREL_cwEDMR10K';
Opt.File.Load.Name0 = '004_1p0V_10KHz_3G_40K_10Scan_0Deg_Light.DTA';
Opt.File.Load.Name90 = '004_1p0V_10KHz_3G_40K_10Scan_90Deg_Light.DTA';
Opt.File.Load.Path0 = strjoin({Opt.File.Load.Folder, ...
    Opt.File.Load.Name0}, '/');
Opt.File.Load.Path90 = strjoin({Opt.File.Load.Folder, 
    Opt.File.Load.Name90}, '/');

Opt.File.Save.Folder = ...
    '/home/gianluca/matlab_util/util_GM/cwEDMR_summer_1ordBl';
Opt.File.Save.Name = 'cw40K_BlcPc';
Opt.File.Save.Path = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name}, '/');

Opt.Run.Blc = false;
Opt.Run.Pc = false;
Opt.Run.ManualPc = false;

% Import
[B, Spc, Params] = eprloadQuad(Opt.File.Load.Path0, Opt.File.Load.Path90);

B = B';
Spc = Spc';

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
subplot(2,2,1); plot(B, real(Spc), B, real(Bl));
xline(B(Opt.BlcOpt.Range(2))); xline(B(Opt.BlcOpt.Range1(1))); 
xlim([min(B) max(B)]);
legend('raw data 0 deg', 'baseline');
subplot(2,2,2); plot(B, imag(Spc), B, imag(Bl));
xline(B(Opt.BlcOpt.Range(2))); xline(B(Opt.BlcOpt.Range1(1))); 
xlim([min(B) max(B)]); 
legend('raw data 90 deg', 'imaginary part baseline');
subplot(2,2,3); plot(B, real(Blc)); xlim([min(B) max(B)]);
legend('Blc data 0 deg');
subplot(2,2,4); plot(B, imag(Blc)); xlim([min(B) max(B)]);
legend('Blc data 90 deg');

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
figure()
plot(B, real(BlcPc), B, imag(BlcPc)); xlim([min(B) max(B)]);
legend('real part', 'imaginary part');


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

save(Opt.File.Save.Path, '-struct', 'Data') 