% function switches from kinetic parameters to thermodynamic parameteres

function thermoParam = calcThermo(kineticParam, Tref)
R = 8.314e-3;
if Tref < 120
    Tref = Tref + 273.15;
end
Ea1 = kineticParam(1);
k1 = kineticParam(2);
Ea2 = kineticParam(3);
k2 = kineticParam(4);
dH = Ea1 - Ea2;
K = k1/k2;
dG = -R*Tref*log(K);
dS = (dH-dG)/Tref;
Tm = dH/dS;
thermoParam = [Tm-273.15, dH, dS, dG];
end