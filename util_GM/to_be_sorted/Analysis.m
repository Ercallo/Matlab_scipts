clearvars;
clc;
clear;
clf;

[B,Spc,Opt]=eprload('002_1p0V_PEDMR_Field_Sweep_20db_100ns_10scan_12p5K_Light.DTA');

Opt.Order = 1;

t=B{1}';
B0=B{2}';

s = Spc(:,300);

c = Spc(200,:)';

[M,N] = size(Spc);

mat = zeros(M,N);

DatiBLC =zeros(M,N);

Fit1200 = load('Fit1200.mat');

%% Baseline subraction time domain

data = repmat(struct, 1, N);



for i = 1:N
    
    [mat(:, i), b] = BaseLineCorrection(t, Spc(:,i));
    
    data(i).Time = t;
    data(i).SignalFresh = Spc;
    data(i).SignalBLC = mat(:,i);
    data(i).Baseline = b;
       
end

%% Baseline subtraction field domain
    
%[y0, l] = BaseLineCorrectiontField(B0,mat);

%% Find the baseline region

field = repmat(struct, 1, N);

line = zeros(M,3);

for i = 1:M
   
    width = (max(B0) - min(B0)) * 0.02;
    indices = (B0 <= min(B0)+30) | (B0 >= max(B0)-30);

    k = B0(indices);
    mat1 = mat(i,indices)';

    [h,Fit] = polyfit(k, mat1,2);

    l= polyval(h,B0)  ;
    
    line(i,:) = h;

    y0 =  mat(i,:)' - l;
    
    DatiBLC(i,:)= y0;
    
    field(i).Field = B0;
    field(i).SignalFresh = mat;
    field(i).SignalBLC = y0;
    field(i).Baseline = l;
       
    
end


%% Plot

aa=1000;  %Starting value to calculate the fit in the time domain 
bb=32768;
cc = 150;   %Define the position of the peak in the field domain



