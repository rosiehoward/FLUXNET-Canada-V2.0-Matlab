function Cva = convertAbsHumMetToPPM(T,RH,P)


% constants
Rv = 461;       % water vapour gas constant (J kg^-1 K^-1)
eps = 622;    % Rd/Rv (g_vapour/kg_dryair)
T0 = 273.15;    % reference temperature (K)
e0 = 0.6113;    % reference vapour pressure (kPa)
Lv = 2.5e6;     % latent heat of vaporization (J kg^-1)
% Ld = 2.83e6;    % latent heat of deposition (J kg^-1) 
Mva = 18.02;    % molecular mass of water vapour (g/mol)
R = 8.3143;     % gas constant (J mol^-1 kg^-1)


T_K = T + 273.15;   % convert temperature to Kelvin

% calculate absolute humidity from met measurements of T and RH
rho_v = absHumidityMet(T_K,RH);

% convert to partial pressure of water vapour (Pva)
Cva = (rho_v.*R.*T_K)./Mva;

