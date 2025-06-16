function currExp = correctTemperature(currExp)
% check whether tempCorrected property exist
if isempty(currExp{1}.tempCorrected)
    return
end

for i = 1:length(currExp)
    stages = currExp{i}.stages;
    lastTemp = stages{1}.tempArr(end);
    maxTemp = 0;
    for j = 2:length(stages)
        scanrate = stages{j}.scanrate;
        tempArr = stages{j}.tempArr;
        absArr = stages{j}.absArr;
        if scanrate > 0 
            % heating
            TFArr = tempArr > lastTemp;
        elseif scanrate < 0
            TFArr = tempArr < lastTemp;
        end
        lastTemp = tempArr(end);
        tempArr = nonzeros(tempArr.*TFArr).';
        absArr = nonzeros(absArr.*TFArr).';
        if max(tempArr) > maxTemp
            maxTemp = max(tempArr);
        end
        stages{j}.tempArr = tempArr;
        stages{j}.absArr = absArr;
    end
    tempArr = stages{1}.tempArr;
    absArr = stages{1}.absArr;
    TFArr = tempArr < maxTemp;
    tempArr = nonzeros(tempArr.*TFArr).';
    absArr = nonzeros(absArr.*TFArr).';
    stages{1}.tempArr = tempArr;
    stages{1}.absArr = absArr;
    currExp{i}.stages = stages;
end
end