%% Plot IV curves from different folders
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.File.Load.Folder0 = ...
    'D:\Profile\qse\NREL\2022_March\iv_curve\20220310_susi';
% Opt.File.Load.Name0 = '005_si22522_4_pad_wide_light.txt';
Opt.File.Load.Name0 = '006_si22522_4_pad_light.txt';
Opt.File.Load.Path0 = strjoin({Opt.File.Load.Folder0, ...
    Opt.File.Load.Name0}, '\');
Opt.File.Load.Folder1 = ...
   Opt.File.Load.Folder0;
% Opt.File.Load.Name1 = '021_si22522_4_aa_wide_light.txt';
Opt.File.Load.Name1 = '022_si22522_4_aa_light.txt';
Opt.File.Load.Path1 = strjoin({Opt.File.Load.Folder1, ...
    Opt.File.Load.Name1}, '\');
Opt.File.Load.Folder2 = ...
    Opt.File.Load.Folder0;
% 'D:\Profile\qse\NREL\2022_March\iv_curve\20220307_susi\afternoon';
% Opt.File.Load.Name2 = '003_si22522_4_wide_dark.txt';
Opt.File.Load.Name2 = '002_si22522_4_dark.txt';
Opt.File.Load.Path2 = strjoin({Opt.File.Load.Folder2, ...
    Opt.File.Load.Name2}, '\');
% Opt.File.Load.Name3 = '035_si22522_4_teflonall8x_wide_light.txt';
Opt.File.Load.Name3 = '036_si22522_4_teflonall8x_light.txt';
Opt.File.Load.Path3 = strjoin({Opt.File.Load.Folder2, ...
    Opt.File.Load.Name3}, '\');

Opt.File.Save.Folder = ...
    Opt.File.Load.Folder0;
Opt.File.Save.Name = 'p08_si22522_4_aa';
Opt.File.Save.Path = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name}, '/');

Opt.SaveFig = true;

%% Import
Aa = 1; % cm2
data0 = importdata(Opt.File.Load.Path0, '\t', 21);
x0 = data0.data(:, 1);
y0f = data0.data(:, 2)/Aa; y0r = data0.data(:, 3)/Aa;

Aa = 1; % cm2
data1 = importdata(Opt.File.Load.Path1, '\t', 21);
x1 = data1.data(:, 1);
y1f = data1.data(:, 2)/Aa; y1r = data1.data(:, 3)/Aa;

Aa = 1; % cm2
data2 = importdata(Opt.File.Load.Path2, '\t', 21);
x2 = data2.data(:, 1);
y2f = data2.data(:, 2)/Aa; y2r = data2.data(:, 3)/Aa;
data3 = importdata(Opt.File.Load.Path3, '\t', 21);
x3 = data3.data(:, 1);
y3f = data3.data(:, 2)/Aa; y3r = data3.data(:, 3)/Aa;

%%
f = figure();
% plot(x0, y0r, x1, y1r, x2, y2r, x3, y3r);
% plot(x1, y1r, x0, y0r)
plot(x0, y0r, 'Color', '#0072BD', 'Linestyle', '-');
% plot(x2, y2r, 'Color', 'red', 'Linestyle', '-');
hold on;
plot(x2, y2r, 'Color', '#0072BD', 'Linestyle', '--')
% plot(x1, y1r, 'Color', '#D95319', 'Linestyle', '-');
% plot(x3, y3r, 'Color', 'red', 'Linestyle', '--');
% plot(x0, y0r, 'Color', 'blue', 'Linestyle', '-');
plot(x1, y1r, 'Color', '#D95319', 'LineStyle', '-');
% xlim([min([min(x0) min(x1) min(x2)]) max([max(x0) max(x1) max(x2)])]);
% legend('si22522\_1 light', 'old sample light', 'old sample dark');
xlim([min(x1) max(x2)]);
% xlim([-0.2 0.8]);
grid on;
% ylabel('Current density [mA/cm^2]', 'Fontsize', 14);
ylabel('Current [mA]', 'Fontsize', 14);
xlabel('Voltage [V]', 'Fontsize', 14);
legend('low', 'medium', 'high', 'Location', 'northwest');
legend('si22522\_4\_JL\_nomask', 'si22522\_4\_Jd', ...
    'si22522\_4\_JL\_active\_area\_covered', ...
    'si22522\_4\_Jd', 'Location', 'northwest');
% legend('si22522\_4\_JL\_nomask\_pad\_covered', 'Location', 'northwest');
% legend('si22522\_3\_JL\_0p7\_1', 'si22522\_3\_JL\_0p7\_2', ...
%     'si22522\_3\_JL\_0p8\_1', 'si22522\_3\_JL\_0p8\_2',...
%     'Location', 'northwest');
if Opt.SaveFig
    saveas(f, Opt.File.Save.Path, 'png')
end

Jsc0 = y0f(1);
Jsc1 = y1f(1);
Jsc2 = y2f(1);
Jsc3 = y3f(1);