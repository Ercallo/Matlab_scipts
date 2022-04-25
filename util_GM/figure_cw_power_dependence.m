%% Visualize cw temperature dependence
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.Load.Folder = 'D:\Profile\qse\BDPA\220414\data_analysis';
Opt.Load.Files = dir(strjoin({Opt.Load.Folder, 'BDPA*.mat'}, '\'));
Opt.Save.Name = 'BDPA_power_dependence';

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

% Set common range
Opt.Exp.Range = setExpRange(cw);

%% T dependence tiledlayout
figure('WindowStyle', 'normal', 'Position', [50 50 900 600]);
t = tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
xTicks = 340:5:356;
for i = 1:numel(Opt.Load.Files)
    x = cw(i).x; y = cw(i).y;
    nexttile, plot(x, y, 'k');
    xlim(Opt.Exp.Range); ylim(setYLim(y, 0.1));
    xticks(xTicks); yticks(0);
    
    s = strjoin({'T =', erase(cw(i).Name, {'cw', '_BlcPc.mat'})});
    text(0.75, 0.15, s, 'Units', 'normalized', 'FontSize', 12);
    s = strjoin({'(', char(96+i), ')'}, '');
    text(0.9, 0.9, s, 'Units', 'normalized', 'FontSize', 12, ...
        'FontWeight', 'bold');
    
    if i>4
        xlabel('Magnetic field [mT]', 'Fontsize', 12);
    end
    if mod(i, 2)
        ylabel('Signal [a.u.]', 'Fontsize', 12);
    end
    % annotation('textbox', [0.75 0.85 .1 .1], 'String', t, ...
    %     'FitBoxToText', 'on');
end

if Opt.Run.SaveFig
    % Opt.Save.FigName = strjoin({Opt.Save.Name, 'f0_no40_nobox.pdf'}, '_');
    Opt.Save.FigName = Opt.Save.Name;
    Opt.Save.FigPath = strjoin({Opt.Save.Folder, Opt.Save.FigName}, '\');
    exportgraphics(t, Opt.Save.FigPath, 'ContentType', 'vector')
end

%% Power dependence in one plot
figure()
for i = 1:numel(Opt.Load.Files)
    x = cw(i).x; y = cw(i).y;
    plot(x, y);
    hold on
end
xlim(Opt.Exp.Range); ylim(setYLim(cw(3).y, 0.1));
legend('18dB', '24dB', '30dB', '36dB', '42dB');
xlabel('Magnetic field [mT]', 'Fontsize', 12);
ylabel('Signal [a.u.]', 'Fontsize', 12);

xTicks = 343.5:.5:345;
xMinorTicks = xTicks - .25;
ax = gca;
ax.YTick = 0;
ax.XTick = xTicks;
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = xMinorTicks;
if Opt.Run.SaveFig
    Opt.Save.FigName = strjoin({Opt.Save.Name, '.pdf'}, "");
    Opt.Save.FigPath = strjoin({Opt.Save.Folder, Opt.Save.FigName}, '\');
    exportgraphics(gcf, Opt.Save.FigPath, 'ContentType', 'vector');
end
%%
%{
legend('raw data 0°', 'baseline');
nexttile, plot(B, imag(Spc), B, imag(Bl));
xline(B(Opt.Bc.Range(2))); xline(B(Opt.Bc.Range1(1))); 
xlim([min(B) max(B)]); 
legend('raw data 90°', 'baseline');
nexttile, plot(B, real(Blc)); xlim([min(B) max(B)]);
legend('Blc data 0°');
nexttile, plot(B, imag(Blc)); xlim([min(B) max(B)]);
legend('Blc data 90°');
xlabel(t, 'B0 [mT]', 'Fontsize', 16);
ylabel(t, 'Signal [V]', 'Fontsize', 16);

if Opt.Run.SaveFig
    Opt.Save.FigName = strjoin({Opt.Save.Name, 'f0_baseline'}, '_'); % .png
    Opt.Save.FigPath = strjoin({Opt.Save.Folder, Opt.Save.FigName}, '\');
    saveas(t, Opt.Save.FigPath, 'png')
end
%}

%%
function yRange = setYLim(y, perc)
% Set the ylim of the plot to be a certain percentage bigger than the ppAmp
% of the spectrum
    ppAmp = max(y) - min(y);
    RangeMin = min(y) - ppAmp*perc;
    RangeMax = max(y) + ppAmp*perc;
    yRange = [RangeMin RangeMax];
end

function Range = setExpRange(cw)
% Find the largest range that is common to every spectrum
    xMin = cw(1).Exp.Range(1); xMax = cw(1).Exp.Range(2);
    for i = 1:numel(cw)
        if cw(i).Exp.Range(1) > xMin
            xMin = cw(i).Exp.Range(1);
        end
        if cw(i).Exp.Range(2) < xMax
            xMax = cw(i).Exp.Range(2);
        end
    end
    Range = [xMin xMax];
end