%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Name: cal_muscleState
%
% Function: 根据tspan初始时刻的骨骼模型位置、速度，计算各肌肉长度和速度 calcu-
% late the muscle states (muscle length and velocity) according to the pose
% and velocity of the skeleton model at the start of tspan
%
% Parameter(s):
% - n: 循环数 number of cycles
% - skeletonPose: 存储骨骼模型的姿态和速度（可参考init_skeletonPose.m）store
% the skeleton model's pose and velocity
%
% Output(s):
% - muscleState: muscleState = [muscleLength muscleVelocity] 为各肌肉长度和
% 速度 the length and velocity of all 14 muscles calculated based on the
% skeletonPose
%
% Author: Wei Jin
%
% Last Update: 2022/11/12
%
% Log:
% #1 basic functions of calculating muscle states
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function muscleStateRecord = cal_muscleState(n, simT, skeletonPose, muscleStateRecord)

% assuming simT = 0.005, then skeletonPose.pos/vel.xx(n):
%   n      1       2        3      ...
% tStart   0      .005     .01     ...

% 只有新的步长开始后才调用一次 called only at the beginning of new simulation loop

%% 模型参数(m)
phx = 7.07/100; % pelvis-hip x 反方向
phy = 6.61/100; % pelvis-hip y 反方向
hky = 39.6/100; % hip-knee y 反方向
kay = 43/100; % knee-ankle y 反方向
acx = 4.877/100; % ankle-calcn x
acy = 4.195/100; % ankle-calcn y
 
%% 姿态和速度定义
px = skeletonPose.pos.pelvisX(n);
py = skeletonPose.pos.pelvisY(n);
pq = skeletonPose.pos.pelvisTilt(n);
hr = skeletonPose.pos.hipR(n);
hl = skeletonPose.pos.hipL(n);
kr = skeletonPose.pos.kneeR(n);
kl = skeletonPose.pos.kneeL(n);
ar = skeletonPose.pos.ankleR(n);
al = skeletonPose.pos.ankleL(n);

% 复合角度重定义
qhr     = pq + hr;
qhkr    = pq + hr + kr;
qhkar   = pq + hr + kr + ar;
qhl     = pq + hl;
qhkl    = pq + hl + kl;
qhkal   = pq + hl + kl + al;


%% 计算
hipX = px + phy*sin(pq) - phx*cos(pq);
hipY = py - phy*cos(pq) - phx*sin(pq);

% ---------------------------- left ------------------------------ %
kneeLX = hipX + hky*sin(hl+pq);
kneeLY = hipY - hky*cos(hl+pq);

ankleLX = kneeLX + kay*sin(hl+pq+kl);
ankleLY = kneeLY - kay*cos(hl+pq+kl);

calcnLX = ankleLX + acy*sin(qhkal) - acx*cos(qhkal);
calcnLY = ankleLY - acy*cos(qhkal) - acx*sin(qhkal);

gas1LX = hipX - 0.02*cos(qhl) + 0.386*sin(qhl);
gas1LY = hipY - 0.02*sin(qhl) - 0.386*cos(qhl);
gas2LX = calcnLX - 0.031 * sin(qhkal);
gas2LY = calcnLY + 0.031 * cos(qhkal);

ham1LX = px - 0.12596*cos(pq) + 0.10257*sin(pq);
ham1LY = py - 0.12596*sin(pq) - 0.10257*cos(pq);
ham2LX = kneeLX - 0.028*cos(qhkl) + 0.02*sin(qhkl);
ham2LY = kneeLY - 0.028*sin(qhkl) - 0.02*cos(qhkl);
ham3LX = kneeLX - 0.021*cos(qhkl) + 0.04*sin(qhkl);
ham3LY = kneeLY - 0.021*sin(qhkl) - 0.04*cos(qhkl);

glu1LX = px - 0.1349*cos(pq) - 0.0176*sin(pq);
glu1LY = py - 0.1349*sin(pq) + 0.0176*cos(pq);
glu2LX = px - 0.1376*cos(pq) + 0.052*sin(pq);
glu2LY = py - 0.1376*sin(pq) - 0.052*cos(pq);
glu3LX = hipX - 0.0426*cos(qhl) + 0.053*sin(qhl);
glu3LY = hipY - 0.0426*sin(qhl) - 0.053*cos(qhl);
glu4LX = hipX - 0.0156*cos(qhl) + 0.1016*sin(qhl);
glu4LY = hipY - 0.0156*sin(qhl) - 0.1016*cos(qhl);

