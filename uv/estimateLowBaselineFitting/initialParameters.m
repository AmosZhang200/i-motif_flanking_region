function [initialParam, minRSS, minInd] = initialParameters(originalExp, Tref, timeBased)
initialk = [0.001, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5];
initialH = -100:-50:-500;
initialTm = 5:2:35;
%initialTm = 45:3:72;

initialPCell = {};
initialRSSArr = [];

index = 1;
for i = 1:length(initialk)
    for j = 1:length(initialH)
        for k = 1:length(initialTm)
            parameters = calcKinetic(initialk(i), initialH(j), initialTm(k), Tref);
            currExp = originalExp{1};
            stages = currExp.stages;
            %options = optimset('MaxIter', 10);
            % 2023-10-31 update: no initial optimization for multiple
            % experiments
            rss = merit(parameters, stages, Tref, -1, -1, timeBased);
            %parameters(2) = abs(parameters(2));
            %parameters(4) = abs(parameters(4));

            initialPCell{index} = parameters;
            initialRSSArr(index) = rss;
            index = index + 1;
        end
    end
end

[minRSS, minInd] = min(initialRSSArr);
initialParam = initialPCell{minInd};

end