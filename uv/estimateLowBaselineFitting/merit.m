% Created 2023-10-28
% merit function allows input with or without indexCell, i.e. simulate with
% or without the error analysis

% varargin need to have 2 mandatory inputs
function [rss, absDiffArr, x] = merit(parameters, stages, Tref, plotI, varargin)

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
        [~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref), stages{j}.tempArr, y0, options);
    elseif varargin{2} == 1
        % cooling
        if dTdt < 0
            tspan = abs((stages{j}.tempArr-max(stages{j}.tempArr))/dTdt);
        elseif dTdt > 0
            tspan = abs((stages{j}.tempArr-min(stages{j}.tempArr))/dTdt);
        end
        T0 = stages{j}.tempArr(1);
        [~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref,T0), tspan, y0,options);
    end
    [rowSize, ~] = size(simulatedFraction);
    expSize = length(stages{j}.tempArr);
    
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
            tspan = 0:0.5:30;
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
    U = [U; simulation{j}(:, 1)];
    F = [F; simulation{j}(:, 2)];
    T = [T; stages{j}.tempArr.'];
    Y = [Y; stages{j}.absArr.'];
end

A = [];
A = [A, T.*F];

index = 0;
% adding zeros to make the size the same
for j = 1:length(simulation)/2
    eachF = zeros(1, length(F));
    for k = 1:length(simulation{j*2-1}(:,2))
        eachF(k+index) = simulation{j*2-1}(k,2);
    end
    index = index + length(simulation{j*2-1}(:,2));
    for k = 1:length(simulation{j*2}(:,2))
        eachF(k+index) = simulation{j*2}(k,2);
    end
    index = index + length(simulation{j*2}(:,2));
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
disp(rss)

% if plot larger than 0, for actual plotting
if plotI > 0
    makeFig(plotI)
    colorCell = getColor(length(stages));
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
    for j = length(simulation):-1:1
        simulatedAbs = simulatedAbsCell{j};
        hold on;
        plot((stages{j}.tempArr-273.15), stages{j}.absArr, "o", ...
            'MarkerFaceColor','w','MarkerSize', 5, "Color", colorCell{j});
        plot((stages{j}.tempArr-273.15), simulatedAbs, "Color", ...
            colorCell{j}, "LineWidth",3);

        % mLow = x(1);
        % bLow = x(1+j);
        % mHigh = x(length(simulation)+2);
        % bHigh = x(length(simulation)+2+j);
        mLow = x(1);                                % 1
        bLow = x(2+floor((j-1)/2));                 % 2 3 4
        mHigh = x(2+length(simulation)/2);          % 5
        bHigh = x(2+length(simulation)/2+j);        % 6 7 8 9 10 11
        lowBaselineY = stages{j}.tempArr * mLow + bLow;
        lowYCell{end+1} = lowBaselineY;
        highBaselineY = stages{j}.tempArr * mHigh + bHigh;
        highYCell{end+1} = highBaselineY;
        % if mod(j, 2) == 1
        %     delta = highBaselineY(end) - lowBaselineY(end);
        % else
        %     delta = highBaselineY(1) - lowBaselineY(1);
        % end
        plot((stages{j}.tempArr-273.15), lowBaselineY, "k-")
        plot((stages{j}.tempArr-273.15), highBaselineY, "k-")
    end
    lowYCell = flip(lowYCell);
    highYCell = flip(highYCell);
    xlim([0 100])
    hold off;

    makeFig(plotI+1)
    for j = length(simulation):-1:1
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
    xlim([0 100])
    ylim([-0.05 1.05])
    hold off;

    makeFigResidual(plotI+2)
    for j = length(simulation):-1:1
        simulatedAbs = simulatedAbsCell{j};

        lowBaselineY = lowYCell{j};
        highBaselineY = highYCell{j};

        normalizedAbs = (lowBaselineY - stages{j}.absArr) ./ (lowBaselineY - highBaselineY);
        normalizedSimu = (lowBaselineY - simulatedAbs) ./ (lowBaselineY - highBaselineY);

        residual = normalizedSimu - normalizedAbs;
        hold on;
        plot((stages{j}.tempArr-273.15), residual, "o", 'MarkerFaceColor', 'w', 'MarkerSize', 5, "Color", colorCell{j});
    end
    hold off;
    ylim([-0.1, 0.1])
end

absDiffArr = [];

for j = length(simulation):-1:1
    mLow = x(1);                                % 1
    bLow = x(2+floor((j-1)/2));                 % 2 3 4
    mHigh = x(2+length(simulation)/2);          % 5
    bHigh = x(2+length(simulation)/2+j);        % 6 7 8 9 10 11
    lowBaselineY = stages{j}.tempArr * mLow + bLow;
    highBaselineY = stages{j}.tempArr * mHigh + bHigh;
    if mod(j, 2) == 1
        delta = highBaselineY(end) - lowBaselineY(end);
    else
        delta = highBaselineY(1) - lowBaselineY(1);
    end
    absDiffArr = [absDiffArr, delta];
end
end
