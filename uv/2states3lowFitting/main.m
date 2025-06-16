% kinetic parameters: E1, k1, E2, k2

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

% load the experiment
currExp = loadExperiment(uv);
currExp = correctTemperature(currExp);

for i = 1:length(currExp)
    stages = currExp{i}.stages;
    for j = 1:length(stages)
        tempArr = stages{j}.tempArr;
        absArr = stages{j}.absArr;
        TFarray = tempArr <= 60 + 273.15;
        newtempArr = tempArr(TFarray);
        newabsArr = absArr(TFarray);
        stages{j}.tempArr = newtempArr;
        stages{j}.absArr = newabsArr;
    end
    currExp{i}.stages = stages;
end

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
        options = optimset('MaxFunEval', 1e8);
        [parameters, rss] = fminsearch(@twoMerit, parameters, options, ...  
            stages, Tref, -1, -1, timeBased);
        % prevent negative rate constant
        parameters(2) = abs(parameters(2));
        parameters(4) = abs(parameters(4));
    end
    paramArr(i, :) = parameters;
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