ili1LX = px - 0.0647*cos(pq) - 0.0887*sin(pq);
ili1LY = py - 0.0647*sin(pq) + 0.0887*cos(pq);
ili2LX = px - 0.03*cos(pq) + 0.01*sin(pq);
ili2LY = py - 0.03*sin(pq) - 0.01*cos(pq);
ili3LX = hipX + 0.033*cos(qhl) + 0.035*sin(qhl);
ili3LY = hipY + 0.033*sin(qhl) - 0.035*cos(qhl);
ili4LX = hipX - 0.0188*cos(qhl) + 0.0597*sin(qhl);
ili4LY = hipY - 0.0188*sin(qhl) - 0.0597*cos(qhl);

vas1LX = hipX + 0.029*cos(qhl) + 0.1924*sin(qhl);
vas1LY = hipY + 0.029*sin(qhl) - 0.1924*cos(qhl);
vas2LX = hipX + 0.0335*cos(qhl) + 0.2084*sin(qhl);
vas2LY = hipY + 0.0335*sin(qhl) - 0.2084*cos(qhl);
vas3LX = kneeLX + 0.04*cos(qhkl) - 0.025*sin(qhkl);
vas3LY = kneeLY + 0.04*sin(qhkl) + 0.025*cos(qhkl);

sol1LX = kneeLX - 0.024*cos(qhkl) + 0.1533*sin(qhkl);
sol1LY = kneeLY - 0.024*sin(qhkl) - 0.1533*cos(qhkl);
sol2LX = calcnLX - 0.031 * sin(qhkal);
sol2LY = calcnLY + 0.031 * cos(qhkal);

tib1LX = kneeLX + 0.0179*cos(qhkl) + 0.1624*sin(qhkl);
tib1LY = kneeLY + 0.0179*sin(qhkl) - 0.1624*cos(qhkl);
tib2LX = kneeLX + 0.0329*cos(qhkl) + 0.3951*sin(qhkl);
tib2LY = kneeLY + 0.0329*sin(qhkl) - 0.3951*cos(qhkl);
tib3LX = calcnLX + 0.1166*cos(qhkal) - 0.0178*sin(qhkal);
tib3LY = calcnLY + 0.1166*sin(qhkal) + 0.0178*cos(qhkal);

% ---------------------------- right ----------------------------- %
kneeRX = hipX + hky*sin(hr+pq);
kneeRY = hipY - hky*cos(hr+pq);

ankleRX = kneeRX + kay*sin(hr+pq+kr);
ankleRY = kneeRY - kay*cos(hr+pq+kr);

calcnRX = ankleRX + acy*sin(qhkar) - acx*cos(qhkar);
calcnRY = ankleRY - acy*cos(qhkar) - acx*sin(qhkar);

gas1RX = hipX - 0.02*cos(qhr) + 0.386*sin(qhr);
gas1RY = hipY - 0.02*sin(qhr) - 0.386*cos(qhr);
gas2RX = calcnRX - 0.031 * sin(qhkar);
gas2RY = calcnRY + 0.031 * cos(qhkar);

ham1RX = px - 0.12596*cos(pq) + 0.10257*sin(pq);
ham1RY = py - 0.12596*sin(pq) - 0.10257*cos(pq);
ham2RX = kneeRX - 0.028*cos(qhkr) + 0.02*sin(qhkr);
ham2RY = kneeRY - 0.028*sin(qhkr) - 0.02*cos(qhkr);
ham3RX = kneeRX - 0.021*cos(qhkr) + 0.04*sin(qhkr);
ham3RY = kneeRY - 0.021*sin(qhkr) - 0.04*cos(qhkr);

