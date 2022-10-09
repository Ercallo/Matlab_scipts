function Range = setExpRange(cw)
% Find the largest range that is common to every spectrum
    xMin = cw(1).Exp.Range(1); xMax = cw(1).Exp.Range(2);
    for i = 1:numel(cw)
        if cw(i).Exp.Range(1) > xMin
            xMin = cw(i).Exp.Range(1);
        end
        if cw(i).Exp.Range(2) < xMax
            xMax = cw(i).Exp.Range(2);
        end
    end
    Range = [xMin xMax];
end