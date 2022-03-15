clearvars;
clc;
clear;
clf;

fileID = fopen('001_mapping.txt');

data = textscan(fileID,'%s','delimiter','\n');

a = data{1};

a(6:27) = [];

nLine = 980;
nPosition = 286;

%%

position = a(6:8);
dati = a(13:980);
dati = split(dati);
position = split(position);

File.xPosition = str2double(position{1,2});
File.yPosition = str2double(position{2,2});
File.zPosition = str2double(position{3,2});
File.Freq = dati(:,1);
File.Ch1 = dati(:,2);
File.Ch2 = dati(:,3);
File.Ch3 = dati(:,4);
File.Ch4 = dati(:,5);

%% ciclo for

File = repmat(File, 1, nPosition);

%%

for i = 1:nPosition
    
    position = a(6+nLine*(i-1):8+nLine*(i-1));
    position = split(position);
    dati = a(13+nLine*(i-1):980+nLine*(i-1));
    dati = split(dati);
    
    File(i).xPosition = str2double(position{1,2});
    File(i).yPosition = str2double(position{2,2});
    File(i).zPosition = str2double(position{3,2});
    File(i).Freq = str2double(dati(:,1));
    File(i).Ch1 = str2double(dati(:,2));
    File(i).Ch2 = str2double(dati(:,3));
    File(i).Ch3 = str2double(dati(:,4));
    File(i).Ch4 = str2double(dati(:,5));
        
end

%% figure
M = 137;

for i = 1+M : 5+M
    figure(i)
    
    plot(File(i).Freq,File(i).Ch1)
    
    
end

    
    