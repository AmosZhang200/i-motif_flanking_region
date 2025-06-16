% kinetic parameters: E1, k1, E2, k2
% (folding activation enthalpy, folding rate, unfolding activation enthalpy, unfolding rate)

if ~exist("plotI", "var")
    plotI = 5;
end
if ~exist("Tref", "var")
    Tref = 25+273.15;
    disp("Tref set to 25 C")
end
if ~exist("timeBased", "var")
    timeBased = 1;
    disp("timeBased set to True")
    pause(2)
end

if Tref < 120
    Tref = Tref + 273.15;
end

currExp = loadExperiment(uv);
currExp = correctTemperature(currExp);

[initialp, minRSS, minInd] = initialParameters(currExp, Tref);
disp(initialp)
disp(minRSS)
pause(2)

% find the current experiments
%experiments = currExp.experiments;
for i = 1:length(currExp)
    parameters = initialp;
    stages = currExp{i}.stages;
    for times = 1:3
        options = optimset('MaxFunEval', 1e8);
        [parameters, rss] = fminsearch(@threeMerit, parameters, options, ...     %(9:end)
            stages, Tref, -1);
        % prevent unwanted negative rate constant
        parameters(2) = abs(parameters(2));
        parameters(4) = abs(parameters(4));
        parameters(6) = abs(parameters(6));
        parameters(8) = abs(parameters(8));
    end
    paramArr(i, :) = parameters;
    rssArr(i, :) = rss;
    if rss < 10
        parametersArr(i, :) = parameters;
        thermoArr(i, :) = calcThermo(parameters, Tref);
        threeMerit(parameters, stages, Tref, plotI)     
        plotI = plotI + 3;
    end
end

% multiple experiments input
if length(currExp) > 1
    parameters = mean(paramArr);
    rss = mean(rssArr);

    kineticError = std(paramArr);
    rssError = std(rssArr);
    thermo = mean(thermoArr);
    thermoError = std(thermoArr);

    disp(parameters)
    disp(kineticError)
    disp(thermo)
    disp(thermoError)
else
    parameters = parametersArr;
    thermo = thermoArr;
    disp(parameters)
    disp(thermo)
end


