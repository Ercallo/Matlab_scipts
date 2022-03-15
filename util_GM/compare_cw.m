%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.File.Load.Folder0 = ...
    'D:\Profile\qse\NREL\2021_summer\CWEDMR';
Opt.File.Load.Name0 = 'cw10K_BlcPc.mat';
Opt.File.Load.Path0 = strjoin({Opt.File.Load.Folder0, ...
    Opt.File.Load.Name0}, '\');
Opt.File.Load.Folder1 = ...
    'D:\Profile\qse\NREL\2022_march\20220311';
Opt.File.Load.Name1 = 'cw10K_12db_BlcPc.mat';
Opt.File.Load.Path1 = strjoin({Opt.File.Load.Folder1, ...
    Opt.File.Load.Name1}, '\');

Opt.File.Name = 'cw10K_12db_p4_blackcolor';
Opt.File.Save.Folder = ...
    Opt.File.Load.Folder0;

% Useless?
Opt.File.Save.Name0 = strjoin({Opt.File.Name, 'Spc_Bl_comparison'}, '_');
Opt.File.Save.Path0 = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name0}, '\');

Opt.File.Save.Name1 = strjoin({Opt.File.Name, 'comparison'}, '_');
Opt.File.Save.Path1 = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name1}, '\');
Opt.File.Save.Name2 = Opt.File.Name; % Visualize only one
Opt.File.Save.Path2 = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name2}, '\');

Opt.SaveFig = false;

%% Import
% Is this the right way to normalize?
I0 = 1; % uA
I1 = 1; % uA
load(Opt.File.Load.Path0); x0 = x; y0 = y/I0; % Normalized with DC current
r0 = real(BlcPc.Spc)/I0; i0 = imag(BlcPc.Spc)/I0;
Blr0 = real(BlcPc.Bl)/I0; Bli0 = imag(BlcPc.Bl)/I0;
load(Opt.File.Load.Path1); x1 = x; y1 = y/I1;
r1 = real(BlcPc.Spc)/I1; i1 = imag(BlcPc.Spc)/I1;
Blr1 = real(BlcPc.Bl)/I1; Bli1 = imag(BlcPc.Bl)/I1;

%%
figure('visible', 'off')
t = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile,
plot(x0, r0, x0, Blr0); xlim(Exp.Range); legend('new', 'bl');
nexttile, 
plot(x1, r1, x1, Blr1); xlim(Exp.Range); legend('old', 'bl');
nexttile,
plot(x0, i0, x0, Bli0); xlim(Exp.Range); legend('new', 'bl');
nexttile,
plot(x1, i1, x1, Bli1); xlim(Exp.Range); legend('old', 'bl');
xlabel(t, 'B0 [mT]')
ylabel(t, 'Norm. cw signal [V/uA]')

% I don't think this is useful
if false
    saveas(t, Opt.File.Save.Path0, 'png')
end

f = figure();
plot(x0, y0, x1, y1); xlim(Exp.Range);
xlabel('B0 [mT]', 'fontsize', 14);
ylabel('Signal [V]', 'fontsize', 14);
legend('si22522\_1', 'old sample');
if Opt.SaveFig
    saveas(f, Opt.File.Save.Path1, 'png')
end

%% Import
load(Opt.File.Load.Path1); x1 = x; y1 = y;

%%
f = figure();
% plot(x1, y1 /(max(y1) - min(y1)), 'k'); xlim(Exp.Range);
plot(x1, y1, 'k'); xlim(Exp.Range);
xlabel('B0 [mT]', 'Fontsize', 16)
ylabel('Signal [V]', 'Fontsize', 16)
if Opt.SaveFig
    saveas(f, Opt.File.Save.Path2, 'png')
end