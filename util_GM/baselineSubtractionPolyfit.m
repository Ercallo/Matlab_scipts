function [y, b] = baselineSubtractionPolyfit(x, y, varargin)
% Baseline correction with a polynomial function.
% @param (1xN) double x
% @param (1xN) double y
% @param varargin: Opt (Opt.Order, Opt.Range, Opt.Range1)
% @return y: baseline corrected signal
% @return b: baseline
Opt = parseOptions(varargin{:});

if isreal(y)
    % Define the baseline region
    Width = (max(x) - min(x))*Opt.Width;
    idx = (x <= min(x) + Width) | (x >= max(x) - Width);
    
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
    [yr, br] = baselineSubtractionPolyfit(x, yr, Opt);
    [yi, bi] = baselineSubtractionPolyfit(x, yi, Opt);
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
addParameter(parser, 'Width', 0.15);

% Parse input.
parse(parser, varargin{:});
Opt = parser.Results;
end


