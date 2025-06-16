% function used to find solution temperature (actual temperature) 
% from the block temperature 
% Refer to Figure S1

function tempArr = actualTemperature(tempArr, scanrate, pH)
    pH = str2double(pH);
    if pH == 5.5
        if scanrate == -3
            tempArr = 0.95*tempArr + 6.0517;
        elseif scanrate == 3
            tempArr = 0.9583*tempArr - 1.9353;
        elseif scanrate == -2
            tempArr = 0.9638*tempArr + 4.1392;
        elseif scanrate == 2
            tempArr = 0.9697*tempArr - 1.4155;
        elseif scanrate == -1
            tempArr = 0.9717*tempArr + 2.5276;
        elseif scanrate == 1
            tempArr = 0.9815*tempArr - 0.7047;
        end
    else 
        if scanrate == -4
            tempArr = 0.9669*tempArr + 6.7276;
        elseif scanrate == 4
            tempArr = 0.969*tempArr - 3.839;
        elseif scanrate == -3
            tempArr = 0.96*tempArr + 5.5491;
        elseif scanrate == 3
            tempArr = 0.9718*tempArr - 2.9842;
        elseif scanrate == -2
            tempArr = 0.9572*tempArr + 4.2738;
        elseif scanrate == 2
            tempArr = 0.978*tempArr - 2.0099;
        elseif scanrate == -1
            tempArr = 0.9737*tempArr + 2.3471;
        elseif scanrate == 1
            tempArr = 0.9863*tempArr - 0.848;
        end
    end
end