glu1RX = px - 0.1349*cos(pq) - 0.0176*sin(pq);
glu1RY = py - 0.1349*sin(pq) + 0.0176*cos(pq);
glu2RX = px - 0.1376*cos(pq) + 0.052*sin(pq);
glu2RY = py - 0.1376*sin(pq) - 0.052*cos(pq);
glu3RX = hipX - 0.0426*cos(qhr) + 0.053*sin(qhr);
glu3RY = hipY - 0.0426*sin(qhr) - 0.053*cos(qhr);
glu4RX = hipX - 0.0156*cos(qhr) + 0.1016*sin(qhr);
glu4RY = hipY - 0.0156*sin(qhr) - 0.1016*cos(qhr);

ili1RX = px - 0.0647*cos(pq) - 0.0887*sin(pq);
ili1RY = py - 0.0647*sin(pq) + 0.0887*cos(pq);
ili2RX = px - 0.03*cos(pq) + 0.01*sin(pq);
ili2RY = py - 0.03*sin(pq) - 0.01*cos(pq);
ili3RX = hipX + 0.033*cos(qhr) + 0.035*sin(qhr);
ili3RY = hipY + 0.033*sin(qhr) - 0.035*cos(qhr);
ili4RX = hipX - 0.0188*cos(qhr) + 0.0597*sin(qhr);
ili4RY = hipY - 0.0188*sin(qhr) - 0.0597*cos(qhr);

vas1RX = hipX + 0.029*cos(qhr) + 0.1924*sin(qhr);
vas1RY = hipY + 0.029*sin(qhr) - 0.1924*cos(qhr);
vas2RX = hipX + 0.0335*cos(qhr) + 0.2084*sin(qhr);
vas2RY = hipY + 0.0335*sin(qhr) - 0.2084*cos(qhr);
vas3RX = kneeRX + 0.04*cos(qhkr) - 0.025*sin(qhkr);
vas3RY = kneeRY + 0.04*sin(qhkr) + 0.025*cos(qhkr);

sol1RX = kneeRX - 0.024*cos(qhkr) + 0.1533*sin(qhkr);
sol1RY = kneeRY - 0.024*sin(qhkr) - 0.1533*cos(qhkr);
sol2RX = calcnRX - 0.031 * sin(qhkar);
sol2RY = calcnRY + 0.031 * cos(qhkar);

tib1RX = kneeRX + 0.0179*cos(qhkr) + 0.1624*sin(qhkr);
tib1RY = kneeRY + 0.0179*sin(qhkr) - 0.1624*cos(qhkr);
tib2RX = kneeRX + 0.0329*cos(qhkr) + 0.3951*sin(qhkr);
tib2RY = kneeRY + 0.0329*sin(qhkr) - 0.3951*cos(qhkr);
tib3RX = calcnRX + 0.1166*cos(qhkar) - 0.0178*sin(qhkar);
tib3RY = calcnRY + 0.1166*sin(qhkar) + 0.0178*cos(qhkar);

% length of muscle
gasLenL = sqrt((gas1LX - gas2LX)^2 + (gas1LY - gas2LY)^2);
hamLenL = sqrt((ham1LX - ham2LX)^2 + (ham1LY - ham2LY)^2) + sqrt((ham2LX - ham3LX)^2 + (ham2LY - ham3LY)^2);
gluLenL = sqrt((glu1LX - glu2LX)^2 + (glu1LY - glu2LY)^2) + sqrt((glu2LX - glu3LX)^2 + (glu2LY - glu3LY)^2) + sqrt((glu3LX - glu4LX)^2 + (glu3LY - glu4LY)^2);
iliLenL = sqrt((ili1LX - ili2LX)^2 + (ili1LY - ili2LY)^2) + sqrt((ili2LX - ili3LX)^2 + (ili2LY - ili3LY)^2) + sqrt((ili3LX - ili4LX)^2 + (ili3LY - ili4LY)^2);
vasLenL = sqrt((vas1LX - vas2LX)^2 + (vas1LY - vas2LY)^2) + sqrt((vas2LX - vas3LX)^2 + (vas2LY - vas3LY)^2);
solLenL = sqrt((sol1LX - sol2LX)^2 + (sol1LY - sol2LY)^2);
tibLenL = sqrt((tib1LX - tib2LX)^2 + (tib1LY - tib2LY)^2) + sqrt((tib2LX - tib3LX)^2 + (tib2LY - tib3LY)^2);

