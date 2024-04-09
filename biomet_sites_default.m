function pthOut = biomet_sites_default
% Use relative path
[pthOut,~,~] = fileparts(pwd); 
pthOut = fullfile(pthOut,'Sites');