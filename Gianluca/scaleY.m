function [scaledY, propFactor] = scaleY(y, ref)
% Scale y to the same peak to peak amplitude as ref.
%
% Input:
%   y       vector to scale
%   ref     vector taken as reference
%
% Output:
%   

ppAmpRef = max(ref) - min(ref);
ppAmpY = max(y) - min(y);
propFactor = ppAmpRef/ppAmpY;
scaledY = propFactor*y;

end