function colors = getColor(numColor)
colorLib = {'#0010BF', '#C20200', '#0085FF', '#FF5700', '#00D0FF', '#F4C520'};
if mod(numColor, 2) ~= 0
    numColor = numColor + 1;
end
if numColor <= 6
    colors = colorLib(1:numColor);
else
    numEachColor = numColor/2;
    redArr = rescale(1:numEachColor)/1.2; % prevent bright yellow line
    blueArr = rescale(1:numEachColor);
    colors = {};
    for i = 1:numEachColor
        eachColor = [0, blueArr(i), 1];
        colors{end+1} = eachColor;
        eachColor = [1, redArr(i), 0];
        colors{end+1} = eachColor;
    end
end
end