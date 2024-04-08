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
%
kill

yearIn = 2023;
siteID = 'TPAg';

ECpath  = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_CPEC_clean_%d.mat',siteID,yearIn));
METpath = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_master_%d.mat',siteID,yearIn));

% Create TimeVector
TimeVector = fr_round_time(datenum(yearIn,1,1,0,30,0):1/48:datenum(yearIn+1,1,1,0,0,0))';

tmp = load(ECpath);
TPAg_EC = convert_data(tmp.master);
TPAg_EC.TimeVector = TimeVector;
tmp = load(METpath);
TPAg_Met  = convert_data(tmp.master);
TPAg_Met.TimeVector = TimeVector;
clear tmp TimeVector

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
[structIn,dbFileNames, dbFieldNames,errCode] = db_struct2database(TPAg_EC,pthOutEC,verbose_flag,excludeSubStructures,timeUnit,missingPointValue,structType,1);

% Process Met data
dataType = 'Met';
pthOutMet = fullfile(dbPath,'yyyy',siteID,dataType);   
[structIn,dbFileNames, dbFieldNames,errCode] = db_struct2database(TPAg_Met,pthOutMet,verbose_flag,excludeSubStructures,timeUnit,missingPointValue,structType,1);


%% Load and plot one or more years of data

% load time vector
tv = read_bor(fullfile(pthOutEC,'clean_tv'),8,[],yearIn);

% convert time vector to Matlab's datetime
tv_dt = datetime(tv,'ConvertFrom','datenum');

% load TA from EC
Tair_EC = read_bor(fullfile(pthOutEC,'Tair'),[],[],yearIn);
AirTemp_AbvCnpy = read_bor(fullfile(pthOutMet,'AirTemp_AbvCnpy'),[],[],yearIn);

% show data
figure(1)
plot(tv_dt,[Tair_EC, AirTemp_AbvCnpy],'LineWidth',2)
title('Air Temperature')
legend('EC','Met');
ylabel('degC')
zoom on
grid on

%% Cleaning data First stage
%
% Create an ini file then run fr_automated_cleaning
% 
fr_automated_cleaning(yearIn,siteID,[1]);

%% Read and plot

dataType = 'Met\Clean';
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

%% Second stage cleaning (below we do 1 and 2):
fr_automated_cleaning(yearIn,siteID,[1 2]);

%% 
dataType = 'Clean\SecondStage';
pthSecondStageClean = fullfile(dbPath,'yyyy',siteID,dataType);
RH_SecondStage =  read_bor(fullfile(pthSecondStageClean,'RH_1_1_1'),[],[],yearIn);

figure(3)
plot(tv_dt,RH_1_1_1,'o',tv_dt,RH_SecondStage,'o')
title('RH')
legend('RH 1^{st} Stage','RH 2^{nd} Stage')
zoom on
grid on

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