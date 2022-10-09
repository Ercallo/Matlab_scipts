function varargout = mfesfit(X, Y, Sys0, Vary, Exp)
% X: cell array with n B0 axes
% Y: cell array with n spectra
nargoutchk(0, 3);

%% Concatenate arrays 
nSpectra = numel(X);
nPoints = cellfun(@numel, X);
x = zeros(sum(nPoints), 1);
y = x;

indices = cell(1, nSpectra);

Exp.RangePerSpectrum = cell(1, nSpectra);
Exp.nPointsPerSpectrum = cell(1, nSpectra);

for i = 1:nSpectra
    nPointsBefore = sum(nPoints(1:i-1));
    indices{i} = (1:nPoints(i)) + nPointsBefore;
    x(indices{i}) = X{i};
    y(indices{i}) = Y{i};
    
    Exp.RangePerSpectrum{i} = [min(X{i}), max(X{i})];
    Exp.nPointsPerSpectrum{i} = numel(X{i});
end
Exp.mwFreq = Exp.mwFreqPerSpectrum{1};
Exp.Range = [min(x), max(x)];
Exp.nPoints = numel(x);

%% Call esfit
if nargout == 0
    esfit('mfpepper', y, Sys0, Vary, Exp);
else
    [Sys, yfit] = esfit('mfpepper', y, Sys0, Vary, Exp);
    
    switch nargout
        case 1
            varargout{1} = Sys;
        case 2
            varargout{1} = Sys;
            varargout{2} = yfit;
        case 3
            varargout{1} = Sys;
            varargout{2} = y;
            varargout{3} = yfit;
    end
end

end