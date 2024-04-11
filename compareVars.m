% function [var1,var2,tv_dt] = compareVars(path,site,year,indVar1,indVar2,plotName)
% compare variables where two or more exist after FirstStage
%
% arguments:
%       path:                   path to Database (biomet_database_default)
%       site:                   siteID
%       year:                   yearIn
%       indVar1:                index of first variable to compare (from
%                               varMapFile Excel spreadsheet 'VariableCompare.xlsx)
%                               ***This can be changed later to get data from INI files instead***
%       indVar2:                index of second variable to compare
%       plotName (optional):    provide filename if you want to save the plot
%
% Rosie Howard
% 9 April 2024

% load variable mapping spreadsheet (must create this first)
% ****later can come from INI files but this works for now****
% default compare file
varMapFile = 'VariableCompare.xlsx';
varMapPath = ['../../Matlab/local_personal_plots/Altaf_data/' site '/'];
varMap = readtable([varMapPath varMapFile]);
% [numVar,~] = size(varMap);

% select variables to compare (this needs to be handled much better)
variableInds = [indVar1,indVar2];  % enter two (or more) rows to be compared
% variableInds = [indVar1,indVar2];  % enter two (or more) rows to be compared

% varname1 = varMap.FirstStageName{variableInds(1)};    % first variable
% varname2 = varMap.FirstStageName{variableInds(2)};    % second variable

dataType1 = varMap.MetOrFlux{variableInds(1)};
dataType2 = varMap.MetOrFlux{variableInds(2)};

% path to original data
pthOut1 = fullfile(path,'yyyy',site,varMap.dataType1);
pthOut2 = fullfile(path,'yyyy',site,varMap.dataType2);

% dataPath1 = fullfile([path '/yyyy/' site '/' varMap.MetOrFlux{variableInds(1)} '/Clean']);
% dataPath2 = fullfile([path '/yyyy/' site '/' varMap.MetOrFlux{variableInds(2)} '/Clean']);

% load time vector
% pthOut = fullfile(path,'yyyy',site,varMap.MetOrFlux{variableInds(1)});
tv = read_bor(fullfile(pthOut1,'clean_tv'),8,[],year);  % clean_tv is the same everywhere (or should be!)
% convert time vector to Matlab's datetime
tv_dt = datetime(tv,'ConvertFrom','datenum');

% path to First Stage data
dataType1 = 'Met/Clean';     % for Mac
dataType2 = 'Flux/Clean';     % for Mac

pthFirstStageCleanMet = fullfile(dbPath,'yyyy',siteID,dataType1);
pthFirstStageCleanMFlux = fullfile(dbPath,'yyyy',siteID,dataType2);

dataType = 'Clean/SecondStage';
pthSecondStageClean = fullfile(dbPath,'yyyy',siteID,dataType);

% load variables
var1 = read_bor(fullfile(dataPath1,varname1),[],[],year);
var2 = read_bor(fullfile(dataPath2,varname2),[],[],year);

% plot variables
if ~isempty(plotName)
    saveplot = 1;   % = yes, 0 = no (add as input arg?)
else 
    saveplot = 0;
end
close;
figure('units','centimeters','outerposition',[0 0 40 40]);
set(gcf,'color','white');

%traces
subplot(3,2,1:2);
plot(tv_dt,var1,'.','LineWidth',2)
hold on
plot(tv_dt,var2,'.','LineWidth',2)
legend(varname1,varname2);
% ylabel('degC')
zoom on
grid on

% difference plot
subplot(3,2,3:4);
plot(tv_dt,var1 - var2,'o',tv_dt,tv*0,'k--');
legend('Diff')
grid on

% histograms
subplot(3,2,5);
histogram(var1);
hold on
histogram(var2);
legend(varname1,varname2);
grid on

% scatterplots
subplot(3,2,6);
plot(var2,var1,'x');
xlabel(varname2);
ylabel(varname1);
hold on
grid on
maxVal = max(max(var1),max(var2));
minVal = min(min(var1),min(var2));
k = floor(minVal):ceil(maxVal);
plot(k,k,'k--');
legend('Meas','1:1',Location='northwest')

sgtitle([site ': ' varname1 ' & ' varname2 ' Comparison']);

% save plot
if saveplot == 1
    savepath = [varMapPath num2str(year) '/CompareDiffVar/'];
    filetext = plotName;
    type = 'png';
    im_res = 200;
    str = ['print -d' type ' -r' num2str(im_res) ' ' savepath filetext '.' type];
    eval(str);
end

% end     % end of function
