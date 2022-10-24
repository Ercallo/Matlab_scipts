%% Pin SC EPRoC - Elexysis 2021-06-17
% Comparison of SNR using different amplification factors at the EDMR pre
% amplifier.
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\Files\soft\software\Matlab'));

% File and Run options
Opt.LFolder = 'D:\Profile\qse\Files\Side projects\_Pin SC EPRoC - Elexsys\20210617';
Opt.Ldir0 = dir([Opt.LFolder, '\*_0Deg.DTA']);
Opt.LPaths = [Opt.LFolder, '\', Opt.Ldir0.name];
Opt.Ldir90 = dir([Opt.LFolder, '\*_90Deg.DTA']);

%%
cw = struct();
ncw = 4;

% Field offset (obtained from 013_calibration_NC60)
B0Offset = 1.763;
for icw=1:ncw
    LPath0_ = [Opt.LFolder, '\', Opt.Ldir0(icw).name];
    LPath90_ = [Opt.LFolder, '\', Opt.Ldir90(icw).name];

    [cw(icw).xRaw, cw(icw).yRaw, cw(icw).Params] = ...
        eprloadQuad(LPath0_, LPath90_);
    
    cw(icw).x = (cw(icw).xRaw - B0Offset)/10; % mT
    newStr = strsplit(Opt.Ldir0(icw).name, '_');
    cw(icw).Title = [newStr{3}, ' ', newStr{4}];
end

%% Baseline correction

Opt.Bl.Order = 2;
Opt.Bl.Range = [335 337.5; 345 348];

for icw = 1:ncw
    cw(icw).BlOpt = Opt.Bl;
    % y1 is the spectrum baseline corrected but not phase corrected
    [cw(icw).y1, cw(icw).Bl] = ...
        subtractBaseline(cw(icw).x, cw(icw).yRaw, Opt.Bl);
end

figure();
tiledlayout(4, 2)
for icw = 1:ncw; nexttile()
    plot(cw(icw).x, real(cw(icw).yRaw), cw(icw).x, real(cw(icw).Bl));
    xlim(setAxLim(cw(icw).x, 0)); ylim(setAxLim(real(cw(icw).yRaw), 0.2));
    xline(Opt.Bl.Range(1,2)); xline(Opt.Bl.Range(2,1));
    nexttile()
    plot(cw(icw).x, imag(cw(icw).yRaw), cw(icw).x, imag(cw(icw).Bl)); 
    xlim(setAxLim(cw(icw).x, 0)); ylim(setAxLim(imag(cw(icw).yRaw), 0.2));
    xline(Opt.Bl.Range(1,2)); xline(Opt.Bl.Range(2,1));
end

%% Phase correction

for icw = 1:ncw
    % y2 is the spectrum baseline and phase corrected
    [cw(icw).y2, cw(icw).Phase] = correctPhase(cw(icw).y1, 'Maximum');
    cw(icw).y = real(cw(icw).y2);
end

figure();
tiledlayout('flow');
for icw = 1:ncw;  nexttile; 
    plot(cw(icw).x, real(cw(icw).y2), cw(icw).x, imag(cw(icw).y2));
    xlim(setAxLim(cw(icw).x, 0)); ylim(setAxLim(real(cw(icw).y2), 0.2)); 
end

%% Manual phase correction (mpc)
mpcModel = @(y2, p) y2 * exp(1i*p*pi/180);
mpcArray = zeros(numel(cw(1).x), 181); % Array of phase corrected data
mpc = {mpcArray, mpcArray, mpcArray, mpcArray};
for impc = 1:ncw
    mpcArray_ = mpcArray;
    for iP = -90:90
        mpcArray_(:,90 + iP + 1) = mpcModel(cw(impc).y2, iP*1);
    end
    mpc{impc} = mpcArray_;

    figure()
    p0 = 23; % Phase at which the scrollable starts
    h1 = ScrollableAxes('Index', 91 + 1 + p0); 
    plot(h1, cw(impc).x, -90:90, real(mpc{1, impc}));
    hold on
    plot(h1, cw(impc).x, -90:90, imag(mpc{1, impc}));
end

%% SNR
figure();
tiledlayout('flow');
for icw = 1:ncw
    cw(icw).smoothY = datasmooth(cw(icw).y, 4, 'savgol');
    nexttile
    plot(cw(icw).x, cw(icw).y, cw(icw).x, cw(icw).smoothY)
    xlim(setAxLim(cw(icw).x, 0)); ylim(setAxLim(cw(icw).y, 0.2)); 
    title(cw(icw).Title)

    [~, cw(icw).ppAmp, ~] = ...
        getSNR(cw(icw).x, cw(icw).smoothY, Opt.Bl.Range, 'Stdev');
    [~, ~, cw(icw).NoiseStdev] = ...
        getSNR(cw(icw).x, cw(icw).y, Opt.Bl.Range, 'Stdev');
    [~, ~, cw(icw).NoisePp] = ...
        getSNR(cw(icw).x, cw(icw).y, Opt.Bl.Range, 'PeakToPeak');
    cw(icw).SnrStdev = cw(icw).ppAmp/cw(icw).NoiseStdev;
    cw(icw).SnrPp = cw(icw).ppAmp/cw(icw).NoisePp;
end

%% Final plot
subplotID = ["(a)", "(b)", "(c)", "(d)"];
figure()
tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact')
for icw = 1:ncw; nexttile
    plot(cw(icw).x, cw(icw).y)
    hold on
    rectangle('Position', [0 -50 Opt.Bl.Range(1, 2) 300], ...
        'FaceColor', [0.92 0.92 0.92], 'EdgeColor', [0.7 0.7 0.7]);
    rectangle('Position', [Opt.Bl.Range(2, 1) -50 200 300], ...
        'FaceColor', [0.92 0.92 0.92], 'EdgeColor', [0.7 0.7 0.7]);
    
    h = get(gca, 'Children');
    set(gca,'Children',[h(3) h(2) h(1)])
    set(gca, "Layer", "top")
    
    yline(cw(icw).NoiseStdev/2); yline(-cw(icw).NoiseStdev/2);
    yline(cw(icw).NoisePp/2, 'r'); yline(-cw(icw).NoisePp/2, 'r');
    yline(max(cw(icw).smoothY), 'b'); yline(min(cw(icw).smoothY), 'b');
    xlim(setAxLim(cw(icw).x, 0)); ylim(setAxLim(cw(icw).y, 0.1));
    xticks(336:2:346);
    if icw == 1 || icw == 3
        ylabel('EDMR signal [a. u.]', 'FontSize', 10)
    end
    if icw > 2
        xlabel('Magnetic field [mT]', 'FontSize', 10)
    end

    text(0.05, 0.9, subplotID(icw), 'Units', 'normalized', ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'BackgroundColor', [0.92 0.92 0.92])
    annStr = {sprintf('SnrStdev = %.1f', string(cw(icw).SnrStdev)), ...
        sprintf('SnrPp = %.1f', string(cw(icw).SnrPp))};
    text(0.05, 0.15, annStr, 'Units', 'normalized', ...
        'FontSize', 8, ...
        'BackgroundColor', 'white', ...
        'EdgeColor', 'black');
    % title(cw(icw).Title)
end
nexttile(1); yticks([-4 0 4]);
nexttile(2); yticks([-1.5 0 1.5]);
nexttile(3); yticks([-0.5 0 0.5]);
nexttile(4); yticks([-14 0 14]);

exportgraphics(gcf, [Opt.LFolder, '/Comparison preamp settings.png'])
