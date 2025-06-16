% % function F1 = makeFig(figI)
% % %clf(figure(figI));
% % F1 = figure(figI);
% % % F1 = gcf;
% % %F1.WindowStyle = 'Docked';
% % F1.Position = [200 200 600 500];
% % hold on
% % set(gcf,'color','w')
% % set(gca,'LineWidth',2,'FontSize',18,'XColor','k','YColor','k','FontName','Arial','FontWeight','bold')
% % box on
% % ax = gca;
% % ax.Position = [0.15,0.15,0.8,0.8];
% % box on
% % % lgd = legend();
% % % lgd.Position = [0.28, 0.75, 0.2, 0.1];
% % end
% function makeFig(plotI)
% % clear the figure content
% clf(figure(plotI))
% % f is the figure handle
% f = figure(plotI);
% % set figure background color to be white
% f.Color = [1,1,1];
% f.Position = [200, 200, 600, 500];
% a = gca;
% a.LineWidth = 3;
% a.FontSize = 18;
% a.XColor = [0 0 0];
% a.FontName = 'Arial';
% a.FontWeight = 'bold';
% a.Position = [0.15, 0.15, 0.8, 0.8];
% hold on;
% box on;
% end

% function F1 = makeFig(figI)
% %clf(figure(figI));
% F1 = figure(figI);
% % F1 = gcf;
% %F1.WindowStyle = 'Docked';
% F1.Position = [200 200 600 500];
% hold on
% set(gcf,'color','w')
% set(gca,'LineWidth',2,'FontSize',18,'XColor','k','YColor','k','FontName','Arial','FontWeight','bold')
% box on
% ax = gca;
% ax.Position = [0.15,0.15,0.8,0.8];
% box on
% % lgd = legend();
% % lgd.Position = [0.28, 0.75, 0.2, 0.1];
% end
% 
% works for single plot, subplot and tiled plot
function f = makeFig(plotI)

%clf(figure(plotI));
f = figure(plotI);
% F1 = gcf;
%F1.WindowStyle = 'Docked';
f.Color = [1,1,1];
f.Position = [200 200 600 500];
if isempty(f.Children)
    hold on
    set(gcf,'color','w')
    set(gca,'LineWidth',2,'FontSize',20,'XColor','k','YColor','k','FontName','times','FontWeight','bold')
    box on
    ax = gca;
    ax.Position = [0.15,0.15,0.8,0.8];
    box on
    % lgd = legend();
    % lgd.Position = [0.28, 0.75, 0.2, 0.1];

else
    %f.Position = [200 200 600 500];
    f.Color = [1,1,1];
    fchild = f.Children;

    generalTitle = 0;

    for i = 1:length(fchild)
        if isa(fchild(i), 'matlab.graphics.layout.TiledChartLayout')
            fchild(i).Title.FontSize = 28;
            fchild(i).Title.FontWeight = 'bold';
            fchild(i).Title.FontName = 'times';
            tileChild = fchild.Children;
            %colorCell = getColor(length(tileChild));
            for j = 1:length(tileChild)
                if ~isa(tileChild(j), 'matlab.graphics.axis.Axes')
                    error("Your subplot contained at least one non-figure object");
                end
                ax = tileChild(j);
                ax.LineWidth = 2;
                ax.FontSize = 20;
                ax.FontName = 'times';
                ax.FontWeight = 'bold';
                ax.XColor = 'k';
                ax.YColor = 'k';
                ax.Box = "on";
                ax.Title.FontWeight = 'bold';
                ax.Title.FontSize = 20;
                if generalTitle == 0
                    ax.Title.FontSize = 28;
                end
                if isa(ax.Children, 'matlab.graphics.chart.primitive.Line')
                    ax.Children.LineWidth = 3;
                    %ax.Children.Color = colorCell{j};
                end
            end
        elseif isa(fchild(i), 'matlab.graphics.illustration.subplot.Text')
            fchild(i).FontName = 'times';
            fchild(i).FontSize = 20;
            fchild(i).FontWeight = 'bold';
            generalTitle = 1;
        elseif isa(fchild(i), 'matlab.graphics.illustration.ColorBar')
            ax = fchild(i);
            ax.FontSize = 15;
            ax.FontWeight = 'bold';
            ax.FontName = 'times';
            ax.LineWidth = 2;
        else
            if ~isa(fchild(i), 'matlab.graphics.axis.Axes')
                error("Your subplot contained at least one non-figure object");
            end
            ax = fchild(i);
            ax.Position = [0.15,0.15,0.8,0.8];
            ax.LineWidth = 2;
            ax.FontSize = 20;
            ax.FontName = 'times';
            ax.FontWeight = 'bold';
            ax.XColor = 'k';
            ax.YColor = 'k';
            ax.Box = "on";
            ax.Title.FontWeight = 'bold';
            ax.Title.FontSize = 20;
            if generalTitle == 0
                ax.Title.FontSize = 28;
            end
            %colorCell = getColor(length(ax.Children));
            % for j = 1:length(ax.Children)
            %     if isa(ax.Children(j), 'matlab.graphics.chart.primitive.Line')
            %         line = ax.Children(j);
            %         line.LineWidth = 3;
            %         %line.Color = colorCell{j};
            %     end
            % end
        end
    end
end
end

% function colorCell = getColor(numColor)
%     if mod(numColor, 2) ~= 0
%         numColor = numColor + 1;
%     end
%     numEachColor = numColor/2;
%     redArr = rescale(1:numEachColor)/1.2; % prevent light yellow line
%     blueArr = rescale(1:numEachColor);
%     colorCell = {};
%     for i = 1:numEachColor
%         eachColor = [0, blueArr(i), 1];
%         colorCell{end+1} = eachColor;
%         eachColor = [1, redArr(i), 0];
%         colorCell{end+1} = eachColor;
%     end
% end