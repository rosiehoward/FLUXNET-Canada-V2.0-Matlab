% function compareStages(path,site,year)
% compare plots between data cleaning stages
%
% arguments:
%       path:   path to Database
%       site:   siteID
%       year:   yearIn
%       stage:  stage to compare up to (first or second)
%
% Rosie Howard
% 8 April 2024

clear;
% set database path, site ID, and year
dbPath = biomet_database_default;
siteID = 'TPAG';
yearIn = 2020:2023;
freq = 0.5; % hours

% set other manual parameters
stage = 'Second';   % select stage to compare up to (Zero, First, Second, Third; 
                    % cleaning must have been done up to the stage you select!)

% look at traces/histograms/scatterplots
makeStandardPlot = 1;   % 1 = yes, 0 = no
saveStandardPlot = 1;   % 1 = yes, 0 = no

% look at stats
stats = 0;         
saveStatsPlots = 1;

% look at daily distributions
dailyDist = 0;  
saveDistPlots = 1;

varMapFile = 'VariableMapping.xlsx';
localPlotsPath = '../../Matlab/local_personal_plots/TurkeyPoint_Altaf/';

% load variable mapping spreadsheet (must create this first)
% ****later can come from INI files but this works for now****
varMap = readtable(fullfile(localPlotsPath,siteID,varMapFile));
[numVar,~] = size(varMap);

% select stages to compare (this needs to be handled much better)
stageZero = varMap.Properties.VariableNames{4};    % original data
stageOne = varMap.Properties.VariableNames{5};    % First stage
stageTwo = varMap.Properties.VariableNames{6};      % Second stage
stageThree = varMap.Properties.VariableNames{7};    % Third stage


%% loop over variables (comparing across stages)
a = find(varMap.IncludeInPlotting == 1);

