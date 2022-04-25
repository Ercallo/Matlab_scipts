%% Visualize cw temperature dependence
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.Load.Folder = 'D:\Profile\qse\BDPA\220414\data_analysis';
Opt.Load.Files = dir(strjoin({Opt.Load.Folder, 'BDPA*.mat'}, '\'));
Opt.Save.Name = 'BDPA_saturation_curve';

Opt.Save.Folder = Opt.Load.Folder;

Opt.Run.SaveFig = true;

% Import
cw = load(strjoin({Opt.Load.Folder, Opt.Load.Files(1).name}, '\'));
cw = repmat(cw, numel(Opt.Load.Files),1);
for i = 1:numel(Opt.Load.Files)
    Path = strjoin({Opt.Load.Folder, Opt.Load.Files(i).name}, '\');
    cw(i) = load(Path);
end
for i = 1:numel(Opt.Load.Files)
    cw(i).Name = Opt.Load.Files(i).name;
end

%%
[yMin, yMax, xMin, xMax] = deal(zeros(1, numel(Opt.Load.Files)));
for i = 1:numel(Opt.Load.Files)
    x = cw(i).x; y = cw(i).y;
    [yMin(i), I] = min(y); xMin(i) = x(I);
    [yMax(i), I] = max(y); xMax(i) = x(I);
end
ppAmp = yMax - yMin;
lw = xMin - xMax;

%%
figure()
plot(0:3:60, ppAmp, 'ko-')
ylabel('Amplitude peak to peak [a. u.]', 'Fontsize', 12);
yyaxis right
plot(0:3:60, lw, 'o-')
ylabel('Linewidth [G]', 'Fontsize', 12);
xlabel('Attenuation [dB]', 'Fontsize', 12);

xlim([-1 61]);
xTicks = 0:15:60;
xMinorTicks = 0:3:60;
ax = gca;
ax.XTick = xTicks;
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = xMinorTicks;

if Opt.Run.SaveFig
    Opt.Save.FigName = strjoin({Opt.Save.Name, '.pdf'}, '');
    Opt.Save.FigPath = strjoin({Opt.Save.Folder, Opt.Save.FigName}, '\');
    exportgraphics(gcf, Opt.Save.FigPath, 'ContentType', 'vector');
end