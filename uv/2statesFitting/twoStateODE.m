% created 2023-10-28
% This twoStateODE function allows both time based or temperature based ode
% simulations
% varargin can either be empty or T0 value
function dFdT = twoStateODE(T, F, parameters, dTdt, Tref, varargin)

if nargin == 6
    % T is actually time if 6 inputs
    T0 = varargin{1};
    T = T0 + T*dTdt;
end

E1r = parameters(1);
k1r = abs(parameters(2));
E2r = parameters(3);
k2r = abs(parameters(4));

R = 8.314e-3;

% after arrhenius equation extract the rate at different temperature
% assuming the folding rate is constant
k1 = k1r*exp((E1r/R)*((1/Tref) - (1/T)));
k2 = k2r*exp((E2r/R)*((1/Tref) - (1/T)));

if nargin == 5
    dFdT(1) = (k2*F(2) - k1*F(1))/dTdt;
    dFdT(2) = (k1*F(1) - k2*F(2))/dTdt;
    dFdT = dFdT(:);
elseif nargin == 6
    dFdT(1) = k2*F(2) - k1*F(1);
    dFdT(2) = k1*F(1) - k2*F(2);
    dFdT = dFdT(:);
end
end