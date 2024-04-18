function vars_daily = convertToDailyArray(vars,recsPerDay,daysPerYear)
%
% Plot distribution by hour or half-hour, over all days of the year
%
% Input args:
%       var = input variable (must be divisible by 24)
%       freq = data frequency in hours
%       leap year flag: 1 = yes, 0 = no (modify later to input year and
%       calculate this inside function)
%
% Rosie Howard
% 11 April 2024

vars_daily = NaN(recsPerDay,daysPerYear);

for j = 1:length(vars)
    vars_daily(j) = vars(j);
end


% [~,n] = size(vars);

% vars_daily_all = cell(1,n);

% for i = 1:n
%     vars_daily = NaN(recsPerDay,daysPerYear);
%     % [a,b] = size(var_daily);
% 
%     for j = 1:length(vars)
%         vars_daily(j) = vars(j);
%     end
% 
%     vars_daily_all{1,i} = vars_daily;
% end









