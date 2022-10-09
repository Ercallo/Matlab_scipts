%% Visualize cw temperature dependence
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.LName = 'p10K';
Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\PEDMR\data_analysis';
Opt.LPath = [Opt.LFolder, '\', Opt.LName, '_Blc.mat'];

Opt.SFigPath = [Opt.LFolder, '\', Opt.LName, '_map.pdf'];
% % Import
% p = load([Opt.LFolder, '\', Opt.LFiles(1).name]);
% p = repmat(p, numel(Opt.LFiles), 1);
% for i = 1:numel(Opt.LFiles)
%     p(i) = load([Opt.LFolder, '\', Opt.LFiles(i).name]);
% end
% for i = 1:numel(Opt.LFiles)
%     p(i).Name = Opt.LFiles(i).name;
% end

load(Opt.LPath);
cmap = viridis();

%%
tInit = 15000;
tIdx = t >= tInit;

figure();
imagesc(B(BIdx), t(tIdx)/1000, dIoverI(z(tIdx, BIdx), -60e-6));
c =colorbar;
c.Label.String = '\DeltaI/I';
c.Label.FontSize = 14;
set(gca,'YTick', 50:50:160);
ylabel('Time / µs', 'Fontsize', 14)
xlabel('Magnetic field / mT', 'Fontsize', 14)
xlim([343.3 353.2])
s = strjoin({'T =', erase(Opt.LName, 'p')});
text(0.75, 0.95, s, 'Units', 'normalized', 'FontSize', 12, 'Color', 'white');
set(gca, 'YDir', 'normal');
colormap(flipud(cmap));
set(gca, 'YDir', 'normal');

exportgraphics(gca, Opt.SFigPath, 'ContentType', 'vector')

%% Visualize cw temperature dependence
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.LName = 'p12p5K';
Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\PEDMR\data_analysis';
Opt.LPath = [Opt.LFolder, '\', Opt.LName, '_part1_Blc.mat'];

Opt.SFigPath = [Opt.LFolder, '\', Opt.LName, '_map.pdf'];
% % Import
% p = load([Opt.LFolder, '\', Opt.LFiles(1).name]);
% p = repmat(p, numel(Opt.LFiles), 1);
% for i = 1:numel(Opt.LFiles)
%     p(i) = load([Opt.LFolder, '\', Opt.LFiles(i).name]);
% end
% for i = 1:numel(Opt.LFiles)
%     p(i).Name = Opt.LFiles(i).name;
% end

load(Opt.LPath);
cmap = viridis();

%%
tInit = 15000;
tIdx = t >= tInit;

BIdx = B == B;

figure();
imagesc(B(BIdx), t(tIdx)/1000, dIoverI(z(tIdx, BIdx), -90e-6));
c =colorbar;
c.Label.String = '\DeltaI/I';
c.Label.FontSize = 14;
set(gca,'YTick', 500:500:1600);
s = 'T = 12.5K';
text(0.75, 0.95, s, 'Units', 'normalized', 'FontSize', 12, 'Color', 'white');
ylabel('Time / µs', 'Fontsize', 14)
xlabel('Magnetic field / mT', 'Fontsize', 14)
set(gca, 'YDir', 'normal');
colormap(flipud(cmap));
set(gca, 'YDir', 'normal');

exportgraphics(gca, Opt.SFigPath, 'ContentType', 'vector')

%% Visualize cw temperature dependence
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.LName = 'p15K';
Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\PEDMR\data_analysis';
Opt.LPath = [Opt.LFolder, '\', Opt.LName, '_Blc.mat'];

Opt.SFigPath = [Opt.LFolder, '\', Opt.LName, '_map.pdf'];
% % Import
% p = load([Opt.LFolder, '\', Opt.LFiles(1).name]);
% p = repmat(p, numel(Opt.LFiles), 1);
% for i = 1:numel(Opt.LFiles)
%     p(i) = load([Opt.LFolder, '\', Opt.LFiles(i).name]);
% end
% for i = 1:numel(Opt.LFiles)
%     p(i).Name = Opt.LFiles(i).name;
% end

load(Opt.LPath);
cmap = viridis();

%%
tInit = 15000;
tIdx = t >= tInit;

BIdx = B == B;

figure();
imagesc(B(BIdx), t(tIdx)/1000, dIoverI(z(tIdx, BIdx), -87e-6));
c =colorbar;
c.Label.String = '\DeltaI/I';
c.Label.FontSize = 14;
set(gca,'YTick', 50:50:160);
set(gca,'XTick', 341:3:356);
s = strjoin({'T =', erase(Opt.LName, 'p')});
text(0.75, 0.95, s, 'Units', 'normalized', 'FontSize', 12, 'Color', 'white');
ylabel('Time / µs', 'Fontsize', 14)
xlabel('Magnetic field / mT', 'Fontsize', 14)
xlim([340 353.3])
set(gca, 'YDir', 'normal');
colormap(flipud(cmap));
set(gca, 'YDir', 'normal');

exportgraphics(gca, Opt.SFigPath, 'ContentType', 'vector')

%% Visualize cw temperature dependence
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

% File and Run options
Opt.LName = 'p20K';
Opt.LFolder = 'D:\Profile\qse\NREL\2021_summer\PEDMR\data_analysis';
Opt.LPath = [Opt.LFolder, '\', Opt.LName, '_Blc.mat'];

Opt.SFigPath = [Opt.LFolder, '\', Opt.LName, '_map.pdf'];
% % Import
% p = load([Opt.LFolder, '\', Opt.LFiles(1).name]);
% p = repmat(p, numel(Opt.LFiles), 1);
% for i = 1:numel(Opt.LFiles)
%     p(i) = load([Opt.LFolder, '\', Opt.LFiles(i).name]);
% end
% for i = 1:numel(Opt.LFiles)
%     p(i).Name = Opt.LFiles(i).name;
% end

load(Opt.LPath);
cmap = viridis();

%%
tInit = 15000;
tIdx = t >= tInit;

BIdx = B == B;

figure();
imagesc(B(BIdx), t(tIdx)/1000, dIoverI(z(tIdx, BIdx), -87e-6));
c =colorbar;
c.Label.String = '\DeltaI/I';
c.Label.FontSize = 14;
set(gca,'YTick', 50:50:160);
set(gca,'XTick', 341:3:356);
xlim([340 353.3])
s = strjoin({'T =', erase(Opt.LName, 'p')});
text(0.75, 0.95, s, 'Units', 'normalized', 'FontSize', 12, 'Color', 'white');
ylabel('Time / µs', 'Fontsize', 14)
xlabel('Magnetic field / mT', 'Fontsize', 14)
set(gca, 'YDir', 'normal');
colormap(flipud(cmap));
set(gca, 'YDir', 'normal');

exportgraphics(gca, Opt.SFigPath, 'ContentType', 'vector')

%%
function y = dIoverI(y, Iph)
y = y/102400/128*2/10000/50/Iph;
end