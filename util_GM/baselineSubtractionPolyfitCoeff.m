function [y, b, p] = baselineSubtractionPolyfitCoeff(x, y, varargin)
% Baseline correction with a polynomial function.
% @param (1xN) double x
% @param (1xN) double y
% @param varargin: Opt (Opt.Order, Opt.Range, Opt.Range1)
% @return y: baseline corrected signal
% @return b: baseline
Opt = parseOptions(varargin{:});

if isreal(y)
    % Define the baseline region
    if isempty(Opt.Range)
        X = x;
        Y = y;
    elseif isempty(Opt.Range1)
        X = x(Opt.Range(1) : Opt.Range(2));
        Y = y(Opt.Range(1) : Opt.Range(2));
    else
        % s = size(x);
        % if s(1) > 1
        %     X = [x(Opt.Range(1): Opt.Range(2)); x(Opt.Range1(1): Opt.Range1(2))];
        %     Y = [y(Opt.Range(1): Opt.Range(2)); y(Opt.Range1(1): Opt.Range1(2))];
        % else
        X = [x(Opt.Range(1): Opt.Range(2)) x(Opt.Range1(1): Opt.Range1(2))];
        Y = [y(Opt.Range(1): Opt.Range(2)) y(Opt.Range1(1): Opt.Range1(2))];
    end
    % Polynomial fit
    [p, ~, mu] = polyfit(X, Y, Opt.Order);
    % Baseline calculation
    b = polyval(p, x, [], mu);
    % Baseline subtraction
    y = y - b;
else
    % Separate real and imaginary part and call function separately.
    yr = real(y);
    yi = imag(y);
    [yr, br] = baselineSubtractionPolyfitCoeff(x, yr, Opt);
    [yi, bi] = baselineSubtractionPolyfitCoeff(x, yi, Opt);
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
addParameter(parser, 'Range', []);
addParameter(parser, 'Range1', []);

% Parse input.
parse(parser, varargin{:});
Opt = parser.Results;
end


