function debug(simSpan, skeletonPose, torque, muscleRecord, simSlope)

% time
t = 0.005 : 0.005 : simSpan(end);

% skeleton pose
pose = skeletonPose.pos;
px   = pose.pelvisX(2:end);
py   = pose.pelvisY(2:end);
pq   = pose.pelvisTilt(2:end);
hr   = pose.hipR(2:end);
hl   = pose.hipL(2:end);
er   = pose.exoR(2:end);
el   = pose.exoL(2:end);
kr   = pose.kneeR(2:end);
kl   = pose.kneeL(2:end);
ar   = pose.ankleR(2:end);
al   = pose.ankleL(2:end);

%% curve of joint angle

% figure, subplot(5,2,1)
% plot(t, px), title('pelvis x displacement'), xlabel('t/s'), ylabel('m');
% subplot(5,2,2)
% plot(t, py), title('pelvis y displacement'), xlabel('t/s'), ylabel('m');
% subplot(5,2,3)
% plot(t, pq), title('pelvis tilt'), xlabel('t/s'), ylabel('m');
% subplot(5,2,5)
% plot(t, hr), title('right hip angle'), xlabel('t/s'), ylabel('rad'), ylim([-0.5,2]);
% subplot(5,2,6)
% plot(t, hl), title('left hip angle'), xlabel('t/s'), ylabel('rad'), ylim([-0.5,2]);
% subplot(5,2,7)
% plot(t, kr), title('right knee angle'), xlabel('t/s'), ylabel('rad'), ylim([-3,0]);
% subplot(5,2,8)
% plot(t, kl), title('left knee angle'), xlabel('t/s'), ylabel('rad'), ylim([-3,0]);
% subplot(5,2,9)
% plot(t, ar), title('right ankle angle'), xlabel('t/s'), ylabel('rad'), ylim([-1.5,1]);
% subplot(5,2,10)
% plot(t, al), title('left ankle angle'), xlabel('t/s'), ylabel('rad'), ylim([-1.5,1]);

%% gait phase

% gaitIndicatorR = zeros(1, length(skeletonPose.gaitPhaseR));
% gaitIndicatorL = gaitIndicatorR;
% for i = 2 : length(gaitIndicatorR)
%
%     % new gait cycle
%     if skeletonPose.gaitPhaseR(i-1) == 4 && skeletonPose.gaitPhaseR(i) == 0
%         gaitIndicatorR(i) = not(gaitIndicatorR(i-1));
%     else
%     % old gait cycle
%         gaitIndicatorR(i) = gaitIndicatorR(i-1);
%     end
%
%     if skeletonPose.gaitPhaseL(i-1) == 4 && skeletonPose.gaitPhaseL(i) == 0
%         gaitIndicatorL(i) = not(gaitIndicatorL(i-1));
%     else
%         gaitIndicatorL(i) = gaitIndicatorL(i-1);
%     end
%
% end

heelStrikeR = [];
for i = 2 : length(skeletonPose.gaitPhaseR)
    
    if skeletonPose.gaitPhaseR(i-1) == 4 && skeletonPose.gaitPhaseR(i) == 0
        heelStrikeR = [heelStrikeR, i];
    end
    
end

% gaitIndicatorR = gaitIndicatorR(2:end);
% gaitIndicatorL = gaitIndicatorL(2:end);
% subplot(5,2,4), plot(t, skeletonPose.gaitPhaseR(2:end));
% hold on, plot(t, skeletonPose.gaitPhaseL(2:end));
% legend('right','left');

%% curve of joint torque

% figure, subplot(3,2,1)
% plot(t, torque.hipR)
% title('right hip torque'), xlabel('t/s'), ylabel('Nm'), ylim([-150,120]);
% subplot(3,2,2)
% plot(t, torque.hipL)
% title('left hip torque'), xlabel('t/s'), ylabel('Nm'), ylim([-150,120]);
% subplot(3,2,3)
% plot(t, torque.kneeR)
% title('right knee torque'), xlabel('t/s'), ylabel('Nm'), ylim([-80,100]);
% subplot(3,2,4)
% plot(t, torque.kneeL)
% title('left knee torque'), xlabel('t/s'), ylabel('Nm'), ylim([-80,100]);
% subplot(3,2,5)
% plot(t, torque.ankleR)
% title('right ankle torque'), xlabel('t/s'), ylabel('Nm'), ylim([-120,50]);
% subplot(3,2,6)
% plot(t, torque.ankleL),
% title('left ankle torque'), xlabel('t/s'), ylabel('Nm'), ylim([-120,50]);

