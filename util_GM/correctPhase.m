function [y, phase] = correctPhase(y, p0)

% Define fit model.
model = @(p) y * exp(1i*p*pi/180);
objective = @(p, y) imag(cumtrapz(model(p)));
% p = 45;
lb = -90;
ub = 90;
options = optimoptions('lsqnonlin', 'Display', 'off');

% Run fit.
phase = lsqnonlin(@(p) objective(p, y), p0, lb, ub, options);
y = model(phase);

end