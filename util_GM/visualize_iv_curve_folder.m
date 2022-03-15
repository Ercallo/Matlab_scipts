%% Plot all IV curves from the same folder
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.File.Load.Folder = ...
    'D:\Profile\qse\NREL\2022_March\iv_curve\20220301';
Opt.File.Load.Names = dir(strjoin({Opt.File.Load.Folder, ...
    '*.lvm'},'\'));
Opt.File.Load.Path0 = strjoin({Opt.File.Load.Folder, ...
        Opt.File.Load.Names(1).name}, '\');
for i=1:numel(Opt.File.Load.Names)
    Title = strsplit(Opt.File.Load.Names(i).name, '_');
    Opt.File.Load.Titles(i).Title = Title;
end

%% Memory allocation
TempData = importdata(Opt.File.Load.Path0, '\t', 22);
Data.TitleD = strsplit(Opt.File.Load.Names(2).name, '_');
Data.xD = TempData.data(:, 2); Data.yD = TempData.data(:, 3);

Data = repmat(Data, 2, numel(Opt.File.Load.Names)/2);

%% Import
col = 1; row = 1;
for i=2:numel(Opt.File.Load.Names)
    if Opt.File.Load.Titles(i) == Opt.File.Load.Titles(i - 1)
        row = 2;
    else
        col = col +1;
        row = 1;
    end
    Path = strjoin({Opt.File.Load.Folder, ...
        Opt.File.Load.Names(i).name}, '\');
    tempData = importdata(Path, '\t', 22);

    Data(row, col).x = tempData.data(:, 2);
    Data(row, col).y = tempData.data(:, 3);
    Data(wor, col).Title = Opt.File.Load.Names(row).name;
end
    
    
%%
Opt.File.Load.Path0 = strjoin({Opt.File.Load.Folder0, ...
    Opt.File.Load.Name0}, '\');

Opt.File.Save.Folder = ...
    Opt.File.Load.Folder;
Opt.File.Save.Name = 'si22522_1_10K_comparison';
Opt.File.Save.Path = strjoin({Opt.File.Save.Folder, ...
    Opt.File.Save.Name}, '/');

Opt.SaveFig = false;

% Import
data0 = importdata(Opt.File.Load.Path0, '\t', 22);
x0 = data0.data(:, 2); y0 = data0.data(:,3);
% data1 = importdata(Opt.File.Load.Path1, '\t', 22);
% x1 = data1.data(:, 2); y1 = data1.data(:,3);
% data2 = importdata(Opt.File.Load.Path2, '\t', 22);
% x2 = data2.data(:, 2); y2 = data2.data(:,3);

%%
f = figure();
% plot(x0, y0, x1, y1, x2, y2);
plot(x0, y0);
% xlim([min([min(x0) min(x1) min(x2)]) max([max(x0) max(x1) max(x2)])]);
% legend('si22522\_1 light', 'old sample light', 'old sample dark');
xlim([-0.2 0.8]);
legend('si22522 RT dark')
if Opt.SaveFig
    saveas(f, Opt.File.Save.Path, 'png')
end