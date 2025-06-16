% Modified 2023-09-07
% Changed from temperature based function into time based
% function takes in 6 inputs:
%       t: time
%       F: fraction folded
%       params: kinetic parameters
%       T0: starting temperature
%       dTdt: scanrate
%       Tref: reference temperature
% function outputs a list of fraction folded and fraction unfolded values 

function dFdT = threeStateODE(t, F, param, T0, dTdt, Tref)
% calculate the Temperature at a specific time
% T(t) = Tinitial + time * scanrate
T = T0 + dTdt*t;

% parameters for dimer
E1 = param(1);
k1o = abs(param(2));
E2 = param(3);             %E-1
k2o = abs(param(4));       %k-1

% parameters of i-motif
E3 = param(5);             %E2
k3o = abs(param(6));       %k2
E4 = param(7);             %E-2
k4o = abs(param(8));       %k-2

R = 8.314e-3;
k1 = k1o*exp((E1/R)*((1/Tref) - (1/T)));    %k1
k2 = k2o*exp((E2/R)*((1/Tref) - (1/T)));    %k-1
k3 = k3o*exp((E3/R)*((1/Tref) - (1/T)));    %k2
k4 = k4o*exp((E4/R)*((1/Tref) - (1/T)));    %k-2
    
% [fraction unfold, fraction fold 1, fraction fold 2]
%dFdT(1) = (k2*F(2)+k4*F(3)-k1*F(1)-k3*F(1))/scanrate;
%dFdT(2) = (k1*F(1)-k2*F(2))/scanrate;
%dFdT(3) = (k3*F(1)-k4*F(3))/scanrate;

% already time baesd, don't have to divide by scan rate again
% why the dUdT part directly becomes dUdt
% dUdt = (k-1*D - k1*U)
dFdT(1) = k2*F(2) - k1*F(1);
% dDdt = (k1*U + k-2*DM - k-1*D - k2*D)
dFdT(2) = k1*F(1) + k4*F(3) - k2*F(2) - k3*F(2);
% dDMdt = (k2*D - k-2*DM)/dTdt
dFdT(3) = k3*F(2) - k4*F(3);
dFdT = dFdT(:);
end