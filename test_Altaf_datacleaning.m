%% Test Altaf's data cleaning
%
% - Make sure you set the Matlab default folder to the ExternalData\PI-Folder\Matlab
% - A file like this one should be created and should contain everything that
%   we do with the data so that we can always reproduce our data processing
% - biomet_database_default.m and biomet_sites_default.m for this project are
%   based on the relative paths and assume the folder structure:
%       newProject\Matlab
%       newProject\Database
%       newProject\Sites
%

%****************************************
% make sure you are in MATLAB directory *
%****************************************

kill

yearIn = 2018;
siteID = 'TPAg';

if strcmp(siteID,'TP_PPT') | strcmp(siteID,'TPD_PPT')
    METpath = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_master_%d.mat',siteID,yearIn));
    % METpathPrevYear = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_master_%d.mat',siteID,yearIn+1));
    tmp_Met = load(METpath);
    eval([siteID '_Met = convert_data(tmp_Met.master);'])
    % TPAg_Met  = convert_data(tmp_Met.master);
else
    ECpath  = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_CPEC_clean_%d.mat',siteID,yearIn));
    METpath = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_master_%d.mat',siteID,yearIn));

    tmp_EC = load(ECpath);
    eval([siteID '_EC = convert_data(tmp_EC.master);'])
    % TPAg_EC = convert_data(tmp_EC.master);
    tmp_Met = load(METpath);
    eval([siteID '_Met = convert_data(tmp_Met.master);'])
    % TPAg_Met  = convert_data(tmp_Met.master);
end

% Create TimeVector
GMToffset = 5/24;  % Altaf's raw data is in GMT time
TimeVector = fr_round_time(datenum(yearIn,1,1,0,30,0):1/48:datenum(yearIn+1,1,1,0,0,0))' - GMToffset; %#ok<NASGU,DATNM>
% TimeVector = fr_round_time(datenum(yearIn,1,1,0,30,0):1/48:datenum(yearIn+1,1,1,0,0,0))'; %#ok<DATNM>

eval([siteID '_EC.TimeVector = TimeVector;']);
eval([siteID '_Met.TimeVector = TimeVector;']);
% TPAg_EC.TimeVector = TimeVector;
% TPAg_Met.TimeVector = TimeVector;

clear tmp* TimeVector

return

%-----------------------------------------------------------------------------
%% Database creation
% This is where the database will go

dbPath = biomet_database_default; %#ok<*UNRCH>
    
structType = 1;  %0 - old and slow, 1 - new and fast
verbose_flag=[];
excludeSubStructures = [];
timeUnit = '30min';
missingPointValue = NaN;

% Process Flux data
dataType = 'Flux';
pthOutEC = fullfile(dbPath,'yyyy',siteID,dataType);   
% eval(['[structIn,dbFileNames, dbFieldNames,errCode] = db_struct2database(' siteID '_EC,pthOutEC,verbose_flag,excludeSubStructures,timeUnit,missingPointValue,structType,1);']);

% Process Met data
dataType = 'Met';
pthOutMet = fullfile(dbPath,'yyyy',siteID,dataType);   
% eval(['[structIn,dbFileNames, dbFieldNames,errCode] = db_struct2database(' siteID '_Met,pthOutMet,verbose_flag,excludeSubStructures,timeUnit,missingPointValue,structType,1);']);


%% Load and plot one or more years of data

% load time vector
tv = read_bor(fullfile(pthOutMet,'clean_tv'),8,[],yearIn);

% convert time vector to Matlab's datetime
tv_dt = datetime(tv,'ConvertFrom','datenum');

make_plot = 1;  % 0 = no, 1 = yes
saveplot = 1;   % 0 = no, 1 = yes
dataType = 'Flux';

if strcmp(dataType,'Flux')
    pthOut = pthOutEC;
elseif strcmp(dataType,'Met')
    pthOut = pthOutMet;
end

% irgaFilteringPlots;

% list_files = dir([dbPath '/' num2str(yearIn) '/' siteID '/' dataType '/']););
list_files = dir([biomet_database_default '/' num2str(yearIn) '/' siteID '/' dataType '/']);

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
        if saveplot == 1
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

% % load TA from EC
% Tair_EC = read_bor(fullfile(pthOutEC,'Tair'),[],[],yearIn);
% AirTemp_AbvCnpy = read_bor(fullfile(pthOutMet,'AirTemp_AbvCnpy'),[],[],yearIn);
% 
% % show data
% figure(1)
% plot(tv_dt,[Tair_EC, AirTemp_AbvCnpy],'LineWidth',2)
% title('Air Temperature')
% legend('EC','Met');
% ylabel('degC')
% zoom on
% grid on

