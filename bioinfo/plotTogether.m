% Function plots the number of SW rated duplexes surrounding the iM 
% and random sequences together

function plotI = plotTogether(junctionCleaned, randomCell, titleName, plotI)

makeFig(plotI);
nbins = [19, 25, 30, 35, 40, 45, 50, 55, 60, 75];
iMcount = zeros(1,length(nbins));

[nRow, ~] = size(junctionCleaned);

for i = 1:nRow
    if junctionCleaned{i, 2} < nbins(1)
        iMcount(1) = iMcount(1) + 1;
    else
        for k = 2:length(nbins)
            if junctionCleaned{i, 2} >= nbins(k-1) && junctionCleaned{i, 2} < nbins(k)
                iMcount(k) = iMcount(k) + 1;
            end
        end
    end
end

randomCountList = [];

[nRow, ~] = size(junctionCleaned);

for h = 1:length(randomCell)
    randomCount = zeros(1,length(nbins));
    randomCleaned = randomCell{h};
    for i = 1:nRow
        if randomCleaned{i, 1} < nbins(1)
            randomCount(1) = randomCount(1) + 1;
        else
            for k = 2:length(nbins)
                if randomCleaned{i, 1} >= nbins(k-1) && randomCleaned{i, 1} < nbins(k)
                    randomCount(k) = randomCount(k) + 1;
                end
            end
        end
    end
    randomCountList = cat(1, randomCountList, randomCount);
end

randomCount = round(mean(randomCountList));

X = categorical({'0-18','19-24','25-29','30-34', '35-39', '40-44', '45-49', '50-54', '55-59', '60-75'});
X = reordercats(X,{'0-18','19-24','25-29','30-34', '35-39', '40-44', '45-49', '50-54', '55-59', '60-75'});
hold on;
b = bar(X, [randomCount; iMcount]);
hold off;

colors = ["#FF0000", "#0000FF"];
for i = 1:length(b)
    b(i).FaceColor = colors(i);
end
% Annotating the count of random or i-motif nucleotide on the top of the
% bar
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1, ytips1, labels1, "HorizontalAlignment","center","VerticalAlignment","bottom", 'FontSize', 12, 'FontWeight', 'bold')
xtips2 = b(2).XEndPoints;
ytips2 = b(2).YEndPoints;
labels2 = string(b(2).YData);
text(xtips2, ytips2, labels2, "HorizontalAlignment","center","VerticalAlignment","bottom", 'FontSize', 12, 'FontWeight', 'bold')
set(gca, 'TickLength', [0,0])
set(gca, 'FontSize', 14)
%set(gca, 'FontWeight', 'bold')
%ylim([0, 620])
ylim([0, 1450])
legend("Random", "iM", 'FontSize', 18, 'FontWeight', 'bold')


%xlabel(strcat('Tm_{Est} (', char(176), 'C)'), 'FontSize', 24, 'FontWeight','bold')
title(titleName, FontSize=26, FontWeight="bold")
plotI = plotI + 1;
end