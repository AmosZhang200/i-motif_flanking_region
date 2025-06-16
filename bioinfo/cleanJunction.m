% Function requires a cell array (output of "findJunction" function) as the input
% Function returns a cell array with cleaned junction, by removing empty searches

function [returnJunction, deleteIndex] = cleanJunction(junctionInput)

tempJunction = {};
index = 1;

% function iterate through the junction cell arrays only collect
% information from the non-empty cell arrays
for i = 1:length(junctionInput)
    for j = 1:length(junctionInput{i})
        for k = 1:length(junctionInput{i}{j})
            tempJunction{index, k} = junctionInput{i}{j}{k};
        end
        index = index + 1;
    end
end

% there might be duplication between these mapped iM, the next block
% of the code finds the duplication with the index.
deleteIndex = [];
for i = 1:length(tempJunction)
    currentiM = tempJunction(i, :);
    currentName = currentiM{1};
    name1 = extractBefore(currentName, '_');
    currentSeq = currentiM{3};
    for j = i+1:length(tempJunction)
        comparediM = tempJunction(j, :);
        comparedName = comparediM{1};
        comparedSeq = comparediM{3};
        name2 = extractBefore(comparedName, '_');
        if strcmp(name1, name2) && strcmp(currentSeq, comparedSeq) && ~strcmp(currentName, comparedName)
            % delete the repeated sequence
            deleteIndex = [deleteIndex, j];
        end
    end
end

returnJunction = {};

index = 1;
% this code snippet removes the duplication of the i-motifs from the
% cleaned junction cell arrays
for i = 1:length(tempJunction)
    if ~ismember(i, deleteIndex)
        returnJunction(index, :) = tempJunction(i, :);
        returnJunction(index, 1) = extractBefore(returnJunction(index, 1), '_');
        index = index + 1;
    end
end
end
