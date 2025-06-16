% kinetic parameters: E1, k1, E2, k2

if ~exist("plotI", "var")
    plotI = 5;
end
if ~exist("Tref", "var")
    Tref = 55+273.15;
    disp("Tref set to 55 C")
end
if ~exist("timeBased", "var")
    timeBased = 0;
    disp("timeBased set to False, at pH 5.5")
    pause(2)
end

if Tref < 120
    Tref = Tref + 273.15;
end

currExp = loadExperiment(uv);
currExp = correctTemperature(currExp);

[initialParam, minRSS, minInd] = initialParameters(currExp, Tref, timeBased);

disp(initialParam)
disp(minRSS)

paramArr = [];
thermoArr = [];
rssArr = [];

% find the current experiments
for i = 1:length(currExp)
    parameters = initialParam;
    stages = currExp{i}.stages;
    for times = 1:3
        % run the fminsearch multiple rounds and try to reduce
        % the rss at each time
        options = optimset('MaxFunEval', 1e8);
        [parameters, rss] = fminsearch(@twoMerit, parameters, options, ...     %(9:end)
            stages, Tref, -1, -1, timeBased);
        % prevent negative rate constant
        parameters(2) = abs(parameters(2));
        parameters(4) = abs(parameters(4));
    end
    rssArr(i, :) = rss;
    if rss < 10
        parametersArr(i, :) = parameters;
        thermoArr(i, :) = calcThermo(parameters, Tref);
        twoMerit(parameters, stages, Tref, plotI, -1, timeBased)
        plotI = plotI + 3;
    end
end


% multiple experiments input
if length(currExp) > 1
    parameters = mean(parametersArr);
    rss = mean(rssArr);

    kineticError = std(parametersArr);
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