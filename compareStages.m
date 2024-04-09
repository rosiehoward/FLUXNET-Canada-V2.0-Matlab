function compareStages(path,site,year)
% compare plots between data cleaning stages
%
% Rosie Howard
% 8 April 2024

% load variable mapping spreadsheet (must create this first)
% later can come from INI files but this works for now
varMapFile = 'VariableMapping.xlsx';
varMapPath = ['../../Matlab/local_personal_plots/Altaf_data/' site '/'];
varMap = readtable([varMapPath varMapFile]);
[numVar,~] = size(varMap);

% select stages to compare (this needs to be handled much better)
stageZero = varMap.Properties.VariableNames{3};    % original data
stageOne = varMap.Properties.VariableNames{4};    % First stage
% stageTwo = varMap.Properties.VariableNames{5};      % Second stage

% loop over variables
for i = 1:numVar
    if varMap.IncludeInPlotting(i) == 1
        % plot this variable, need path to data
        dataPathZero = fullfile([path '/yyyy/' site '/' varMap.MetOrFlux{i}]);
        dataPathOne = fullfile([path '/yyyy/' site '/' varMap.MetOrFlux{i} '/Clean']);

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

        % plot variables
        clf;
        set(gcf,'color','white');

        %traces
        subplot(2,2,1:2);
        plot(tv_dt,var1,'.','LineWidth',2)
        hold on
        plot(tv_dt,var2,'.','LineWidth',2)
        legend(varname1,varname2);
        % ylabel('degC')
        zoom on
        grid on

        % histograms
        subplot(2,2,3);
        histogram(var1);
        hold on
        histogram(var2);
        legend(varname1,varname2);
        grid on

        % scatterplots
        subplot(2,2,4);
        plot(var1,var2,'x');
        xlabel(varname1);
        ylabel(varname2);
        grid on

    else
        continue
    end

end


end
