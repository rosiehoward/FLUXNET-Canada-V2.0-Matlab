% plotRawDatabaseVars.m
%
% Rosie Howard
% April 2024

% Load and plot one or more years of data
yearIn = 2020:2023;

% load time vector
tv = read_bor(fullfile(biomet_path('yyyy','TPAg','Met'),'clean_tv'),8,[],yearIn);

% convert time vector to Matlab's datetime
tv_dt = datetime(tv,'ConvertFrom','datenum');

make_plot = 0;  % 0 = no, 1 = yes
save_plot = 0;   % 0 = no, 1 = yes
dataType = 'Met';

if strcmp(dataType,'Flux')
    pthOut = pthOutEC; %#ok<*UNRCH>
elseif strcmp(dataType,'Met') 
    pthOut = pthOutMet;
end

% irgaFilteringPlots;

% list_files = dir([dbPath '/' num2str(yearIn) '/' siteID '/' dataType '/']););
list_files = dir([biomet_database_default '/' num2str(yearIn(1)) '/' siteID '/' dataType '/']);

if make_plot == 1
    for i = 1:length(list_files)
        baseFileName = list_files(i).name;
        if strcmp(baseFileName,'.') ...
                | strcmp(baseFileName,'..') ...
                | strcmp(baseFileName,'.DS_Store') ...
                | strcmp(baseFileName,'clean_tv') ...
                | strcmp(baseFileName,'TimeVector') ...
                | strcmp(baseFileName,'Clean')
            continue
        else
            value = baseFileName;
        end
        % load data
        var = read_bor(fullfile(pthOut,value),[],[],yearIn);
        % AirTemp_AbvCnpy = read_bor(fullfile(pthOutMet,'AirTemp_AbvCnpy'),[],[],yearIn);

        % show data
        % figure(1)
        clf;
        set(gcf,'color','white');
        subplot(2,1,1);
        plot(tv_dt,var,'.','LineWidth',2)
        title(value)
        % legend('EC','Met');
        % ylabel('degC')
        zoom on
        grid on
        subplot(2,1,2);
        histogram(var);
        grid on

        % save plot
        if save_plot == 1
            savepath = ['/Users/rosiehoward/Documents/UBC/Micromet/Matlab/local_personal_plots/TurkeyPoint_Altaf/' siteID '/' num2str(yearIn) '/' dataType '/'];
            filetext = value;
            type = 'png';
            im_res = 200;
            str = ['print -d' type ' -r' num2str(im_res) ' ' savepath filetext '.' type];
            eval(str);
        end

    end
end
% clear pthOut

%%
% % load TA from EC
% Tair_EC = read_bor(fullfile(pthOutEC,'Tair'),[],[],yearIn);
AirTemp_AbvCnpy = read_bor(fullfile(biomet_path('yyyy','TPAG','Met'),'AirTemp_AbvCnpy'),[],[],yearIn);
TA_1_1_1 = read_bor(fullfile(biomet_path('yyyy','TPAG','Met/Clean'),'TA_1_1_1'),[],[],yearIn);
TA_1_1_1_Second = read_bor(fullfile(biomet_path('yyyy','TPAG','Clean/SecondStage'),'TA_1_1_1'),[],[],yearIn);

DownShortwaveRad = read_bor(fullfile(biomet_path('yyyy','TPAG','Met'), 'DownShortwaveRad'),[],[],yearIn);

WD_1_1_1 = read_bor(fullfile(biomet_path('yyyy','TPAG','Flux/Clean'),'WD_1_1_1'),[],[],yearIn);

% 
% % show data
figure(1)
plot(tv_dt,[TA_1_1_1_Second,TA_1_1_1,AirTemp_AbvCnpy],'.','LineWidth',2)
title('Air Temperature')
legend('Second','First stage','Raw');
ylabel('degC')
zoom on
grid on
