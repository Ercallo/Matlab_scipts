%% Fit time domain

function [y, bl] = BaseLineCorrectionTime(x, y, varargin)
Opt = parseOptions(varargin{:});

% Define the baseline region
xBL = x(1:Opt.Range(2));
yBL = y(1:Opt.Range(2));

% Define the fit model
[h, Fit] = polyfit(xBL, yBL, 0);

bl = zeros(length(y), 1) + h;

y = y - bl;

end

%% Option parsing
function Opt = parseOptions(varargin)

% Initialize input parser object.
parser = inputParser;
parser.StructExpand = true;
parser.KeepUnmatched = true;

% Define parameters.
addParameter(parser, 'Range', [0 100]);

% Parse input.
parse(parser, varargin{:});
Opt = parser.Results;
end

