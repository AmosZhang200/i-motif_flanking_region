% Created 2022-10-03
% totally modified from experiments based to sample based Merit
% Modified 2023-02-10
% change from absolute path to relative path
% 2023-03-12
% renamed twoMerit

function rss = threeMerit(parameters, stages, Tref, plotI)
fracSimu = {};
% the start fraction unfolded / fraction folded composition
% Since we always start at high temperature, we assume that
% fraction unfolded = 1
% and fraction folded = 0

y0 = [1,0,0];
% set experiment for 30 minutes at highest temperature and let system to
% equilibrate
tspan = 0:0.5:30;
T0 = stages{1}.tempArr(1);
dTdt = 0;
options = odeset('AbsTol',1e-15);
[~, eachFrac] = ode15s(@(t,y)threeStateODE(t,y,parameters,T0,dTdt,Tref),tspan,y0,options);
y0 = eachFrac(end,:);

for j = 1:length(stages)
    dTdt = double(stages{j}.scanrate);
    if dTdt < 0
        tspan = abs((stages{j}.tempArr - max(stages{j}.tempArr))/dTdt);
    elseif dTdt > 0
        tspan = abs((stages{j}.tempArr - min(stages{j}.tempArr))/dTdt);
    end
    T0 = stages{j}.tempArr(1);
    options = odeset('AbsTol',1e-15);
    [~, eachFrac] = ode15s(@(t, y)threeStateODE(t,y,parameters,T0,dTdt,Tref),...
        tspan, y0, options);
    % the last row of simulated fraction unfolded/fraction folded at this
    % stage is the starting point of next stage.
    
    % The frac_u_simu is a cell array and each element is fraction
    % folded / unfolded (displayed vertically) for each stage

    fracSimu{end+1} = eachFrac;
    y0 = eachFrac(end, :);
    if dTdt < 0
        %% changed 2025-03-28 from 10 minutes to 30 minutes
        T0 = stages{j}.tempArr(end);
        dTdt = 0;
        tspan = 0:0.5:10;
        options = odeset('AbsTol',1e-15);
        [~, eachFrac] = ode15s(@(t, y)threeStateODE(t,y,parameters,T0,dTdt,Tref), tspan, y0,options);
        y0 = eachFrac(end, :);
    end
end

% put all the stages for one sample together as a n*1 list.
% simulated fractional unfolded
simuU = [];
% simulated fractional folded 1
simuF1 = [];
% simulated fractional folded 2
simuF2 = [];
% temperature
simuT = [];
% absorbance
simuY = [];

