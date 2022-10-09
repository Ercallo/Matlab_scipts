addpath('D:\Profile\out\Desktop\ProgrammiMatlab\MultiFrequencyFit');
clearvars;
clc;
clear;

%% Load Data
load('20210223_mfesr_generated_data.mat')

X=x;
Y=y;

param = Exp;

clear Exp;

for i = 1:3
    mwFreq(i) = param{i}.mwFreq;
    %nPoints(i) = Exp{i}.nPoints;
    %Range(i) = Exp{i}.Range{1,2};   
end

%% Figure

subplot(3,1,1);
plot(x{1},y{1});
subplot(3,1,2);
plot(x{2},y{2});
subplot(3,1,3);
plot(x{3},y{3});

%% Analysis 

Sys.S = 1/2;
Sys.Nucs = 'Si';
Sys.g = [2.017 2.0084 2.0037];
Sys.gStrain = [0.011 0.0075 0.0037];
Sys.lw = [0 0.54];
Sys.FieldOffset = [0, 0, 0];
Sys.A = [144];
Sys.AStrain = [109];
Sys.Scaling = [1 3 61];


Vary.g = [0.005, 0.001, 0.001];
Vary.gStrain = Sys.gStrain;
Vary.A = [20];
Vary.AStrain = [30];
%Vary.weight = 0.6;
Vary.lw = [0 0.04];
%Vary.FieldOffset = [0 0.2 1];
%Vary.Scaling = [0 0 0];

Exp.mwFreqPerSpectrum = num2cell(mwFreq);
Exp.Harmonic = 0;

mfesfit(X, Y, Sys, Vary, Exp)