gasLenR = sqrt((gas1RX - gas2RX)^2 + (gas1RY - gas2RY)^2);
hamLenR = sqrt((ham1RX - ham2RX)^2 + (ham1RY - ham2RY)^2) + sqrt((ham2RX - ham3RX)^2 + (ham2RY - ham3RY)^2);
gluLenR = sqrt((glu1RX - glu2RX)^2 + (glu1RY - glu2RY)^2) + sqrt((glu2RX - glu3RX)^2 + (glu2RY - glu3RY)^2) + sqrt((glu3RX - glu4RX)^2 + (glu3RY - glu4RY)^2);
iliLenR = sqrt((ili1RX - ili2RX)^2 + (ili1RY - ili2RY)^2) + sqrt((ili2RX - ili3RX)^2 + (ili2RY - ili3RY)^2) + sqrt((ili3RX - ili4RX)^2 + (ili3RY - ili4RY)^2);
vasLenR = sqrt((vas1RX - vas2RX)^2 + (vas1RY - vas2RY)^2) + sqrt((vas2RX - vas3RX)^2 + (vas2RY - vas3RY)^2);
solLenR = sqrt((sol1RX - sol2RX)^2 + (sol1RY - sol2RY)^2);
tibLenR = sqrt((tib1RX - tib2RX)^2 + (tib1RY - tib2RY)^2) + sqrt((tib2RX - tib3RX)^2 + (tib2RY - tib3RY)^2);

%% 赋值

% length
muscleStateRecord.len(1,n) = vasLenR;
muscleStateRecord.len(2,n) = hamLenR;
muscleStateRecord.len(3,n) = gluLenR;
muscleStateRecord.len(4,n) = iliLenR;
muscleStateRecord.len(5,n) = gasLenR;
muscleStateRecord.len(6,n) = solLenR;
muscleStateRecord.len(7,n) = tibLenR;
muscleStateRecord.len(8,n) = vasLenL;
muscleStateRecord.len(9,n) = hamLenL;
muscleStateRecord.len(10,n) = gluLenL;
muscleStateRecord.len(11,n) = iliLenL;
muscleStateRecord.len(12,n) = gasLenL;
muscleStateRecord.len(13,n) = solLenL;
muscleStateRecord.len(14,n) = tibLenL;
% velocity
if n > 1 % n = 1 时使用normalGait过来的初始值
    muscleStateRecord.vel(1,n) = (muscleStateRecord.len(1,n) - muscleStateRecord.len(1,n-1)) / simT;
    muscleStateRecord.vel(2,n) = (muscleStateRecord.len(2,n) - muscleStateRecord.len(2,n-1)) / simT;
    muscleStateRecord.vel(3,n) = (muscleStateRecord.len(3,n) - muscleStateRecord.len(3,n-1)) / simT;
    muscleStateRecord.vel(4,n) = (muscleStateRecord.len(4,n) - muscleStateRecord.len(4,n-1)) / simT;
    muscleStateRecord.vel(5,n) = (muscleStateRecord.len(5,n) - muscleStateRecord.len(5,n-1)) / simT;
    muscleStateRecord.vel(6,n) = (muscleStateRecord.len(6,n) - muscleStateRecord.len(6,n-1)) / simT;
    muscleStateRecord.vel(7,n) = (muscleStateRecord.len(7,n) - muscleStateRecord.len(7,n-1)) / simT;
    muscleStateRecord.vel(8,n) = (muscleStateRecord.len(8,n) - muscleStateRecord.len(8,n-1)) / simT;
    muscleStateRecord.vel(9,n) = (muscleStateRecord.len(9,n) - muscleStateRecord.len(9,n-1)) / simT;
    muscleStateRecord.vel(10,n) = (muscleStateRecord.len(10,n) - muscleStateRecord.len(10,n-1)) / simT;
    muscleStateRecord.vel(11,n) = (muscleStateRecord.len(11,n) - muscleStateRecord.len(11,n-1)) / simT;
    muscleStateRecord.vel(12,n) = (muscleStateRecord.len(12,n) - muscleStateRecord.len(12,n-1)) / simT;
    muscleStateRecord.vel(13,n) = (muscleStateRecord.len(13,n) - muscleStateRecord.len(13,n-1)) / simT;
    muscleStateRecord.vel(14,n) = (muscleStateRecord.len(14,n) - muscleStateRecord.len(14,n-1)) / simT;
end


end