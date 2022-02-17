function y = mfpepper(Sys, Exp, Opt)

if nargin < 3
   Opt = struct;
end

nSpectra = numel(Exp.nPointsPerSpectrum);

nPoints = cell2mat(Exp.nPointsPerSpectrum);
y = zeros(1, sum(nPoints));
for iSpectra = 1:nSpectra
    
    % Copy ith experimental parameters from cell arrays.
    Exp_ = Exp;
    fields = fieldnames(Exp_);
    for iField = 1:numel(fields)
        f = fields{iField};
        if iscell(Exp_.(f))
            Exp_.(f) = Exp_.(f){iSpectra};
        end
    end
    Exp_.mwFreq = Exp_.mwFreqPerSpectrum;
    Exp_.Range = Exp_.RangePerSpectrum;
    Exp_.nPoints = Exp_.nPointsPerSpectrum;
    
    % Copy FieldOffset and Scaling parameters.
    Sys_ = Sys;
    if isfield(Sys_, 'FieldOffset') && numel(Sys_.FieldOffset) > 1
        Sys_.FieldOffset = Sys_.FieldOffset(iSpectra);
    end
    if isfield(Sys_, 'Scaling') && numel(Sys_.Scaling) > 1
        Sys_.Scaling = Sys_.Scaling(iSpectra);
    end
    
    y_ = pepperFieldOffset(Sys_, Exp_);
    
    % Copy into combined array.
    indices = sum(nPoints(1:iSpectra-1)) + (1:nPoints(iSpectra));
    y(indices) = y_;
end

end