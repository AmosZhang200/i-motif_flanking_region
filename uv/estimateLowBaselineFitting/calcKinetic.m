% created 2023-04-18
% function requires four imput
% k1: the rate constant
% deltaH: the change in enthalpy in kJ/mol
% Tm: the melting temperature in degrees C
% Tref: the reference temperature in degrees C
% The function returns corresponding kinetic parameters

function kineticParam = calcKinetic(k1, deltaH, Tm, Tref)
if Tm < 130
    Tm = Tm + 273.15;   % change from C to K
end
if Tref < 130
    Tref = Tref + 273.15;
end
R = 8.314e-3; % gas constant in value kJ/mol/K

Ea1 = deltaH / 2;       % negative value
Ea2 = - deltaH / 2;     % positive value

deltaS = deltaH / Tm;   % calculate change in entropy
deltaG = deltaH - Tref * deltaS;
K = exp(-deltaG/(R*Tref)); % the equilibrium constant

% K = k2/k1; k2: k-1

k2 = k1/K;

kineticParam = [Ea1, k1, Ea2, k2];


end