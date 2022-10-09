%% Plot IV curves from different folders
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.File.Load.Folder0 = ...
    'D:\Profile\qse\Desktop\aSi_Michele\220328';
% Opt.File.Load.Name0 = '005_si22522_4_pad_wide_light.txt';
Opt.File.Load.Name0 = '01_IV_curve_chip_spento.txt';
Opt.File.Load.Path0 = strjoin({Opt.File.Load.Folder0, ...
    Opt.File.Load.Name0}, '\');
Opt.File.Load.Folder1 = ...
   Opt.File.Load.Folder0;
% Opt.File.Load.Name1 = '021_si22522_4_aa_wide_light.txt';
Opt.File.Load.Name1 = '02_IV_curve_max_b1.txt';
Opt.File.Load.Path1 = strjoin({Opt.File.Load.Folder1, ...
    Opt.File.Load.Name1}, '\');
Opt.File.Load.Folder2 = ...
    Opt.File.Load.Folder0;
% 'D:\Profile\qse\NREL\2022_March\iv_curve\20220307_susi\afternoon';
% Opt.File.Load.Name2 = '003_si22522_4_wide_dark.txt';
Opt.File.Load.Name2 = '03_IV_curve_min_b1.txt';
Opt.File.Load.Path2 = strjoin({Opt.File.Load.Folder2, ...
    Opt.File.Load.Name2}, '\');
% Opt.File.Load.Name3 = '035_si22522_4_teflonall8x_wide_light.txt';
Opt.File.Load.Name3 = '04_IV_curve_n2_max_b1.txt';
Opt.File.Load.Path3 = strjoin({Opt.File.Load.Folder2, ...
    Opt.File.Load.Name3}, '\');

Opt.File.Save.Folder = ...
    Opt.File.Load.Folder0;
Opt.File.Save.Name = 'p08_si22522_4_aa';
Opt.File.Save.Path = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name}, '/');

Opt.SaveFig = false;

%% Import
Aa = 20000; % cm2
% data0 = importdata(Opt.File.Load.Path0, '\t', 21);
data0 = importdata(Opt.File.Load.Path0, '\t');
x0 = data0.data(:, 1);
y0f = data0.data(:, 2)/Aa; % y0r = data0.data(:, 3)/Aa;

Aa = 20000; % cm2
% data1 = importdata(Opt.File.Load.Path1, '\t', 21);
data1 = importdata(Opt.File.Load.Path1, '\t');
x1 = data1.data(:, 1);
y1f = data1.data(:, 2)/Aa; % y1r = data1.data(:, 3)/Aa;

Aa = 20000; % cm2
% data2 = importdata(Opt.File.Load.Path2, '\t', 21);
data2 = importdata(Opt.File.Load.Path2, '\t');
x2 = data2.data(:, 1);
y2f = data2.data(:, 2)/Aa; % y2r = data2.data(:, 3)/Aa;
% data3 = importdata(Opt.File.Load.Path3, '\t', 21);
data3 = importdata(Opt.File.Load.Path3, '\t');
x3 = data3.data(:, 1);
y3f = data3.data(:, 2)/Aa; % y3r = data3.data(:, 3)/Aa;

%%
f = figure();
plot(x0, y0f, x1, y1f, x2, y2f, x3, y3f);
% plot(x1, y1r, x0, y0r)
% plot(x0, y0r, 'Color', '#0072BD', 'Linestyle', '-');
% plot(x2, y2r, 'Color', 'red', 'Linestyle', '-');
% hold on;
% plot(x2, y2r, 'Color', '#0072BD', 'Linestyle', '--')
% plot(x1, y1r, 'Color', '#D95319', 'Linestyle', '-');
% plot(x3, y3r, 'Color', 'red', 'Linestyle', '--');
% plot(x0, y0r, 'Color', 'blue', 'Linestyle', '-');
% plot(x1, y1r, 'Color', '#D95319', 'LineStyle', '-');
% xlim([min([min(x0) min(x1) min(x2)]) max([max(x0) max(x1) max(x2)])]);
% legend('si22522\_1 light', 'old sample light', 'old sample dark');
xlim([min(x0) max(x0)]);
% xlim([-0.2 0.8]);
grid on;
% ylabel('Current density [mA/cm^2]', 'Fontsize', 14);
ylabel('Current [A]', 'Fontsize', 14);
xlabel('Voltage [V]', 'Fontsize', 14);
legend('chip spento', 'max b1', 'min b1', 'N2 max b1', ...
    'Location', 'northwest');
% legend('si22522\_4\_JL\_nomask', 'si22522\_4\_Jd', ...
%     'si22522\_4\_JL\_active\_area\_covered', ...
%     'si22522\_4\_Jd', 'Location', 'northwest');
% legend('si22522\_4\_JL\_nomask\_pad\_covered', 'Location', 'northwest');
% legend('si22522\_3\_JL\_0p7\_1', 'si22522\_3\_JL\_0p7\_2', ...
%     'si22522\_3\_JL\_0p8\_1', 'si22522\_3\_JL\_0p8\_2',...
%     'Location', 'northwest');
if Opt.SaveFig
    saveas(f, Opt.File.Save.Path, 'png')
end

% Jsc0 = y0f(1);
% Jsc1 = y1f(1);
% Jsc2 = y2f(1);
% Jsc3 = y3f(1);

%%
Iph = -0.015/20000;
model = @(I0, p) I0*(exp(echarge*x0/boltzm/p) - 1) + Iph;
I00 = 1e-14; % 1 pA/cm2 ??
p0 = 300*1.5;
%%
close all
plot(x0, model(I00, p0), x0, y0f)
legend('model', 'data')
%%
bestfit = lsqnonlin( @(p) y(1:end-8) - model(p), p0);

%%
ratio = (y0f(10) - Iph + I0)/(y1f(10) - Iph + I0);
logratio = log(ratio);
result = logratio*boltzm*300/echarge/x0(10);
T1 = 300/(1-result);