%% Cleaning data First stage
%
% Create an ini file then run fr_automated_cleaning
% 
fr_automated_cleaning(yearIn,siteID,[1]); %#ok<NBRAK2>

%% Plot data to compare

dbPath = biomet_database_default; %#ok<*UNRCH>
compareStages(dbPath,siteID,yearIn);

%% Read and plot

dataType = 'Met/Clean';     % for Mac
% dataType = 'Met\Clean';   % for PC!
pthFirstStageClean = fullfile(dbPath,'yyyy',siteID,dataType);
% NOTE: different name for TA!
TA_1_1_1 = read_bor(fullfile(pthFirstStageClean,'TA_1_1_1'),[],[],yearIn);

figure(1)
plot(tv_dt,AirTemp_AbvCnpy,tv_dt,TA_1_1_1,'o')
title('TA raw and 1^{st} stage clean')
legend('Raw','Clean')
zoom on
grid on

%% Now create a flag in the FirstStage.ini: TA>0 and use it to "clean" RH
figure(2)
RH_1_1_1 = read_bor(fullfile(pthFirstStageClean,'RH_1_1_1'),[],[],yearIn);
RH_low = read_bor(fullfile(pthFirstStageClean,'RH_low'),[],[],yearIn);
RH_warm = read_bor(fullfile(pthFirstStageClean,'RH_warm'),[],[],yearIn);

ax(1) = subplot(2,1,1);
plot(tv_dt,AirTemp_AbvCnpy,'o',tv_dt,TA_1_1_1,'o',tv_dt,tv*0)
title('TA raw and 1^{st} stage clean')
legend('T Raw','T Clean')
zoom on
grid on

ax(2) = subplot(2,1,2);
plot(tv_dt,RH_1_1_1,'o',tv_dt,RH_warm,'o')
title('RH_{warm}')
legend('RH 1^{st} Stage','RH warm')
zoom on
grid on
linkaxes(ax,'x')

%% Inspect other newly created clean variables
dataType = 'Met/Clean';     % for Mac
pthFirstStageClean = fullfile(dbPath,'yyyy',siteID,dataType);

TA_1_1_1 = read_bor(fullfile(pthFirstStageClean,'TA_1_1_1'),[],[],yearIn);
SW_IN_1_1_1 = read_bor(fullfile(pthFirstStageClean,'SW_IN_1_1_1'),[],[],yearIn);

ax(1) = subplot(2,1,1);
plot(tv_dt,SW_IN_1_1_1,'.',tv_dt,tv*0)
title('1^{st} stage clean SW_{down}')
% legend('T Raw','T Clean')
zoom on
grid on

ax(2) = subplot(2,1,2);
plot(tv_dt,TA_1_1_1,'.',tv_dt,tv*0)
title('1^{st} Stage T_{air}')
zoom on
grid on
linkaxes(ax,'x')

%% Second stage cleaning (below we do 1 and 2):
fr_automated_cleaning(yearIn,siteID,[1 2]);

%% 
dataType = 'Clean/SecondStage';
% dataType = 'Clean\SecondStage';
pthSecondStageClean = fullfile(dbPath,'yyyy',siteID,dataType);

NETRAD_1_1_1 = read_bor(fullfile(pthSecondStageClean,'NETRAD_1_1_1'),[],[],yearIn);
NETRAD_1_1_1_measured = read_bor(fullfile(pthSecondStageClean,'NETRAD_1_1_1_measured'),[],[],yearIn);

badRad = read_bor(fullfile(pthSecondStageClean,'badRad'),[],[],yearIn);
badWD = read_bor(fullfile(pthSecondStageClean,'badWD'),[],[],yearIn);

WD_1_1_1 = read_bor(fullfile(pthSecondStageClean,'WD_1_1_1'),[],[],yearIn);
SW_IN_1_1_1 = read_bor(fullfile(pthSecondStageClean,'SW_IN_1_1_1'),[],[],yearIn);

