clearvars;
clc;
clear;
clf;

[B,Spc,Opt]=eprload('002_1p0V_PEDMR_Field_Sweep_20db_100ns_10scan_12p5K_Light.DTA');

Opt.Order = 1;

t=B{1}';                                                                   %Time axis
B0=B{2}';                                                                  %Field axis 

[M,N] = size(Spc);

blc_field =zeros(M,N);

%Fit1200 = load('Fit1200.mat');

%% Baseline subraction time domain


blc_time = zeros(M,N);

for i = 1:N
    
    [blc_time(:, i), b] = BaseLineCorrection(t, Spc(:,i));
    
    BLC(1).SignalFresh = Spc;
    BLC(i).SignalTimeBLC = blc_time(:,i);
    BLC(i).TimeBaseline = b;
       
end

%% Baseline subtraction field domain 

fiting_coeff = zeros(M,3);

for i = 1:M
   
    %width = (max(B0) - min(B0)) * 0.02;                                    %we can define the width if we need a more general function
    indices = (B0 <= min(B0)+30) | (B0 >= max(B0)-30);

    k = B0(indices);
    fitting_region = blc_time(i,indices)';

    [h,Fit] = polyfit(k, fitting_region,2);                                 %Polynomial fitting routine to find the baseline

    l= polyval(h,B0);
    
    fiting_coeff(i,:) = h;

    blc =  blc_time(i,:)' - l;
    
    blc_field(i,:)= blc;
   
    BLC(i).SignalFieldBLC = blc;
    BLC(i).FieldBaseline = l;
    
end


%% Make the plots of the data after the baseline correction

t1=1000;                                                                    %Starting value for the time slice
t2=32768;                                                                   %Final value for the time slice
Bc = 150;                                                                   %Value for the field slice

%plot to show the baseline correction in the field domain
figure(1)
plot(B0, blc_time(125,:));
hold on
plot(B0,BLC(125).FieldBaseline,'g');
plot(B0, blc_field(125,:),'r');
xline(min(B0)+30)
xline(max(B0)-30)
legend('pulito','bl','blc')
xlabel('B0 [G]')
ylabel('Current [a.u]')
title('Base Line Correction')


%Slice in the time domain
figure(2)
plot(t(1:end)/1000, blc_field(1:end,133),'b');
legend('Slice at B0 = 3462 G')
xlabel('t [us]')
ylabel('Current [a.u]')
title('Transient')

%Slice in the field domain
figure(3)
plot(B0,blc_field(t1,:),'b')
legend('Slice at t = ? us')
xlabel('B0 [G]')
ylabel('Current [a.u]')
title('Field Sweep')

figure(4)
imagesc(B0,t(t1:t2)/1000,blc_field(t1:t2,:));
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
surf(B0,t(t1:t2),blc_field(t1:t2,:));
shading interp;
colorbar;

%% Exponential fit of the broad signal
%Here we start the deconvolution process. We check the lenght of the
%exponential decays and we select a point where we assume that there is
%just one component that is contributing to the signal. Then we have to
%select the number of points in the field domain (within the FWHM) and we
%run two different fit: one to find the time constant and one to find the
%amplitude

w_broad = 10;                                                               %Define the width of the window in the field domain of the broad peak

options = optimset('display','off');

for i = Bc-w_broad : Bc+w_broad

    y = blc_field(t1:end,i);

    x = t(t1:end);

    initialTau = 50000;

    % Fit tau.
    Fit.TauBroad(i-(Bc-w_broad)+1) = lsqnonlin( @(p) y - model(x, y, p), initialTau, [],[], options);
    
    % Get the amplitude for the fit result.
    [yfit, Fit.AmpBroad(i-(Bc-w_broad)+1)] = model(x, y, Fit.TauBroad(i-(Bc-w_broad)+1));
    
    %{
    figure(6)
    subplot(3,7,i-(Bc-w_broad)+1)
    hold on
    plot(x, y);
    plot(x, yfit);
    legend('Data', 'Fit');
    hold off   
    %}
    
end

Fit.media_Tau_Broad = mean(Fit.TauBroad);

%% Amplitude fit
% We fix the time constant Tau and we fit the amplitude of the broad peak
% all over the field range

for i = 1:N
    
    x = t(t1:end);
    y = blc_field(t1:end,i);
    f = exp(-x/Fit.media_Tau_Broad);
       
    Fit.Amplitude_broad(i) = f\y;
   
end

figure(7)
plot(B0,Fit.Amplitude_broad, 'b')

%% Fit on the first hyperfine peak

% Here we start the fit keeping the time constant and the amplitude of the
% broad peak fixed

t1_hf = 1200;                                                               % starting point to fit the transiet (after 60 us)
Bc_hf = 135;                                                                %Define the position of the peak in the field domain

w_broad_hf = 7;

x = t(t1_hf:end);

model2 = @(a) a*exp(-x/Fit.media_Tau_Broad);                                      %Define the single exp. model to perform the fitting routine 

for i = Bc_hf-w_broad_hf:Bc_hf+w_broad_hf
           
    y = blc_field(t1_hf:end,i) - model2(Fit.Amplitude_broad(i));
   
    initialTau = 10000;

    % Fit tau.
    Fit.Tau_hf(i-(Bc_hf-w_broad_hf)+1) = lsqnonlin( @(p) y  - model(x, y, p), initialTau, [],[], options);
    
    % Get the amplitude for the fit result.
    [yfit, Fit.Amplitude_hf(i-(Bc_hf-w_broad_hf)+1)] = model(x, y, Fit.Tau_hf(i-(Bc_hf-w_broad_hf)+1));
    
    
    figure(8)
    subplot(3,5,i-(Bc_hf-w_broad_hf)+1)
    hold on
    plot(x, y);
    plot(x, yfit);
    legend('Data', 'Fit');
    hold off
    
end

Fit.media_Tau_hf = mean(Fit.Tau_hf);

%% Fit with fixed Tau hf to find the amplitude of the hf peak all over the field range



for i = 1:N
    
    x = t(t1_hf:end);
    y = blc_field(t1_hf:end,i);
    f = exp(-x/Fit.media_Tau_hf);
       
    Fit.Amplitude_hf(i) = f\y;
   
end

figure(9)
plot(B0,Fit.Amplitude_hf, 'b')


%% Fit fixing the time constants and varying the amplitude of hf and the broad peak

model3 = @(amp1) amp1*exp(-x/Fit.media_Tau);

model4 = @(amp2) amp2*exp(-x/Fit.media_Tau_hf);

for i = 1:N
    
    
    x = t(t1_hf:end);
    
    y = blc_field(t1_hf:end,i);

    
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
plot(B0, blc_field(vv,:), 'b');
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



