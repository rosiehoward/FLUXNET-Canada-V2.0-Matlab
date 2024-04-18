function plotStandardComparison(site,tv_dt,vars,varnames)

% clf;
close;
figure('units','centimeters','outerposition',[0 0 40 40]);
set(gcf,'color','white');

[~,n] = size(vars);

%traces
subplot(3,2,1:2);
plot(tv_dt,vars(:,1),'.','LineWidth',2);
hold on;
plot(tv_dt,vars(:,2),'.','LineWidth',2);
if n == 2   % zero and first stages
    legend(varnames{1},varnames{2});
elseif n == 3   % all stages
    plot(tv_dt,vars(:,3),'.','LineWidth',2);
    legend(varnames{1},varnames{2},varnames{3});
end
zoom on
grid on

% histograms
subplot(3,2,3);
histogram(vars(:,1));
hold on
histogram(vars(:,2));
if n == 2   % zero and first stages
    legend(varnames{1},varnames{2});
elseif n == 3   % all stages
    histogram(vars(:,3));
    legend(varnames{1},varnames{2},varnames{3});
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
elseif n == 3   % all stages
    plot(vars(:,2),vars(:,3),'.');
    legend('zero-one','1:1','one-two',Location='northwest');
end
xlabel(varnames{1});
ylabel(varnames{2});
grid on

% different plot
subplot(3,2,5:6);
plot(tv_dt,vars(:,1) - vars(:,2),'.');
if n == 3
    hold on; 
    plot(tv_dt,vars(:,1) - vars(:,3),'.');
    plot(tv_dt,vars(:,2) - vars(:,3),'.');
end
legend('Diff')
grid on

if n == 2
    sgtitle([site ': FirstStage-Original Comparison']);
elseif n == 3
    sgtitle([site ': SecondStage-FirstStage-Original Comparison']);
end

