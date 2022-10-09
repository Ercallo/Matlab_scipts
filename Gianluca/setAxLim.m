function outRange = setAxLim(x, Ratio)
% Return a range that is perc times bigger than the range between the 
% maximum and the minimum of x. Useful to set limits for both axes of a
% plot.
%
% Input:
%   x           vector
%   Ratio       (outRange - ppAmp)/outRange, usually set at 0.2
%
% Output:
%   outRange    new range to give as input to xlim or ylim

ppAmp = max(x) - min(x);
RangeMin = min(x) - ppAmp*Ratio;
RangeMax = max(x) + ppAmp*Ratio;
outRange = [RangeMin RangeMax];

end