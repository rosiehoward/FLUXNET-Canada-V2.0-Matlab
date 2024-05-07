% irgaFilteringPlots.m
% Rosie Howard
% 1 May 2024

clear;
siteID = 'TPAg';
yearIn = 2023;

dbPath = biomet_database_default;

firstStageMetPath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Met/Clean';
firstStageFluxPath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Flux/Clean';

secondStagePath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Clean/SecondStage';
thirdStagePath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Clean/ThirdStage';

% test for correlation between CO2/H2O (open path) and precipitation
WS_TP39 = read_bor(fullfile(firstStageMetPath,'WS_TP39'),[],[],yearIn);

% load variables
% GN_Precip = read_bor(fullfile(pthOut,'GN_Precip'),[],[],yearIn);
TX_Rain = read_bor(fullfile('/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TP_PPT/Met','TX_Rain'),[],[],yearIn);

CO2 = read_bor(fullfile(firstStageFluxPath,'CO2_MIXING_RATIO_1_1_1'),[],[],yearIn);
H2O = read_bor(fullfile(firstStageFluxPath,'H2O_MIXING_RATIO_1_1_1'),[],[],yearIn);
Fc = read_bor(fullfile(firstStageFluxPath,'FC'),[],[],yearIn);
wrot = read_bor(fullfile(firstStageFluxPath,'w_rot'),[],[],yearIn);

USTAR_SecondStage = read_bor(fullfile(secondStagePath,'USTAR'),[],[],yearIn);
H_SecondStage = read_bor(fullfile(secondStagePath,'H'),[],[],yearIn);
LE_SecondStage = read_bor(fullfile(secondStagePath,'LE'),[],[],yearIn);

TA_1_1_1_FirstStage = read_bor(fullfile(firstStageMetPath,'TA_1_1_1'),[],[],yearIn);
RH_1_1_1_FirstStage = read_bor(fullfile(firstStageMetPath,'RH_1_1_1'),[],[],yearIn);

PA_1_1_1_SecondStage = read_bor(fullfile(secondStagePath,'PA_1_1_1'),[],[],yearIn);
TA_1_1_1_SecondStage = read_bor(fullfile(secondStagePath,'TA_1_1_1'),[],[],yearIn);
RH_1_1_1_SecondStage = read_bor(fullfile(secondStagePath,'RH_1_1_1'),[],[],yearIn);
VPD_1_1_1_SecondStage = read_bor(fullfile(secondStagePath,'VPD_1_1_1'),[],[],yearIn);

Tdew = dewpointMet(TA_1_1_1_SecondStage,RH_1_1_1_SecondStage);
Tdep = TA_1_1_1_SecondStage - Tdew;  % dewpoint depression
T_LiCorSurface = TA_1_1_1_SecondStage + 2;   % big assumption, dependent on radiation etc.
Tdep_LiCor = T_LiCorSurface - Tdew;

% for dew to form on LiCor surface, it must cool to Tdew temperature
indTdep = find(Tdep > 0);  % just use air temperature for now, remove indices where Tdep > 0 (Ts or Ta is warmer than Tdew)
Tdep_cond(indTdep) = NaN;

CO2std = read_bor(fullfile(firstStageFluxPath,'CO2_SIGMA_1_1_1'),[],[],yearIn);
H2Ostd = read_bor(fullfile(firstStageFluxPath,'H2O_SIGMA_1_1_1'),[],[],yearIn);
wrotstd = read_bor(fullfile(firstStageFluxPath,'W_SIGMA_1_1_1'),[],[],yearIn);

% percentiles and other stats
% ptile_test = 85;    % change this percentile to experiment with data removal
% ptiles = [80,85,90];
ptiles = [85,90,95];
% ptiles = [70,80,90];
% ptiles = [50,75,90,95];
len_ptiles = length(ptiles);

% load time vector
tv = read_bor(fullfile(firstStageMetPath,'clean_tv'),8,[],yearIn);
% convert time vector to Matlab's datetime
tv_dt = datetime(tv,'ConvertFrom','datenum');

