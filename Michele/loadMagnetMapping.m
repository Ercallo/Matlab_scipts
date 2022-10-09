function [Data,Params] = loadMagnetMapping(file)
%LOADMAGNETMAPPING Summary of this function goes here
%   Detailed explanation goes here
fileID = fopen(file);
f = textscan(fileID,'%s','delimiter','\n');
fclose(fileID);
f = f{1};

% Lines of global parameters
globalParams = 6:30;
Params = f(globalParams);

% Remove lines to have the same comments for every position
f(globalParams) = [];

nStepX = strsplit(string(Params(end-2)), ' ');
nStepX = str2double(nStepX(end));
nStepY = strsplit(string(Params(end-1)), ' ');
nStepY = str2double(nStepY(end));
nStepZ = strsplit(string(Params(end)), ' ');
nStepZ = str2double(nStepZ(end));
nPos = nStepX*nStepY*nStepZ;

% Line of first data point
nFirstData = 13;

fStart = strsplit(string(Params(3)), ' ');
fStart = str2double(fStart(end));
fStep = strsplit(string(Params(4)), ' ');
fStep = str2double(fStep(end));
fStop = strsplit(string(Params(5)), ' ');
fStop = str2double(fStop(end));
nf = (fStop - fStart)/fStep;

% Total number of lines for one position
nLine = nf+nFirstData;

% Import first position for initialization
Pos_ = f(6:8);
Pos_ = split(Pos_);
Data_ = f(nFirstData:nLine);
Data_ = split(Data_);

Data.xPos = str2double(Pos_{1,2});
Data.yPos = str2double(Pos_{2,2});
Data.zPos = str2double(Pos_{3,2});
Data.f = Data_(:,1);
Data.Ch1 = Data_(:,2);
Data.Ch2 = Data_(:,3);
Data.Ch3 = Data_(:,4);
Data.Ch4 = Data_(:,5);

Data = repmat(Data, 1, nPos);
for i = 1:nPos
    Pos_ = f(6+nLine*(i-1):8+nLine*(i-1));
    Pos_ = split(Pos_);
    Data_ = f(nFirstData+nLine*(i-1):nLine*i);
    Data_ = split(Data_);
    
    Data(i).xPos = str2double(Pos_{1,2});
    Data(i).yPos = str2double(Pos_{2,2});
    Data(i).zPos = str2double(Pos_{3,2});
    Data(i).f = str2double(Data_(:,1));
    Data(i).Ch1 = str2double(Data_(:,2));
    Data(i).Ch2 = str2double(Data_(:,3));
    Data(i).Ch3 = str2double(Data_(:,4));
    Data(i).Ch4 = str2double(Data_(:,5));
end