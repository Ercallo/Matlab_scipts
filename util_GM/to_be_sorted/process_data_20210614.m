clearvars;
clc;
clear;


%% Parameters
Opt.Dir = '20210614';
Opt.Order = 1;

%% CW data
addpath('d:\Profile\out\Desktop\Denver\20210614'); 

%% Data Import

dati=dir('*.DTA');
dati={dati(:).name};
dati=dati';

%% Data analysis light


file1 = dati(contains(dati,'_0Deg_Light.DTA'));
file2 = strrep(file1, '_0Deg_Light', '_90Deg_Light');

Title = strrep(file1, '_',' ');

file1(9) = [];
file2(9) = [];
Title(9) = [];


Data = repmat(struct, 1, numel(file1));

for i= 1:numel(file1)
    
    a = [file1{i}];
    c = [file2{i}];
    
    [x, y, P] = eprloadQuad(a,c);
    [S, b] = subtractBaseline(x, y, Opt);
    [Sig, phase] = correctPhase(S);
    
    yint = cumtrapz(x, y);
    [~, k] = max(abs(yint));
    yint = yint * sign(yint(k));
    
    Data(i).Field = x;
    Data(i).SignalFresh = y;
    Data(i).SignalBLC = S;
    Data(i).SignalPhase = Sig;
    Data(i).Integrated = yint;
    Data(i).Baseline = b;
    Data(i).Phase = phase;
    
    figure(i)
    
    subplot(3,1,3);
    plot(Data(i).Field,real(Data(i).SignalPhase),Data(i).Field,imag(Data(i).SignalPhase));
    xlabel('B0 [mT]');
    ylabel('Signal [a.u.]');
   
    subplot(3,1,2);
    plot(Data(i).Field,real(Data(i).SignalBLC),Data(i).Field,imag(Data(i).SignalBLC));
    ylabel('Signal [a.u.]');
    title('14 06 2021')
    
    subplot(3,1,1);
    plot(Data(i).Field,real(Data(i).SignalFresh),Data(i).Field,real(Data(i).Baseline),Data(i).Field,imag(Data(i).SignalFresh),Data(i).Field,imag(Data(i).Baseline));
    ylabel('Signal [a.u.]');
    title(Title{i})
end

%% Data analysis dark

file1Dark = dati(contains(dati,'_0Deg_Dark.DTA'));
file2Dark = strrep(file1Dark, '_0Deg_Dark', '_90Deg_Dark');

TitleDark = strrep(file1Dark, '_',' ');

DataDark = repmat(struct, 1, numel(file1Dark));

for i= 1:numel(file1Dark)
    
    d = [file1Dark{i}];
    e = [file2Dark{i}];
    
    [x, y, P] = eprloadQuad(d,e);
    [S, b] = subtractBaseline(x, y, Opt);
    [Sig, phase] = correctPhase(S);
    
    yint = cumtrapz(x, y);
    [~, k] = max(abs(yint));
    yint = yint * sign(yint(k));
    
    DataDark(i).Field = x;
    DataDark(i).SignalFresh = y;
    DataDark(i).SignalBLC = S;
    DataDark(i).SignalPhase = Sig;
    DataDark(i).Integrated = yint;
    DataDark(i).Baseline = b;
    DataDark(i).Phase = phase;
    
    figure(numel(file1)+i)
    
    subplot(3,1,3);
    plot(DataDark(i).Field,real(DataDark(i).SignalPhase),DataDark(i).Field,imag(DataDark(i).SignalPhase));
    xlabel('B0 [mT]');
    ylabel('Signal [a.u.]');
   
    
    subplot(3,1,2);
    plot(DataDark(i).Field,real(DataDark(i).SignalBLC),DataDark(i).Field,imag(DataDark(i).SignalBLC));
    ylabel('Signal [a.u.]');
    title('14 06 2021')
     
    subplot(3,1,1);
    plot(DataDark(i).Field,real(DataDark(i).SignalFresh),DataDark(i).Field,real(DataDark(i).Baseline),DataDark(i).Field,imag(DataDark(i).SignalFresh),DataDark(i).Field,imag(DataDark(i).Baseline));
    ylabel('Signal [a.u.]');
    title(TitleDark{i})
end

    
  
