%% Fit Field domain


function [y0, bl] = BaseLineCorrectionField(x, y0, varargin)
% x = 1xN double: B axis
% y0 = 1xN double: slice in the B-domain
Opt = parseOptions(varargin{:});

% find the baseline region

width = (max(x) - min(x)) * Opt.Width;
idx = (x <= min(x)+width) | (x >= max(x)-width);

[P, S, mu] = polyfit(x(idx), y0(idx), Opt.Order);

%[h,Fit] = polyfit(B0, mat(500,:)',1);
bl = polyval(P, x, S, mu);
y0 =  y0 - bl;

end


%% Option parsing
function Opt = parseOptions(varargin)

% Initialize input parser object.
parser = inputParser;
parser.StructExpand = true;
parser.KeepUnmatched = true;

% Define parameters.
addParameter(parser, 'Order', 0);
addParameter(parser, 'Width', 0.15);

% Parse input.
parse(parser, varargin{:});
Opt = parser.Results;

end