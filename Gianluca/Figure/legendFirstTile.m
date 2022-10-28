function lgd = legendFirstTile(tL, DisplayNames, varargin)
% ADD DOCUMENTATION

ax = nexttile(1);
if ~isempty(varargin)
    h = varargin{:};
    lgd = legend(ax, h, DisplayNames);
else
    lgd = legend(ax, DisplayNames);
end
GridSize = tL.GridSize;
if GridSize(1) ~= 1 || GridSize(2) ~= 1
    lgd.ItemTokenSize = [10 10 10];
end
% lgd.Location = 'NorthEast';
% lgd.NumColumns = 2;

end

