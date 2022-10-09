function [ppAmp, yMax, yMin, xMax, xMin] = getPeakToPeakAmp(x, y)
% Find the peak to peak amplitude and positions and values of the maximum 
% and minimum of the signal y.
%
% [Snr, ppSig, noiseStdev] = getPeakToPeakAmp(x, y)
% Input:
%   x           vector of length N
%   y           spectrum, vector of length N
%
% Output:
%   ppAmp       amplitude peak to peak of the signal, float
%   yMax        value of the maximum of the signal
%   yMin        value of the minimum of the signal
%   xMax        x value of the maximum of the signal
%   xMin        x value of the minimum of the signal

[yMax, xMaxIdx] = max(y);
xMax = x(xMaxIdx);
[yMin, xMinIdx] = min(y);
xMin = x(xMinIdx);
ppAmp = yMax - yMin;
end