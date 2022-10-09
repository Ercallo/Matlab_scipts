%% General script for computation of signal to noise ration of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.Load.Name = 'cw10K_100sc_BlcPc.mat';
Opt.Save.Name = '6dB';

% Opt.Load.Folder = 'D:\Profile\qse\NREL\2021_summer\CWEDMR\data_analysis';
Opt.Load.Folder = 'D:\Profile\qse\NREL\2022_spring\20220301\data_analysis';
Opt.Load.Path = strjoin({Opt.Load.Folder, Opt.Load.Name}, '\');

Opt.Save.Folder = Opt.Load.Folder;
Opt.Save.Name3 = strjoin({Opt.Save.Name, 'p3_snr'}, '_'); % .png
Opt.Save.Path3 = strjoin({Opt.Save.Folder, Opt.Save.Name3}, '\');

Opt.SaveFig = false;

% Import
load(Opt.Load.Path);

%%
Opt.RangeN = 1:150; % Range for noise max and min 
Opt.RangeS = 1:1000; % Range for signal max and min
[ppAmpN, maxN, minN] = AmplitudePP(x(Opt.RangeN), y(Opt.RangeN));
[ppAmpS, maxS, minS] = AmplitudePP(x(Opt.RangeS), y(Opt.RangeS));

f = figure();
plot(x, y); xlim([min(x) max(x)]);
yline(minS); yline(maxS); yline(minN+0.1); yline(maxN-0.1);
% yline(min(y(Opt.RangeN)), 'b'); yline(y(Opt.RangeN), 'b');
xline(x(Opt.RangeN(end)), 'b'); xline(x(Opt.RangeS(end)), 'r');

xlabel('B0 [mT]', 'Fontsize', 16); ylabel('Signal [V]', 'Fontsize', 16);
if Opt.SaveFig
    saveas(f, Opt.Save.Path1, 'png');
end

%%
function [ppAmp, maxy, miny] = AmplitudePP(x, y)
maxy = max(y);
miny = min(y);
ppAmp = maxy - miny;

end