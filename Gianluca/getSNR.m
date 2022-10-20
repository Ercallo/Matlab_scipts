function [Snr, ppAmp, noiseLev] = getSNR(x, y, noiseRange, varargin)
% Calculate signal to noise ratio, defined as the ratio between peak to
% peak intensity of the signal over the standard deviation of the noise
% distribution. The peak to peak amplitude of the signal is calculated over
% all the spectrum, while the standard deviation of the noise is calculated
% only in the noiseRange region.
%
% [Snr, ppAmp, noiseLev] = getSNR(x, y, noiseRange, Mode)
% Input:
%   x           vector of length N
%   y           spectrum, vector of length N
%   noiseRange  segments of the spectrum considered as noise (expressed
%               in the units of x),
%               double (Mx2): [x11 x12; x21 x22; ...]
%   Mode        determines how the NoiseLev is calculated, Stdev (default)
%               or PeaktoPeak
%
% Output:
%   Snr         signal to noise ratio, float
%   ppAmp       amplitude peak to peak of the signal, float
%   noiseLev    noise level, depends on selected Mode
%               standard deviation (Stdev mode) or peak to peak 
%               amplitude (PeakToPeak mode) of the noise distribution

Opt = parseOptions(varargin{:});

ppAmp = max(y) - min(y);
[~, ~, noiseY] = maskSpectrum(x, y, noiseRange);
if strcmp(Opt.Mode, "PeakToPeak")
    noiseLev = max(noiseY) - min(noiseY);
elseif strcmp(Opt.Mode, "Stdev")
    noiseLev = std(noiseY);
end
Snr = ppAmp/noiseLev;

end

%% Options parsing
function Opt = parseOptions(varargin)

if nargin == 0
    Opt.Mode = "Stdev";
else
    % Initialize input parser object.
    parser = inputParser;
    parser.StructExpand = true;
    parser.KeepUnmatched = true;
    
    % Define parameters.
    expectedModes = {'Stdev', 'PeakToPeak'};
    addParameter(parser, 'Mode', 'Stdev', ...
        @(x) any(validatestring(x,expectedModes)))
    
    % Parse input.
    parse(parser, struct('Mode', varargin{:}));
    Opt = parser.Results;
end

end