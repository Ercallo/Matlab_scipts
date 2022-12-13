function lgd = legendFirstTile(tL, varargin)
% ADD DOCUMENTATION

ax = nexttile(1);
if nargin > 3
    ME = MException('legentFirstTile: too many imput arguments');
    throw(ME);
elseif nargin == 3
    DisplayNames = varargin{1};
    h = varargin{2};
    lgd = legend(ax, h, DisplayNames);
elseif nargin == 2
    DisplayNames = varargin{1};
    lgd = legend(ax, DisplayNames);
else
    lgd = legend(ax);
end

GridSize = tL.GridSize;
if GridSize(1) ~= 1 || GridSize(2) ~= 1
    lgd.ItemTokenSize = [10 10 10];
end
% lgd.Location = 'NorthEast';
% lgd.NumColumns = 2;

end

