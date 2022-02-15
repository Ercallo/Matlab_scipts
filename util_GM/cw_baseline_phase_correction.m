%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all

folder = '/home/gianluca/matlab_util/util_GM/to_be_sorted/NREL_cwEDMR10K/';
dataName = 'cwEDMR13K'; % Desired import-export data name
filename0 = '011_1p0V_10KHz_1p2G_13K_10Scan_0Deg_Light.DTA';
filename90 = '011_1p0V_10KHz_1p2G_13K_10Scan_90Deg_Light.DTA';


[B, Spc, Params] = eprloadQuad(strjoin({folder, filename0}, ''), ...
                               strjoin({folder, filename90}, ''));

% Work with column vector (1xn double)                           
B = B';
Spc = Spc';

% Field offset
Boffset = 5.181;
B = (B - Boffset)/10; % mT

%% Baseline correction
Opt.Range = [1, 200];
Opt.Range1 = [numel(B) - 200, numel(B)];
Opt.Order = 1;

[Blc, Bl] = baselineSubtractionPolyfit(B, Spc, Opt);

figure()
subplot(2,2,1); plot(B, real(Spc), B, real(Bl));
xline(B(Opt.Range(2))); xline(B(Opt.Range1(1))); xlim([min(B) max(B)]);
legend('raw data 0 deg', 'baseline');
subplot(2,2,2); plot(B, imag(Spc), B, imag(Bl));
xline(B(Opt.Range(2))); xline(B(Opt.Range1(1))); xlim([min(B) max(B)]); 
legend('raw data 90 deg', 'imaginary part baseline');
subplot(2,2,3); plot(B, real(Blc)); xlim([min(B) max(B)]);
legend('Blc data 0 deg');
subplot(2,2,4); plot(B, imag(Blc)); xlim([min(B) max(B)]);
legend('Blc data 90 deg');

%% Phase correction
[BlcPc, Phase] = correctPhase(Blc); % Baseline and phase corrected 

figure()
plot(B, real(BlcPc), B, imag(BlcPc)); xlim([min(B) max(B)]);
legend('real part', 'imaginary part');

%% Save everything into a structure
cwEDMR.B = B; % Corrected with calibration
cwEDMR.Bl = Bl;
cwEDMR.SpcBlc = Blc;
cwEDMR.SpcBlcPc = real(BlcPc); % Imaginary part is almost zero everywhere

% If possible, average initial and final value of mwFreq
cwEDMR.Exp.mwFreq = Params(1).MWFQ * 1e-09;
cwEDMR.Exp.Range = [min(B) max(B)];

save(strjoin({folder, dataName, '_BlcPc.mat'} , ''), 'cwEDMR'); 