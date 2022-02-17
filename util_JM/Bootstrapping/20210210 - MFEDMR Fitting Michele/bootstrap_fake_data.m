clearvars;

%% Parameters
Opt.File.Data = '20210223_mfesr_generated_data.mat';
Opt.File.InitialFit = 'tmp_initial_fit.mat';
Opt.Run.InitialFit = false;

%% Data import
Data = load(Opt.File.Data);

%% Initialize fit parameters and ranges
Sys0.g = [2.0170 2.0084 2.0037];
Sys0.gStrain = [0.0110 0.0075 0.0037];
Sys0.Nucs = 'Si';
Sys0.A = 144;
Sys0.AStrain = 109;
Sys0.lw = [0 0.54];
Sys0.Scaling = [1 3 61];

Vary.g = [0.0050 0.0040 0.0030];
Vary.gStrain = 0.9 * Sys0.gStrain;
Vary.A = 100;
Vary.AStrain = 100;
Vary.lw = 0.9 * Sys0.lw;
Vary.Scaling = Sys0.Scaling .* [0 1 1];

Exp.mwFreqPerSpectrum = cellfun(@(c) c.mwFreq, Data.Exp, 'UniformOutput', false);
Exp.Harmonic = 0;

%% Run initial fit
if Opt.Run.InitialFit || ~isfile(Opt.File.InitialFit)
    [Sys, y, yfit] = mfesfit(Data.x, Data.y, Sys0, Vary, Exp);
    save(Opt.File.InitialFit, 'Sys', 'y', 'yfit');
else
    load(Opt.File.InitialFit);
end
