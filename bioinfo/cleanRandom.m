% function very similar to cleanJunction
% Function requires a cell array (output of "findRandomBps" function) as the input
% as well as the delete index to get rid of the duplicated sequences
% although the random sequence is not duplicated, it is still removed to
% match the number of iM forming sequences.
% Function returns a cell array with cleaned random, by removing the empty searches

function returnRandom = cleanRandom(randbps, deleteIndex)

tempRandom = {};
index = 1;

for i = 1:length(randbps)
    for j = 1:length(randbps{i})
        for k = 1:length(randbps{i}{j})
            tempRandom{index, k} = randbps{i}{j}{k};
        end
        index = index + 1;
    end
end

returnRandom = {};

index = 1;

for i = 1:length(tempRandom)
    if ~ismember(i, deleteIndex)
        returnRandom(index, :) = tempRandom(i, :);
        index = index + 1;
    end
end
end
