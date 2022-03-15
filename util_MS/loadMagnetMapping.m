function [Data,Params] = loadMagnetMapping(file)
%LOADMAGNETMAPPING Summary of this function goes here
%   Detailed explanation goes here
fileID = fopen(file);
f = textscan(fileID,'%s','delimiter','\n');
fclose(fileID);

nLine = 980;
nPos = 286;

f = f{1};
Params = f(6:27);
f(6:27) = [];

Pos_ = f(6:8);
Pos_ = split(Pos_);
Data_ = f(13:980);
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
    Data_ = f(13+nLine*(i-1):980+nLine*(i-1));
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

