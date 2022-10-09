%% General script for initial correction of cwEDMR data
clearvars, clear, clc, close all
addpath(genpath('D:\Profile\qse\matlab_util'));

load('D:\Profile\qse\NREL\2022_spring\20220301\data_analysis\cw10K_100sc_BlcPc.mat')
load('D:\Profile\qse\NREL\2022_spring\20220301\data_analysis\fit_boot\cw10K_100sc_fit_three.mat')
yold = y; yfitold = yfit; xold = x;
figure()
[pepy, F] = scaleY(pepper(Sys,Exp), y); pepy = pepy(5:end-5);
pep1 = pepper(Sys{1,1}, Exp); pep1 = F*pep1(5:end-5);
pep2 = pepper(Sys{1,2}, Exp); pep2 = F*pep2(5:end-5);
plot(x,y,x,pepy);
hold on
plot(x, pep1, 'r');
plot(x, pep2, 'k');

DInt2 = cumtrapz(cumtrapz(pep2));
DInt1 = cumtrapz(cumtrapz(pep1));

%%
figure()
tiledlayout(2,1)
nexttile, plot(x, pep2, x, DInt2/500)
nexttile, plot(x, pep1, x, DInt1/500)

%%
load('D:\Profile\qse\NREL\2021_summer\CWEDMR\data_analysis\cw10K_BlcPc.mat')
load('D:\Profile\qse\NREL\2021_summer\CWEDMR\data_analysis\fit_boot\cw10K_fit_three.mat')
ynew = y; yfitnew = yfit;
figure()
[pepy, F] = scaleY(pepper(Sys,Exp), y);
pep1 = pepper(Sys{1,1}, Exp); pep1 = F*pep1;
pep2 = pepper(Sys{1,2}, Exp); pep2 = F*pep2;
pep3 = pepper(Sys{1,3}, Exp); pep3 = F*pep3;
plot(x,y,x,pepy);
hold on
plot(x, pep1, 'r');
plot(x, pep2, 'k');
plot(x, pep3, 'b');

DInt3 = cumtrapz(cumtrapz(pep3));
DInt12 = cumtrapz(cumtrapz(pep2 + pep1));

%%
figure()
tiledlayout(2,1)
nexttile, plot(x, pep3, x, DInt3)
nexttile, plot(x, pep2 + pep1, x, DInt12)

%%
figure()
tiledlayout(2,1)
nexttile, plot(xold, yold, xold, yfitold)
nexttile, plot(x, ynew, x, yfitnew)

%%
function varargout = scaleY(y, ref)
% Scale y to the same amplitude pp as ref
    ppAmpRef = max(ref) - min(ref);
    ppAmpY = max(y) - min(y);
    propFactor = ppAmpRef/ppAmpY;
    scaledY = propFactor*y;
    if nargout == 1
        varargout{1} = scaledY;
    else
        varargout{1} = scaledY; varargout{2} = propFactor;
    end
end