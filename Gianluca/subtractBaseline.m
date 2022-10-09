function [y, b, p] = subtractBaseline(x, y, varargin)
% Baseline correction with a polynomial function.
%
% [y, b, p] = subtractBaseline(x, y, Opt)
% Input:
%   x       vector of length N
%   y       spectrum, vector of length N
%   Opt     options
%       .Order  int, order of the polynomial baseline
%       .Width  fraction of spectrum at the edges considered as baseline.
%               This attribute is considered only when the attribute
%               Opt.Range doesn't exist,
%               double 0 < Width < 1
%       .Range  segments of the spectrum considered as baseline (expressed
%               in the units of x),
%               double (Mx2): [x11 x12; x21 x22; ...]
%
% Output:
%   y       spectrum baseline corrected
%   b       baseline
%   p       coefficients of the polynomial function, double (1, Opt.Order)

Opt = parseOptions(varargin{:});

if isreal(y)
    % Define the baseline region
    try
        Width = (max(x) - min(x))*Opt.Width;
        idx = (x <= min(x) + Width) | (x >= max(x) - Width);
    catch
        idx = maskSpectrum(x, y, Opt.Range);
    end

    % Polynomial fit
    [p, ~, mu] = polyfit(x(idx), y(idx), Opt.Order);
    % Baseline calculation
    b = polyval(p, x, [], mu);
    % Baseline subtraction
    y = y - b;
else
    % Separate real and imaginary part and call function separately.
    yr = real(y);
    yi = imag(y);
    [yr, br] = subtractBaseline(x, yr, Opt);
    [yi, bi] = subtractBaseline(x, yi, Opt);
    y = yr + yi*1i;
    b = br + bi*1i;
end

end

%% Option parsing
function Opt = parseOptions(varargin)

% Initialize input parser object.
parser = inputParser;
parser.StructExpand = true;
parser.KeepUnmatched = true;

% Define parameters.
addParameter(parser, 'Order', 2);

Fields = fieldnames(varargin{:});
if sum(strcmp('Range', Fields))
    addParameter(parser, 'Range', []);
else
    addParameter(parser, 'Width', 0.15, @(x) x > 0);
end

% Parse input.
parse(parser, varargin{:});
Opt = parser.Results;

end


