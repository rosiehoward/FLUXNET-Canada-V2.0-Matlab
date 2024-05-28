% plotThirdStageNewVars.m
%
% Rosie Howard
% 20 April 2024

%% 
dataType = 'Clean/SecondStage';
% dataType = 'Clean\SecondStage';
pthSecondStageClean = fullfile(dbPath,'yyyy',siteID,dataType);

NETRAD_1_1_1 = read_bor(fullfile(pthSecondStageClean,'NETRAD_1_1_1'),[],[],yearIn);
NETRAD_1_1_1_measured = read_bor(fullfile(pthSecondStageClean,'NETRAD_1_1_1_measured'),[],[],yearIn);

badRad = read_bor(fullfile(pthSecondStageClean,'badRad'),[],[],yearIn);
badWD = read_bor(fullfile(pthSecondStageClean,'badWD'),[],[],yearIn);

WD_1_1_1 = read_bor(fullfile(pthSecondStageClean,'WD_1_1_1'),[],[],yearIn);
SW_IN_1_1_1 = read_bor(fullfile(pthSecondStageClean,'SW_IN_1_1_1'),[],[],yearIn);

VPD_1_1_1 = read_bor(fullfile(pthSecondStageClean,'VPD_1_1_1'),[],[],yearIn);
FC_1_1_1 = read_bor(fullfile(pthSecondStageClean,'FC_1_1_1'),[],[],yearIn);
SC_1_1_1 = read_bor(fullfile(pthSecondStageClean,'SC_1_1_1'),[],[],yearIn);
USTAR = read_bor(fullfile(pthSecondStageClean,'USTAR'),[],[],yearIn);
ET = read_bor(fullfile(pthSecondStageClean,'ET'),[],[],yearIn);
NEE_1_1_1 = read_bor(fullfile(pthSecondStageClean,'NEE_1_1_1'),[],[],yearIn);
RG_1_1_1 = read_bor(fullfile(pthSecondStageClean,'RG_1_1_1'),[],[],yearIn);

% RH_1_1_1 = read_bor(fullfile(pthFirstStageClean,'RH_1_1_1'),[],[],yearIn);
% RH_SecondStage =  read_bor(fullfile(pthSecondStageClean,'RH_1_1_1'),[],[],yearIn);

% TA_1_1_1 = read_bor(fullfile(pthFirstStageClean,'TA_1_1_1'),[],[],yearIn);
% TA_SecondStage = read_bor(fullfile(pthSecondStageClean,'TA_1_1_1'),[],[],yearIn);


dataType = 'Clean/ThirdStage';
pthThirdStageClean = fullfile(dbPath,'yyyy',siteID,dataType);

GPP_PI_F_DT = read_bor(fullfile(pthThirdStageClean,'GPP_PI_F_DT'),[],[],yearIn);
GPP_PI_F_NT = read_bor(fullfile(pthThirdStageClean,'GPP_PI_F_NT'),[],[],yearIn);
Reco_PI_F_DT = read_bor(fullfile(pthThirdStageClean,'Reco_PI_F_DT'),[],[],yearIn);
Reco_PI_F_NT = read_bor(fullfile(pthThirdStageClean,'Reco_PI_F_NT'),[],[],yearIn);
H_PI_F_MDS = read_bor(fullfile(pthThirdStageClean,'H_PI_F_MDS'),[],[],yearIn);
LE_PI_F_MDS = read_bor(fullfile(pthThirdStageClean,'LE_PI_F_MDS'),[],[],yearIn);
NEE_PI_F_MDS = read_bor(fullfile(pthThirdStageClean,'NEE_PI_F_MDS'),[],[],yearIn);
