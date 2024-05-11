% test_SW_avg_period.m
%
% Rosie Howard
% 8 May 2024

clear;
siteID = 'TPAg';
yearIn = 2023;

dbPath = biomet_database_default;

firstStageMetPath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Met/Clean';
firstStageFluxPath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Flux/Clean';

secondStagePath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Clean/SecondStage';
thirdStagePath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Clean/ThirdStage';
thirdStageUStarPath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/Database/yyyy/TPAg/Clean/ThirdStage_Default_Ustar';

% load time vector
tv = read_bor(fullfile(firstStageMetPath,'clean_tv'),8,[],yearIn);
% convert time vector to Matlab's datetime
tv_dt = datetime(tv,'ConvertFrom','datenum');

% load SW variables
SW_IN_TP39 = read_bor(fullfile(firstStageMetPath,'SW_IN_TP39'),[],[],yearIn);
SW_IN_1_1_1 = read_bor(fullfile(firstStageMetPath,'SW_IN_1_1_1'),[],[],yearIn);

SW_IN_badRadTilt = SW_IN_1_1_1;
badRadTilt = find(tv>datenum(2023,6,0,0,30,0) & tv<datenum(2023,8,10,0,30,0));
SW_IN_badRadTilt(badRadTilt) = NaN;

avg_period = [0,1,3,6,12,24];
ap_length = length(avg_period);

new_SW_minus1 = calc_avg_trace(tv,SW_IN_badRadTilt,[SW_IN_TP39],-1); %#ok<NBRAK2>
new_SW_minus1(new_SW_minus1 < 0) = 0;
for i = 1:ap_length
    eval(['new_SW_' num2str(avg_period(i)) ' = calc_avg_trace(tv,SW_IN_badRadTilt,[SW_IN_TP39],' num2str(avg_period(i)) ');']);  %#ok<EVLSEQVAR>
    eval(['new_SW_' num2str(avg_period(i)) '(new_SW_' num2str(avg_period(i)) ' < 0) = 0;']);
end

%% plot output to compare
close;
figure('units','centimeters','outerposition',[0 0 40 40]);
set(gcf,'color','white');
subplot(2,1,1);
plot(tv_dt,SW_IN_TP39,'LineWidth',1.5);
hold on
grid on
plot(tv_dt,SW_IN_badRadTilt,'LineWidth',1.5);
legend('SW TP39','SW TPAg');

subplot(2,1,2);
plot(tv_dt,new_SW_minus1,'LineWidth',1.5);
hold on
grid on
legend('minus 1')

figure;
set(gcf,'color','white');
for j = 1:ap_length
    subplot(ap_length,1,j);
    eval(['plot(tv_dt,new_SW_' num2str(avg_period(j)) ',''.'');']);                                             

end





