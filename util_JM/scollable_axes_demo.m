% Demonstration of the baseline correction procedure with 2D plotting I
% would typically apply to a PEDMR measurement. The data file is a PEDMR
% 2D transient experiment on an a-Si:H pin solar cell, recorded at
% room temperature and 263 GHz (I used 263 GHz because it has a large
% non-resonant response, which is not the case for X-band and a-Si:H).
clearvars;
figure(1); clf;

%% Script parameters
Opt.File = 'ASIRT_001_JM2125';
Opt.TimeBaselineWidth = 10; % in µs
Opt.FieldBaselineWidth = 5; % in mT at both sides of the spectrum
Opt.InitialField = 9375;    % in mT (sets the initially plotted time-domain slice)
Opt.InitialTime = 13;       % in µs (sets the initially plotted field-domain slice)
Opt.XLabel = 'Time (µs)';
Opt.YLabel = 'Magnetic field (mT)';
Opt.ZLabel = 'Signal (a. u.)';


%% Import raw data
[abscissa, z] = eprload(Opt.File);
x = abscissa{1}.' * 1e-3; % Time in µs
y = abscissa{2} * 1e-1;   % Magnetic field in mT
z = real(z); % At 263 GHz, we measure both channels, so the signal is complex.

% Axis limits for plotting.
xlimits = [min(x), max(x)];
ylimits = [min(y), max(y)];
zlimits = [min(z(:)), max(z(:))];
zlimits = zlimits + 0.2 * abs(diff(zlimits)) * [-1 1]; % Enlarge by +/-20 %.

% This create the ScrollableAxes object (handle reference h1), which
% stores the 2D data matrices and takes care of selecting the right slice
% when we move the slider. For each subplot/tile, you have to create a new
% ScrollableAxes object and pass the handle to the plot(h, ...) functions.
% When you call the plot(h, x, y, z) function, the first abscissa (x)
% defines the plotted axis, the second (y) corresponds to the slider. 
%
% The optional 'Index' property of the ScrollableAxes object can be used
% to set the initial slider index (here to Opt.InitialField and
% Opt.InitialTime).
subplot(2, 3, 1);
[~, ky] = min(abs(y - Opt.InitialField));
h1 = ScrollableAxes('Index', ky);
plot(h1, x, y, z, 'Color', 'k'); % Time-domain plot
xlim(xlimits);
ylim(zlimits);
xlabel(Opt.XLabel);
ylabel(Opt.ZLabel);

subplot(2, 3, 4);
[~, kx] = min(abs(x - Opt.InitialTime));
h2 = ScrollableAxes('Index', kx);
plot(h2, y, x, z, 'Color', 'k'); % Field-domain plot
xlabel(Opt.YLabel);
ylabel(Opt.ZLabel);


%% Baseline subtraction

% Calculate and subtract baseline in time domain.
indices = x <= Opt.TimeBaselineWidth;
bx = mean(z(indices, :), 1);
bx = bsxfun(@times, bx, ones(size(z))); % Expand as matrix.
z = z - bx;

% Calculate and subtract baseline in field domain.
indices = (y <= min(y) + Opt.FieldBaselineWidth) | ...
          (y >= max(y) - Opt.FieldBaselineWidth);
by = bsxfun(@times, mean(z(:, indices), 2), ones(size(z)));
z = z - by;
b = bx + by; % Total baseline

% Plot the baseline into the existing plots.
subplot(2, 3, 1); 
hold on
plot(h1, x, y, b, 'Color', 'r');
hold off
xlim(xlimits);
ylim(zlimits);

subplot(2, 3, 4); 
hold on
plot(h2, y, x, b, 'Color', 'r'); 
hold off
xlim(ylimits);
ylim(zlimits);


%% Plot the baseline-corrected spectrum

% Calculate new limits for the baseline-corrected data.
zlimits = [min(z(:)), max(z(:))];
zlimits = zlimits + 0.2 * abs(diff(zlimits)) * [-1 1]; % Enlarge by +/-20 %.

% Note that we use the same ScrollableAxes objects, so the slider controls
% both plots in each row. You could also create new objects if we want to
% scroll separately between left and right column.
subplot(2, 3, 2);
h3 = ScrollableAxes('Index', ky);
plot(h3, x, y, z, 'Color', 'k'); % Time-domain plot
xlim(xlimits);
ylim(zlimits);
xlabel(Opt.XLabel);

subplot(2, 3, 5);
h4 = ScrollableAxes('Index', ky);
plot(h4, y, x, z, 'Color', 'k'); % Field-domain plot
xlim(ylimits);
ylim(zlimits);
xlabel(Opt.YLabel);

% 2D color plot of the corrected data.
subplot(1, 3, 3);
imagesc(y, x, z);
set(gca, 'YDir', 'normal') % imagesc() inverts the y axis!
xlabel(Opt.YLabel);
ylabel(Opt.XLabel);

% Change the colormap (inverted 'hot').
cmap = colormap('hot');
cmap = flipud(cmap);
colormap(gca, cmap);


%% Add slider markers
% This is an additional feature that allows to add markers into other 
% plots, which are automatically linked to the slider of a ScrollableAxes.
% We do this for the colormap plot...
subplot(1, 3, 3);
plotXMarker(h3, 'Color', 'white'); % Vertical marker (upper right slider).
plotYMarker(h4, 'Color', 'white'); % Horizontal marker (lower right slider).

% ... and for the scrollable plots themselves. Note that plotting markers
% doesn't require hold on/off.
subplot(2, 3, 2);
plotXMarker(h4, 'Color', 'black');

subplot(2, 3, 5);
plotXMarker(h3, 'Color', 'black');