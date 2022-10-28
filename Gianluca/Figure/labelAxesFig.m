function [] = labelAxesFig(tL, xLab, yLab)
%PLOTCWEDMR Summary of this function goes here
%   Detailed explanation goes here

% Font for label to use when the graph has more than one tile
TILEDLAYOUT_LABEL_FONT = 10;
SINGLETILE_LABEL_FONT = 16;

GridSize = tL.GridSize;
nr = GridSize(1);
nc = GridSize(2);
for ir = 1:nr
    iTile = (ir - 1)*nc + 1;
    ax = nexttile(iTile);
    ax.YLabel.String = yLab;
end
for ic = 1:nc
    iTile = (nr - 1)*nc + ic;
    ax = nexttile(iTile);
    ax.XLabel.String = xLab;
end
if nr*nc > 1
    ax.FontSize = TILEDLAYOUT_LABEL_FONT - 1;
    ax.YLabel.FontSize = TILEDLAYOUT_LABEL_FONT;
    ax.XLabel.FontSize = TILEDLAYOUT_LABEL_FONT;
else
    ax.FontSize = SINGLETILE_LABEL_FONT - 3;
    ax.YLabel.FontSize = SINGLETILE_LABEL_FONT;
    ax.XLabel.FontSize = SINGLETILE_LABEL_FONT;

end