%% CO2

CO2std_max = max(CO2std,[],"omitmissing");
CO2std_min = min(CO2std,[],"omitmissing");
CO2std_ptiles = prctile(CO2std,ptiles);

% try different percentiles
CO2_ptiles = repmat(CO2,[1 len_ptiles]);

for i = 1:len_ptiles
    indCO2std = find(CO2std > CO2std_ptiles(i));
    CO2_ptiles(indCO2std,i) = NaN;
end

%% plot CO2 by CO2std data removal
figure;
subplot(2,1,1)
plot(tv_dt,CO2,'.')
hold on
% plot(tv_dt,CO2_ptiles(:,4),'.')
plot(tv_dt,CO2_ptiles(:,3),'.')
plot(tv_dt,CO2_ptiles(:,2),'.')
plot(tv_dt,CO2_ptiles(:,1),'.')
grid
set(gcf,'color','white');
ylabel('CO2 mixing ratio')

subplot(2,1,2)
width = 5;
histogram(CO2,'BinWidth',width)
grid
hold on
% histogram(CO2_ptiles(:,4),'BinWidth',width)
set(gca,'YScale','log');
histogram(CO2_ptiles(:,3),'BinWidth',width)
histogram(CO2_ptiles(:,2),'BinWidth',width)
histogram(CO2_ptiles(:,1),'BinWidth',width)
legend('All','90th','85th','80th')
xlabel('CO2 mixing ratio')
ylabel('Freq');

%% H2O

H2Ostd_max = max(H2Ostd,[],"omitmissing");
H2Ostd_min = min(H2Ostd,[],"omitmissing");
H2Ostd_ptiles = prctile(H2Ostd,ptiles);

% try different percentiles
H2O_ptiles = repmat(H2O,[1 len_ptiles]);

for i = 1:len_ptiles
    indH2Ostd = find(H2Ostd > H2Ostd_ptiles(i));
    H2O_ptiles(indH2Ostd,i) = NaN;
end

%% plot H2O by H2Ostd percentile data removal
figure;
subplot(2,1,1)
plot(tv_dt,H2O,'.')
hold on
% plot(tv_dt,H2O_ptiles(:,4),'.')
plot(tv_dt,H2O_ptiles(:,3),'.')
plot(tv_dt,H2O_ptiles(:,2),'.')
plot(tv_dt,H2O_ptiles(:,1),'.')
grid
set(gcf,'color','white');
ylabel('H2O mixing ratio')

subplot(2,1,2)
width = 0.25;
histogram(H2O,'BinWidth',width)
grid
hold on
% histogram(H2O_ptiles(:,4),'BinWidth',width)
set(gca,'YScale','log');
histogram(H2O_ptiles(:,3),'BinWidth',width)
histogram(H2O_ptiles(:,2),'BinWidth',width)
histogram(H2O_ptiles(:,1),'BinWidth',width)
legend('All','80th','85th','90th')
% legend('All','95th','90th','75th','50th')
xlabel('H2O mixing ratio')
ylabel('Freq');

%% plot H2O traces with H2Ostd data removal plus RH/Rain/Td-depression
figure;
% ax(1) = subplot(2,1,1);
yyaxis left
% plot(tv_dt,H2O,'.')
% hold on
% plot(tv_dt,H2O_ptiles(:,4),'.')
% plot(tv_dt,H2O_ptiles(:,3),'.')
plot(tv_dt,H2O_ptiles(:,2),'.')     % 80th percentile
% plot(tv_dt,H2O_ptiles(:,1),'.')
hold on
grid
set(gcf,'color','white');
ylabel('H2O mixing ratio')

% ax(2) = subplot(2,1,2);
yyaxis right
plot(tv_dt,Tdep_cond);
% grid
% ylim([-1 25])
% hold on
% yyaxis right
% plot(tv_dt,RelHum_AbvCnpy,'.')

% linkaxes(ax,'x');

%% Fc using wrot

