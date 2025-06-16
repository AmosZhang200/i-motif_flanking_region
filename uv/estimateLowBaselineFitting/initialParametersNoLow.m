function [initialParam, minRSS, minInd] = initialParametersNoLow(originalExp, Tref, timeBased, deltaAbs, x)
initialk = [0.001, 0.01, 0.02, 0.05, 0.1];
%initialH = -300:-50:-500;
initialH = -100:-50:-500;
%initialTm = 45:3:72;
initialTm = 5:2:35;

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
            rss = meritNoLowBaseline(parameters, stages, Tref, -1, -1, timeBased, deltaAbs, x);
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