%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.Name = 'cw20K';
Opt.Load.Folder = 'D:\Profile\qse\NREL\2021_summer\CWEDMR\2ordBl';
Opt.Load.Name = strjoin({Opt.Name, 'BlcPc.mat'}, '_');
Opt.Load.Path = strjoin({Opt.Load.Folder, ...
    Opt.Load.Name}, '\');
Opt.Load.FitName = strjoin({Opt.Name, 'fit_one.mat'}, '_');
Opt.Load.FitPath = strjoin({Opt.Load.Folder, ...
    Opt.Load.FitName}, '\');
Opt.Load.BootName = strjoin({Opt.Name, 'boot_one.mat'}, '_');
Opt.Load.BootPath = strjoin({Opt.Load.Folder, ...
    Opt.Load.BootName}, '\');

Opt.Save.Folder = Opt.Load.Folder;
Opt.Save.FitName = strjoin({Opt.Name, 'fit_one'}, '_');
Opt.Save.FitPath = strjoin({Opt.Save.Folder, ...
    Opt.Save.FitName}, '\');
Opt.Save.BootName = strjoin({Opt.Name, 'boot_one'}, '_');
Opt.Save.BootPath = strjoin({Opt.Save.Folder, ...
    Opt.Save.BootName}, '\');

Opt.SaveFig = true;

% Import
load(Opt.Load.Path);
load(Opt.Load.FitPath);
load(Opt.Load.BootPath);

%%
f = figure();
plot(x, y, x, yfit);
xlim([min(x) max(x)]);
xlabel('B0 [mT]', 'Fontsize', 16);
ylabel('Signal [V]', 'Fontsize', 16);
legend('data', 'fit');

if Opt.SaveFig
    saveas(f, Opt.Save.FitPath, 'png');
end

%%
figure();
t = tiledlayout(1,2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile, histfit(BootSys0.g);
hold on
xline(Sys.g, 'r', 'LineWidth', 3);
xlabel('g-value', 'Fontsize', 12);

nexttile, histfit(BootSys0.lw(:, 2));
xlabel('Linewidth [mT]', 'Fontsize', 12);
xline(Sys.lw(2), 'r', 'LineWidth', 3);
ylabel(t, 'Counts', 'Fontsize', 12);

if Opt.SaveFig
    Opt.Save.BootPath
    saveas(t, Opt.Save.BootPath, 'png');
end