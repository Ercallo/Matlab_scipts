%% Prepare some fake exponential data
Input.Amplitude = 3000;
Input.Tau = 30;

x = linspace(0, 10*Input.Tau, 1e3);
y = Input.Amplitude * exp(-x/Input.Tau);
y = addnoise(y,  5, 'f');

%% Run the fit
% Separation of linear and non-linear parameters happens in the model
% function at the end of the script. The lsqnonlin solver only fits tau.
% Linear scaling is done by simple linear-equation solving (mldivide).

% Initial guess and boundaries for tau.
initialTau = 10;
lowerBound = 1;
upperBound = 1000;

% Fit tau.
Fit.Tau = lsqnonlin(...
    @(p) y - model(x, y, p), ...
    initialTau, ...
    lowerBound, ...
    upperBound);

% Get the amplitude for the fit result.
[yfit, Fit.Amplitude] = model(x, y, Fit.Tau);


%% Plot results
fprintf('\nOriginal data:\tTau = %d, Amplitude = %d\n', Input.Tau, Input.Amplitude);
fprintf('Fit result:\tTau = %.1f, Amplitude = %.0f\n\n', Fit.Tau, Fit.Amplitude);

figure(1); clf;
hold on
plot(x, y);
plot(x, yfit);
hold off


%% Linear/non-linear fitting model
% I hope, you have the most recent MATLAB version, otherwise functions
% within a script might not be possible.
function [yfit, amplitude] = model(x, y, tau)

% First calculate the exponential without scaling, then fit the linear
% scaling parameter.
yfit = exp(-x/tau);
amplitude = yfit(:) \ y(:); % Solve linear equation: yfit * amplitude = y.
yfit = yfit * amplitude;

end