for year = yearIn

    % is it a leap year?
    % use Biomet function "leapyear"
    leap = leapyear(year);
    if leap
        fprintf('\n');
        fprintf([num2str(year) ' is a leap year\n']);
        daysPerYear = 366;
    else
        fprintf('\n');
        fprintf([num2str(year) ' is not a leap year\n']);
        daysPerYear = 365;
    end

    for i = 1:length(a)
        if varMap.IncludeInPlotting(a(i)) == 1     % plot this variable
            fprintf('\n');
            fprintf(['Looking at ' varMap.OriginalName{a(i)} '...\n']);
            if strcmpi(varMap.Site{a(i)},siteID) == 0
                % need path to data for alternative site
                dataPathZero = fullfile(biomet_path('yyyy',varMap.Site{a(i)},varMap.MetOrFlux{a(i)}));
                dataPathOne = fullfile(biomet_path('yyyy',varMap.Site{a(i)},[varMap.MetOrFlux{a(i)} '/Clean']));
                dataPathTwo = fullfile(biomet_path('yyyy',varMap.Site{a(i)},'/Clean/SecondStage'));
                dataPathThree = fullfile(biomet_path('yyyy',varMap.Site{a(i)},'/Clean/ThirdStage'));
            else
                % need path to data for CURRENT site
                dataPathZero = fullfile(biomet_path('yyyy',siteID,varMap.MetOrFlux{a(i)}));
                dataPathOne = fullfile(biomet_path('yyyy',siteID,[varMap.MetOrFlux{a(i)} '/Clean']));
                dataPathTwo = fullfile(biomet_path('yyyy',siteID,'/Clean/SecondStage'));
                dataPathThree = fullfile(biomet_path('yyyy',siteID,'/Clean/ThirdStage'));
            end

            % load time vector
            % pthOut = fullfile(dbPath,'yyyy',siteID,varMap.MetOrFlux{a(i)});
            tv = read_bor(fullfile(biomet_path('yyyy',siteID,varMap.MetOrFlux{a(i)}),'clean_tv'),8,[],year);
            % convert time vector to Matlab's datetime
            tv_dt = datetime(tv,'ConvertFrom','datenum');

            % load variables
            if ~strcmpi(varMap.OriginalName{a(i)},'NaN')
                varname0 = eval(['varMap.' stageZero '{a(i)}']); %#ok<EVLDOT>
                var0 = read_bor(fullfile(dataPathZero,varname0),[],[],year);
            end
            if ~strcmpi(varMap.FirstStageName{a(i)},'NaN')
                varname1 = eval(['varMap.' stageOne '{a(i)}']); %#ok<EVLDOT>
                var1 = read_bor(fullfile(dataPathOne,varname1),[],[],year);
            end
            if strcmpi(stage,'Second')
                if ~strcmpi(varMap.SecondStageName{a(i)},'NaN')
                    varname2 = eval(['varMap.' stageTwo '{a(i)}']); %#ok<EVLDOT>
                    var2 = read_bor(fullfile(dataPathTwo,varname2),[],[],year);
                    varname2 = [varname2 '_SecondStage']; %#ok<AGROW>
                end
            elseif strcmpi(stage,'Third') %#ok<UNRCH>
                if ~strcmpi(varMap.ThirdStageName{a(i)},'NaN')
                    varname3 = eval(['varMap.' stageThree '{a(i)}']); %#ok<EVLDOT>
                    var3 = read_bor(fullfile(dataPathThree,varname3),[],[],year);
                    varname3 = [varname3 '_ThirdStage']; %#ok<AGROW>
                end
            end

            % concat variables for easy argument passing
            if strcmpi(stage,'First') & exist('var0',"var") && exist('var1',"var")
                n = 2;
                vars = cat(2,var0,var1);
                varnames = {varname0,varname1};
            elseif strcmpi(stage,'Second') & exist('var0',"var") && exist('var1',"var") && exist('var2',"var")
                n = 3;
                vars = cat(2,var0,var1,var2);
                varnames = {varname0,varname1,varname2};
            elseif strcmpi(stage,'Third') & exist('var0',"var") && exist('var1',"var") && exist('var2',"var") && exist('var3',"var")
                n = 4;
                vars = cat(2,var0,var1,var2,var3);
                varnames = {varname0,varname1,varname2,varname3};
            end

            %*********************************
            % plot standard variables
            if makeStandardPlot == 1
                fprintf('\n');
                fprintf('Plotting standard comparisons between stages...\n');
                plotStandardComparison(siteID,tv_dt,vars,varnames,dataPathOne);
                % save plot
                % dataPathOne
                if saveStandardPlot == 1
                    if n == 2
                        fprintf('\n');
                        fprintf(['Saving ' varnames{1} ' plot...\n']);
                        savepath = [localPlotsPath siteID '/' num2str(year) '/' varMap.MetOrFlux{a(i)} '/Clean/'];
                        filetext = varnames{2};
                    elseif n == 3
                        fprintf('\n');
                        fprintf(['Saving ' varnames{2} ' plot...\n']);
                        savepath = [localPlotsPath siteID '/' num2str(year) '/Clean/SecondStage/'];
                        filetext = varnames{3};
                    elseif n == 4
                        fprintf('\n');
                        fprintf(['Saving ' varnames{3} ' plot...\n']);
                        savepath = [localPlotsPath siteID '/' num2str(year) '/Clean/ThirdStage/'];
                        filetext = varnames{3};
                    end
                    type = 'png';
                    im_res = 200;
                    str = ['print -d' type ' -r' num2str(im_res) ' ' savepath filetext '.' type];
                    eval(str);
                end
            end
            %*********************************

            %*********************************
            % calculate and plot stats
            if stats == 1
                fprintf('\n');
                fprintf('Calculating stats and doing some plotting...\n');
                statsAllStages = varStats(vars);

                % barchart of all stats
                plotStatsAllStages(siteID,statsAllStages,varnames);
                % save plot
                if saveStatsPlots == 1
                    fprintf('\n');
                    fprintf(['Saving ' varnames{1} ' plot...\n']);
                    if n == 2
                        savepath = [localPlotsPath siteID '/' num2str(year) '/' varMap.MetOrFlux{a(i)} '/Clean/'];
                        filetext = [varnames{2} '_Stats'];
                    elseif n == 3
                        savepath = [localPlotsPath siteID '/' num2str(year) '/Clean/SecondStage/'];
                        filetext = [varnames{3} '_Stats'];
                    end

                    type = 'png';
                    im_res = 200;
                    str = ['print -d' type ' -r' num2str(im_res) ' ' savepath filetext '.' type];
                    eval(str);
                end
            end
            %*********************************

            %*********************************
            if dailyDist == 1
                % rearrange arrays into daily data
                recsPerDay = 24/freq;
                recsPerHour = 1/freq;
                varZero_daily = convertToDailyArray(vars(:,1),recsPerDay,daysPerYear);
                varFirst_daily = convertToDailyArray(vars(:,2),recsPerDay,daysPerYear);
                varSecond_daily = [];
                if n == 3
                    varSecond_daily = convertToDailyArray(vars(:,3),recsPerDay,daysPerYear);
                end

                % plot hourly distribution by day
                plotDailyDistByFreq(siteID,varnames,freq,varZero_daily,varFirst_daily,varSecond_daily);
                % save plot
                if saveDistPlots == 1
                    if n == 2
                        savepath = [localPlotsPath siteID '/' num2str(year) '/' varMap.MetOrFlux{a(i)} '/Clean/'];
                        filetext = [varnames{2} '_Distr'];
                    elseif n == 3
                        savepath = [localPlotsPath siteID '/' num2str(year) '/Clean/SecondStage/'];
                        filetext = [varnames{3} '_Distr'];
                    end
                    type = 'png';
                    im_res = 200;
                    str = ['print -d' type ' -r' num2str(im_res) ' ' savepath filetext '.' type];
                    eval(str);
                end
            end

        else
            continue
        end
    end

end

