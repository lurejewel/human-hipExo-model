function animation_Assisted(t, out)

px      = out(:,1);
py      = out(:,2);
pq      = out(:,3);
hipR    = out(:,4);
kneeR   = out(:,5);
ankleR  = out(:,6);
hipL    = out(:,7);
kneeL   = out(:,8);
ankleL  = out(:,9);

% % 采用线性插值跟踪px py和pq和位置和速度
% for i = 1:length(t)
%     idx = fix(100*t(i))+1;
%     px(i) = (modelConfig.pelvisTrack.X(idx+1) - modelConfig.pelvisTrack.X(idx)) * (100*t(i)-idx+1) + modelConfig.pelvisTrack.X(idx);
%     py(i) = (modelConfig.pelvisTrack.Y(idx+1) - modelConfig.pelvisTrack.Y(idx)) * (100*t(i)-idx+1) + modelConfig.pelvisTrack.Y(idx);
%     pq(i) = (modelConfig.pelvisTrack.tilt(idx+1) - modelConfig.pelvisTrack.tilt(idx)) * (100*t(i)-idx+1) + modelConfig.pelvisTrack.tilt(idx);
% end

% 模型参数：尺寸(meters)
torsoLen = 46/100; % length of torso
phx = 7.07/100; % pelvis-hip x 反方向
phy = 6.61/100; % pelvis-hip y 反方向
hky = 39.6/100; % hip-knee y 反方向
kay = 43/100; % knee-ankle y 反方向
acx = 4.877/100; % ankle-calcn x
acy = 4.195/100; % ankle-calcn y
htx = 17/100; % heel-toe x
ctx = 18.5/100; % calcn-toe x
cty = 1.5/100; % calcn-toe y
chx = 1.5/100; % calcn-heel x
chy = 1.5/100; % calcn-heel y

%% 创建图窗
screenSize = get(0, 'ScreenSize');
width = screenSize(3) / 2.5;
left = 0;
bottom = screenSize(4) / 4;
height = screenSize(4) / 2;
fig = figure('Position', [left bottom width height], 'Color', 'w');

set(fig, 'DoubleBuffer', 'on');
set(gca, 'xlim', [-120, 120], 'ylim', [-120, 120], 'NextPlot', 'replace', 'Visible', 'off');
nextFrameTime = 0;
timescale = 0.1;
FramePerSec = 15;

mov = VideoWriter('直接施加力矩的肌骨动力学1');
mov.FrameRate = FramePerSec;
mov.Quality = 100;
open(mov);

%% 绘图

for i = 1 : length(t)
    if((t(i) >= nextFrameTime) || i == length(t))
        nextFrameTime = nextFrameTime + timescale / FramePerSec;
        hold off
        
        back1X = px(i) - 0.1007*cos(pq(i)) - 0.0815*sin(pq(i));
        back1Y = py(i) - 0.1007*sin(pq(i)) + 0.0815*cos(pq(i));
        back2X = px(i) - 0.1007*cos(pq(i)) - 0.5415*sin(pq(i));
        back2Y = py(i) - 0.1007*sin(pq(i)) + 0.5415*cos(pq(i));
        plot([back1X back2X], [back1Y back2Y], 'Color', [0.2 0.2 0.2], 'LineWidth', 3); hold on % torso
        
        hipX = px(i) + phy*sin(pq(i)) - phx*cos(pq(i));
        hipY = py(i) - phy*cos(pq(i)) - phx*sin(pq(i));
        
        % ---------------------------- left ------------------------------ %
        kneeLX = hipX + hky*sin(hipL(i)+pq(i));
        kneeLY = hipY - hky*cos(hipL(i)+pq(i));
        plot([hipX kneeLX], [hipY kneeLY], 'Color', [0.5,0.5,0.5], 'LineWidth', 3); hold on % left femur
        ankleLX = kneeLX + kay*sin(hipL(i)+pq(i)+kneeL(i));
        ankleLY = kneeLY - kay*cos(hipL(i)+pq(i)+kneeL(i));
        plot([kneeLX ankleLX], [kneeLY ankleLY], 'Color', [0.5,0.5,0.5], 'LineWidth', 3); hold on % left tibia
        thetaL = pq(i) + hipL(i) + kneeL(i) + ankleL(i);
        calcnLX = ankleLX + acy*sin(thetaL) - acx*cos(thetaL);
        calcnLY = ankleLY - acy*cos(thetaL) - acx*sin(thetaL);
        heelLX = calcnLX + chx*cos(thetaL) - chy*sin(thetaL);
        heelLY = calcnLY + chx*sin(thetaL) + chy*cos(thetaL);
        toeLX = heelLX + htx*cos(thetaL);
        toeLY = heelLY + htx*sin(thetaL);
        plot([heelLX toeLX], [heelLY toeLY], 'Color', [0.5,0.5,0.5], 'LineWidth', 3); hold on % left foot
        
        % ---------------------------- right ----------------------------- %
        kneeRX = hipX + hky*sin(hipR(i)+pq(i));
        kneeRY = hipY - hky*cos(hipR(i)+pq(i));
        plot([hipX kneeRX], [hipY kneeRY], 'Color', [0.2,0.2,0.2], 'LineWidth', 3); hold on % right femur
        ankleRX = kneeRX + kay*sin(hipR(i)+pq(i)+kneeR(i));
        ankleRY = kneeRY - kay*cos(hipR(i)+pq(i)+kneeR(i));
        plot([kneeRX ankleRX], [kneeRY ankleRY], 'Color', [0.2,0.2,0.2], 'LineWidth', 3); hold on % right tibia
        thetaR = pq(i) + hipR(i) + kneeR(i) + ankleR(i);
        calcnRX = ankleRX + acy*sin(thetaR) - acx*cos(thetaR);
        calcnRY = ankleRY - acy*cos(thetaR) - acx*sin(thetaR);
        heelRX = calcnRX + chx*cos(thetaR) - chy*sin(thetaR);
        heelRY = calcnRY + chx*sin(thetaR) + chy*cos(thetaR);
        toeRX = heelRX + htx*cos(thetaR);
        toeRY = heelRY + htx*sin(thetaR);
        plot([heelRX toeRX], [heelRY toeRY], 'Color', [0.2,0.2,0.2], 'LineWidth', 3); hold on % right foot        
        
        plot([-10 10], [0 0], 'LineWidth', 2); % 地平线
        axis equal
        xlim([-10 10]), ylim([-2.5 3.5]);
        drawnow;
        F = getframe(gcf);
        writeVideo(mov, F);

    end
end

end