wrotstd_max = max(wrotstd,[],"omitmissing");
wrotstd_min = min(wrotstd,[],"omitmissing");
wrotstd_ptiles = prctile(wrotstd,ptiles);

% try different percentiles
Fc_ptiles = repmat(Fc,[1 len_ptiles]);

for i = 1:len_ptiles
    indwrotstd = find(wrotstd > wrotstd_ptiles(i));
    Fc_ptiles(indwrotstd,i) = NaN;
end

%% plot Fc by wrotstd data removal
figure;
subplot(2,1,1)
plot(tv_dt,Fc,'.')
hold on
% plot(tv_dt,Fc_ptiles(:,4),'.')
plot(tv_dt,Fc_ptiles(:,3),'.')
plot(tv_dt,Fc_ptiles(:,2),'.')
plot(tv_dt,Fc_ptiles(:,1),'.')
grid
set(gcf,'color','white');
ylabel('Fc')

subplot(2,1,2)
width = 2;
histogram(Fc,'BinWidth',width)
grid
hold on
% histogram(Fc_ptiles(:,4),'BinWidth',width)
set(gca,'YScale','log');
histogram(Fc_ptiles(:,3),'BinWidth',width)
histogram(Fc_ptiles(:,2),'BinWidth',width)
histogram(Fc_ptiles(:,1),'BinWidth',width)
% legend('All','95th','90th','75th','50th')
legend('All','95th','90th','85th')
xlabel('Fc')
ylabel('Freq');

%% Fc
indFc_ptile = union(indCO2std,indCO2std);
Fc_ptile = Fc;
Fc_ptile(indFc_ptile) = NaN;




% plot toggles
% plot 1: CO2 mixing ratio, H2O mixing ratio, CO2 Flux
p = 0;
% plot 2: CO2 mixing ratio, RH, and CO2 flux
q = 0;
% plot 3: CO2, H2O, and w standard deviations
r = 0;
% plot 3: histograms of CO2, H2O, and w standard deviations
s = 0;

t = 1;

%% plot 1: CO2 mixing ratio, H2O mixing ratio, CO2 Flux
close;
if p == 1
    % plot 1: CO2 mixing ratio, H2O mixing ratio, CO2 Flux
    figure('units','centimeters','outerposition',[0 0 60 50]);
    set(gcf,'color','white');
    ax(1) = subplot(3,1,1);
    yyaxis left     % plot left CO2
    plot(tv_dt,CO2,'.');
    ylim([380 1000]);
    ylabel('CO2 Mixing Ratio','FontSize',16)

    yyaxis right    % plot right TX_rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    ax(2) = subplot(3,1,2);
    yyaxis left     % plot left H2O
    plot(tv_dt,H2O,'.');
    ylim([0 40]);
    ylabel('H2O Mixing Ratio','FontSize',16)
    ylabel('RH')

    yyaxis right    % plot TX_Rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    ax(3) = subplot(3,1,3);
    yyaxis left     % plot left Fc
    plot(tv_dt,Fc,'.');
    ylim([-10 50]);
    ylabel('CO2 Flux','FontSize',16)

    yyaxis right    % plot TX_Rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    linkaxes(ax,'x');
end

%% plot 2: CO2 mixing ratio, RH, and CO2 flux
if q == 1
    % plot 2: CO2 mixing ratio, RH, and CO2 flux
    figure('units','centimeters','outerposition',[0 0 60 50]);
    set(gcf,'color','white');
    ax(1) = subplot(3,1,1);
    yyaxis left     % plot left CO2
    plot(tv_dt,CO2,'.');
    ylim([380 1000]);
    ylabel('CO2 Mixing Ratio','FontSize',16)

    yyaxis right    % plot right TX_rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    ax(2) = subplot(3,1,2);
    yyaxis left     % plot left H2O
    plot(tv_dt,RelHum_AbvCnpy,'.');
    ylim([30 105]);
    ylabel('RH')

    yyaxis right    % plot TX_Rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    ax(3) = subplot(3,1,3);
    yyaxis left     % plot left Fc
    plot(tv_dt,Fc,'.');
    ylim([-10 50]);
    ylabel('CO2 Flux','FontSize',16)

    yyaxis right    % plot TX_Rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    linkaxes(ax,'x');
