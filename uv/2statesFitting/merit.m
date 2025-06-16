% varargin need to have 2 mandatory inputs
function rss = merit(parameters, stages, Tref, plotI, varargin)

simulation = cell(1, length(stages));
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
            % there is a holding stage for 30 minutes after each cooling
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
        simulation{j} = simulatedFraction(indexCell{j}, :);
        stages{j}.tempArr = stages{j}.tempArr(indexCell{j});
        stages{j}.absArr = stages{j}.absArr(indexCell{j});
    else
        simulation{j} = simulatedFraction;
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
    maxMinArr = [];
    if nargin == 7
        deltaEpsilon = varargin{3};
    end
    for j = length(simulation):-1:1
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
        % plot((stages{j}.tempArr-273.15), lowBaselineY/1/1.67*1000000, "k-")
        % plot((stages{j}.tempArr-273.15), highBaselineY/1/1.67*1000000, "k-")
    end
    lowYCell = flip(lowYCell);
    highYCell = flip(highYCell);
    %xlabel(strcat('Temperature ', char(176), 'C'))
    %ylabel("epislon")
    %title(stages{1}.name)
    xlim([0 100])
    maxEpi = max(maxMinArr);
    minEpi = min(maxMinArr);
    % y limit = 7.3e4;
    if nargin == 7
        ylim([minEpi-0.005/1/1.67*1000000, minEpi+deltaEpsilon+0.005/1/1.67*1000000])
    else 
        ylim([minEpi-0.005/1/1.67*1000000, maxEpi+0.005/1/1.67*1000000])
    end
    hold off;

    % for ploting the normalized vs. temp data
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
    %xlabel(strcat('Temperature ', char(176), 'C'))
    %ylabel("Fraction unfolded")
    %title(stages{1}.name)
    xlim([0 100])
    ylim([-0.05 1.05])
    hold off;

    % for ploting the rss vs. temp data
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
    %xlabel(strcat('Temperature ', char(176), 'C'))
    %ylabel("Residual")
    %title(stages{1}.name)
    hold off;
    xlim([0, 100])
    ylim([-0.1, 0.1])

    %% Plot 4: with simulation more than experimental data values
    if nargin == 7
        % % this part of the code will plot the simulated data with more
        % % simulated datapoints
        plotsimu = cell(1, length(stages));
        tspan = 0:1:30;
        options = odeset('AbsTol',1e-15);
        T0 = 95+273.15;
        % holding, scanrate at 0 degree/min
        dTdt = 0;
        y0 = [1,0];
        [~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref,T0), tspan, y0, options);
        % all columes, last row
        y0 = simulatedFraction(end, :);



        coolingTemp = 95:-0.005:15;
        coolingTemp = coolingTemp + 273.15;
        heatingTemp = 15:0.005:95;
        heatingTemp = heatingTemp + 273.15;
        simulatedTempCell = {coolingTemp,heatingTemp,coolingTemp,heatingTemp,coolingTemp,heatingTemp};
        for j = 1:length(stages)
            simulatedTemp = simulatedTempCell{j};
            dTdt = double(stages{j}.scanrate);
            [~, simulatedFraction] = ode15s(@(t,y) twoStateODE(t,y,parameters,dTdt,Tref), simulatedTemp, y0, options);
            y0 = simulatedFraction(end, :);
            plotsimu{j} = simulatedFraction;
        end

        simu_U = [];
        simu_F = [];
        simu_T = [];

        for j = 1:length(plotsimu)
            % all rows, first column (first column values) are the fractional
            % unfolded values
            simu_U = [simu_U; plotsimu{j}(:, 1)];
            simu_F = [simu_F; plotsimu{j}(:, 2)];
            simu_T = [simu_T; simulatedTempCell{j}.'];
        end

        simu_A = [];
        simu_A = [simu_A, simu_T.*simu_F];

        index = 0;
        % adding zeros to make the size the same
        for j = 1:length(plotsimu)
            eachF = zeros(1, length(simu_F));
            for k = 1:length(plotsimu{j}(:, 2))
                eachF(k+index) = plotsimu{j}(k, 2);
            end
            index = index + length(plotsimu{j}(:, 2));
            simu_A = [simu_A, eachF'];
        end

        simu_A = [simu_A, simu_T.*simu_U];

        index = 0;
        for j = 1:length(plotsimu)
            eachU = zeros(1, length(simu_U));
            for k = 1:length(plotsimu{j}(:, 1))
                eachU(k+index) = plotsimu{j}(k, 1);
            end
            index = index + length(plotsimu{j}(:, 1));
            simu_A = [simu_A, eachU'];
        end

        simulatedY = simu_A*x;
        simulatedAbsCell = {};
        index = 1;
        for j = 1:length(plotsimu)
            absLength = length(plotsimu{j}(:,1));
            simulatedAbs = simulatedY(index:index + absLength - 1).';
            simulatedAbsCell{end+1} = simulatedAbs;
            index = index + absLength;
        end


        makeFig(plotI+3)
        lowYCell = {};
        highYCell = {};
        maxMinArr = [];
        if nargin == 7
            deltaEpsilon = varargin{3};
        end
        for j = length(simulation):-1:1
            simulatedTemp = simulatedTempCell{j};
            simulatedAbs = simulatedAbsCell{j};
            hold on;
            plot((stages{j}.tempArr-273.15), stages{j}.absArr/1/1.67*1000000, "o", ...
                'MarkerFaceColor','w','MarkerSize', 5, "Color", colorCell{j});
            %stages{j}.absArr/1/1.67*1000000
            plot((simulatedTemp-273.15), simulatedAbs/1/1.67*1000000, "Color", ...
                colorCell{j}, "LineWidth",3);
            %simulatedAbs/1/1.67*1000000
            maxMinArr = [maxMinArr, stages{j}.absArr/1/1.67*1000000];
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

            % plot((stages{j}.tempArr-273.15), lowBaselineY/1/1.67*1000000, "k-")
            % plot((stages{j}.tempArr-273.15), highBaselineY/1/1.67*1000000, "k-")
        end
        lowYCell = flip(lowYCell);
        highYCell = flip(highYCell);
        xlim([0 100])

        minEpi = min(maxMinArr);
        % y limit = 7.3e4;
        ylim([minEpi-0.005/1/1.67*1000000, minEpi+deltaEpsilon+0.005/1/1.67*1000000])
        hold off;

        makeFig(plotI+4)
        for j = length(simulation):-1:1
            lowBaselineY = lowYCell{j};
            highBaselineY = highYCell{j};

            normalizedAbs = (lowBaselineY - stages{j}.absArr) ./ (lowBaselineY - highBaselineY);
            simulatedTemp = simulatedTempCell{j};
            normalizedSimu = plotsimu{j}(:, 1);
            hold on;
            %plot((stages{j}.tempArr-273.15), normalizedAbs, "Color", colorCell{j}, "LineWidth",3);
            plot((stages{j}.tempArr-273.15), normalizedAbs, "o", 'MarkerFaceColor','w','MarkerSize', 5, "Color", colorCell{j});
            plot((simulatedTemp-273.15), normalizedSimu, "Color", colorCell{j}, "LineWidth",3);
        end
        %xlabel(strcat('Temperature ', char(176), 'C'))
        %ylabel("Fraction unfolded")
        %title(stages{1}.name)
        xlim([0 100])
        ylim([-0.05 1.05])
        hold off;
    end
end
%disp(rss)
end