%% curve of muscle activation & excitation

% normalize activation according to right heel strike
cycles = length(heelStrikeR) - 1;
temp = zeros(cycles, 7, 1000);
for i = 1 : cycles
    
    cycleStart = heelStrikeR(i);
    cycleEnd = heelStrikeR(i+1);
    
    for j = 1 : 7
        F = griddedInterpolant(linspace(0,100,cycleEnd-cycleStart+1), muscleRecord(j).activationState(cycleStart:cycleEnd));
        temp(i,j,:) = F(linspace(0,100,1000));
    end
    
end


% normalized activation of right muscle
s = size(temp);
if s(1) ~= 1 % more than one gait cycle
    figure, subplot(2,4,1)
    plot(linspace(0,100,1000), reshape(mean(temp(:,1,:)), [1,1000]), 'LineWidth', 2);
    title('activation of vastus')
    grid on, ylim([0 1])
    subplot(2,4,2)
    plot(linspace(0,100,1000), reshape(mean(temp(:,2,:)), [1,1000]), 'LineWidth', 2);
    title('activation of hamstrings')
    grid on, ylim([0 0.5])
    subplot(2,4,3)
    plot(linspace(0,100,1000), reshape(mean(temp(:,3,:)), [1,1000]), 'LineWidth', 2);
    title('activation of gluteus maximus')
    grid on, ylim([0 1])
    subplot(2,4,4)
    plot(linspace(0,100,1000), reshape(mean(temp(:,4,:)), [1,1000]), 'LineWidth', 2);
    title('activation of iliopsoas')
    grid on, ylim([0 1])
    subplot(2,4,5)
    plot(linspace(0,100,1000), reshape(mean(temp(:,5,:)), [1,1000]), 'LineWidth', 2);
    title('activation of gastrocnemius')
    grid on, ylim([0 1])
    subplot(2,4,6)
    plot(linspace(0,100,1000), reshape(mean(temp(:,6,:)), [1,1000]), 'LineWidth', 2);
    title('activation of soleus')
    grid on, ylim([0 1])
    subplot(2,4,7)
    plot(linspace(0,100,1000), reshape(mean(temp(:,7,:)), [1,1000]), 'LineWidth', 2);
    title('activation of tibialis anterior')
    grid on, ylim([0 0.2])
end

% vastus
figure, subplot(7,2,1)
plot(t, muscleRecord(1).excitationState)
hold on, plot(t, muscleRecord(1).activationState)
% plot(t, gaitIndicatorR)
title('right vasti excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')
subplot(7,2,2)
plot(t, muscleRecord(8).excitationState)
hold on, plot(t, muscleRecord(8).activationState)
title('left vasti excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')

% hamsrtings
subplot(7,2,3)
plot(t, muscleRecord(2).excitationState)
hold on, plot(t, muscleRecord(2).activationState)
% plot(t, gaitIndicatorR)
title('right hamstrings excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')
subplot(7,2,4)
plot(t, muscleRecord(9).excitationState)
hold on, plot(t, muscleRecord(9).activationState)
title('left hamstrings excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')

% gluteus maximus
subplot(7,2,5)
plot(t, muscleRecord(3).excitationState)
hold on, plot(t, muscleRecord(3).activationState)
% plot(t, gaitIndicatorR)
title('right gluteus maximus excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')
subplot(7,2,6)
plot(t, muscleRecord(10).excitationState)
hold on, plot(t, muscleRecord(10).activationState)
title('left gluteus maximus excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')

% iliopsoas
subplot(7,2,7)
plot(t, muscleRecord(4).excitationState)
hold on, plot(t, muscleRecord(4).activationState)
% plot(t, gaitIndicatorR)
title('right iliopsoas excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')
subplot(7,2,8)
plot(t, muscleRecord(11).excitationState)
hold on, plot(t, muscleRecord(11).activationState)
title('left iliopsoas excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')

