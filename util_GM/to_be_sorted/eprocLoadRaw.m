function [data, x, ch1, ch2, ch3, ch4, Params] = eprocLoadRaw(filename)

% Import file
delimeterIn = '\t';
headerlinesIn = 37;
data = importdata(filename,delimeterIn,headerlinesIn);

for i=1:numel(data.textdata)
    if contains(data.textdata(i),'Magnetic Field')
        newStr = split(data.textdata(i));
        Params.MagneticField = str2double(newStr{end});
    % here there should be the mw frequency for the case of field sweep
    %
    %
    elseif contains(data.textdata(i),'Microwave Power')
        newStr = split(data.textdata(i));
        Params.MicrowavePower = str2double(newStr{end});
    elseif contains(data.textdata(i),'Start Frequency')
        newStr = split(data.textdata(i));
        Params.StartFrequency = str2double(newStr{end});
    % here there should be the start field for the case of field sweep
    %
    %
    elseif contains(data.textdata(i),'Step Size')
        newStr = split(data.textdata(i));
        Params.StepSize = str2double(newStr{end});
    elseif contains(data.textdata(i),'Stop Frequency')
        newStr = split(data.textdata(i));
        Params.StopFrequency = str2double(newStr{end});
    % here there should be the stop field for the case of field sweep
    %
    %
    elseif contains(data.textdata(i),'Elapsed Sweeps')
        newStr = split(data.textdata(i));
        Params.ElapsedSweeps = str2double(newStr{end});        
    end
end
ch1 = data.data(:,2:Params.ElapsedSweeps+2);
ch2 = data.data(:,Params.ElapsedSweeps+3:2*Params.ElapsedSweeps+3);
ch3 = data.data(:,2*Params.ElapsedSweeps+4:3*Params.ElapsedSweeps+4);
ch4 = data.data(:,3*Params.ElapsedSweeps+5:4*Params.ElapsedSweeps+5);
x = data.data(:,1);
end