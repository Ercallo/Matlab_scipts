function [y, phase] = correctPhase(y, varargin)
% Phase correction for signals in orthogonal channels.
%
% [y, phase] = correctPhase(y)
% [y, phase] = correctPhase(y, Mode)
%
% Input:
%   y       spectrum, complex vector of length N
%   Mode    criterium for phase correction, string or char vector
%       Integral    minimize the area under the imaginary part of the
%                   spectrum
%       Maximum     minimize the peak to peak amplitude of the imaginary
%                   part of the spectrum
% Output:
%   y       spectrum phase corrected (real part)
%   phase   corresponding phase

Opt = parseOptions(varargin{:});

% Define fit model.
model = @(p) y*exp(1i*p*pi/180);
objective = @(p) imag(cumtrapz(model(p)));
if strcmp(Opt.Mode, "Maximum")
    objective = @(p) imag(max(model(p) - min(model(p))));
end

p0 = 0;
lb = -90;
ub = 90;
options = optimoptions('lsqnonlin', 'Display', 'off');

% Run fit.
phase = lsqnonlin(@(p) objective(p), p0, lb, ub, options);
y = model(phase);

end

%% Options parsing
function Opt = parseOptions(varargin)

if nargin == 0
    Opt.Mode = "Integral";
else
    % Initialize input parser object.
    parser = inputParser;
    parser.StructExpand = true;
    parser.KeepUnmatched = true;
    
    % Define parameters.
    expectedModes = {'Integral', 'Maximum'};
    addParameter(parser, 'Mode', 'Integral', ...
        @(x) any(validatestring(x,expectedModes)))
    
    % Parse input.
    parse(parser, struct('Mode', varargin{:}));
    Opt = parser.Results;
end

end