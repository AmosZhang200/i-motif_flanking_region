% Created 2022-10-03
% totally modified from experiments based to sample based Merit
% Modified 2023-02-10
% change from absolute path to relative path
% 2023-03-12
% renamed twoMerit
% 2023-07-31
% change from temperature based merit function to time based merit function
% 2023-09-07
% 2 state merit function with 3 lower baselines (instead of 1 or 6)
% Created 2023-10-28
% merit function allows input with or without indexCell, i.e. simulate with
% or without the error analysis

% 2025-03-25 
% slightly modified algorithm, ignoring the regions between 40-60 C at
% cooling stages, for pH 5.5 only (varargin{2} = 0)


% varargin need to have 2 mandatory inputs
function rss = twoMerit(parameters, stages, Tref, plotI, varargin)

simulation = {};
y0 = [1,0];

% 30 minutes holding at 95 degrees
tspan = 0:1:30;
options = odeset('AbsTol',1e-15);
T0 = stages{1}.tempArr(1);
% holding, scanrate at 0 degree/min
dTdt = 0;
[~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref,T0), tspan, y0, options);
% all columes, last row
y0 = simulatedFraction(end, :);

for j = 1:length(stages)
    dTdt = double(stages{j}.scanrate);
    if varargin{2} == 0
        if dTdt < 0
            ind = find(stages{j}.tempArr<40+273.15 | stages{j}.tempArr>60+273.15);
            newtempArr = stages{j}.tempArr(ind);
            newabsArr = stages{j}.absArr(ind);
            [~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref), newtempArr, y0, options);
        elseif dTdt > 0
            [~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref), stages{j}.tempArr, y0, options);
        end
    end
    [rowSize, ~] = size(simulatedFraction);
    if dTdt < 0
        ind = find(stages{j}.tempArr<40+273.15 | stages{j}.tempArr>60+273.15);
        newtempArr = stages{j}.tempArr(ind);
        newabsArr = stages{j}.absArr(ind);
        expSize = length(newtempArr);
    elseif dTdt > 0
        expSize = length(stages{j}.tempArr);
    end
    % ~rowSize == expSize will give 0 when rowSize = 1 ~rowSize = 0,
    % (~rowSize == expSize) = 0
    if rowSize ~= expSize
        %simulatedFraction = [zeros(length(stages{j}.tempArr), 1), zeros(length(stages{j}.tempArr), 1)];
        simulatedFraction = [zeros(length(stages{j}.tempArr), 2)];
    end
    
    y0 = simulatedFraction(end, :);
    
    % if time based simulation
    if varargin{2} == 1
        % if at cooling stage
        if dTdt < 0
            % there is a holding stage for 10 minutes after each cooling
            % stages
            tspan = 0:0.5:10;
            dTdt = 0;
            T0 = stages{j}.tempArr(end);
            [~, holdingFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref,T0), tspan, y0, options);
            y0 = holdingFraction(end, :);
        end
    end

    % store the simulated value
    % bootstraping analysis
    if iscell(varargin{1})
        indexCell = varargin{1};
        simulation{end+1} = simulatedFraction(indexCell{j}, :);
        stages{j}.tempArr = stages{j}.tempArr(indexCell{j});
        stages{j}.absArr = stages{j}.absArr(indexCell{j});
    else
        simulation{end+1} = simulatedFraction;
    end
    
end

U = [];
F = [];
T = [];
Y = [];

