%% Bootstrap
clearvars, clear, clc, close all

folder = '/home/gianluca/matlab_util/util_GM/to_be_sorted/NREL_cwEDMR10K/';
dataName = 'cwEDMR30K'; % Desired import-export data name

% Load the baseline and phase corrected data
load(strjoin({folder, dataName, '_BlcPc.mat'},''));

x = cwEDMR.B;
y = cwEDMR.SpcBlcPc;
Exp = cwEDMR.Exp;

Opt.NumBoot = 5000;
Opt.RunInitialFit = true;
Opt.RunBootstrap = true;
Opt.CacheInitialFit = strjoin({folder, dataName, '_fit.mat'}, '');
Opt.CacheBootstrap = strjoin({folder, dataName, '_bootstrap.mat'}, '');
Opt.Fit.Method = 'simplex fcn';
Opt.Fit.maxTime = 0.5;

%% Fit parameters
Sys0.S = 1/2;
% Sys0.g = 1.9986;
Sys0.g = 1.9979;
Sys0.A = 117; % MHz
Sys0.lw = [0.0103 0.6795]; % mT [Gaussian Lorentzian]
Sys0.Nucs = 'P';

Vary0.g = 0.001;
Vary0.lw = [0.001 0.01];

% Pb0:
Sys1.S = 1/2;
Sys1.g = 2.0049;
Sys1.lw = [0.00 1.9];
Sys1.weight = 1;

Vary1.g = 0.001;
Vary1.lw = [0.00 0.5];
Vary1.weight = 0.5;

% Dangling Bond 2:
Sys2.S = 1/2;
Sys2.g = 2.0085;
Sys2.lw = [4.4 0.0];
Sys2.weight = 2;

Vary2.g = 0.001;
Vary2.lw = [0.5 0.0];
Vary2.weight = 2;

%% Run fit
if Opt.RunInitialFit || ~isfile(Opt.CacheInitialFit)
    % [Sys, yfit] = esfit(@pepper, y, {Sys0, Sys1, Sys2}, ...
    %     {Vary0, Vary1, Vary2}, Exp, [], Opt.Fit);
    [Sys, yfit] = esfit(@pepper, y, {Sys1, Sys2}, ...
        {Vary1, Vary2}, Exp, [], Opt.Fit);
    save(Opt.CacheInitialFit, 'Sys', 'yfit');
else
    load(Opt.CacheInitialFit);
end

figure(2); clf;
plot(x, y, x, yfit); xlim(Exp.Range);

%% Run bootstrap iterations
if Opt.RunBootstrap || ~isfile(Opt.CacheBootstrap)
    r = y - yfit;
    [~, idx] = bootstrp(Opt.NumBoot, [], r);
    R = r(idx);
    Y = y + R.';

    Boot = cell(1, Opt.NumBoot);
    parfor i = 1:Opt.NumBoot
        y_ = Y(i, :);
%         Boot{i} = esfit(@pepper, y_, {Sys0, Sys1, Sys2}, ...
%             {Vary0, Vary1, Vary2}, Exp, [], Opt.Fit);
        Boot{i} = esfit(@pepper, y_, {Sys1, Sys2}, ...
            {Vary1, Vary2}, Exp, [], Opt.Fit);
    end
else
    load(Opt.CacheInitialFit);
end

%% Copy all Boot Sys structure into one structure
% % BootSys0 = Boot{1,1}{1,1};
% % BootSys0 = rmfield(BootSys0, {'S', 'A', 'Nucs', 'weight'});
% % BootCi0 = BootSys0;
% % fields = fieldnames(BootSys0);
% % 
% % for i = 1:numel(fields)
% %     f = fields{i};
% %     BootSys0.(f) = repmat(BootSys0.(f), Opt.NumBoot, 1);
% %     for j = 1:Opt.NumBoot
% %         BootSys0.(f)(j, :) = Boot{1,j}{1,1}.(f);
% %     end
% %     BootCi0.(f) = bootstrapCIBca(BootSys0.(f), Sys0.(f), 0.95);
% % end
% % 
% % figure(1); clf;
% % subplot(1,3,1);
% % histfit(BootSys0.g);
% % subplot(1,3,2);
% % histfit(BootSys0.lw(:,1));
% % subplot(1,3,3);
% % histfit(BootSys0.lw(:,2));


% % BootSys1 = Boot{1,1}{1,2};
BootSys1 = Boot{1,1}{1,1};
BootSys1 = rmfield(BootSys1, 'S');
BootCi1 = BootSys1;
fields = fieldnames(BootSys1);

for i = 1:numel(fields)
    f = fields{i};
    BootSys1.(f) = repmat(BootSys1.(f), Opt.NumBoot, 1);
    for j = 1:Opt.NumBoot
        % % BootSys1.(f)(j, :) = Boot{1,j}{1,2}.(f);
        BootSys1.(f)(j, :) = Boot{1,j}{1,1}.(f);        
    end
    BootCi1.(f) = bootstrapCIBca(BootSys1.(f), Sys1.(f), 0.95);
end

% Varying g, lw only in the second component, weight
figure(1); clf;
subplot(1,3,1);
histfit(BootSys1.g);
subplot(1,3,2);
histfit(BootSys1.lw(:,2));
subplot(1,3,3);
histfit(BootSys1.weight);


% % BootSys2 = Boot{1,1}{1,3};
BootSys2 = Boot{1,1}{1,2};
BootSys2 = rmfield(BootSys2, 'S');
BootCi2 = BootSys2;
fields = fieldnames(BootSys2);

for i = 1:numel(fields)
    f = fields{i};
    BootSys2.(f) = repmat(BootSys2.(f), Opt.NumBoot, 1);
    for j = 1:Opt.NumBoot
        % % BootSys2.(f)(j, :) = Boot{1,j}{1,3}.(f);
        BootSys2.(f)(j, :) = Boot{1,j}{1,2}.(f);
    end
    BootCi2.(f) = bootstrapCIBca(BootSys2.(f), Sys2.(f), 0.95);
end

% Varying g, lw only first component, weight
figure(1); clf;
subplot(1,3,1);
histfit(BootSys2.g);
subplot(1,3,2);
histfit(BootSys2.lw(:,1));
subplot(1,3,3);
histfit(BootSys2.weight);

% % save(Opt.CacheBootstrap, 'BootSys0', 'BootCi0', ...
% %     'BootSys1', 'BootCi1', 'BootSys2', 'BootCi2')
save(Opt.CacheBootstrap, 'BootSys1', 'BootCi1', 'BootSys2', 'BootCi2')