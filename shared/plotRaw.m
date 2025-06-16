% function used to plot raw data from a processed data file

if ~exist('plotI','var')
    plotI = 5;
end

currExp = loadExperiment(uv);
currExp = correctTemperature(currExp);

for i = 1:length(currExp)
    maxMinArr = [];
    stages = currExp{i}.stages;
    
    makeFig(plotI)
    
    maxAbs = 0;
    minAbs = 10;
    for j = 1:length(stages)
        absArr = stages{j}.absArr;
        maxAbsStage = max(absArr);
        if maxAbsStage > maxAbs
            maxAbs = maxAbsStage;
        end
        minAbsStage = min(absArr);
        if minAbsStage < minAbs
            minAbs = minAbsStage;
        end
    end
    
    for j = length(stages):-1:1
        colorCell = getColor(length(stages));
        hold on
        plot((stages{j}.tempArr-273.15), stages{j}.absArr/1/1.67*1000000, 'o', ...
                'MarkerFaceColor','w','MarkerSize', 5, 'Color', colorCell{j});
        % plot((stages{j}.tempArr-273.15), stages{j}.absArr, 'o', ...
        %         'MarkerFaceColor','w','MarkerSize', 5, 'Color', colorCell{j});
        maxMinArr = [maxMinArr, stages{j}.absArr/1/1.67*1000000];
        % maxMinArr = [maxMinArr, stages{j}.absArr/1/1.67*1000000];
    end
    
    maxEpi = max(maxMinArr);
    minEpi = min(maxMinArr);
    ylim([minEpi-maxEpi*0.03, maxEpi+maxEpi*0.03])
    hold off
    
    plotI = plotI + 1;
end