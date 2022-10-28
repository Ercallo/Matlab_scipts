function [] = exportFig(fig, SFolder, SName, extension, varargin)
% ADD DOCUMENTATION
if isempty(extension)
    extension = '.png';
end
exportStr = input(...
    sprintf("Export %s graph in %s? Type 'y' to export\n", ...
    varargin{:}, extension), ...
    's');
if strcmp(exportStr, 'y')
    extension = '.png';
    if ~contains(extension, '.')
        extension = ['.', extension];
    end
    FilePath = [char(SFolder), '\', char(SName), char(extension)];
    exportgraphics(fig, FilePath);
else
    disp('Graphics not exported')
end
end

