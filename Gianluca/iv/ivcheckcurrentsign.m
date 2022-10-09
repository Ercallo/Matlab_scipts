function [V, I] = ivcheckcurrentsign(V, I)
% Return I in such a way that Iph is positive. This is equivalent to have 
% the forward bias regime in the forth (lower right) quadrant.
% The function works for IV curves with forward bias on the first 
% (upper right) quadrant and third (lower left) quadrant.
% Return V in ascending order.
%
% [V, I] = checksigns(V, I)
% Input:
%   V   voltage, vector of length n
%   I   current, vector of length n
%
% Output:
%   V   voltage in ascending order
%   I   current with forward bias region in the forth quadrant

[~, idx] = max(abs(I));
if idx < 10
    % IV curve in the third quadrant
    V = -V;
else
    % IV curve in the first quadrant
    I = -I;
end

% Return V in ascending order
if V(end) < V(1)
    V = flip(V);
    I = flip(I);
end
end