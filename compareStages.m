function compareStages(path,site,year)
% compare plots between data cleaning stages
%
% arguments:
%       path: path to Database
%       site: siteID
%       year: yearIn
%
% Rosie Howard
% 8 April 2024

% load variable mapping spreadsheet (must create this first)
% ****later can come from INI files but this works for now****
varMapFile = 'VariableMapping.xlsx';
varMapPath = ['../../Matlab/local_personal_plots/Altaf_data/' site '/'];
varMap = readtable([varMapPath varMapFile]);
[numVar,~] = size(varMap);

% select stages to compare (this needs to be handled much better)
stageZero = varMap.Properties.VariableNames{4};    % original data
stageOne = varMap.Properties.VariableNames{5};    % First stage
stageTwo = varMap.Properties.VariableNames{6};      % Second stage

saveplot = 0;   % = yes, 0 = no (add as input arg?)
makeplot = 1;   % = yes, 0 = no (add as input arg?)
stats = 1;      % look at stats    

% loop over variables
for i = 1:numVar
    if varMap.IncludeInPlotting(i) == 1     % plot this variable
        disp(['Looking at ' varMap.OriginalName{i} '...']);
        if strcmp(varMap.Site{i},site) == 0
            % need path to data for alternative site
            dataPathZero = fullfile([path '/yyyy/' varMap.Site{i} '/' varMap.MetOrFlux{i}]);
            dataPathOne = fullfile([path '/yyyy/' site '/' varMap.MetOrFlux{i} '/Clean']);
            dataPathTwo = fullfile([path '/yyyy/' site '/Clean/SecondStage']);
        else
            % need path to data for CURRENT site
            dataPathZero = fullfile([path '/yyyy/' site '/' varMap.MetOrFlux{i}]);
            dataPathOne = fullfile([path '/yyyy/' site '/' varMap.MetOrFlux{i} '/Clean']);
            dataPathTwo = fullfile([path '/yyyy/' site '/Clean/SecondStage']);
        end
        

        % load time vector
        pthOut = fullfile(path,'yyyy',site,varMap.MetOrFlux{i});
        tv = read_bor(fullfile(pthOut,'clean_tv'),8,[],year);
        % convert time vector to Matlab's datetime
        tv_dt = datetime(tv,'ConvertFrom','datenum');

        % load variables
        varname1 = eval(['varMap.' stageZero '{i}']); %#ok<EVLDOT>
        var1 = read_bor(fullfile(dataPathZero,varname1),[],[],year);
        varname2 = eval(['varMap.' stageOne '{i}']); %#ok<EVLDOT>
        var2 = read_bor(fullfile(dataPathOne,varname2),[],[],year);
        varname3 = eval(['varMap.' stageTwo '{i}']); %#ok<EVLDOT>
        var3 = read_bor(fullfile(dataPathTwo,varname3),[],[],year);
        if strcmp(varname2,varname3)
            varname3 = [varname3 '_SecondStage']; %#ok<AGROW>
        end

        %% plot variables
        if makeplot == 1
            clf;
            % close;
            % figure('units','centimeters','outerposition',[0 0 40 40]);
            set(gcf,'color','white');

            %traces
            subplot(3,2,1:2);
            plot(tv_dt,var1,'.','LineWidth',2)
            hold on
            plot(tv_dt,var2,'.','LineWidth',2)
            % legend(varname1,varname2);
            plot(tv_dt,var3,'.','LineWidth',2)
            legend(varname1,varname2,varname3);
            % ylabel('degC')
            zoom on
            grid on

            % histograms
            subplot(3,2,3);
            histogram(var1);
            hold on
            histogram(var2);
            histogram(var3);
            legend(varname1,varname2,varname3);
            grid on

            % scatterplots
            subplot(3,2,4);
            plot(var1,var2,'x');
            hold on
            plot(var2,var3,'.');
            xlabel(varname1);
            ylabel(varname2);
            grid on
            maxVal = max(max(var1),max(var2));
            minVal = min(min(var1),min(var2));
            k = floor(minVal):ceil(maxVal);
            plot(k,k,'--');
            legend('zero-one','one-two','1:1',Location='northwest')

            % different plot
            subplot(3,2,5:6);
            plot(tv_dt,var1 - var2,'.');
            hold on
            plot(tv_dt,var1 - var3,'.');
            plot(tv_dt,var2 - var3,'.');
            legend('Diff')
            grid on

            sgtitle([site ' - Stages Comparison']);

            % save plot
            if saveplot == 1
                savepath = [varMapPath num2str(year) '/' varMap.MetOrFlux{i} '/Clean/'];
                filetext = varname3;
                type = 'png';
                im_res = 200;
                str = ['print -d' type ' -r' num2str(im_res) ' ' savepath filetext '.' type];
                eval(str);
            end
        end

        if stats == 1
            if strcmp(varname2,'SW_IN_1_1_1') | strcmp(varname2,'SW_OUT_1_1_1')
                SW_down = daily_SW_stats(var3);
                figure; boxplot(SW_down');
            end
        end

       
    else
        continue
    end
    

end


end
