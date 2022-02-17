clearvars;

%% Parameters
Opt.nPoints = 1024;
Opt.LineWidthFactor = 10;
Opt.SNR = 75;

%% Spin system
Sys.S = 1/2;
Sys.g = [2.017, 2.009, 2.004];
Sys.gStrain = [0.014, 0.008, 0.003];
Sys.Nucs = 'Si';
Sys.A = 200;
Sys.AStrain = 0.5*Sys.A;
Sys.lw = [0, 0.5];

Exp.mwFreq = [0.5, 9.6, 263];
Exp.nPoints = 20480;
Exp.Harmonic = 0;

%% Prepare spectra
nExp = numel(Exp.mwFreq);
Data.x = cell(1, nExp);
Data.y = cell(1, nExp);
Data.Exp = cell(1, nExp);
for i = 1:nExp
    Exp_ = Exp;
    Exp_.mwFreq = Exp.mwFreq(i);
    
    %% Simulate on a broad field range
    g = mean(Sys.g);
    v = Exp_.mwFreq*1e3;
    x0 = mhz2mt(v, mean(Sys.g));
    dx = mhz2mt(v, g-max(Sys.gStrain)) - mhz2mt(v, g+max(Sys.gStrain)) + max(Sys.lw);
    Exp_.Range = x0 + 30*dx*[-1 1];
    Exp_.Range(1) = max(Exp_.Range(1), 0);
    y = pepper(Sys, Exp_);
    
    %% Limit range by approximate FWHM
    Sys0.S = 1/2;
    Sys0.g = mean(Sys.g);
    Vary.g = 0.1;
    Sys0.lw = dx * [0, 1];
    Vary.lw = Sys0.lw;
    Fit.Method = 'simplex fcn';
    Fit.Scaling = 'maxabs';
    [Sys0, yfit] = esfit('pepper', y, Sys0, Vary, Exp_, [], Fit);
    x0 = mhz2mt(Exp_.mwFreq*1e3, Sys0.g);
    dx = max(Sys0.lw);
    
    %% Refit
    Exp_.Range = x0 + Opt.LineWidthFactor*dx*[-1 1];
    Exp_.nPoints = Opt.nPoints;
    [x, y] = pepper(Sys, Exp_);
    
    %% Scale
    y = y / max(abs(y));
    
    %% Add noise
    y = addnoise(y, Opt.SNR);
    Data.x{i} = x;
    Data.y{i} = y;
    Data.Exp{i} = Exp_;
    
    subplot(nExp, 1, i);
    plot(x, y, 'k', 'Linewidth', 1);
    xlim([min(x), max(x)]);
    ylim([-0.2, 1.2]);
    box on
    set(gca, 'Linewidth', 1, 'Fontsize', 14, 'YTick', [0 1]);
    xlabel('Magnetic field (mT)');
    ylabel('ESR signal');
end

save('20210223_mfesr_generated_data', '-struct', 'Data');