function [Snr, ppAmp, noiseStdev] = getSNR(x, y, noiseRange)
% Calculate signal to noise ratio, defined as the ratio between peak to
% peak intensity of the signal over the standard deviation of the noise
% distribution. The peak to peak amplitude of the signal is calculated over
% all the spectrum, while the standard deviation of the noise is calculated
% only in the noiseRange region.
%
% [Snr, ppAmp, noiseStdev] = getSNR(y, noiseRange)
% Input:
%   x           vector of length N
%   y           spectrum, vector of length N
%   noiseRange  segments of the spectrum considered as noise (expressed
%               in the units of x),
%               double (Mx2): [x11 x12; x21 x22; ...]
%
% Output:
%   Snr         signal to noise ratio, float
%   ppAmp       amplitude peak to peak of the signal, float
%   noiseStdev  standard deviation of the noise distribution, float

ppAmp = max(y) - min(y);
[~, noiseY] = maskSpectrum(x, y, noiseRange);
noiseStdev = std(noiseY);
Snr = ppAmp/noiseStdev;

end