% kinetic parameters orders: E1, k1, E2, k2 
% (folding activation enthalpy, folding rate, unfolding activation enthalpy, unfolding rate)

% deltaEpsilon as an optional parameter, it will align the y-axis range to
% be the same
% deltaEpsilon = 67031;

if ~exist("plotI", "var")
    plotI = 5;
end
if ~exist("Tref", "var")
    Tref = 25+273.15;
    disp("Tref set to 298.15K")
end
if ~exist("timeBased", "var")
    timeBased = 1;
    disp("timeBased set to True")
    pause(2)
end

if Tref < 200
    Tref = Tref + 273.15;
end

% load the experiment from processed directory
currExp = loadExperiment(uv);
currExp = correctTemperature(currExp);

[initialParam, minRSS, minInd] = initialParameters(currExp, Tref, timeBased);

disp(initialParam)
disp(minRSS)
pause(2)

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
        % rss = 0, plotI = -1 not plotting
        options = optimset('MaxFunEval', 1e8);
        [parameters, rss] = fminsearch(@merit, parameters, options, ...     %(9:end)
            stages, Tref, -1, -1, timeBased);
        % prevent unwanted negative rate constant
        parameters(2) = abs(parameters(2));
        parameters(4) = abs(parameters(4));
    end
    paramArr(i, :) = parameters;
    rssArr(i, :) = rss;
    if rss < 10
        parametersArr(i, :) = parameters;
        thermoArr(i, :) = calcThermo(parameters, Tref);
        if exist("deltaEpsilon", "var")
            merit(parameters, stages, Tref, plotI, -1, timeBased, deltaEpsilon)
            plotI = plotI + 5;
        else
            merit(parameters, stages, Tref, plotI, -1, timeBased)
            plotI = plotI + 3;
        end
        
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