end

%% plot 3: CO2, H2O, and w standard deviations
if r == 1
    % plot 3: CO2, H2O, and w standard deviations
    figure('units','centimeters','outerposition',[0 0 60 50]);
    set(gcf,'color','white');
    ax(1) = subplot(3,1,1);
    yyaxis left     % plot left CO2
    plot(tv_dt,CO2_std,'.');
    % ylim([380 1000]);
    ylabel('CO2 stdev','FontSize',16)

    yyaxis right    % plot right TX_rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    ax(2) = subplot(3,1,2);
    yyaxis left     % plot left H2O
    plot(tv_dt,H2O_std,'.');
    % ylim([30 105]);
    ylabel('H2O stdev')

    yyaxis right    % plot TX_Rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    ax(3) = subplot(3,1,3);
    yyaxis left     % plot left Fc
    plot(tv_dt,w_rot_std,'.');
    % ylim([-10 50]);
    ylabel('w rot stdev','FontSize',16)

    yyaxis right    % plot TX_Rain
    plot(tv_dt,TX_Rain);
    ylim([0 10]);
    ylabel('Rain','FontSize',16)
    grid

    linkaxes(ax,'x');
end

%% plot 4: histograms of CO2, H2O, and w standard deviations
if s == 1
    % plot 3: CO2, H2O, and w standard deviations
    figure('units','centimeters','outerposition',[0 0 60 50]);
    set(gcf,'color','white');
    ax(1) = subplot(3,1,1);
    
    width = 5;      % histogram bin width

    histogram(CO2std,'BinWidth',width);
    set(gca,'YScale','log');
    ylim([0 14000]);
    hold on
    grid on

    h1 = xline(CO2std_ptiles,'k--',{'75th','90th','95th'},'LineWidth',1.5);
    xlabel('CO2 stdev','FontSize',16)
    ylabel('Frequency','FontSize',16)

    ax(2) = subplot(3,1,2);
    histogram(H2Ostd);
    set(gca,'YScale','log');
    ylim([0 8000]);
    hold on
    grid on

    h2 = xline(H2Ostd_ptiles,'k--',{'75th','90th','95th'},'LineWidth',1.5);

    xlabel('H2O stdev','FontSize',16)
    ylabel('Frequency','FontSize',16)

    ax(3) = subplot(3,1,3);
    histogram(wrotstd);
    ylim([0 1000]);
    hold on
    grid on

    h3 = xline(wrotstd_ptiles,'k--',{'75th','90th','95th'},'LineWidth',1.5);
    
    xlabel('wrot stdev','FontSize',16)
    ylabel('Frequency','FontSize',16)
end

%% plot 5: test percentile data removal
if t == 1
    figure('units','centimeters','outerposition',[0 0 60 50]);
    set(gcf,'color','white');
    subplot(3,1,1);
    
    plot(tv_dt,CO2,'.')
    hold on
    plot(tv_dt,CO2_ptile,'.')
    
    % plot(tv_dt,CO2_90,'.')
    % ylim([0 14000]);
    grid on

    subplot(3,1,2);
    plot(tv_dt,H2O,'.')
    hold on
    plot(tv_dt,H2O_ptile,'.')
    % ylim([0 8000]);
    hold on
    grid on

    h2 = xline(H2Ostd_ptiles,'k--',{'75th','90th','95th'},'LineWidth',1.5);

    xlabel('H2O stdev','FontSize',16)
    ylabel('Frequency','FontSize',16)

    ax(3) = subplot(3,1,3);
    histogram(wrotstd);
    ylim([0 1000]);
    hold on
    grid on

    h3 = xline(wrotstd_ptiles,'k--',{'75th','90th','95th'},'LineWidth',1.5);
    
    xlabel('wrot stdev','FontSize',16)
    ylabel('Frequency','FontSize',16)
end
