%% Visualize cw temperature dependence
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

c_gray = '#b2beb5'; c_or = '#D95319'; c_gre = '#77AC30'; c_lbl = '#4DBEEE';
c_comp = {c_or, c_gre, c_lbl};

% File and Run options
Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\cwEDMR\data_analysis';
Opt.LFiles = dir([Opt.LFolder, '\', '*Pc.mat']);
Opt.LFiles(7) = []; % Exclude 40K;
Opt.SName = '2021_summer_cw_T';

Opt.LFolderFit = [Opt.LFolder, '\', 'fit_boot'];
Opt.LFilesFit = dir([Opt.LFolderFit, '\', '*.mat']);
Opt.LFilesFit(4) = []; % Exclude 40K;

Opt.SFolder = Opt.LFolder;

Opt.Run.SaveFig = true;
%%
% Import
cw = load([Opt.LFolder, '\', Opt.LFiles(1).name]);
cw = repmat(cw, numel(Opt.LFiles),1);
fit = load([Opt.LFolderFit, '\', Opt.LFilesFit(1).name]);
fit = repmat(fit, numel(Opt.LFilesFit),1);
%%
for i = 1:numel(Opt.LFiles)
    cw(i) = load([Opt.LFolder, '\', Opt.LFiles(i).name]);
    fit(i) = load([Opt.LFolderFit, '\', Opt.LFilesFit(i).name]);
end
for i = 1:numel(Opt.LFiles)
    cw(i).Name = Opt.LFiles(i).name;
    fit(i).Name = Opt.LFilesFit(i).name;
end

% Set common range
Opt.Exp.Range = setExpRange(cw);

%%
pep = repmat({cw(1).y}, numel(Opt.LFiles), 3);
sumPep = repmat({cw(1).y}, numel(Opt.LFiles), 1);
propFactor = ones(1, numel(Opt.LFiles));
for i = 1:4
    for j = 1:3
        pep(i, j) = {pepper(fit(i).Sys{1, j}, fit(i).Exp)};
    end
    [sumPep{i}, propFactor(i)] = scaleY(pep{i,1}+pep{i,2}+pep{i,3},cw(i).y);
    for j = 1:3
        pep{i, j} = propFactor(i)*pep{i, j};
    end
end
for i = 5:6
    for j = 1:2
        pep(i, j) = {pepper(fit(i).Sys{1, j}, fit(i).Exp)};
    end
    [sumPep{i}, propFactor(i)] = scaleY(pep{i,1} + pep{i,2}, cw(i).y);
    for j = 1:2
        pep{i, j} = propFactor(i)*pep{i, j};
    end
end

%% T dependence figure
figure('WindowStyle', 'normal', 'Position', [50 50 50+690 50+690*3/4]);
t = tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
xTicks = 340:5:356;
xMinorTicks = xTicks + 2.5;
for i = 1:6
    x = cw(i).x; y = cw(i).y; yfit = fit(i).yfit;
    nexttile,
        plot(x, y, 'k')
    hold on;
    plot(x, yfit, 'r');
    plot(x, y - yfit, 'Color', c_gray);
    xlim(Opt.Exp.Range);
    yLim = setYLim(y, 0.1); yfitLim = setYLim(yfit, 0.1);
    ylim([min(yLim(1), yfitLim(1)) max(yLim(2), yfitLim(2))]);
    h = get(gca,'Children');
    set(gca,'Children',[h(2) h(3) h(1)])
    
    % xticks(xTicks); yticks(0);
    % set(gca,'XMinorTick','on')
    ax = gca;
    ax.YTick = 0;
    ax.XTick = xTicks;
    ax.XAxis.MinorTick = 'on';
    ax.XAxis.MinorTickValues = xMinorTicks;
    
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
nexttile(1), legend('data', 'fit', 'residuals', 'Location', 'southwest'); 

if Opt.Run.SaveFig
    % Opt.SFigName = strjoin({Opt.SName, 'f0_no40_nobox.pdf'}, '_');
    Opt.SFigName = strjoin({Opt.SName, '.pdf'}, '');
    Opt.SFigPath = strjoin({Opt.SFolder, Opt.SFigName}, '\');
    % exportgraphics(t, Opt.SFigPath, 'ContentType', 'vector')
    % exportgraphics(t, 'D:\Profile\qse\master_thesis\images\2021_summer_cw_T.pdf', 'ContentType', 'vector')
end
exportgraphics(t, 'D:\Profile\qse\master_thesis\images\2021_summer_cw_T.pdf', 'ContentType', 'vector')
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
    Opt.SFigName = strjoin({Opt.SName, 'f0_baseline'}, '_'); % .png
    Opt.SFigPath = strjoin({Opt.SFolder, Opt.SFigName}, '\');
    saveas(t, Opt.SFigPath, 'png')
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

function varargout = scaleY(y, ref)
% Scale y to the same amplitude pp as ref
    ppAmpRef = max(ref) - min(ref);
    ppAmpY = max(y) - min(y);
    propFactor = ppAmpRef/ppAmpY;
    scaledY = propFactor*y;
    if nargout == 1
        varargout = scaledY;
    else
        varargout{1} = scaledY; varargout{2} = propFactor;
    end
end