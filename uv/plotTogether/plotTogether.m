% function plot raw data together with identical y-axis range       
% function requires 2 integer inputs, plotI value, and wavelength value   
% plotI can be any positive integer values used to plot figures     
% wavelength can only be either 260 or 295                                 

function plotTogether(plotI, wavelength)
% function loads experiments from the "processed" directory
% details can be found in ../shared/uv file
currExp = loadExperiment(uv);
% function corrects the technical hysteresis (only when the scan rates are
% 1, 2, and 3 degrees/min)
%  details can be found in ../shared/correctTemperature file
currExp = correctTemperature(currExp);

% finds the maximum delta absorbance (y-axis range) across all 
% input UV-experiments
maxDeltaAbs = 0;
for i = 1:length(currExp)
    stages = currExp{i}.stages;
    maxAbs = 0;
    minAbs = 10;
    for j = 1:length(stages)
        if maxAbs < max(stages{j}.absArr)
            maxAbs = max(stages{j}.absArr);
        end
        if minAbs > min(stages{j}.absArr)
            minAbs = min(stages{j}.absArr);
        end
    end
    deltaAbs = maxAbs - minAbs;
    disp(deltaAbs)
    if maxDeltaAbs < deltaAbs
        maxDeltaAbs = deltaAbs;
    end
end
deltaEplison = maxDeltaAbs/1/1.67*1000000;

% plots each individual experiments with idential y-axis range
for i = 1:length(currExp)
    makeFig(plotI)
    stages = currExp{i}.stages;
    newAbsArr = {};
    for j = 1:length(stages)
        newAbsArr{end+1} = stages{j}.absArr;
    end
    maxAbs = 0;
    minAbs = 10;
    for j = 1:length(stages)
        for k = 1:length(newAbsArr{j})
            if newAbsArr{j}(k) > maxAbs
                maxAbs = newAbsArr{j}(k);
            end
            if newAbsArr{j}(k) < minAbs
                minAbs = newAbsArr{j}(k);
            end
        end
    end

    for j = length(stages):-1:1
        tempArr = stages{j}.tempArr;
        absArr = stages{j}.absArr;
        color = stages{j}.color;
        plot(tempArr-273.15, absArr/1/1.67*1000000, 'o', Color=color)
    end
    xlabel(strcat("Temperature ",char(176), "C)"))
    ylabel(strcat(char(949), "(M^{-1}cm^{-1})"))
    xlim([0 100])
    if wavelength == 260
        % % for 260 nm
        ylim([maxAbs/1/1.67*1000000-maxDeltaAbs/1/1.67*1000000-0.015/1/1.67*1000000 maxAbs/1/1.67*1000000+0.015/1/1.67*1000000])
    elseif wavelength == 295
        % % for 295 nm
        ylim([minAbs/1/1.67*1000000-0.01/1/1.67*1000000 minAbs/1/1.67*1000000+maxDeltaAbs/1/1.67*1000000+0.01/1/1.67*1000000])
    end
    plotI = plotI + 1;
end
end