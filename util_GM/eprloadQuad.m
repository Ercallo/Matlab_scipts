function [x, y, P] = eprloadQuad(file1, file2, varargin)

% Import files.
[x1, y1, Par1] = eprload(file1);
[x2, y2, Par2] = eprload(file2);

% Combine field axes.
v1 = Par1.MWFQ * 1e-9;
v2 = Par2.MWFQ * 1e-9;
x2 = x2 * v1/v2;
y2 = interp1(x2, y2, x1, 'nearest', 'extrap');

% Combine signal;
x = x1;
y = y1 + y2*1i;
P = [Par1, Par2];

end