% gastrocneumius
subplot(7,2,9)
plot(t, muscleRecord(5).excitationState)
hold on, plot(t, muscleRecord(5).activationState)
% plot(t, gaitIndicatorR)
title('right gastrocnemius excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')
subplot(7,2,10)
plot(t, muscleRecord(12).excitationState)
hold on, plot(t, muscleRecord(12).activationState)
title('left gastrocnemius excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')

% soleus
subplot(7,2,11)
plot(t, muscleRecord(6).excitationState)
hold on, plot(t, muscleRecord(6).activationState)
% plot(t, gaitIndicatorR)
title('right soleus excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')
subplot(7,2,12)
plot(t, muscleRecord(13).excitationState)
hold on, plot(t, muscleRecord(13).activationState)
title('left soleus excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')

% tibalis anterior
subplot(7,2,13)
plot(t, muscleRecord(7).excitationState)
hold on, plot(t, muscleRecord(7).activationState)
% plot(t, gaitIndicatorR)
title('right tibialis anterior excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')
subplot(7,2,14)
plot(t, muscleRecord(14).excitationState)
hold on, plot(t, muscleRecord(14).activationState)
title('left tibialis anterior excitation & activation'), xlabel('t/s'), ylim([0 1]);
legend('excitation', 'activation')

%% animation

% torso para
phx = 7.07/100; % pelvis-hip x 反方向
phy = 6.61/100; % pelvis-hip y 反方向
hky = 39.6/100; % hip-knee y 反方向
kay = 43/100; % knee-ankle y 反方向
acx = 4.877/100; % ankle-calcn x
acy = 4.195/100; % ankle-calcn y
htx = 17/100; % heel-toe x
% ctx = 18.5/100; % calcn-toe x
% cty = 1.5/100; % calcn-toe y
chx = 1.5/100; % calcn-heel x
chy = 1.5/100; % calcn-heel y
exoy = 30/100; % exo length

% color para
Dirt = [139 115 85]/255; % 地平线
Light = [0.7 0.7 0.7]; % 左腿
Dark = [0.3 0.3 0.3]; % 右腿 & 躯干
DeepRed = [178 34 34]/255; % 右腿肌肉
LightRed = [255 193 193]/255; % 左腿肌肉
Gold = [255 215 0]/255; % 右腿外骨骼
LightGold = [238 221 130]/255; % 左腿外骨骼

% create figure
screenSize = get(0, 'ScreenSize');
width = screenSize(3) * 0.8;
left = screenSize(3) * 0.1;
bottom = screenSize(4) * 0.1;
height = screenSize(4) * 0.8;
fig = figure('Position', [left bottom width height], 'Color', 'w');
set(fig, 'DoubleBuffer', 'on');
set(gca, 'xlim', [-120, 120], 'ylim', [-120, 120], 'NextPlot', 'replace', 'Visible', 'off');
nextFrameTime = 0;
timescale = 0.2;
FramePerSec = 30; % 15帧

mov = VideoWriter('20230210人+外骨骼仿真分析[无助力]');
mov.FrameRate = FramePerSec;
mov.Quality = 100;
open(mov);

