function plotDailyDistByFreq(site,varnames,freq,varargin)

varZero_daily = varargin{1};
varFirst_daily = varargin{2};
varSecond_daily = varargin{3};

recsPerDay = 24/freq;            
recsPerHour = 1/freq;

% plot hourly distribution by day
if isempty(varSecond_daily)
    close;
    figure('units','centimeters','outerposition',[0 0 25 25]);
    set(gcf,'color','white');

    ax(1) = subplot(2,1,1);
    boxplot(varZero_daily');
    xlim([1 recsPerDay]);
    set(gca,'XTick',1:recsPerHour:recsPerDay);
    set(gca,'XTickLabel',1:24);
    grid;
    title(varnames{1});

    ax(2) = subplot(2,1,2);
    boxplot(varFirst_daily');
    xlim([1 recsPerDay]);
    set(gca,'XTick',1:recsPerHour:recsPerDay);
    set(gca,'XTickLabel',1:24);
    grid;
    title(varnames{2});
 
    sgtitle([site ': distribution by day'])

else

    close;
    figure('units','centimeters','outerposition',[0 0 25 25]);
    % figure(2);
    set(gcf,'color','white');

    ax(1) = subplot(3,1,1);
    boxplot(varZero_daily');
    xlim([1 recsPerDay]);
    set(gca,'XTick',1:recsPerHour:recsPerDay);
    set(gca,'XTickLabel',1:24);
    grid;
    title(varnames{1});

    ax(2) = subplot(3,1,2);
    boxplot(varFirst_daily');
    xlim([1 recsPerDay]);
    set(gca,'XTick',1:recsPerHour:recsPerDay);
    set(gca,'XTickLabel',1:24);
    grid;
    title(varnames{2});

    ax(3) = subplot(3,1,3);
    boxplot(varSecond_daily');
    xlim([1 recsPerDay]);
    set(gca,'XTick',1:recsPerHour:recsPerDay);
    set(gca,'XTickLabel',1:24);
    grid;
    title(varnames{3});

    sgtitle([site ': distribution by day'])

end
