%% Data cleaning for Turkey Point Sites (PI: Altaf Arain)
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

siteID = 'TPAG';    % must be upper case
yearIn = 2020:2023;

for yearIn = yearIn

    if strcmp(siteID,'TP_PPT') | strcmp(siteID,'TPD_PPT')   % only Met data
        METpath = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_master_%d.mat',siteID,yearIn));
        tmp_Met = load(METpath); %#ok<*NASGU>
        eval([siteID '_Met = convert_data(tmp_Met.master);'])
    else
        ECpath  = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_CPEC_clean_%d.mat',siteID,yearIn));
        METpath = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_master_%d.mat',siteID,yearIn));

        tmp_EC = load(ECpath);
        eval([siteID '_EC = convert_data(tmp_EC.master);'])
        tmp_Met = load(METpath);
        eval([siteID '_Met = convert_data(tmp_Met.master);'])
    end

    % Create TimeVector
    GMToffset = 5/24;  % Altaf's raw data is in GMT time, adjust to ET
    TimeVector = fr_round_time(datenum(yearIn,1,1,0,30,0):1/48:datenum(yearIn+1,1,1,0,0,0))' - GMToffset; %#ok<DATNM>

    if ~strcmp(siteID,'TP_PPT') | ~strcmp(siteID,'TPD_PPT')   % only Met data
        eval([siteID '_EC.TimeVector = TimeVector;']);
    end
    eval([siteID '_Met.TimeVector = TimeVector;']);

    clear tmp* TimeVector

    % return
    %-----------------------------------------------------------------------------
    % Database creation

    dbPath = biomet_database_default; %#ok<*UNRCH>

    structType = 1;  %0 - old and slow, 1 - new and fast
    verbose_flag=[];
    excludeSubStructures = [];
    timeUnit = '30min';
    missingPointValue = NaN;

    % Process Flux data
    dataType = 'Flux';
    pthOutEC = fullfile(dbPath,'yyyy',siteID,dataType);
    eval(['[structIn,dbFileNames, dbFieldNames,errCode] = db_struct2database(' siteID '_EC,pthOutEC,verbose_flag,excludeSubStructures,timeUnit,missingPointValue,structType,1);']);

    % Process Met data
    dataType = 'Met';
    pthOutMet = fullfile(dbPath,'yyyy',siteID,dataType);
    eval(['[structIn,dbFileNames, dbFieldNames,errCode] = db_struct2database(' siteID '_Met,pthOutMet,verbose_flag,excludeSubStructures,timeUnit,missingPointValue,structType,1);']);

end    % end looping over years


%% Load and plot one or more years of data
%plotRawDatabaseVars;

%% Cleaning data First stage 
% fr_automated_cleaning(yearIn,siteID,[1]); %#ok<NBRAK2>

%% First and second stage cleaning:
% fr_automated_cleaning(yearsIn,siteID,[1 2]);

%% Run third stage 
% Currently have workaround so R script can find Database, putting _config.yaml 
% file in both project root and Matlab directory (one below) - will be improved soon
% fr_automated_cleaning(yearsIn,siteID,7);

%% plot Third Stage "new" variables (e.g. GPP, NEE, etc.) and all others
% plotThirdStageNewVars;
% Flux_ThirdStagePlots;

%% Run first, second, third stage, and convert to AmeriFlux format ([1 2 7 8]) for all years
% Once everything is working and has been plotted/checked, can run all stages at once:
fr_automated_cleaning(yearIn,siteID,[1 2 7 8]);

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

% cd 'E:\Junk\Altaf_TP_test'
% setupLocalDataCleaning
% work on ini files, add a couple of lines, test, repeat...
% when happy go back to the server
% cd \\137.82.55.154\ExternalData\TurkeyPoint
% and re-run the cleaning
% fr_automated_cleaning(yearIn, siteID, [1 2]);


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