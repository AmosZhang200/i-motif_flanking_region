% function F1 = makeFigResidual(figI)
% %clf(figure(figI));
% F1 = figure(figI);
% % F1 = gcf;
% %F1.WindowStyle = 'Docked';
% F1.Position = [200 200 600 120];
% hold on
% set(gcf,'color','w')
% set(gca,'LineWidth',2,'FontSize',18,'XColor','k','YColor','k','FontName','Arial','FontWeight','bold')
% box on
% ax = gca;
% ax.Position = [0.15,0.15,0.8,0.8];
% % lgd = legend();
% % lgd.Position = [0.28, 0.75, 0.2, 0.1];
% end

function makeFigResidual(plotI)
% clear the figure content
%clf(figure(plotI))
% f is the figure handle
f = figure(plotI);
% set figure background color to be white
f.Color = [1,1,1];
f.Position = [200, 200, 600, 120];
a = gca;
a.LineWidth = 2;
a.FontSize = 20;
a.XColor = [0 0 0];
a.FontName = 'times';
a.FontWeight = 'bold';
a.Position = [0.15, 0.15, 0.8, 0.8];
hold on;
box on;
end