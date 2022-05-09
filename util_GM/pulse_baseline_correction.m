%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

Opt.LName = '017_1p0V_PEDMR_Field_Sweep_26p7dB_200ns_17scan_20K_Light_longer_timebase.DTA';
Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\PEDMR';
Opt.LPath = [Opt.LFolder, '\', Opt.LName];

Opt.SFolder = [Opt.LFolder, '\', 'data_analysis'];
Opt.SPath = [Opt.SFolder, '\', 'p20K', '_Blc.mat'];

[Axes, Spc, Params] = eprload(Opt.LPath);

Boffset = 1.9;
t = Axes{1}';
B = (Axes{2} - Boffset)/10; % mT
[tLen, BLen] = size(Spc);

%% Baseline correction time
[tBl, tBlc] = deal(zeros(tLen, BLen));
for i = 1:BLen
    % Fit and subtract a constant to each slice in t-domain
    [tBlc(:, i), tBl(:, i)] = BaseLineCorrectionTime(t, Spc(:, i));
end

%%
Opt.Bc.Width = 0.15;
Opt.Bc.Order = 0;

[BBl, BBlc] = deal(zeros(tLen, BLen));
for i = 1:tLen
    % Fit and subtract a constant to each slice in B-domain
    [BBlc(i,:), BBl(i,:)] = BaseLineCorrectionField(B, tBlc(i, :), Opt.Bc);
end

%%
figure()
h = ScrollableAxes('Index', 150);
plot(h, B, t, tBlc);
hold on
plot(h, B, t, BBl);

%%
figure()
h = ScrollableAxes('Index', 150);
plot(h, t, B, BBlc);

%%
BIdx = (B > 344) & (B < 352);
BIdx = B > 100;
h = ScrollableAxes('Index', 150);
plot(h, B(BIdx), t, BBlc(:, BIdx));

%%
tIdx = 1:tLen > 190;
% idx = 1:tLen;
figure();
% imagesc(B, t(idx), Blc(idx, :));
imagesc(B(BIdx), t(tIdx), BBlc(tIdx, BIdx));
cmap = 'viridis';
colormap(cmap); colorbar;
ax = gca; ax.YDir = 'normal';

%%
Data.B = B;
Data.t = t;
Data.Blc.Spc = Spc;
Data.Blc.tBl = tBl;
Data.Blc.BBl = BBl;
Data.z = BBlc;

Data.Exp.mwFreq = Params(1).MWFQ*1e-09; % GHz
Data.Exp.Range = [min(B) max(B)];
Data.Exp.Harmonic = 0;

save(Opt.SPath, '-struct', 'Data');