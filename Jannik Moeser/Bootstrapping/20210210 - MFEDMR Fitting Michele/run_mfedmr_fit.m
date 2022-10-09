clearvars
file = 'Umeda2000_MFESR_digitized_20201019';
load(file);

X = num2cell(X, 1);
Y = num2cell(Y, 1);

Sys.g = [2.015, 2.01, 2.005];
Sys.gStrain = [0.01, 0.007, 0.005];
Sys.lw = 1;
Sys.FieldOffset = [0, 0, 0];
Sys.Scaling = [1, 2, 3];

Vary.g = [0.005, 0.005, 0.005];
Vary.gStrain = Sys.gStrain;
Vary.lw = Sys.lw;
Vary.FieldOffset = [0 0.2 1];
Vary.Scaling = Sys.Scaling .* [0, 1, 1];

Exp.mwFreqPerSpectrum = num2cell(Frequency);
Exp.Harmonic = 0;

mfesfit(X, Y, Sys, Vary, Exp)