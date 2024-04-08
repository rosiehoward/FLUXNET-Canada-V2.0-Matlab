function pthOut = biomet_database_default
% Use relative path
[pthOut,~,~] = fileparts(pwd); 
pthOut = fullfile(pthOut,'Database'); 

