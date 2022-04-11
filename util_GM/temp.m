%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

Data = importdata(...
    'D:\Profile\qse\NREL\2022_march\iv_curve\20220401\si22522_4_RT_jL.lvm', ...
    '\t', 22);
x = Data.data(:,2); y = Data.data(:,3);

f = figure();
plot(x, y, '-o');
legend('Signal peak-peak', 'Noise peak-peak', 'S/N');
% saveas(f, ...
%     'D:\Profile\qse\NREL\2022_march\220331\data_analysis\amp_power', ...
%     'png');

%%
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

Data = importdata(...
    'D:\Profile\qse\NREL\2022_march\220331\data_analysis\idc_power.txt');
Att = Data.data(:,1); Idc = Data.data(:,2);

f = figure();
plot(Att, Idc, '-o');
xlim([5 31]);
ylim([135 150]);
xlabel('Power attenuation [dB]', 'Fontsize', 16);
ylabel('Current DC [uA]', 'Fontsize', 16);
saveas(f, ...
    'D:\Profile\qse\NREL\2022_march\220331\data_analysis\idc_power', ...
    'png');