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
dbpath = biomet_database_default;
siteID = 'TPAg';
yearIn = 2023;
freq = 0.5; % hours

% set other manual parameters
stage = 'First';   % select stage to compare up to (Zero, First, Second; 
                    % cleaning must have been done up to this stage)

% look at traces/histograms/scatterplots
makeStandardPlot = 0;   % 1 = yes, 0 = no
saveStandardPlot = 1;   % 1 = yes, 0 = no

% look at stats
stats = 0;         
saveStatsPlots = 1;

% look at daily distributions
dailyDist = 1;  
saveDistPlots = 1;

varMapFile = 'VariableMapping.xlsx';
localRootPath = '../../Matlab/local_personal_plots/Altaf_data/';

% load variable mapping spreadsheet (must create this first)
% ****later can come from INI files but this works for now****
varMap = readtable(fullfile(localRootPath,siteID,varMapFile));
[numVar,~] = size(varMap);

% select stages to compare (this needs to be handled much better)
stageZero = varMap.Properties.VariableNames{4};    % original data
stageOne = varMap.Properties.VariableNames{5};    % First stage
stageTwo = varMap.Properties.VariableNames{6};      % Second stage

% is it a leap year?
% use Biomet function "leapyear"
leap = leapyear(yearIn);

if leap
    fprintf('\n');
    fprintf([num2str(yearIn) ' is a leap year\n']);
    daysPerYear = 366;
else
    fprintf('\n');
    fprintf([num2str(yearIn) ' is not a leap year\n']);
    daysPerYear = 365;
end

%% loop over variables (comparing across stages)
a = find(varMap.IncludeInPlotting == 1);

for i = 1:length(a)
    if varMap.IncludeInPlotting(a(i)) == 1     % plot this variable
        fprintf('\n');
        fprintf(['Looking at ' varMap.OriginalName{a(i)} '...\n']);
        if strcmpi(varMap.Site{a(i)},siteID) == 0
            % need path to data for alternative site
            dataPathZero = fullfile([dbpath '/yyyy/' varMap.Site{a(i)} '/' varMap.MetOrFlux{a(i)}]);
            dataPathOne = fullfile([dbpath '/yyyy/' varMap.Site{a(i)} '/' varMap.MetOrFlux{a(i)} '/Clean']);
            dataPathTwo = fullfile([dbpath '/yyyy/' varMap.Site{a(i)} '/Clean/SecondStage']);
        else
            % need path to data for CURRENT site
            dataPathZero = fullfile([dbpath '/yyyy/' siteID '/' varMap.MetOrFlux{a(i)}]);
            dataPathOne = fullfile([dbpath '/yyyy/' siteID '/' varMap.MetOrFlux{a(i)} '/Clean']);
            dataPathTwo = fullfile([dbpath '/yyyy/' siteID '/Clean/SecondStage']);
        end

        % load time vector
        pthOut = fullfile(dbpath,'yyyy',siteID,varMap.MetOrFlux{a(i)});
        tv = read_bor(fullfile(pthOut,'clean_tv'),8,[],yearIn);
        % convert time vector to Matlab's datetime
        tv_dt = datetime(tv,'ConvertFrom','datenum');

        % load variables
        varname0 = eval(['varMap.' stageZero '{a(i)}']); %#ok<EVLDOT>
        var0 = read_bor(fullfile(dataPathZero,varname0),[],[],yearIn);
        varname1 = eval(['varMap.' stageOne '{a(i)}']); %#ok<EVLDOT>
        var1 = read_bor(fullfile(dataPathOne,varname1),[],[],yearIn);
        if strcmpi(stage,'Second')
            varname2 = eval(['varMap.' stageTwo '{a(i)}']); %#ok<UNRCH,EVLDOT>
            var2 = read_bor(fullfile(dataPathTwo,varname2),[],[],yearIn);
            if strcmpi(varname1,varname2)
                varname2 = [varname2 '_SecondStage']; %#ok<AGROW>
            end
        end
        
        % concat variables for easy argument passing
        if strcmpi(stage,'First')
            n = 2;
            vars = cat(2,var0,var1);
            varnames = {varname0,varname1};
        elseif strcmpi(stage,'Second')
            n = 3;
            vars = cat(2,var0,var1,var2);
            varnames = {varname0,varname1,varname2};
        end
        
        %*********************************
        % plot standard variables
        if makeStandardPlot == 1
            fprintf('\n');
            fprintf('Plotting standard comparisons between stages...\n');
            plotStandardComparison(siteID,tv_dt,vars,varnames);
            % save plot
            if saveStandardPlot == 1
                if n == 2
                    fprintf('\n');
                    fprintf(['Saving ' varnames{1} ' plot...\n']);
                    savepath = [localRootPath siteID '/' num2str(yearIn) '/' varMap.MetOrFlux{a(i)} '/Clean/'];
                    filetext = varnames{2};
                elseif n == 3
                    fprintf('\n');
                    fprintf(['Saving ' varnames{1} ' plot...\n']);
                    savepath = [localRootPath siteID '/' num2str(yearIn) '/Clean/SecondStage/'];
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
                    savepath = [localRootPath siteID '/' num2str(yearIn) '/' varMap.MetOrFlux{a(i)} '/Clean/'];
                    filetext = [varnames{2} '_Stats'];
                elseif n == 3
                    savepath = [localRootPath siteID '/' num2str(yearIn) '/Clean/SecondStage/'];
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
                    savepath = [localRootPath siteID '/' num2str(yearIn) '/' varMap.MetOrFlux{a(i)} '/Clean/'];
                    filetext = [varnames{2} '_Distr'];
                elseif n == 3
                    savepath = [localRootPath siteID '/' num2str(yearIn) '/Clean/SecondStage/'];
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

