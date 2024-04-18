function plotStatsAllStages(site,statsAllStages,plotTitle)

% barchart of all stats
close all;
% clf;
% figure(1);
figure('units','centimeters','outerposition',[0 0 25 25]);
set(gcf,'color','white');

[~,n] = size(statsAllStages);

if n == 2
    annotation('textbox', [0.05, 0.05, 0.5, 0], 'string', ...
        ['corrZeroFirst = ' num2str(statsAllStages(6,2))]);
elseif n == 3
    annotation('textbox', [0.05, 0.05, 0.5, 0], 'string', ...
        ['corrZeroFirst = ' num2str(statsAllStages(6,2)) ...
        ', corrFirstSecond = ' num2str(statsAllStages(6,3))]);
else
    fprintf('Check size of input to plotStatsAllStages...\n');
end

subplot(2,1,1);
bar(statsAllStages(1:5,:));
set(gca,'YGrid','on');
if n == 2
    legend('Zero','First','location','northeast');
elseif n == 3
    legend('Zero','First','Second','location','northeast');
end
xticklabels({'Max','Min','Mean','Median','Std'});

subplot(2,1,2);
bar(statsAllStages(7:8,:));
set(gca,'YGrid','on');
if n == 2
    legend('','Zero-First','location','northwest');
elseif n == 3
    legend('','Zero-First','First-Second','location','northwest');
end

xticklabels({'MAE','RMSE'});

sgtitle([site ': Stats for ' plotTitle{length(plotTitle)}]);    % use second stage variable name

