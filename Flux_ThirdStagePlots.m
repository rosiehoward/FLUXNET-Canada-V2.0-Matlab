% plotting flux variables (second stage) and third stage
%
% Rosie Howard
% 6 May 2024

clear;
siteID = 'TPAg';
yearIn = 2023;

dbPath = biomet_database_default;

firstStageMetPath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Met/Clean';
firstStageFluxPath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Flux/Clean';

secondStagePath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Clean/SecondStage';
thirdStagePath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Clean/ThirdStage';
thirdStageUStarPath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Clean/ThirdStage_Default_Ustar';

% load time vector
tv = read_bor(fullfile(firstStageMetPath,'clean_tv'),8,[],yearIn);
% convert time vector to Matlab's datetime
tv_dt = datetime(tv,'ConvertFrom','datenum');

%% NEE and other derived plots
FC = read_bor(fullfile(secondStagePath,'FC'),[],[],yearIn);
SC = read_bor(fullfile(secondStagePath,'SC'),[],[],yearIn);
NEE = read_bor(fullfile(secondStagePath,'NEE'),[],[],yearIn);
ET = read_bor(fullfile(secondStagePath,'ET'),[],[],yearIn);
VPD_1_1_1 = read_bor(fullfile(secondStagePath,'VPD_1_1_1'),[],[],yearIn);

m = length(FC);

nFC = length(find(~isnan(FC)));
nPerFC = (nFC/m)*100;
nPerFC = round(nPerFC*10)/10;

nSC = length(find(~isnan(SC)));
nPerSC = (nSC/m)*100;
nPerSC = round(nPerSC*10)/10;

nNEE = length(find(~isnan(NEE)));
nPerNEE = (nNEE/m)*100;
nPerNEE = round(nPerNEE*10)/10;

plot(tv_dt,FC,'.');
hold on
plot(tv_dt,SC,'.');
plot(tv_dt,NEE);
grid on
legend('FC','SC','NEE')
set(gcf,'color','white');

annotation('textbox', [0.05, 0.05, 0.5, 0], 'string', ...
           ['nFC = ' num2str(nFC) ' (' num2str(nPerFC) '%),' ...
            ' nSC = ' num2str(nSC) ' (' num2str(nPerSC) '%),' ...
            ' nNEE = ' num2str(nNEE) ' (' num2str(nPerNEE) '%)'],'fontsize',12);

%% plot all third stage
makeplot = 1;
saveplot = 1;
savepath = ['/Users/rosiehoward/Documents/UBC/Micromet/Matlab/local_personal_plots/TurkeyPoint_Altaf/' siteID '/' num2str(yearIn) '/Clean/ThirdStage/'];
% savepath = ['/Users/rosiehoward/Documents/UBC/Micromet/Matlab/local_personal_plots/TurkeyPoint_Altaf/' siteID '/' num2str(yearIn) '/Clean/ThirdStage_Default_Ustar/'];

% load variables
list_files = dir([biomet_database_default '/' num2str(yearIn) '/' siteID '/Clean/ThirdStage']);
% list_files = dir([biomet_database_default '/' num2str(yearIn) '/' siteID '/Clean/ThirdStage_Default_Ustar']);

if makeplot == 1
    for i = 1:length(list_files)
        baseFileName = list_files(i).name;
        if strcmp(baseFileName,'.') ...
                | strcmp(baseFileName,'..') ...
                | strcmp(baseFileName,'.DS_Store') ...
                | strcmp(baseFileName,'clean_tv') ...
                | strcmp(baseFileName,'TimeVector') ...
                | strcmp(baseFileName,'Clean') ...
                | strcmp(baseFileName,'ProcessingSettings.yml') ...
                | strcmp(baseFileName,'.Rhistory')
            continue
        else
            value = baseFileName;
        end
        % load data
        var = read_bor(fullfile(thirdStagePath,value),[],[],yearIn);
        % var = read_bor(fullfile(thirdStageUStarPath,value),[],[],yearIn);
        
        % calculate number of samples
        m = length(var);
        nvar = length(find(~isnan(var)));
        nPervar = (nvar/m)*100;
        nPervar = round(nPervar*10)/10;

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

        annotation('textbox', [0.05, 0.05, 0.5, 0], 'string', ...
           ['nvar = ' num2str(nvar) ' (' num2str(nPervar) '%)'],'fontsize',12);

        % save plot
        if saveplot == 1
            % savepath = [];
            filetext = value;
            type1 = 'png';
            type2 = 'fig';
            im_res = 200;
            str1 = ['print -d' type1 ' -r' num2str(im_res) ' ' savepath filetext '.' type1];
            % str2 = ['print -d' type2 ' -r' num2str(im_res) ' ' savepath filetext '.' type2];
            eval(str1);
            % eval(str2);
        end

    end

end