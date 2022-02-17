function y = pepperFieldOffset(Sys, Exp, Opt)

if nargin < 3 || isempty(Opt)
    Opt = struct;
end

persistent fieldOffset
if isempty(fieldOffset)
    fieldOffset = 0;
end

if (isfield(Sys, 'FieldOffset'))
    fieldOffset = Sys.FieldOffset;
end

% Handle the field offset.
Exp_ = Exp;
Exp_.Range = Exp_.Range - fieldOffset;

y = pepper(Sys, Exp_, Opt);

% Handle scaling.
if isfield(Sys, 'Scaling')
    y = y * Sys.Scaling;
end

end