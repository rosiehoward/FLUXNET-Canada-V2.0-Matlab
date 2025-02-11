function tagsOut = TPAG_CustomTags
% Define the set of standard data-cleaning tags. 
% This is used to better organize "dependant" fields in the FistStage.ini files.
% Any tag under tagsOut can appear inside of the "dependent" field.
% All tag names have to start with "tag_".
%
% Example:
%   This line will cause all CO2 and H2O based trace points to be removed when
%   the LI-7200 is not working or the pump is dead (flow<1 or such).
%
%		Dependent = 'tag_LI7200'
%
% Zoran Nesic           File created        Mar 30, 2024
%                       Last modification:  May  3, 2024
% 

% Revisions
%
% May 3, 2024 (Zoran)
%   - Moved CO2 and H2O variances from HF to _All tags.
% Apr 14, 2024 (Zoran)
%   - added CH4_MIXING_RATIO to tag_7700
% Apr 10, 2024 (Zoran)
%  - added the missing tagsOut.tag_CH4_fluxes
%  - found that when defining tags I used tagsOut.tag_* instead of just tag_*
%

%% CampbellSci instruments dependent on CR5000 battery

tagsOut.tag_CR5000_batt =     [ ...
                        'TA_1_1_1,' ...         % air temperature above canopy
                        'RH_1_1_1,' ...         % relative humidity above canopy
                        'PA_A_100cm,' ...       % soil moisture measurement; period average
                        'PA_A_10_40cm,' ...     % 
                        'PA_A_50cm,' ...        
                        'PA_A_5cm,' ...         
                        'SWC_1_1_1,' ...        % soil water content 
                        'SWC_1_2_1,' ... 
                        'SWC_1_3_1,' ...
                        'TS_1_1_1,' ...         % soil temperature
                        'TS_1_2_1,' ... 
                        'TS_1_3_1,' ...     
                        'G_1_1_1,' ...          % soil heat flux 
                        'SW_IN_1_1_1,' ...      % maybe not these radiation variables - not sure if they are
                        'LW_IN_1_1_1,' ...      % attached to CS logger...???
                        'SW_OUT_1_1_1,' ...
                        'LW_OUT_1_1_1,' ...
                        ];
%% flux variables dependent on number of samples per half hour

tagsOut.tag_EC_flux =   [ ...
                        'PA_1_1_1,' ...     % pressure from CSAT3
                        'CO2_MIXING_RATIO_1_1_1,' ...    
                        'CO2_SIGMA_1_1_1,' ... 
                        'FC,' ...
                        'SC,' ...
                        'H2O_MIXING_RATIO_1_1_1,' ... 
                        'H2O_SIGMA_1_1_1,' ...
                        'H,' ... 
                        'LE,' ... 
                        'T_SONIC_1_1_1,' ... 
                        'u_unrot,' ... 
                        'u_rot,' ... 
                        'U_SIGMA_1_1_1,' ... 
                        'USTAR,' ... 
                        'v_unrot,' ... 
                        'v_rot,' ... 
                        'V_SIGMA_1_1_1,' ... 
                        'w_unrot,' ... 
                        'w_rot,' ... 
                        'W_SIGMA_1_1_1,' ... 
                        'WD_1_1_1,' ... 
                        'WS_1_1_1,' ...
                        ];


% %% LI-7200/LI-7500
% 
% tagsOut.tag_LI7200 =    [ ...
% 					    'tag_CO2_All,' ...	
% 					    'tag_H2O_All,' ...									
% 				        ];
% %--- CO2 ---				
% % remove all CO2 traces including low-frequency ones (example: no-flow, air is not moving through the instrument)
% tagsOut.tag_CO2_All = [ ...                    
%                         'CO2,' ...
%                         'CO2_MIXING_RATIO,'...
%                         'co2_var,'...                        
%                         'tag_CO2_HF,' ...
%                         ];
% 
% % Remove all high-frequency CO2 traces(example: low flow but still moving enough air to get co2_mean)
% tagsOut.tag_CO2_HF = [  ...
%                         'un_co2_flux,'...
%                         'FC,'...
%                         'w_co2_cov,'...
%                         'SC,'...
%                         ];
% 
% %--- H2O ---
% % remove all H2O traces (example: no-flow, air is not moving through the instrument)
% tagsOut.tag_H2O_All = [ ...                    
%                         'H2O,' ...
%                         'H2O_MIXING_RATIO,'...
% 	                    'h2o_var,'...                        
%                         'tag_H2O_HF,' ...
%                         ];
% 
% % Remove all high-frequency H2O traces(example: low flow but still moving enough air to get h2o_mean) 
% tagsOut.tag_H2O_HF = [...	    
% 	                    'h2o_flux,'...
% 	                    'LE,'...
% 	                    'ET,'...
% 	                    'un_h2o_flux,'...
% 	                    'un_LE  ,'...
% 	                    'w_h2o_cov,'...                       
% 	                    'SLE,'...
% 						'h2o_strg,'...
%                         ];
% % --- All CO2/H2O fluxes are bad ---
% tagsOut.tag_CO2_H2O_fluxes = [...
%                             'tag_H2O_HF,'...
% 							'tag_CO2_HF,'...
%                             ];
% 
% %% Sonic Anemometer (should we add here: L, zdL,...?)
% tagsOut.tag_EC_Anemometer = [ ...
%                             'tag_CO2_H2O_fluxes,'...
%                             'tag_CH4_fluxes,'...
%                             'u_mean,'...
%                             'u_unrot,'...
%                             'u_var,'...
%                             'u_rot,'...
%                             'v_mean,'...
%                             'v_unrot,'...
%                             'v_var,'...
%                             'v_rot,'...                             
%                             'w_mean,'...
%                             'w_unrot,'...
%                             'w_var,'...
%                             'w_rot,'...
% 							'wind_speed,'...
% 							'WS_MAX,'...
%                             'ts,'...
% 							'ts_var,',...
%                             'H,'...
% 							'w_ts_cov,'...							
%                             'SH,'...
%                             'un_H,'...
%                             'USTAR,'...
%                             'TKE,'...
% 							'TAU,'...
% 							'T_SONIC,'...
%                             ];
% %% LI-7700
% tagsOut.tag_LI7700 =        [ ...
%                             'CH4,'...
%                             'CH4_MIXING_RATIO,'...
%                             'ch4_var,'...
%                             'tag_CH4_fluxes,'...
%                             ];
% tagsOut.tag_CH4_fluxes =    [ ...
%                             'FCH4,'...
%                             'un_ch4_flux,'...
%                             'w_ch4_cov,'...
%                             'SCH4,'...
%                             ];
% 
