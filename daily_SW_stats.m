function SW_down = daily_SW_stats(var)
%
% Rosie Howard
% 11 April 2024

SW_down = NaN(48,365);
% [a,b] = size(SW_down);

for i = 1:length(var)
    SW_down(i) = var(i);
end