VPD_1_1_1 = read_bor(fullfile(pthSecondStageClean,'VPD_1_1_1'),[],[],yearIn);
FC_1_1_1 = read_bor(fullfile(pthSecondStageClean,'FC_1_1_1'),[],[],yearIn);
SC_1_1_1 = read_bor(fullfile(pthSecondStageClean,'SC_1_1_1'),[],[],yearIn);
USTAR = read_bor(fullfile(pthSecondStageClean,'USTAR'),[],[],yearIn);
ET = read_bor(fullfile(pthSecondStageClean,'ET'),[],[],yearIn);
NEE_1_1_1 = read_bor(fullfile(pthSecondStageClean,'NEE_1_1_1'),[],[],yearIn);
RG_1_1_1 = read_bor(fullfile(pthSecondStageClean,'RG_1_1_1'),[],[],yearIn);

% RH_1_1_1 = read_bor(fullfile(pthFirstStageClean,'RH_1_1_1'),[],[],yearIn);
% RH_SecondStage =  read_bor(fullfile(pthSecondStageClean,'RH_1_1_1'),[],[],yearIn);

% TA_1_1_1 = read_bor(fullfile(pthFirstStageClean,'TA_1_1_1'),[],[],yearIn);
% TA_SecondStage = read_bor(fullfile(pthSecondStageClean,'TA_1_1_1'),[],[],yearIn);

figure(3)
plot(tv_dt,TA_SecondStage,'.')
hold on
plot(tv_dt,TA_1_1_1,'.');
plot(tv_dt,T_SONIC_1_1_1,'.')

title('RH')
legend('RH 1^{st} Stage','RH 2^{nd} Stage')
zoom on
grid on

%% 
dataType = 'Clean/ThirdStage';
% dataType = 'Clean\SecondStage';
pthSecondStageClean = fullfile(dbPath,'yyyy',siteID,dataType);

GPP_PI_F_DT = read_bor(fullfile(pthSecondStageClean,'GPP_PI_F_DT'),[],[],yearIn);
GPP_PI_F_NT = read_bor(fullfile(pthSecondStageClean,'GPP_PI_F_NT'),[],[],yearIn);
Reco_PI_F_DT = read_bor(fullfile(pthSecondStageClean,'Reco_PI_F_DT'),[],[],yearIn);
Reco_PI_F_NT = read_bor(fullfile(pthSecondStageClean,'Reco_PI_F_NT'),[],[],yearIn);
H_PI_F_MDS = read_bor(fullfile(pthSecondStageClean,'H_PI_F_MDS'),[],[],yearIn);
LE_PI_F_MDS = read_bor(fullfile(pthSecondStageClean,'LE_PI_F_MDS'),[],[],yearIn);
NEE_PI_F_MDS = read_bor(fullfile(pthSecondStageClean,'NEE_PI_F_MDS'),[],[],yearIn);

%% Local Data base
% During the testing and ini file editing the analysis can and should be done
% on the local computer
%

% 1. Somewhere on the local PC create a folder where the database goes
% 2. In Matlab, cd to that folder
% 3. Run setupLocalDataCleaning
% 4. Make sure you edit all the fields properly
% 5. Copy the database
% 6. work from this folder while making ini files 
% 7. Once you like the new ini files, copy them to the server (externaldata)
% 8. In Matlab change the folder to ...\externalfolder\PI-folder
% 9. Re-run the cleaning
% 10. Most important thing - only the copy on the server is an official copy.
%     What we do on our local PCs is only to speed up the process and to avoid
%     erasing the server data while editing and testing.

cd 'E:\Junk\Altaf_TP_test'
setupLocalDataCleaning
% work on ini files, add a couple of lines, test, repeat...
% when happy go back to the server
cd \\137.82.55.154\ExternalData\TurkeyPoint
% and re-run the cleaning
fr_automated_cleaning(yearIn, siteID, [1 2]);


%% After we did everyting for one year, change yearIn for the full range:
% yearIn = 2011:2013 and repeat






%% Local Functions


function structOut=convert_data(structIn)
    for cntVars = 1:size(structIn.labels,1)
        varName = renameFields(strtrim(structIn.labels(cntVars,:)));
        structOut.(varName) = structIn.data(:,cntVars);
    end
end

% --------------------------------------------------------
% rename fields that are not proper Matlab or Windows names
% using Biomet/Micromet renaming strategy
function renFields = renameFields(fieldsIn)
    renFields  = strrep(fieldsIn,' ','_');
    renFields  = strrep(renFields,'-','_');
    renFields  = strrep(renFields,'u*','us');
    renFields  = strrep(renFields,'(z_d)/L','zdL');
    renFields  = strrep(renFields,'T*','ts');
    renFields  = strrep(renFields,'%','p');
    renFields  = strrep(renFields,'/','_');
    renFields  = strrep(renFields,'(','_');
    renFields  = strrep(renFields,')','');
end