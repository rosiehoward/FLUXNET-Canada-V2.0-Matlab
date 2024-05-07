function plotStandardComparison(site,tv_dt,vars,varnames,firstStagePath)

% clf;
close;
figure('units','centimeters','outerposition',[0 0 50 40]);
set(gcf,'color','white');

width = 5;
scale = 'log';
yearIn = 2023;
% scale = 'linear';

[m,n] = size(vars); %#ok<ASGLU>

for j = 1:n
    eval(['n' num2str(j-1) ' = length(find(~isnan(vars(:,j))));']); %#ok<EVLSEQVAR>
    eval(['nPer' num2str(j-1) ' = (n' num2str(j-1) '/m)*100;']); %#ok<EVLSEQVAR>
    eval(['nPer' num2str(j-1) ' = round(nPer' num2str(j-1) '*10)/10;']); %#ok<EVLSEQVAR>
end

if n == 1
    annotation('textbox', [0.05, 0.05, 0.5, 0], 'string', ...
           ['n0 = ' num2str(n0) ' (' num2str(nPer0) '%),'],'fontsize',12);
elseif n == 2
    annotation('textbox', [0.05, 0.05, 0.5, 0], 'string', ...
           ['n0 = ' num2str(n0) ' (' num2str(nPer0) '%),' ...
            ' n1 = ' num2str(n1) ' (' num2str(nPer1) '%)'],'fontsize',12);
elseif n == 3
    annotation('textbox', [0.05, 0.05, 0.5, 0], 'string', ...
           ['n0 = ' num2str(n0) ' (' num2str(nPer0) '%),' ...
            ' n1 = ' num2str(n1) ' (' num2str(nPer1) '%),' ...
            ' n2 = ' num2str(n2) ' (' num2str(nPer2) '%)'],'fontsize',12);
end

%traces
subplot(3,2,1:2);
plot(tv_dt,vars(:,1),'.','LineWidth',2);
hold on;
if n == 2   % zero and first stages
    % plot(tv_dt,vars(:,1),'.','LineWidth',2);
    % hold on;
    plot(tv_dt,vars(:,2),'.','LineWidth',2);
    legend(varnames{1},varnames{2});
elseif n == 3   % second stage
    plot(tv_dt,vars(:,2),'.','LineWidth',2);
    plot(tv_dt,vars(:,3),'.','LineWidth',2);
    legend(varnames{1},varnames{2},varnames{3});
elseif n == 4   % third stage
    plot(tv_dt,vars(:,4),'.','LineWidth',2);
    legend(varnames{1},varnames{4});
end
zoom on
grid on

% histograms
subplot(3,2,3);
% histogram(vars(:,1));       % raw data
% hold on
% if n == 2   % first stages
%     histogram(vars(:,2));
%     set(gca,'YScale','log');
%     legend(varnames{1},varnames{2});
% elseif n == 3   % second stage
%     histogram(vars(:,2));
%     histogram(vars(:,3));
%     set(gca,'YScale','log');
%     legend(varnames{1},varnames{2},varnames{3});
% elseif n == 4   % all stages
%     histogram(vars(:,4));
%     legend(varnames{1},varnames{4});
% end

histogram(vars(:,1),'BinWidth',width);       % raw data
hold on
if n == 2   % first stages
    histogram(vars(:,2),'BinWidth',width);
    set(gca,'YScale',scale);
    legend(varnames{1},varnames{2});
elseif n == 3   % second stage
    histogram(vars(:,2),'BinWidth',width);
    histogram(vars(:,3),'BinWidth',width);
    set(gca,'YScale',scale);
    legend(varnames{1},varnames{2},varnames{3});
elseif n == 4   % all stages
    histogram(vars(:,4),'BinWidth',width);
    legend(varnames{1},varnames{4});
end
grid on

% scatterplots
subplot(3,2,4);
plot(vars(:,1),vars(:,2),'x');
hold on
maxVal = max(max(vars(:,1)),max(vars(:,2)));
minVal = min(min(vars(:,1)),min(vars(:,2)));
k = floor(minVal):ceil(maxVal);
plot(k,k,'--');
if n == 2   % zero and first stages
    legend('zero-one','1:1',Location='northwest');
elseif n == 3   % second stage
    plot(vars(:,2),vars(:,3),'.');
    legend('zero-one','1:1','one-two',Location='northwest');
elseif n == 4   % third stages
    plot(vars(:,3),vars(:,4),'.');
    legend('zero-one','1:1','two-three',Location='northwest');
end
xlabel(varnames{1});
ylabel(varnames{2});
grid on


% difference calculations
if n == 2
    diff21 = vars(:,1) - vars(:,2);     % difference between second and first
elseif n == 3
    diff21 = vars(:,1) - vars(:,2);     % difference between second and first
    diff31 = vars(:,1) - vars(:,3);    % difference between third and first
    diff32 = vars(:,2) - vars(:,3);    % difference between third and second
end

% difference plots
if n == 2
    subplot(3,2,5);
    plot(tv_dt,diff21,'.');
    legend('Diff')
    grid on

    subplot(3,2,6);
    histogram(diff21);
    legend('Diff')
    set(gca,'YScale','log');
    grid on

elseif n == 3
    % subplot(3,2,5);
    % plot(tv_dt,diff21,'.');
    % hold on
    % plot(tv_dt,diff31,'.');
    % plot(tv_dt,diff32,'.');
    % grid on
    % legend('diff21','diff31','diff32')

    subplot(3,2,5);
    histogram(diff21);
    grid on
    hold on
    histogram(diff31);
    histogram(diff32);
    set(gca,'YScale','log');
    legend('diff21','diff31','diff32')

    subplot(3,2,6);
    ptile = 95;
    wrotstd = read_bor(fullfile(firstStagePath,'W_SIGMA_1_1_1'),[],[],yearIn);
    wrotstd_ptile = prctile(wrotstd,ptile);
    histogram(wrotstd);
    grid on
    hold on
    h1 = xline(wrotstd_ptile,'k--',{'90th'},'LineWidth',1.5);
    h1.FontSize = 12;
    legend('w_sigma')
end

if n == 2
    sgtitle([site ': FirstStage-Original Comparison']);
elseif n == 3
    sgtitle([site ': SecondStage-FirstStage-Original Comparison']);
elseif n == 4
    sgtitle([site ': ThirdStage-SecondStage Comparison']);
end