% video
for i = 1 : length(t)
    
    if px(i) == -1
        break;
    end
    
    if((t(i) >= nextFrameTime) || i == length(t))
        nextFrameTime = nextFrameTime + timescale / FramePerSec;
        hold off
        
        % left skeleton -> left muscle -> right skeleton -> right muscle
        back1X = px(i) - 0.1007*cos(pq(i)) - 0.0815*sin(pq(i));
        back1Y = py(i) - 0.1007*sin(pq(i)) + 0.0815*cos(pq(i));
        back2X = px(i) - 0.1007*cos(pq(i)) - 0.5415*sin(pq(i));
        back2Y = py(i) - 0.1007*sin(pq(i)) + 0.5415*cos(pq(i));
        plot([back1X back2X], [back1Y back2Y], 'Color', Dark, 'LineWidth', 3); hold on % torso
        
        hipX = px(i) + phy*sin(pq(i)) - phx*cos(pq(i));
        hipY = py(i) - phy*cos(pq(i)) - phx*sin(pq(i));
        
        % ---------------------------- left ------------------------------ %
        exoLX = hipX + exoy*sin(hl(i)+pq(i)+el(i));
        exoLY = hipY - exoy*cos(hl(i)+pq(i)+el(i));
        plot([hipX exoLX], [hipY exoLY], 'Color', LightGold, 'LineWidth', 2), hold on % left exoskeleton
        kneeLX = hipX + hky*sin(hl(i)+pq(i));
        kneeLY = hipY - hky*cos(hl(i)+pq(i));
        plot([hipX kneeLX], [hipY kneeLY], 'Color', Light, 'LineWidth', 3); hold on % left femur
        ankleLX = kneeLX + kay*sin(hl(i)+pq(i)+kl(i));
        ankleLY = kneeLY - kay*cos(hl(i)+pq(i)+kl(i));
        plot([kneeLX ankleLX], [kneeLY ankleLY], 'Color', Light, 'LineWidth', 3); hold on % left tibia
        thetaL = pq(i) + hl(i) + kl(i) + al(i);
        calcnLX = ankleLX + acy*sin(thetaL) - acx*cos(thetaL);
        calcnLY = ankleLY - acy*cos(thetaL) - acx*sin(thetaL);
        heelLX = calcnLX + chx*cos(thetaL) - chy*sin(thetaL);
        heelLY = calcnLY + chx*sin(thetaL) + chy*cos(thetaL);
        toeLX = heelLX + htx*cos(thetaL);
        toeLY = heelLY + htx*sin(thetaL);
        plot([heelLX toeLX], [heelLY toeLY], 'Color', Light, 'LineWidth', 3); hold on % left foot
        
        gas1LX = hipX - 0.02*cos(pq(i)+hl(i)) + 0.386*sin(pq(i)+hl(i));
        gas1LY = hipY - 0.02*sin(pq(i)+hl(i)) - 0.386*cos(pq(i)+hl(i));
        gas2LX = calcnLX - 0.031 * sin(thetaL);
        gas2LY = calcnLY + 0.031 * cos(thetaL);
        plot([gas1LX gas2LX], [gas1LY gas2LY], 'Color', LightRed, 'LineWidth', 1.5); hold on; % left gastrocneus
        ham1LX = px(i) - 0.12596*cos(pq(i)) + 0.10257*sin(pq(i));
        ham1LY = py(i) - 0.12596*sin(pq(i)) - 0.10257*cos(pq(i));
        ham2LX = kneeLX - 0.028*cos(pq(i)+hl(i)+kl(i)) + 0.02*sin(pq(i)+hl(i)+kl(i));
        ham2LY = kneeLY - 0.028*sin(pq(i)+hl(i)+kl(i)) - 0.02*cos(pq(i)+hl(i)+kl(i));
        ham3LX = kneeLX - 0.021*cos(pq(i)+hl(i)+kl(i)) + 0.04*sin(pq(i)+hl(i)+kl(i));
        ham3LY = kneeLY - 0.021*sin(pq(i)+hl(i)+kl(i)) - 0.04*cos(pq(i)+hl(i)+kl(i));
        plot([ham1LX ham2LX ham3LX], [ham1LY ham2LY ham3LY], 'Color', LightRed, 'LineWidth', 1.5); hold on; % left hamstring
        glu1LX = px(i) - 0.1349*cos(pq(i)) - 0.0176*sin(pq(i));
        glu1LY = py(i) - 0.1349*sin(pq(i)) + 0.0176*cos(pq(i));
        glu2LX = px(i) - 0.1376*cos(pq(i)) + 0.052*sin(pq(i));
        glu2LY = py(i) - 0.1376*sin(pq(i)) - 0.052*cos(pq(i));
        glu3LX = hipX - 0.0426*cos(pq(i)+hl(i)) + 0.053*sin(pq(i)+hl(i));
        glu3LY = hipY - 0.0426*sin(pq(i)+hl(i)) - 0.053*cos(pq(i)+hl(i));
        glu4LX = hipX - 0.0156*cos(pq(i)+hl(i)) + 0.1016*sin(pq(i)+hl(i));
        glu4LY = hipY - 0.0156*sin(pq(i)+hl(i)) - 0.1016*cos(pq(i)+hl(i));
        plot([glu1LX glu2LX glu3LX glu4LX], [glu1LY glu2LY glu3LY glu4LY], 'Color', LightRed, 'LineWidth', 1.5); hold on; % left gluteus maximus
        ili1LX = px(i) - 0.0647*cos(pq(i)) - 0.0887*sin(pq(i));
        ili1LY = py(i) - 0.0647*sin(pq(i)) + 0.0887*cos(pq(i));
        ili2LX = px(i) - 0.03*cos(pq(i)) + 0.01*sin(pq(i));
        ili2LY = py(i) - 0.03*sin(pq(i)) - 0.01*cos(pq(i));
        ili3LX = hipX + 0.033*cos(pq(i)+hl(i)) + 0.035*sin(pq(i)+hl(i));
        ili3LY = hipY + 0.033*sin(pq(i)+hl(i)) - 0.035*cos(pq(i)+hl(i));
        ili4LX = hipX - 0.0188*cos(pq(i)+hl(i)) + 0.0597*sin(pq(i)+hl(i));
        ili4LY = hipY - 0.0188*sin(pq(i)+hl(i)) - 0.0597*cos(pq(i)+hl(i));
        plot([ili1LX ili2LX ili3LX ili4LX], [ili1LY ili2LY ili3LY ili4LY], 'Color', LightRed, 'LineWidth', 1.5); hold on; % left iliopsoas
        vas1LX = hipX + 0.029*cos(pq(i)+hl(i)) + 0.1924*sin(pq(i)+hl(i));
        vas1LY = hipY + 0.029*sin(pq(i)+hl(i)) - 0.1924*cos(pq(i)+hl(i));
        vas2LX = hipX + 0.0335*cos(pq(i)+hl(i)) + 0.2084*sin(pq(i)+hl(i));
        vas2LY = hipY + 0.0335*sin(pq(i)+hl(i)) - 0.2084*cos(pq(i)+hl(i));
        vas3LX = kneeLX + 0.04*cos(pq(i)+hl(i)+kl(i)) - 0.025*sin(pq(i)+hl(i)+kl(i));
        vas3LY = kneeLY + 0.04*sin(pq(i)+hl(i)+kl(i)) + 0.025*cos(pq(i)+hl(i)+kl(i));
        plot([vas1LX vas2LX vas3LX], [vas1LY vas2LY vas3LY], 'Color', LightRed, 'LineWidth', 1.5); hold on; % left vasti
        sol1LX = kneeLX - 0.024*cos(pq(i)+hl(i)+kl(i)) + 0.1533*sin(pq(i)+hl(i)+kl(i));
        sol1LY = kneeLY - 0.024*sin(pq(i)+hl(i)+kl(i)) - 0.1533*cos(pq(i)+hl(i)+kl(i));
        sol2LX = calcnLX - 0.031 * sin(thetaL);
        sol2LY = calcnLY + 0.031 * cos(thetaL);
        plot([sol1LX sol2LX], [sol1LY sol2LY], 'Color', LightRed, 'LineWidth', 1.5); hold on; % left soleus
        tib1LX = kneeLX + 0.0179*cos(pq(i)+hl(i)+kl(i)) + 0.1624*sin(pq(i)+hl(i)+kl(i));
        tib1LY = kneeLY + 0.0179*sin(pq(i)+hl(i)+kl(i)) - 0.1624*cos(pq(i)+hl(i)+kl(i));
        tib2LX = kneeLX + 0.0329*cos(pq(i)+hl(i)+kl(i)) + 0.3951*sin(pq(i)+hl(i)+kl(i));
        tib2LY = kneeLY + 0.0329*sin(pq(i)+hl(i)+kl(i)) - 0.3951*cos(pq(i)+hl(i)+kl(i));
        tib3LX = calcnLX + 0.1166*cos(thetaL) - 0.0178*sin(thetaL);
        tib3LY = calcnLY + 0.1166*sin(thetaL) + 0.0178*cos(thetaL);
        plot([tib1LX tib2LX tib3LX], [tib1LY tib2LY tib3LY], 'Color', LightRed, 'LineWidth', 1.5); hold on; % left tibialis anterior
        
        % ---------------------------- right ----------------------------- %
        kneeRX = hipX + hky*sin(hr(i)+pq(i));
        kneeRY = hipY - hky*cos(hr(i)+pq(i));
        plot([hipX kneeRX], [hipY kneeRY], 'Color', Dark, 'LineWidth', 3); hold on % right femur
        ankleRX = kneeRX + kay*sin(hr(i)+pq(i)+kr(i));
        ankleRY = kneeRY - kay*cos(hr(i)+pq(i)+kr(i));
        plot([kneeRX ankleRX], [kneeRY ankleRY], 'Color', Dark, 'LineWidth', 3); hold on % right tibia
        thetaR = pq(i) + hr(i) + kr(i) + ar(i);
        calcnRX = ankleRX + acy*sin(thetaR) - acx*cos(thetaR);
        calcnRY = ankleRY - acy*cos(thetaR) - acx*sin(thetaR);
        heelRX = calcnRX + chx*cos(thetaR) - chy*sin(thetaR);
        heelRY = calcnRY + chx*sin(thetaR) + chy*cos(thetaR);
        toeRX = heelRX + htx*cos(thetaR);
        toeRY = heelRY + htx*sin(thetaR);
        plot([heelRX toeRX], [heelRY toeRY], 'Color', Dark, 'LineWidth', 3); hold on % right foot
        
        gas1RX = hipX - 0.02*cos(pq(i)+hr(i)) + 0.386*sin(pq(i)+hr(i));
        gas1RY = hipY - 0.02*sin(pq(i)+hr(i)) - 0.386*cos(pq(i)+hr(i));
        gas2RX = calcnRX - 0.031 * sin(thetaR);
        gas2RY = calcnRY + 0.031 * cos(thetaR);
        plot([gas1RX gas2RX], [gas1RY gas2RY], 'Color', DeepRed, 'LineWidth', 1.5); hold on; % right gastrocneus
        ham1RX = px(i) - 0.12596*cos(pq(i)) + 0.10257*sin(pq(i));
        ham1RY = py(i) - 0.12596*sin(pq(i)) - 0.10257*cos(pq(i));
        ham2RX = kneeRX - 0.028*cos(pq(i)+hr(i)+kr(i)) + 0.02*sin(pq(i)+hr(i)+kr(i));
        ham2RY = kneeRY - 0.028*sin(pq(i)+hr(i)+kr(i)) - 0.02*cos(pq(i)+hr(i)+kr(i));
        ham3RX = kneeRX - 0.021*cos(pq(i)+hr(i)+kr(i)) + 0.04*sin(pq(i)+hr(i)+kr(i));
        ham3RY = kneeRY - 0.021*sin(pq(i)+hr(i)+kr(i)) - 0.04*cos(pq(i)+hr(i)+kr(i));
        plot([ham1RX ham2RX ham3RX], [ham1RY ham2RY ham3RY], 'Color', DeepRed, 'LineWidth', 1.5); hold on; % right hamstring
        glu1RX = px(i) - 0.1349*cos(pq(i)) - 0.0176*sin(pq(i));
        glu1RY = py(i) - 0.1349*sin(pq(i)) + 0.0176*cos(pq(i));
        glu2RX = px(i) - 0.1376*cos(pq(i)) + 0.052*sin(pq(i));
        glu2RY = py(i) - 0.1376*sin(pq(i)) - 0.052*cos(pq(i));
        glu3RX = hipX - 0.0426*cos(pq(i)+hr(i)) + 0.053*sin(pq(i)+hr(i));
        glu3RY = hipY - 0.0426*sin(pq(i)+hr(i)) - 0.053*cos(pq(i)+hr(i));
        glu4RX = hipX - 0.0156*cos(pq(i)+hr(i)) + 0.1016*sin(pq(i)+hr(i));
        glu4RY = hipY - 0.0156*sin(pq(i)+hr(i)) - 0.1016*cos(pq(i)+hr(i));
        plot([glu1RX glu2RX glu3RX glu4RX], [glu1RY glu2RY glu3RY glu4RY], 'Color', DeepRed, 'LineWidth', 1.5); hold on; % right gluteus maximus
        ili1RX = px(i) - 0.0647*cos(pq(i)) - 0.0887*sin(pq(i));
        ili1RY = py(i) - 0.0647*sin(pq(i)) + 0.0887*cos(pq(i));
        ili2RX = px(i) - 0.03*cos(pq(i)) + 0.01*sin(pq(i));
        ili2RY = py(i) - 0.03*sin(pq(i)) - 0.01*cos(pq(i));
        ili3RX = hipX + 0.033*cos(pq(i)+hr(i)) + 0.035*sin(pq(i)+hr(i));
        ili3RY = hipY + 0.033*sin(pq(i)+hr(i)) - 0.035*cos(pq(i)+hr(i));
        ili4RX = hipX - 0.0188*cos(pq(i)+hr(i)) + 0.0597*sin(pq(i)+hr(i));
        ili4RY = hipY - 0.0188*sin(pq(i)+hr(i)) - 0.0597*cos(pq(i)+hr(i));
        plot([ili1RX ili2RX ili3RX ili4RX], [ili1RY ili2RY ili3RY ili4RY], 'Color', DeepRed, 'LineWidth', 1.5); hold on; % right iliopsoas
        vas1RX = hipX + 0.029*cos(pq(i)+hr(i)) + 0.1924*sin(pq(i)+hr(i));
        vas1RY = hipY + 0.029*sin(pq(i)+hr(i)) - 0.1924*cos(pq(i)+hr(i));
        vas2RX = hipX + 0.0335*cos(pq(i)+hr(i)) + 0.2084*sin(pq(i)+hr(i));
        vas2RY = hipY + 0.0335*sin(pq(i)+hr(i)) - 0.2084*cos(pq(i)+hr(i));
        vas3RX = kneeRX + 0.04*cos(pq(i)+hr(i)+kr(i)) - 0.025*sin(pq(i)+hr(i)+kr(i));
        vas3RY = kneeRY + 0.04*sin(pq(i)+hr(i)+kr(i)) + 0.025*cos(pq(i)+hr(i)+kr(i));
        plot([vas1RX vas2RX vas3RX], [vas1RY vas2RY vas3RY], 'Color', DeepRed, 'LineWidth', 1.5); hold on; % right vasti
        sol1RX = kneeRX - 0.024*cos(pq(i)+hr(i)+kr(i)) + 0.1533*sin(pq(i)+hr(i)+kr(i));
        sol1RY = kneeRY - 0.024*sin(pq(i)+hr(i)+kr(i)) - 0.1533*cos(pq(i)+hr(i)+kr(i));
        sol2RX = calcnRX - 0.031 * sin(thetaR);
        sol2RY = calcnRY + 0.031 * cos(thetaR);
        plot([sol1RX sol2RX], [sol1RY sol2RY], 'Color', DeepRed, 'LineWidth', 1.5); hold on; % right soleus
        tib1RX = kneeRX + 0.0179*cos(pq(i)+hr(i)+kr(i)) + 0.1624*sin(pq(i)+hr(i)+kr(i));
        tib1RY = kneeRY + 0.0179*sin(pq(i)+hr(i)+kr(i)) - 0.1624*cos(pq(i)+hr(i)+kr(i));
        tib2RX = kneeRX + 0.0329*cos(pq(i)+hr(i)+kr(i)) + 0.3951*sin(pq(i)+hr(i)+kr(i));
        tib2RY = kneeRY + 0.0329*sin(pq(i)+hr(i)+kr(i)) - 0.3951*cos(pq(i)+hr(i)+kr(i));
        tib3RX = calcnRX + 0.1166*cos(thetaR) - 0.0178*sin(thetaR);
        tib3RY = calcnRY + 0.1166*sin(thetaR) + 0.0178*cos(thetaR);
        plot([tib1RX tib2RX tib3RX], [tib1RY tib2RY tib3RY], 'Color', DeepRed, 'LineWidth', 1.5); hold on; % right tibialis anterior
        exoRX = hipX + exoy*sin(hr(i)+pq(i)+er(i));
        exoRY = hipY - exoy*cos(hr(i)+pq(i)+er(i));
        plot([hipX exoRX], [hipY exoRY], 'Color', Gold, 'LineWidth', 2), hold on % right exoskeleton
        
        % horizon
        plot([-1 13], [-(px(1)+1)*simSlope (13-px(1))*simSlope], 'LineWidth', 2, 'Color', Dirt);
        
        axis equal
        xlim([-1 13]), ylim([-1 2]);
        drawnow;
        F = getframe(gcf);
        writeVideo(mov, F);
        
    end
end

end