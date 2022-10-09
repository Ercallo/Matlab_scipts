% PV Panel Characterization Tool
% This tool was developed to characterize PV Panel parameters including
% ideality factor, series and shunt resistance from measured I-V curve.
% Mean Absolute Error in percentage were used as I-V curve fitting 
% assessment indicator. User can adjust the ideality factor, series and
% shunt resistance until the model I-V curve fit closely with the measured
% I-V curve where the mean absolute error is at its minimum.

% Click Open to load the measured I-V curve file provided 
% Monocrystalline Panel 70W at 999W/m^2 'Mono70W999.csv' 
% Polycrystalline Panel 70W at 1000W/m^2 'Poly70W1000.csv'
% Amorphous Thin Film Silicon Panel 100W at 1005W/m^2 'aSi100W1005.csv' 

% Written by Dr Rodney Tan and Landon Hoo
% Version 1.00 (Aug 2018)
function PVPanelCharacterizationTool
    global pvdata;
    figure('Resize','off','NumberTitle','off','Toolbar','none',...
           'Name','PV Panel Characterization Tool');
    
    uicontrol('Style', 'text', 'String', 'G(W/m^2)',...
              'Position', [90 300 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Pmax(W)',...
              'Position', [90 280 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Isc(A)',...
              'Position', [90 260 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Voc(V)',...
              'Position', [90 240 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Imp(A)',...
              'Position', [90 220 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Vmp(V)',...
              'Position', [90 200 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
          
    uicontrol('Style', 'text', 'String', 'Temp(C)',...
              'Position', [90 180 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Ns',...
              'Position', [90 160 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    
    uicontrol('Style', 'text', 'String', 'Rs (ohm)',...
              'Position', [90 140 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'A',...
              'Position', [90 120 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', 'Rsh (ohm)',...
              'Position', [90 100 60 20],'BackgroundColor','w',...
              'horizontalAlignment', 'left');
    
    hG= uicontrol('Style', 'text','Position', [150 300 40 20],...
                  'BackgroundColor','w','horizontalAlignment', 'left');
    hPmax= uicontrol('Style', 'text','Position', [150 280 40 20],...
                  'BackgroundColor','w','horizontalAlignment', 'left');
    hIsc = uicontrol('Style','text','Position', [150 260 40 20],...
                     'BackgroundColor','w','horizontalAlignment', 'left');
    hVoc = uicontrol('Style','text','Position', [150 240 40 20],...
                     'BackgroundColor','w','horizontalAlignment', 'left');
    hImp = uicontrol('Style','text','Position', [150 220 40 20],...
                     'BackgroundColor','w','horizontalAlignment', 'left');
    hVmp = uicontrol('Style','text','Position', [150 200 40 20],...
                     'BackgroundColor','w','horizontalAlignment', 'left');
    hTc = uicontrol('Style','text','Position', [150 180 40 20],...
                    'BackgroundColor','w','horizontalAlignment','left');
    hNs = uicontrol('Style','text','Position', [150 160 40 20],...
                    'BackgroundColor','w','horizontalAlignment','left');
    
    hRsTxt = uicontrol('Style','edit','string','0','Enable','inactive',...
                    'Position', [150 140 40 20],'BackgroundColor','w',...
                    'horizontalAlignment','left');
    hATxt = uicontrol('Style','edit','string','1','Enable','inactive',...
                   'Position', [150 120 40 20],'BackgroundColor','w',...
                   'horizontalAlignment','left');           
    hRsh = uicontrol('Style','edit','string','inf','Enable','inactive',...
                     'Position', [150 100 40 20],'BackgroundColor','w',...
                     'horizontalAlignment','left');
    hRsSldr = uicontrol('Style','slider','Min',0,'Max',3 ,'Value',0,...
                       'SliderStep', [1/300, 0.1],...
                       'Position',[190 140 15 20],'Callback',@PVModel);
    hASldr = uicontrol('Style','slider','Min',0,'Max',3 ,'Value',0.5,...
                         'SliderStep', [1/300, 0.1],...
                         'Position',[190 120 15 20],'Callback',@PVModel);
    hRshSldr = uicontrol('Style','slider','Min',0,'Max',1e3 ,'Value',1e3,...
                         'SliderStep', [1/100, 1],...
                         'Position',[190 100 15 20],'Callback',@PVModel);             
                     
    uicontrol('Style','pushbutton','String','Open',...
              'Position',[90 60 100 25],'Callback',@Open);
    plot(0);
    
    function Open(~,~)
        [filename, pathname] = uigetfile('*.csv');
        if isequal(filename,0)  % Handling Cancel button pressed
            return;
        end
        [pvdata,~]=xlsread([pathname, filename]);
        set(hG,'String',num2str(pvdata(12,2)));
        set(hPmax,'String',num2str(pvdata(6,2)));
        set(hIsc,'String',num2str(pvdata(5,2)));
        set(hVoc,'String',num2str(pvdata(4,2)));
        set(hImp,'String',num2str(pvdata(8,2)));
        set(hVmp,'String',num2str(pvdata(7,2)));
        set(hTc,'String',num2str(pvdata(11,2)));
        set(hNs,'String',num2str(pvdata(13,3)));
        cla;
        plot(pvdata(16:end,1),pvdata(16:end,2));
        PVModel;
    end
    
    function PVModel(~,~)
        cla;
        Isc = pvdata(5,2);
        Voc = pvdata(4,2);
        V = pvdata(16:end,1);
        I = pvdata(16:end,2);
        Ns = pvdata(13,3);
        
        Rs = get(hRsSldr,'Value');
        set(hRsTxt,'String',num2str(Rs));
        A = get(hASldr,'Value');
        set(hATxt,'String',num2str(A));
        Rsh = get(hRshSldr,'Value');
        set(hRsh,'String',num2str(Rsh));
        
        TC = pvdata(11,2);
        q = 1.6e-19;
        k = 1.38e-23;
        TK = 273+TC;                        % Cell Temperature in Kelvin
        vt=(A*k*TK*Ns)/q;                   % Thermal voltage
        
        I0 = Isc/(exp(Voc/vt)-1);           % Reverse Saturation Current
        IL = Isc;                           % Light Current at given G

        i = 0;                              % Set initial current i=0
        I_tmp = zeros(1,length(V));
        for idx = 1:length(V)
            I_tmp(idx)= IL - I0*(exp((V(idx)+(i*Rs))/vt)-1)-((V(idx)+(i*Rs))/Rsh);
            i = I_tmp(idx);                 % Update Current
        end
        I_Model = I_tmp';

        plot(V,I,'linewidth',2);
        hold on;
        plot(V,I_Model,'-.','linewidth',2);
        xlabel('Voltage (V)');
        ylabel('Current (A)');
        
        MAE = sum(abs(I-I_Model))/149;      % Mean Absolute Error
        
        legend('Location','south',...
               'Measured I-V Curve',...
              ['Model I-V Curve',sprintf('\nMAEP(%%)=%0.4f',(MAE/mean(I))*100)]);
    end
end