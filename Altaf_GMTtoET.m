% Altaf_GMTtoET



tmp_EC = load(ECpath);
eval([siteID '_EC = convert_data(tmp_EC.master);'])
TPAg_EC = convert_data(tmp_EC.master);
tmp_Met = load(METpath);
eval([siteID '_Met = convert_data(tmp_Met.master);'])
TPAg_Met  = convert_data(tmp_Met.master);

% Altaf's data is in GMT, need to also load yearIn+1 (if it exists) to append first
% 10 datapoints (5 hours) and remove last 10 datapoints
ECpathPrevYear  = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_CPEC_clean_%d.mat',siteID,yearIn+1));
METpathPrevYear = fullfile(biomet_sites_default,siteID,[siteID '_Raw_Cleaned'],sprintf('%s_master_%d.mat',siteID,yearIn+1));

if isfile(ECpathPrevYear) && isfile(METpathPrevYear)
    fprintf('Adding on some of next year''s data due to timezone difference\n');

    tmp_EC_PrevYear = load(ECpathPrevYear);
    eval([siteID '_EC_PrevYear = convert_data(tmp_EC_PrevYear.master);']);
    TPAg_EC_PrevYear = convert_data(tmp_EC_PrevYear.master);
    tmp_Met = load(METpathPrevYear);
    eval([siteID '_Met_PrevYear = convert_data(tmp_Met.master);'])
    TPAg_Met_PrevYear = convert_data(tmp_Met.master);

    % convert to table, concatenate, then back to struct
    TPAg_EC_PrevYearArray = struct2array(TPAg_EC_PrevYear);
    TPAg_EC_Array = struct2array(TPAg_EC);
    eval([siteID '_Met_PrevYearArray = struct2array(' siteID '_Met_PrevYear);']);
    eval([siteID '_Met_Array = struct2array(' siteID '_Met);']);
    TPAg_Met_PrevYearArray = struct2array(TPAg_Met_PrevYear);
    TPAg_Met_Array = struct2array(TPAg_Met);

    eval(['tmp_' siteID '_Met = cat(1,' siteID '_Met_PrevYearArray(end-10+1:end,:),' siteID '_Met_Array(1:17510,:));']);
    eval(['tmp_Met.master.data = tmp_' siteID '_Met;']);
    eval(['tmp_' siteID '_EC = cat(1,' siteID '_EC_PrevYearArray(end-10+1:end,:),' siteID '_EC_Array(1:17510,:));']);
    eval(['tmp_EC.master.data = tmp_' siteID '_EC;']);
    tmp_TPAg_Met = cat(1,TPAg_Met_PrevYearArray(end-10+1:end,:),TPAg_Met_Array(1:17510,:));
    tmp_Met.master.data = tmp_TPAg_Met;
    tmp_TPAg_EC = cat(1,TPAg_EC_PrevYearArray(end-10+1:end,:),TPAg_EC_Array(1:17510,:));
    tmp_EC.master.data = tmp_TPAg_EC;
    clear *PrevYear* *Array*
end

eval([siteID '_EC = convert_data(tmp_EC.master);']);
eval([siteID '_Met  = convert_data(tmp_Met.master);']);
TPAg_EC = convert_data(tmp_EC.master);
TPAg_Met  = convert_data(tmp_Met.master);