figure(1)
plot(B0, mat(125,:)');
hold on
plot(B0,field(125).Baseline,'g');
plot(B0, DatiBLC(125,:),'r');
xline(min(B0)+30)
xline(max(B0)-30)
legend('pulito','bl','blc')



figure(2)
surf(B0,data(1).Time(aa:bb),DatiBLC(aa:bb,:));
shading interp;
colorbar;

figure(3)
imagesc(field(1).Field,data(1).Time(aa:bb)/1000,DatiBLC(aa:bb,:));
xlabel('B0 [G]')
ylabel('Time [us]')
title('2D Field Sweep')
colorbar;
set(gca, 'YDir', 'normal')
cmap = colormap('hot');
%cmap = [1 0 0
 %       1 1 1
  %      0 1 0];
cmap = flipud(cmap);
colormap(gca, cmap)


figure(5)
plot(t(1:end)/1000, DatiBLC(1:end,133),'b');
legend('Slice at B0 = 3462 G')
xlabel('t [us]')
ylabel('Current [a.u]')
title('Transient')



%% Exponential fit of the broad signal

start = cc-10;
final = cc+10;

options = optimset('display','off');

for i = start:final

    y = DatiBLC(aa:end,i);

    x = t(aa:end);

    initialTau = 50000;

    % Fit tau.
    Fit.Tau(i-start+1) = lsqnonlin( @(p) y - model(x, y, p), initialTau, [],[], options);
    
    % Get the amplitude for the fit result.
    [yfit, Fit.Amplitude(i-start+1)] = model(x, y, Fit.Tau(i-start+1));
    
    
    figure(1)
    subplot(4,7,i-start+1)
    hold on
    plot(x, y);
    plot(x, yfit);
    legend('Data', 'Fit');
    hold off
    
end

Fit.media_Tau = mean(Fit.Tau);

%% Fit with fixed Tau to find the amplitude of the broad peak all over the field range

model2 = @(a) a*exp(-x/Fit.media_Tau);

for i = 1:N

    y = DatiBLC(aa:end,i);

    x = t(aa:end);

    initialAmplitude = 4000;
    
    
    % Fit tau.
    
    Fit.Amplitude2(i) = lsqnonlin( @(p) y - model2(p), initialAmplitude, [],[], options);
    
    
    %{
    figure(1)
    subplot(4,7,i-start+1)
    hold on
    plot(x, y);
    plot(x, model2(Fit.Amplitude2(i-start+1)));
    legend('Data', 'Fit');
    hold off
    %}
end
%%
figure(1)
plot(B0,Fit.Amplitude2, 'o')

%% Fit on the first hyperfine peak

% Here we start the fit keeping the time constant and the amplitude of the
% broad peak fixed

dd = 1200; % starting point to fit the transiet (after 60 us)

ee = 135;   %Define the position of the peak in the field domain

inizio = ee-7;
fine = ee+7;

x = t(dd:end);

model2 = @(a) a*exp(-x/Fit.media_Tau);

for i = inizio:fine
           
    y = DatiBLC(dd:end,i) - model2(Fit.Amplitude2(i));
   
    initialTau = 10000;

    % Fit tau.
    Fit.Tau_hf(i-inizio+1) = lsqnonlin( @(p) y  - model(x, y, p), initialTau, [],[], options);
    
    % Get the amplitude for the fit result.
    [yfit, Fit.Amplitude_hf(i-inizio+1)] = model(x, y, Fit.Tau_hf(i-inizio+1));
    
    
    figure(2)
    subplot(3,5,i-inizio+1)
    hold on
    plot(x, y);
    plot(x, yfit);
    legend('Data', 'Fit');
    hold off
    
end

Fit.media_Tau_hf = mean(Fit.Tau_hf);

%% Fit with fixed Tau hf to find the amplitude of the hf peak all over the field range
x = t(dd:end);
model5 = @(a) a*exp(-x/Fit.media_Tau_hf);

for i = 1:N

    y = DatiBLC(dd:end,i) - model2(Fit.Amplitude2(i));



    initialAmplitude = 4000;
    
    
    % Fit tau.
    
    Fit.Amplitude5(i) = lsqnonlin( @(p) y - model5(p), initialAmplitude, [],[], options);
   
end




%% Fit fixing the time constants and varying the amplitude of hf and the broad peak

model3 = @(amp1) amp1*exp(-x/Fit.media_Tau);

model4 = @(amp2) amp2*exp(-x/Fit.media_Tau_hf);

for i = 1:N
    
    
    x = t(dd:end);
    
    y = DatiBLC(dd:end,i);

    
    initialAmplitude1 = 40000;
    
    initialAmplitude2 = 10000;
    
    
    % Fit both the amplitudes.
    
    fitamp = lsqnonlin( @(p) y - model3(p(1)) - model4(p(2)), [initialAmplitude1, initialAmplitude2], [],[], options);
    Fit.Amplitude3(i) = fitamp(1);
    Fit.Amplitude4(i) = fitamp(2);
end
%%

figure(1)
plot(B0,Fit.Amplitude3,  B0, Fit.Amplitude4, 'k');
hold on
plot(B0,Fit1200.Fit.Amplitude4,' r');


%%
clf;
Diff = Fit.Amplitude3-Fit.Amplitude2;




Error1 = Diff ./ Fit.Amplitude3;

Error1 =  (Fit.Amplitude3 - Fit1200.Fit.Amplitude3) ./ Fit1200.Fit.Amplitude3;

Error2 =  (Fit.Amplitude4 - Fit1200.Fit.Amplitude4) ./ Fit1200.Fit.Amplitude4;


figure(2)
plot(B0,Fit.Amplitude2,  B0, Fit.Amplitude3);

figure(3)
plot(B0,Fit.Amplitude5,  B0, Fit.Amplitude4, 'k');

figure(7)
plot(B0,Fit.Amplitude2, 'b');
hold on
plot(B0,Fit.Amplitude5, 'r');
legend('Hyperfine Deconvolution', 'Broad Peak Deconvolution')
xlabel('B0 [G]')
ylabel('Current [a.u.]')

vv = 1000;

figure(4)
plot(B0, DatiBLC(vv,:), 'b');
hold on;
plot(B0, Fit.Amplitude3*exp(-t(vv)/Fit.media_Tau)+Fit.Amplitude4*exp(-t(vv)/Fit.media_Tau_hf), 'r');
legend('Slice at 50 us', 'Singal Deconvoluted')
xlabel('B0 [G]')
ylabel('Current [a.u.]')



q=1:21;

w=1:15;

figure(5)
plot(q,Fit.Tau,'*')
hold on
yline(Fit.media_Tau)

figure(6)
plot(w,Fit.Tau_hf,'*')
hold on
yline(Fit.media_Tau_hf)


%% Linear/non-linear fitting model
% I hope, you have the most recent MATLAB version, otherwise functions
% within a script might not be possible.
function [yfit, amplitude] = model(x, y, tau)

% First calculate the exponential without scaling, then fit the linear
% scaling parameter.
yfit = exp(-x/tau);
amplitude = yfit(:) \ y(:); % Solve linear equation: yfit * amplitude = y.
yfit = yfit * amplitude;

end



%% Plot

%{
figure(2)
plot(data(1).Time, data(1).SignalFresh(:,1), 'b',  data(1).Time, data(1).Baseline, 'b', data(1).Time, data(1).SignalBLC, 'b')
hold on
plot(data(100).Time, data(100).SignalFresh(:,100), 'r', data(100).Time, data(100).Baseline, 'r', data(100).Time, data(100).SignalBLC, 'r')
plot(data(300).Time, data(300).SignalFresh(:,300), 'g', data(300).Time, data(300).Baseline, 'g', data(300).Time, data(300).SignalBLC, 'g')


figure(1)
imagesc(B0,t,Spc);
colorbar;

figure(3)
imagesc(data(1).Time,B0,mat);
colorbar;

figure(4)
surf(B0,data(1).Time,mat);
shading interp;
colorbar;

%}

%{
width = (max(B0) - min(B0)) * 0.1;
indices = (B0 <= min(B0)+width) | (B0 >= max(B0)-width);

k = B0(indices);
mat1 = mat(1000,indices)';

[h,Fit] = polyfit(k, mat1,1);

%[h,Fit] = polyfit(B0, mat(500,:)',1);

l= zeros (N,1) + h(2) + h(1) * B0  ;

y0 =  mat(1000,:)' - l;


%}
%{


%% Exponential fit questo abbiamo visto che funziona 



y = DatiBLC(aa:end,cc);

x = t(aa:end);

fun = @(z) z(1)*exp(-x./z(2)) - y;


z0= [3000, 1e5 ];

options.Algorithm = 'levenberg-marquardt';
FIT = lsqnonlin(fun,z0, [], [], options)


plot(x,y,'ko',x,fun(FIT) + y,'b-')
legend('Data','Best fit')
xlabel('t')
ylabel('exp(-tx)')

%}

%{
%% Fit with fixed Tau

for i = start:final

    y = DatiBLC(aa:end,i);

    x = t(aa:end);

    initialAmplitude = 4000;
    
    model2 = @(a) a*exp(-x/media_Tau);
    % Fit tau.
    
    Fit.Amplitude2(i-start+1) = lsqnonlin( @(p) y - model2(p), initialAmplitude);
    
    
    %{
    figure(1)
    subplot(4,7,i-start+1)
    hold on
    plot(x, y);
    plot(x, model2(Fit.Amplitude2(i-start+1)));
    legend('Data', 'Fit');
    hold off
    %}
end

figure(1)
plot(B0(start:final),Fit.Amplitude2, 'o')

%% Fit fixing the time constants and varying the amplitude of hf and the broad peak

model3 = @(amp) amp(1)*exp(-x/media_Tau) + amp(2)*exp(-x/media_Tau_hf);

model4 = @(amp2) amp2*exp(-x/media_Tau_hf);

for i = 1:N
    
    
    x = t(dd:end);
    
    y = DatiBLC(dd:end,i);

    
    initialAmplitude1 = 40000;
    
    initialAmplitude2 = 10000;
    
    
    % Fit both the amplitudes.
    
    fitamp = lsqnonlin( @(p) y - model3(p), [initialAmplitude1, initialAmplitude2], [],[], options);
    Fit.Amplitude3(i) = fitamp(1);
    Fit.Amplitude4(i) = fitamp(2);
end

%}
