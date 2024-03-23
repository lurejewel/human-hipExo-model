x1 = linspace(0,2,200);
x2 = linspace(0.8,1.7,200);
v  = linspace(-1.2,1.2,200);
x3 = linspace(0.99,1.05,200);

for i = 1 : 200
    F1(i) = calcFalDer(x1(i),0);
    F2(i) = calcFpeDer(x2(i),0);
    F3(i) = calcFvDer(v(i),0);
    F4(i) = calcFtDer(x3(i),0);
end
% set(gcf,'position',[100 50 500 300]);
figure, plot(x1, F1, 'k', 'LineWidth', 5); ylim([-0.2, 1.2]); box off
set(gcf,'position',[100 50 550 750]);
figure, plot(x2, F2, 'k', 'LineWidth', 5); ylim([-0.2, 1]); box off
set(gcf,'position',[100 50 550 750]);
figure, plot(v,  F3, 'k', 'LineWidth', 5); ylim([-0.2, 1.6]); box off
set(gcf,'position',[100 50 550 750]);
figure, plot(x3, F4, 'k', 'LineWidth', 5); ylim([-0.2, 1]); box off
set(gcf,'position',[100 50 550 750]);