% created 2023-04-16
% function switches from kinetic parameters to thermodynamic parameteres

function thermoParam = calcThermo(kineticParam, Tref)
R = 8.314e-3;
Ea1 = kineticParam(1);
k1 = kineticParam(2);
Ea2 = kineticParam(3);
k2 = kineticParam(4);
dH = Ea1 - Ea2;
K = k1/k2;                  % rate of unfolding over rate of folding
dG = -R*Tref*log(K);
dS = (dH-dG)/Tref;
Tm = dH/dS-273.15;
thermoParam = [Tm, dH, dS, dG];

Ea3 = kineticParam(5);
k3 = kineticParam(6);
Ea4 = kineticParam(7);
k4 = kineticParam(8);
dH = Ea3 - Ea4;
K = k3/k4;
dG = -R*Tref*log(K);
dS = (dH - dG)/Tref;
Tm = dH/dS-273.15;
thermoParam = [thermoParam, Tm, dH, dS, dG];
end