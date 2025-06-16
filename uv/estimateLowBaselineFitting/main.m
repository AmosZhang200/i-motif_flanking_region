% % kinetic parameters: E1, k1, E2, k2

if ~exist('plotI', 'var')
    plotI = 5;
end
if ~exist('Tref', 'var')
    Tref = 25+273.15;
end
if Tref < 120
    Tref = Tref + 273.15;
end
if ~exist('timeBased', 'var')
    timeBased = 1;
end

%load the experiment with well estabilished lower baselines
currExp = loadExperiment(uv);
currExp = correctTemperature(currExp);

[initialParam, ~, ~] = initialParameters(currExp, Tref, timeBased);

% Not required before make the code public, the rss values are displayed 
% for all merit function called.
disp(initialParam)
disp(minRSS);

% find the parameters for the current experiments
slopesArr = [];
for i = 1:length(currExp)
    parameters = initialParam;
    stages = currExp{i}.stages;
    for times = 1:3
        options = optimset('MaxFunEval', 1e8);
        [parameters, rss] = fminsearch(@merit, parameters, options, ...
            stages, Tref, -1, -1, timeBased);
        % prevent unwanted negative rate constant
        parameters(2) = abs(parameters(2));
        parameters(4) = abs(parameters(4));
    end
    thermo = calcThermo(parameters, Tref);
    [~, absDiffArr, slopes] = merit(parameters, stages, Tref, plotI, -1, timeBased);
    slopesArr = [slopesArr; slopes'];
    plotI = plotI + 3;
end
if size(slopesArr, 1) > 1
    slopesArr = mean(slopesArr);
end

% load the experiment with missing lower baselines due to minimum stability
currExp = loadExperiment(uv);
currExp = correctTemperature(currExp);

[initialParam, minRSS, ~] = initialParameters(currExp, Tref, timeBased);
%[initialParam, minRSS, minInd] = initialParametersNoLow(currExp, Tref, timeBased, deltaAbs);

disp(initialParam)
disp(minRSS)

xArr = [];

% find the current experiments
for i = 1:length(currExp)
    parameters = initialParam;
    stages = currExp{i}.stages;
    for times = 1:3
        % run the fminsearch multiple rounds and try to reduce
        % the rss at each time
        options = optimset('MaxFunEval', 1e8);
        [parameters, rss] = fminsearch(@merit, parameters, options, ...     %(9:end)
            stages, Tref, -1, -1, timeBased);

        % prevent unwanted negative rate constant
        parameters(2) = abs(parameters(2));
        parameters(4) = abs(parameters(4));
    end
    thermo = calcThermo(parameters, Tref);
    [~, ~, x] = merit(parameters, stages, Tref, plotI-plotI, -1, timeBased);
    xArr = [xArr; x'];
    % plotI = plotI + 3;
end

% remove the lower baseline: only the higher baselines matter
% combine the low slope from the previous experiment with well estabilished
% slope and the high slopes with this simulation.
if size(slopesArr, 1) == 1
    eachAdd = slopesArr;
    for i = 1:size(xArr, 1)-1
        slopesArr = [slopesArr; eachAdd];
    end
end
xArr = [slopesArr(:, 1), xArr(:,5:end)];

% Still using the same experiments, now find the semi-quantitative
% parameters for the samples without lower baselines
%[initialParam, minRSS, minInd] = initialParameters(currExp, Tref, timeBased);
initialx = xArr(1, :);
[initialParam, minRSS, minInd] = initialParametersNoLow(currExp, Tref, timeBased, absDiffArr, initialx);

% disp(initialParam)
% disp(minRSS)

paramArr = [];
thermoArr = [];
rssArr = [];

% find the current experiments
for i = 1:length(currExp)
    parameters = initialParam;
    stages = currExp{i}.stages;
    eachx = xArr(i, :);
    for times = 1:3
        % run the fminsearch multiple rounds and try to reduce
        % the rss at each time
        % rss = 0, plotI = -1 not plotting
        options = optimset('MaxFunEval', 1e8);
        [parameters, rss] = fminsearch(@meritNoLowBaseline, parameters, options, ...     %(9:end)
            stages, Tref, -1, -1, timeBased, absDiffArr, eachx);
        % prevent unwanted negative rate constant
        parameters(2) = abs(parameters(2));
        parameters(4) = abs(parameters(4));
    end
    paramArr(i, :) = parameters;
    rssArr(i, :) = rss;
    thermoArr(i, :) = calcThermo(parameters, Tref);
    rss = meritNoLowBaseline(parameters, stages, Tref, plotI, -1, timeBased, absDiffArr,eachx);
    plotI = plotI + 3;
end

if length(currExp)>1
    parameters = mean(paramArr);
    kineticError = std(paramArr);
    thermo = mean(thermoArr);
    thermoError = std(thermoArr);
    disp(parameters)
    disp(kineticError)
    disp(thermo)
    disp(thermoError)
else
    disp(parameters)
    disp(thermo)
end
