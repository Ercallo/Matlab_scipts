function [] = annotateSubplotId(tL)
% ADD DOCUMENTATION
GridSize = tL.GridSize;
nTile = GridSize(1)*GridSize(2);
for iTile = 1:nTile
    SubplotId = 96 + iTile;
    unicodeStr = [40 SubplotId 41];
    ax = nexttile(iTile);
    text(0.05, 0.9, char(unicodeStr), 'Units', 'normalized', ...
        'FontWeight', 'bold', ...
        'FontSize', 10)
end
end


