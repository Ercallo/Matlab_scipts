function [] = exportFig(fig, SFolder, SName, extension, varargin)
% ADD DOCUMENTATION
if isempty(extension)
    extension = '.png';
end
if isempty(varargin)
    exportStr = input(...
        sprintf("Export graph in %s? Type 'y' to export\n", ...
        extension), ...
        's');
else
    exportStr = input(...
        sprintf("Export %s graph in %s? Type 'y' to export\n", ...
        varargin{:}, extension), ...
        's');
end
if strcmp(exportStr, 'y')
    if ~contains(extension, '.')
        extension = ['.', char(extension)];
    end
    FilePath = [char(SFolder), '\', char(SName), char(extension)];
    exportgraphics(fig, FilePath);
else
    disp('Graphics not exported')
end
end

