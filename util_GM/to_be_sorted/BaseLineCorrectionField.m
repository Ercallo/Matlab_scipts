%% Fit Field domain


function [y0, l] = BaseLineCorrectiontField(x, y0, varargin)

Opt = parseOptions(varargin{:});

% find the baseline region

width = (max(x) - min(x)) * Opt.Width;
indices = (x <= min(x)+width) | (x >= max(x)-width);

k = x(indices);
mat1 = y0(100,indices);


[h,Fit] = polyfit(k, mat1,Opt.Order);

%[h,Fit] = polyfit(B0, mat(500,:)',1);

l= zeros (301,1) + h(2) + h(1) * x  ;

y0 =  y0(100,:)' - l;

end


%% Option parsing
function Opt = parseOptions(varargin)

% Initialize input parser object.
parser = inputParser;
parser.StructExpand = true;
parser.KeepUnmatched = true;

% Define parameters.
addParameter(parser, 'Order', 1);
addParameter(parser, 'Width', 0.2);

% Parse input.
parse(parser, varargin{:});
Opt = parser.Results;

end