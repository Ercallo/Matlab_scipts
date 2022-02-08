function [y, phase] = correctPhaseMaxima(y)

% Define fit model.
model = @(p) y * exp(1i*p*pi/180);
objective = @(p, y) imag(max(model(p) - min(model(p))));
[~, p] = correctPhase(y);
lb = -90;
ub = 90;
options = optimoptions('lsqnonlin', 'Display', 'off');

% Run fit.
phase = lsqnonlin(@(p) objective(p, y), p, lb, ub, options);
y = model(phase);

end