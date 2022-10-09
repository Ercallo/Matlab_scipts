function [f] = ScrollableLayout(t, B, z, varargin)
% Scrollable Axes in a tiledlayout
% varargin{1} = struct(zfit: fit, 
%                      hfit: scrollable axis for the plot {h1|h4})
% 
f = figure();
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile,
h1 = ScrollableAxes(); plot(h1, B, t, z);
if nargin > 3 && varargin{1}.hfit == "h1"
    zfit = varargin{1}.zfit;
    hold on; plot(h1, B, t, zfit, 'Color', 'red');
end

nexttile(4);
h2 = ScrollableAxes(); plot(h2, t, B, z);
if nargin > 3 && varargin{1}.hfit == "h4"
    zfit = varargin{1}.zfit;
    hold on; plot(h2, t, B, zfit, 'Color', 'red');
end

nexttile(2),
imagesc(B, t, z);
cmap = 'viridis';
colormap(cmap); colorbar;
ax = gca; ax.YDir = 'normal';
plotXMarker(h2, 'Color', 'white'); plotYMarker(h1, 'Color', 'white');

nexttile(1),
plotXMarker(h2, 'Color', 'black');

nexttile(4),
plotXMarker(h1, 'Color', 'black');
end

