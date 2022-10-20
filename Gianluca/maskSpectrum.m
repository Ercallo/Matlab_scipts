function [idx, x, y] = maskSpectrum(x, y, Range)
% Return values of the spectrum that are in Range.
%
% [idx, x, y] = maskSpectrum(x, y, Range)
% Input:
%   x           vector of length N
%   y           spectrum, vector of length N
%   Range       segments of the spectrum to return as output (expressed
%               in the units of x),
%               double (Mx2): [x11 x12; x21 x22; ...]
%
% Output:
%   idx         array of masked indeces, logical of length N
%   x           masked x
%   y           masked y

[M, ~] = size(Range);
idx = zeros(size(x));
for iM = 1:M
    idx_ = (x >= Range(iM, 1)) & (x <= Range(iM, 2));
    idx = idx + idx_;
end
idx = logical(idx);

x = x(idx);
y = y(idx);

end