for j = 1:length(fracSimu)
    if length(fracSimu{j}(:,1)) == length(stages{j}.tempArr)
        simuU = [simuU; fracSimu{j}(:,1)];
        simuF1 = [simuF1; fracSimu{j}(:,2)];
        simuF2 = [simuF2; fracSimu{j}(:,3)];
        simuT = [simuT; stages{j}.tempArr.'];
        simuY = [simuY; stages{j}.absArr.'];
    else
        simuU = [simuU; zeros(size(stages{j}.tempArr.'))];
        simuF1 = [simuF1; zeros(size(stages{j}.tempArr.'))];
        simuF2 = [simuF2; zeros(size(stages{j}.tempArr.'))];
        simuT = [simuT; stages{j}.tempArr.'];
        simuY = [simuY; stages{j}.absArr.'];
    end
end

A = [];

% The slopes at low temperature should all be the same
A = [A, simuT.*simuF2];

% want 1 low baseline for every 2 stages
index = 0;
for j = 1:length(fracSimu)/2
    fracF2 = zeros(1, length(simuF2));

    % fraction folded for one cooling stage
    for k = 1:length(fracSimu{j*2-1}(:,3))
        fracF2(k+index) = fracSimu{j*2-1}(k,3);
    end
    index = index + length(fracSimu{j*2-1}(:,3));

    % fraction folded for one heating stage
    for k = 1:length(fracSimu{j*2}(:,3))
        fracF2(k+index) = fracSimu{j*2}(k,3);
    end
    index = index + length(fracSimu{j*2}(:,3));
    A = [A, fracF2'];
end

% The slopes at middle temperature should all be the same
A = [A, simuT.*simuF1];

index = 0;
for j = 1:length(fracSimu)
    fracF1 = zeros(1, length(simuF1));
    for k = 1:length(fracSimu{j}(:,2))
        fracF1(k+index) = fracSimu{j}(k,2);
    end
    index = index + length(fracSimu{j}(:,2));
    A = [A, fracF1'];
end

% The slopes at high temperature should all be the same
A = [A, simuT.*simuU];

index = 0;
for j = 1:length(fracSimu)
    fracU = zeros(1, length(simuU));
    for k = 1:length(fracSimu{j}(:, 1))
        fracU(k+index) = fracSimu{j}(k, 1);
    end
    index = index + length(fracSimu{j}(:,1));
    A = [A, fracU'];
end

% Ax = y
x = linsolve(A, simuY);
rss = sum((A*x-simuY).^2);

% 20231002
if plotI ~= -1
    makeFig(plotI)
    colorCell = getColor(length(stages));
    YFitted = {};
    YSimu = A*x;
    index = 1;
    for j = 1:length(fracSimu)
        YLength = length(fracSimu{j}(:,1));
        YFittedEach = YSimu(index:index + YLength - 1).';
        YFitted{end+1} = YFittedEach;
        index = index + YLength;
    end

    lowYCell = {};
    midYCell = {};
    highYCell = {};
    % 2025-02-02 added
    maxMinArr = [];

    for j = length(fracSimu):-1:1
        YFittedEach = YFitted{j};
        hold on;
        plot((stages{j}.tempArr-273.15), stages{j}.absArr/1/1.67*10^6, 'o', ...
            'MarkerFaceColor','w','MarkerSize', 5, 'Color', colorCell{j});
        plot((stages{j}.tempArr-273.15), YFittedEach/1/1.67*10^6, 'Color', ...
            colorCell{j}, 'LineWidth', 3);
        maxMinArr = [maxMinArr, stages{j}.absArr/1/1.67*1000000, YFittedEach/1/1.67*1000000];
        m_low = x(1);                           % 1
        b_low = x(2+floor((j-1)/2));            % 2 3 4
        m_middle = x(2+0.5*length(fracSimu));       % 5
        b_middle = x(2+0.5*length(fracSimu)+j);     % 6 7 8 9 10 11
        m_high = x(3+1.5*length(fracSimu));   % 12
        b_high = x(3+1.5*length(fracSimu)+j); % 13 14 15 16 17 18
        
        lowY = stages{j}.tempArr*m_low + b_low;
        lowYCell{end+1} = lowY;
        midY = stages{j}.tempArr*m_middle + b_middle;
        midYCell{end+1} = midY;
        highY = stages{j}.tempArr*m_high + b_high;
        highYCell{end+1} = highY;
        hold on;
        % plot((stages{j}.tempArr-273.15), lowY/1/1.67*1000000, "k-")
        % plot((stages{j}.tempArr-273.15), midY/1/1.67*1000000, "k-")
        % plot((stages{j}.tempArr-273.15), highY/1/1.67*1000000, "k-")
    end
    lowYCell = flip(lowYCell);
    midYCell = flip(midYCell);
    highYCell = flip(highYCell);
    xlim([0 100])
    maxEpi = max(maxMinArr);
    minEpi = min(maxMinArr);
    ylim([minEpi-maxEpi*0.03, maxEpi+maxEpi*0.03])
    %xlabel(strcat("Temperature ", char(176), "C"))
    %ylabel("Absorbance")
    %title(stages{1}.name)
    hold off;

    makeFig(plotI+1)
    for j = length(fracSimu):-1:1
        YFittedEach = YFitted{j};

        lowY = lowYCell{j};
        highY = highYCell{j};

        normalizedAbs = (lowY-stages{j}.absArr)./(lowY-highY);
        normalizedSimu = (lowY-YFittedEach)./(lowY-highY);

        hold on;
        plot((stages{j}.tempArr-273.15), normalizedAbs, 'o', ...
            'MarkerFaceColor','w','MarkerSize', 5, 'Color', colorCell{j});
        plot((stages{j}.tempArr-273.15), normalizedSimu, ...
            'Color', colorCell{j}, 'LineWidth',3);
    end
    %xlabel(strcat("Temperature ", char(176), "C"))
    %ylabel("Fraction unfolded")
    %title(stages{1}.name)
    xlim([0 100])
    ylim([-0.05, 1.05])
    hold off;

    makeFigResidual(plotI+2)
    for j = length(fracSimu):-1:1
        YFittedEach = YFitted{j};

        lowY = lowYCell{j};
        highY = highYCell{j};

        normalizedAbs = (lowY - stages{j}.absArr) ./ (lowY - highY);
        normalizedSimu = (lowY - YFittedEach) ./ (lowY - highY);

        residual = normalizedSimu - normalizedAbs;
        hold on;
        plot((stages{j}.tempArr-273.15), residual, "o", 'MarkerFaceColor', ...
            'w', 'MarkerSize', 5, "Color", colorCell{j});
    end
    %xlabel(strcat('Temperature ', char(176), 'C'))
    %ylabel("Residual")
    %title(stages{1}.name)
    hold off;
    ylim([-0.1, 0.1])
end
rss     % to check if the program runs as what we expect
end