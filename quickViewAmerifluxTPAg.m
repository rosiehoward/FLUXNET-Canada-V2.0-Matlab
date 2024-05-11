filepath = '/Users/rosiehoward/Documents/UBC/Micromet/FLUXNET-Canada-V2.0/TPAg - Ameriflux/';

TPAg_2020 = readtable([filepath 'CA-TPAG_HH_202001010000_202101010000.csv']);
% TPAg_2020(TPAg_2020 == -9999) = NaN;
TPAg_2021 = readtable([filepath 'CA-TPAG_HH_202101010000_202201010000.csv']);
% TPAg_2021(TPAg_2021 == -9999) = NaN;
TPAg_2022 = readtable([filepath 'CA-TPAG_HH_202201010000_202301010000.csv']);
% TPAg_2022(TPAg_2022 == -9999) = NaN;
TPAg_2023 = readtable([filepath 'CA-TPAG_HH_202301010000_202401010000.csv']);
% TPAg_2023(TPAg_2023 == -9999) = NaN;
[a,b] = size(TPAg_2023);
names_TPAg_2023 = TPAg_2023.Properties.VariableNames;

filepath_Rosie = [biomet_database_default '/2023/TPAg/Clean/Ameriflux/'];
TPAg_2023_Rosie = readtable([filepath_Rosie 'CA-TPAG_HH_202301010000_202401010000.csv']);

[c,d] = size(TPAg_2023_Rosie);
names_TPAg_2023_Rosie = TPAg_2023_Rosie.Properties.VariableNames;

for i = 1:b
    varname = names_TPAg_2023{i};
    eval(['var1 = TPAg_2023.' varname ';']); %#ok<*EVLDOT>
    var1(var1 == -9999) = NaN; %#ok<*SAGROW>
    % eval(['var2 = TPAg_2023_Rosie.' varname ';']);
    % var2(var2 == -9999) = NaN;
    
    % subplot(5,1,1);
    % plot(TPAg_2020(:,i),'.');
    % subplot(5,1,2);
    % plot(TPAg_2021(:,i),'.');
    % subplot(5,1,3);
    % plot(TPAg_2022(:,i),'.');
    % subplot(2,1,1);
    plot(var1,'.');
    % subplot(2,1,2);
    % plot(var2,'.');
    sgtitle(varname);
end
