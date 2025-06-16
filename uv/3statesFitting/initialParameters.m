function [initialParam, minRSS, minInd] = initialParameters(originalExp, Tref)
% parameters for iM
initialk = [0.001, 0.005, 0.01, 0.03, 0.05, 0.1, 0.2, 0.5, 1, 2, 5];
initialH = -200:-30:-550;
initialTm = 10:2:40;
%initialTm = 40:3:70;

initialPCell = {};
initialRSSArr = [];

index = 1;
for i = 1:length(initialk)
    for j = 1:length(initialH)
        for k = 1:length(initialTm)
            %parameters = [10, 20, 400, 6.5e-6];
            % parameters for duplex
            parameters = [100, 20, 300, 5e-2];
            parameters = [parameters, calcKinetic(initialk(i), initialH(j), initialTm(k), Tref)];
            currExp = originalExp{1};
                
            stages = currExp.stages;
            %options = optimset('MaxIter', 10);
            % 2023-10-31 update: no initial optimization for multiple
            % experiments
            rss = threeMerit(parameters, stages, Tref, -1);
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