for j = 1:length(simulation)
    % all rows, first column (first column values) are the fractional
    % unfolded values
    dTdt = double(stages{j}.scanrate);
    U = [U; simulation{j}(:, 1)];
    F = [F; simulation{j}(:, 2)];
    if dTdt < 0
        ind = find(stages{j}.tempArr<40+273.15 | stages{j}.tempArr>60+273.15);
        newtempArr = stages{j}.tempArr(ind);
        newabsArr = stages{j}.absArr(ind);
        T = [T; newtempArr.'];
        Y = [Y; newabsArr.'];
    elseif dTdt > 0
        T = [T; stages{j}.tempArr.'];
        Y = [Y; stages{j}.absArr.'];
    end
end

A = [];
A = [A, T.*F];

A = [];
A = [A, T.*F];

index = 0;
% adding zeros to make the size the same
for j = 1:length(simulation)
    eachF = zeros(1, length(F));
    for k = 1:length(simulation{j}(:, 2))
        eachF(k+index) = simulation{j}(k, 2);
    end
    index = index + length(simulation{j}(:, 2));
    A = [A, eachF'];
end

A = [A, T.*U];

index = 0;
for j = 1:length(simulation)
    eachU = zeros(1, length(U));
    for k = 1:length(simulation{j}(:, 1))
        eachU(k+index) = simulation{j}(k, 1);
    end
    index = index + length(simulation{j}(:, 1));
    A = [A, eachU'];
end

x = linsolve(A, Y);
rss = sum((A*x-Y).^2);

if plotI ~= -1
    plotTwoStates(parameters, stages, Tref, plotI)
end
rss
end

function plotTwoStates(parameters, stages, Tref, plotI)
makeFig(plotI)
colorCell = getColor(length(stages));

simulation = {};
y0 = [1,0];

% 30 minutes holding at 95 degrees
tspan = 0:1:30;
options = odeset('AbsTol',1e-15);
T0 = stages{1}.tempArr(1);
% holding, scanrate at 0 degree/min
dTdt = 0;
[~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref,T0), tspan, y0, options);
% all columes, last row
y0 = simulatedFraction(end, :);

for j = 1:length(stages)
    dTdt = double(stages{j}.scanrate);
    [~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref), stages{j}.tempArr, y0, options);
    [rowSize, ~] = size(simulatedFraction);
    expSize = length(stages{j}.tempArr);
    % ~rowSize == expSize will give 0 when rowSize = 1 ~rowSize = 0,
    % (~rowSize == expSize) = 0
    if rowSize ~= expSize
        %simulatedFraction = [zeros(length(stages{j}.tempArr), 1), zeros(length(stages{j}.tempArr), 1)];
        simulatedFraction = [zeros(length(stages{j}.tempArr), 2)];
    end
    
    y0 = simulatedFraction(end, :);

    simulation{end+1} = simulatedFraction;
end

U = [];
F = [];
T = [];
Y = [];

for j = 1:length(simulation)
    % all rows, first column (first column values) are the fractional
    % unfolded values
    dTdt = double(stages{j}.scanrate);
    U = [U; simulation{j}(:, 1)];
    F = [F; simulation{j}(:, 2)];
    T = [T; stages{j}.tempArr.'];
    Y = [Y; stages{j}.absArr.'];
end

A = [];
A = [A, T.*F];

index = 0;
% adding zeros to make the size the same
for j = 1:length(simulation)
    eachF = zeros(1, length(F));
    for k = 1:length(simulation{j}(:, 2))
        eachF(k+index) = simulation{j}(k, 2);
    end
    index = index + length(simulation{j}(:, 2));
    A = [A, eachF'];
end

A = [A, T.*U];

index = 0;
for j = 1:length(simulation)
    eachU = zeros(1, length(U));
    for k = 1:length(simulation{j}(:, 1))
        eachU(k+index) = simulation{j}(k, 1);
    end
    index = index + length(simulation{j}(:, 1));
    A = [A, eachU'];
end

x = linsolve(A, Y);

simulatedY = A*x;
simulatedAbsCell = {};
index = 1;
for j = 1:length(simulation)
    absLength = length(simulation{j}(:,1));
    simulatedAbs = simulatedY(index:index + absLength - 1).';
    simulatedAbsCell{end+1} = simulatedAbs;
    index = index + absLength;
end

lowYCell = {};
highYCell = {};
maxMinArr = [];
for j = length(stages):-1:1
    simulatedAbs = simulatedAbsCell{j};
    hold on;
    plot((stages{j}.tempArr-273.15), stages{j}.absArr/1/1.67*1000000, "o", ...
        'MarkerFaceColor','w','MarkerSize', 5, "Color", colorCell{j});
    %stages{j}.absArr/1/1.67*1000000
    plot((stages{j}.tempArr-273.15), simulatedAbs/1/1.67*1000000, "Color", ...
        colorCell{j}, "LineWidth",3);
    %simulatedAbs/1/1.67*1000000
    maxMinArr = [maxMinArr, stages{j}.absArr/1/1.67*1000000, simulatedAbs/1/1.67*1000000];
    % stages{j}.absArr/1/1.67*1000000, simulatedAbs/1/1.67*1000000
    mLow = x(1);
    bLow = x(1+j);
    mHigh = x(length(simulation)+2);
    bHigh = x(length(simulation)+2+j);
    lowBaselineY = stages{j}.tempArr * mLow + bLow;
    lowYCell{end+1} = lowBaselineY;
    highBaselineY = stages{j}.tempArr * mHigh + bHigh;
    highYCell{end+1} = highBaselineY;

    %plot((stages{j}.tempArr-273.15), lowBaselineY/1/1.67*1000000, "k-")
    %plot((stages{j}.tempArr-273.15), highBaselineY/1/1.67*1000000, "k-")
end
lowYCell = flip(lowYCell);
highYCell = flip(highYCell);
%xlabel(strcat('Temperature ', char(176), 'C'))
%ylabel("epislon")
%title(stages{1}.name)
xlim([0 100])
maxEpi = max(maxMinArr);
minEpi = min(maxMinArr);
%ylim([minEpi-maxEpi*0.03, maxEpi+maxEpi*0.03])
hold off;

% for ploting the normalized vs. temp data
makeFig(plotI+1)
for j = length(stages):-1:1
    simulatedAbs = simulatedAbsCell{j};

    lowBaselineY = lowYCell{j};
    highBaselineY = highYCell{j};

    normalizedAbs = (lowBaselineY - stages{j}.absArr) ./ (lowBaselineY - highBaselineY);
    normalizedSimu = (lowBaselineY - simulatedAbs) ./ (lowBaselineY - highBaselineY);
    hold on;
    %plot((stages{j}.tempArr-273.15), normalizedAbs, "Color", colorCell{j}, "LineWidth",3);
    plot((stages{j}.tempArr-273.15), normalizedAbs, "o", 'MarkerFaceColor','w','MarkerSize', 5, "Color", colorCell{j});
    plot((stages{j}.tempArr-273.15), normalizedSimu, "Color", colorCell{j}, "LineWidth",3);
end
%xlabel(strcat('Temperature ', char(176), 'C'))
%ylabel("Fraction unfolded")
%title(stages{1}.name)
xlim([0 100])
ylim([-0.05 1.05])
hold off;

% for ploting the rss vs. temp data
makeFigResidual(plotI+2)
for j = length(stages):-1:1
    simulatedAbs = simulatedAbsCell{j};

    lowBaselineY = lowYCell{j};
    highBaselineY = highYCell{j};

    normalizedAbs = (lowBaselineY - stages{j}.absArr) ./ (lowBaselineY - highBaselineY);
    normalizedSimu = (lowBaselineY - simulatedAbs) ./ (lowBaselineY - highBaselineY);

    residual = normalizedSimu - normalizedAbs;
    hold on;
    plot((stages{j}.tempArr-273.15), residual, "o", 'MarkerFaceColor', 'w', 'MarkerSize', 5, "Color", colorCell{j});
end
%xlabel(strcat('Temperature ', char(176), 'C'))
%ylabel("Residual")
%title(stages{1}.name)
hold off;
xlim([0, 100])
ylim([-0.1, 0.1])
end
