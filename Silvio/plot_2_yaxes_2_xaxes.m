%% Template for plot of two y-axes vs. two x-axes with tiledlayout
% This template is helpful if you have data that you can plot against two x
% axes, e.g. B0 and g. In this case both x-axes are proportional to each
% other so that you can calculate one from the other. The limit for the
% second x-axis needs to be calculated from the limits of the first one.
% The second y-axis is proportional to the first one, i.e. it can be
% calculated in some way from the first one.

% Generate some data
x = 0:0.01:2*pi;
y = sin(x);

% Conversion factor for y-data
yConversion = 10;

% Define some limits for plot
ylimit1 = [-1,1];               % Mandatory for right y-ticks
ylimit2 = ylimit1*yConversion;  % Limit for second y-axis
xlimit1 = [0,2*pi];             % Radian
xlimit2 = xlimit1*180/pi;       % Degree

figName = 'yaxis_twoxaxes';
figure(1)
clf
t.(figName) = tiledlayout(1,1,'Padding','compact','Units','centimeters');
t.(figName).OuterPosition = [0,0,10,8];
ax1 = nexttile;
hold on
yyaxis(ax1,'left')                    % Plots only left y-axis
ax1.XMinorTick = 'on';
ax1.YMinorTick = 'on';
ax1.YColor = 'k';                     % Standard colour is blue
ylim(ax1,ylimit1)
xlim(ax1,xlimit1)
plot(x,y,'DisplayName','Data')
legend(ax1)
ylabel(ax1,'Y-axis / a.u.')
xlabel(ax1,'X-axis 1 / rad')

% Right y-ticks should be the sames as on left side
yyaxis(ax1,'right')                 % Plots only right y-axis
ax1.YColor = 'k';                   % Standard colour is red
ax1.YMinorTick = 'on';
ylabel('Y-axis 2 / 10 a.u.')
ylim(ax1,ylimit2)

ax2 = axes(t.(figName));            % Create axes for 2nd x-axis
ax2.XAxisLocation = 'top';          % x-axis location is top
ax2.Color = 'none';                 % Axes should be transparent
xlim(ax2,xlimit2)                   % Set limit of top x-axis
ax2.YAxis.Visible = 'off';
ax2.XMinorTick = 'on';
% ax2.XDir = 'reverse';               % x-axis can be reversed
xlabel(ax2,'X-axis 2 / deg')