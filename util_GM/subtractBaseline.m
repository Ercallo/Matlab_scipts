function [y, b] = subtractBaseline(x, y, varargin)

Opt = parseOptions(varargin{:});

% Handle complex input.
if isreal(y)

    % Define fit model.
    model = @(p) polyval(p, x);
    p = zeros(1, Opt.Order + 1);
    p(end) = mean(y);
    
    % Find baseline region.
    width = (max(x) - min(x)) * Opt.Width;
    indices = (x <= min(x)+width) | (x >= max(x)-width);
    
    % Run fit.
    options = optimoptions('lsqnonlin', 'Display', 'off');
    p = lsqnonlin(@(p) objective(y, model(p), indices), p, [], [], options);
    b = model(p);
    y = y - b;
    
else
    
    % Separate real and imaginary part and call function recursively.
    yr = real(y);
    yi = imag(y);
    [yr, br] = subtractBaseline(x, yr, Opt);
    [yi, bi] = subtractBaseline(x, yi, Opt);
    y = yr + yi*1i;
    b = br + bi*1i;
end

end


%% Fit objective.
% Minimize integral of CW signal within the baseline region.
function f = objective(y, b, indices)

y = y - b;
y = cumtrapz(y);
f = y(indices);

end



%% Option parsing
function Opt = parseOptions(varargin)

% Initialize input parser object.
parser = inputParser;
parser.StructExpand = true;
parser.KeepUnmatched = true;

% Define parameters.
addParameter(parser, 'Order', 2);
addParameter(parser, 'Width', 0.1);

% Parse input.
parse(parser, varargin{:});
Opt = parser.Results;

end