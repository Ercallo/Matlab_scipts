%% Fit time domain

function [y, b] = BaseLineCorrectiontTime(x, y)

% Define the baseline region

m = x(1:100);
n = y(1:100);

% Define the fit model

[h,Fit] = polyfit(m,n,0);

b= zeros (length(y),1) + h;

y = y - b;

end


