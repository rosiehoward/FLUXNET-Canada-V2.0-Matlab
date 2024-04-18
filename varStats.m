function statsAllStages = varStats(vars)

    fprintf('Number of variables (stages) provided = %d\n',nargin);

    [~,n] = size(vars);

    % calculate max, min, mean, median, corr, MAE, RMSE
    % allStages = cat(2,varZero,varFirst,varSecond);
    maxAllStages = max(vars,[],1,'omitnan');
    minAllStages = min(vars,[],1,'omitnan');
    meanAllStages = mean(vars,1,'omitnan');
    medianAllStages = prctile(vars,50,1);
    stdAllStages = std(vars,1,'omitnan');

    corrZeroFirst = corr(vars(:,1),vars(:,2),'rows','complete');
    MAE_ZeroFirst = mean(abs(vars(:,1) - vars(:,2)),1,'omitnan');
    RMSE_ZeroFirst = rmse(vars(:,1),vars(:,2),1,'omitnan');

    if n == 3   % up to second stage
        corrFirstSecond = corr(vars(:,2),vars(:,3),'rows','complete');
        MAE_FirstSecond = mean(abs(vars(:,2) - vars(:,3)),1,'omitnan');
        RMSE_FirstSecond = rmse(vars(:,2),vars(:,3),1,'omitnan');
    end

    statsAllStages = cat(1,maxAllStages,minAllStages,meanAllStages,medianAllStages,stdAllStages);

    if n == 2
        statsAllStages = [statsAllStages; ...
                         [NaN,corrZeroFirst]; ...
                         [NaN,MAE_ZeroFirst]; ...
                         [NaN,RMSE_ZeroFirst]];

    elseif n == 3
        statsAllStages = [statsAllStages; ...
                         [NaN,corrZeroFirst,corrFirstSecond]; ...
                         [NaN,MAE_ZeroFirst,MAE_FirstSecond]; ...
                         [NaN,RMSE_ZeroFirst,RMSE_FirstSecond]];
    else
        fprintf('Check input to varStats function...\n')
    end

end

