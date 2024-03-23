function muscleLen = cal_musLen(in)

%% 已弃用

% in: 当前状态量   px    py    pq    hipR   kneeR  ankelR  hipL   kneeL  ankneeLeL
%                  1     2     3      4      5      6      7       8       9
%    dpx    dpy     dpq    dhipR   dkneeR  dankneeLeR  dhipL   dkneeL  dankneeLeL
%     10     11      12      13      14      15      16       17      18

px      = in(1);    py      = in(2);
pq      = in(3);    hipR    = in(4);
kneeR   = in(5);    ankleR  = in(6);
hipL    = in(7);    kneeL   = in(8);
ankleL  = in(9);

% 模型参数：尺寸(meters)
torsoLen = 46/100; % length of torso
phx = 7.07/100; % pelvis-hip x 反方向
phy = 6.61/100; % pelvis-hip y 反方向
hky = 39.6/100; % hip-knee y 反方向
kay = 43/100; % knee-ankneeLe y 反方向
acx = 4.877/100; % ankneeLe-calcn x
acy = 4.195/100; % ankneeLe-calcn y
htx = 17/100; % heel-toe x
ctx = 18.5/100; % calcn-toe x
cty = 1.5/100; % calcn-toe y
chx = 1.5/100; % calcn-heel x
chy = 1.5/100; % calcn-heel y

% left skeleton -> left muscle -> right skeleton -> right muscle
back1X = px - 0.1007*cos(pq) - 0.0815*sin(pq);
back1Y = py - 0.1007*sin(pq) + 0.0815*cos(pq);
back2X = px - 0.1007*cos(pq) - 0.5415*sin(pq);
back2Y = py - 0.1007*sin(pq) + 0.5415*cos(pq);

hipX = px + phy*sin(pq) - phx*cos(pq);
hipY = py - phy*cos(pq) - phx*sin(pq);

% ---------------------------- left ------------------------------ %
kneeLX = hipX + hky*sin(hipL+pq);
kneeLY = hipY - hky*cos(hipL+pq);

ankneeLeLX = kneeLX + kay*sin(hipL+pq+kneeL);
ankneeLeLY = kneeLY - kay*cos(hipL+pq+kneeL);

thetaL = pq + hipL + kneeL + ankleL;
calcnLX = ankneeLeLX + acy*sin(thetaL) - acx*cos(thetaL);
calcnLY = ankneeLeLY - acy*cos(thetaL) - acx*sin(thetaL);
heelLX = calcnLX + chx*cos(thetaL) - chy*sin(thetaL);
heelLY = calcnLY + chx*sin(thetaL) + chy*cos(thetaL);
toeLX = heelLX + htx*cos(thetaL);
toeLY = heelLY + htx*sin(thetaL);

gas1LX = hipX - 0.02*cos(pq+hipL) + 0.386*sin(pq+hipL);
gas1LY = hipY - 0.02*sin(pq+hipL) - 0.386*cos(pq+hipL);
gas2LX = calcnLX - 0.031 * sin(thetaL);
gas2LY = calcnLY + 0.031 * cos(thetaL);

ham1LX = px - 0.12596*cos(pq) + 0.10257*sin(pq);
ham1LY = py - 0.12596*sin(pq) - 0.10257*cos(pq);
ham2LX = kneeLX - 0.028*cos(pq+hipL+kneeL) + 0.02*sin(pq+hipL+kneeL);
ham2LY = kneeLY - 0.028*sin(pq+hipL+kneeL) - 0.02*cos(pq+hipL+kneeL);
ham3LX = kneeLX - 0.021*cos(pq+hipL+kneeL) + 0.04*sin(pq+hipL+kneeL);
ham3LY = kneeLY - 0.021*sin(pq+hipL+kneeL) - 0.04*cos(pq+hipL+kneeL);

glu1LX = px - 0.1349*cos(pq) - 0.0176*sin(pq);
glu1LY = py - 0.1349*sin(pq) + 0.0176*cos(pq);
glu2LX = px - 0.1376*cos(pq) + 0.052*sin(pq);
glu2LY = py - 0.1376*sin(pq) - 0.052*cos(pq);
glu3LX = hipX - 0.0426*cos(pq+hipL) + 0.053*sin(pq+hipL);
glu3LY = hipY - 0.0426*sin(pq+hipL) - 0.053*cos(pq+hipL);
glu4LX = hipX - 0.0156*cos(pq+hipL) + 0.1016*sin(pq+hipL);
glu4LY = hipY - 0.0156*sin(pq+hipL) - 0.1016*cos(pq+hipL);

ili1LX = px - 0.0647*cos(pq) - 0.0887*sin(pq);
ili1LY = py - 0.0647*sin(pq) + 0.0887*cos(pq);
ili2LX = px - 0.03*cos(pq) + 0.01*sin(pq);
ili2LY = py - 0.03*sin(pq) - 0.01*cos(pq);
ili3LX = hipX + 0.033*cos(pq+hipL) + 0.035*sin(pq+hipL);
ili3LY = hipY + 0.033*sin(pq+hipL) - 0.035*cos(pq+hipL);
ili4LX = hipX - 0.0188*cos(pq+hipL) + 0.0597*sin(pq+hipL);
ili4LY = hipY - 0.0188*sin(pq+hipL) - 0.0597*cos(pq+hipL);

vas1LX = hipX + 0.029*cos(pq+hipL) + 0.1924*sin(pq+hipL);
vas1LY = hipY + 0.029*sin(pq+hipL) - 0.1924*cos(pq+hipL);
vas2LX = hipX + 0.0335*cos(pq+hipL) + 0.2084*sin(pq+hipL);
vas2LY = hipY + 0.0335*sin(pq+hipL) - 0.2084*cos(pq+hipL);
vas3LX = kneeLX + 0.04*cos(pq+hipL+kneeL) - 0.025*sin(pq+hipL+kneeL);
vas3LY = kneeLY + 0.04*sin(pq+hipL+kneeL) + 0.025*cos(pq+hipL+kneeL);

sol1LX = kneeLX - 0.024*cos(pq+hipL+kneeL) + 0.1533*sin(pq+hipL+kneeL);
sol1LY = kneeLY - 0.024*sin(pq+hipL+kneeL) - 0.1533*cos(pq+hipL+kneeL);
sol2LX = calcnLX - 0.031 * sin(thetaL);
sol2LY = calcnLY + 0.031 * cos(thetaL);

tib1LX = kneeLX + 0.0179*cos(pq+hipL+kneeL) + 0.1624*sin(pq+hipL+kneeL);
tib1LY = kneeLY + 0.0179*sin(pq+hipL+kneeL) - 0.1624*cos(pq+hipL+kneeL);
tib2LX = kneeLX + 0.0329*cos(pq+hipL+kneeL) + 0.3951*sin(pq+hipL+kneeL);
tib2LY = kneeLY + 0.0329*sin(pq+hipL+kneeL) - 0.3951*cos(pq+hipL+kneeL);
tib3LX = calcnLX + 0.1166*cos(thetaL) - 0.0178*sin(thetaL);
tib3LY = calcnLY + 0.1166*sin(thetaL) + 0.0178*cos(thetaL);

% ---------------------------- right ----------------------------- %
kneeRX = hipX + hky*sin(hipR+pq);
kneeRY = hipY - hky*cos(hipR+pq);

ankneeLeRX = kneeRX + kay*sin(hipR+pq+kneeR);
ankneeLeRY = kneeRY - kay*cos(hipR+pq+kneeR);

thetaR = pq + hipR + kneeR + ankleR;
calcnRX = ankneeLeRX + acy*sin(thetaR) - acx*cos(thetaR);
calcnRY = ankneeLeRY - acy*cos(thetaR) - acx*sin(thetaR);
heelRX = calcnRX + chx*cos(thetaR) - chy*sin(thetaR);
heelRY = calcnRY + chx*sin(thetaR) + chy*cos(thetaR);
toeRX = heelRX + htx*cos(thetaR);
toeRY = heelRY + htx*sin(thetaR);

gas1RX = hipX - 0.02*cos(pq+hipR) + 0.386*sin(pq+hipR);
gas1RY = hipY - 0.02*sin(pq+hipR) - 0.386*cos(pq+hipR);
gas2RX = calcnRX - 0.031 * sin(thetaR);
gas2RY = calcnRY + 0.031 * cos(thetaR);

ham1RX = px - 0.12596*cos(pq) + 0.10257*sin(pq);
ham1RY = py - 0.12596*sin(pq) - 0.10257*cos(pq);
ham2RX = kneeRX - 0.028*cos(pq+hipR+kneeR) + 0.02*sin(pq+hipR+kneeR);
ham2RY = kneeRY - 0.028*sin(pq+hipR+kneeR) - 0.02*cos(pq+hipR+kneeR);
ham3RX = kneeRX - 0.021*cos(pq+hipR+kneeR) + 0.04*sin(pq+hipR+kneeR);
ham3RY = kneeRY - 0.021*sin(pq+hipR+kneeR) - 0.04*cos(pq+hipR+kneeR);

glu1RX = px - 0.1349*cos(pq) - 0.0176*sin(pq);
glu1RY = py - 0.1349*sin(pq) + 0.0176*cos(pq);
glu2RX = px - 0.1376*cos(pq) + 0.052*sin(pq);
glu2RY = py - 0.1376*sin(pq) - 0.052*cos(pq);
glu3RX = hipX - 0.0426*cos(pq+hipR) + 0.053*sin(pq+hipR);
glu3RY = hipY - 0.0426*sin(pq+hipR) - 0.053*cos(pq+hipR);
glu4RX = hipX - 0.0156*cos(pq+hipR) + 0.1016*sin(pq+hipR);
glu4RY = hipY - 0.0156*sin(pq+hipR) - 0.1016*cos(pq+hipR);

ili1RX = px - 0.0647*cos(pq) - 0.0887*sin(pq);
ili1RY = py - 0.0647*sin(pq) + 0.0887*cos(pq);
ili2RX = px - 0.03*cos(pq) + 0.01*sin(pq);
ili2RY = py - 0.03*sin(pq) - 0.01*cos(pq);
ili3RX = hipX + 0.033*cos(pq+hipR) + 0.035*sin(pq+hipR);
ili3RY = hipY + 0.033*sin(pq+hipR) - 0.035*cos(pq+hipR);
ili4RX = hipX - 0.0188*cos(pq+hipR) + 0.0597*sin(pq+hipR);
ili4RY = hipY - 0.0188*sin(pq+hipR) - 0.0597*cos(pq+hipR);

vas1RX = hipX + 0.029*cos(pq+hipR) + 0.1924*sin(pq+hipR);
vas1RY = hipY + 0.029*sin(pq+hipR) - 0.1924*cos(pq+hipR);
vas2RX = hipX + 0.0335*cos(pq+hipR) + 0.2084*sin(pq+hipR);
vas2RY = hipY + 0.0335*sin(pq+hipR) - 0.2084*cos(pq+hipR);
vas3RX = kneeRX + 0.04*cos(pq+hipR+kneeR) - 0.025*sin(pq+hipR+kneeR);
vas3RY = kneeRY + 0.04*sin(pq+hipR+kneeR) + 0.025*cos(pq+hipR+kneeR);

sol1RX = kneeRX - 0.024*cos(pq+hipR+kneeR) + 0.1533*sin(pq+hipR+kneeR);
sol1RY = kneeRY - 0.024*sin(pq+hipR+kneeR) - 0.1533*cos(pq+hipR+kneeR);
sol2RX = calcnRX - 0.031 * sin(thetaR);
sol2RY = calcnRY + 0.031 * cos(thetaR);

tib1RX = kneeRX + 0.0179*cos(pq+hipR+kneeR) + 0.1624*sin(pq+hipR+kneeR);
tib1RY = kneeRY + 0.0179*sin(pq+hipR+kneeR) - 0.1624*cos(pq+hipR+kneeR);
tib2RX = kneeRX + 0.0329*cos(pq+hipR+kneeR) + 0.3951*sin(pq+hipR+kneeR);
tib2RY = kneeRY + 0.0329*sin(pq+hipR+kneeR) - 0.3951*cos(pq+hipR+kneeR);
tib3RX = calcnRX + 0.1166*cos(thetaR) - 0.0178*sin(thetaR);
tib3RY = calcnRY + 0.1166*sin(thetaR) + 0.0178*cos(thetaR);


% ---------------------- length of muscle -------------------------
muscleLen.gasLenR = sqrt((gas1RX - gas2RX)^2 + (gas1RY - gas2RY)^2);
muscleLen.hamLenR = sqrt((ham1RX - ham2RX)^2 + (ham1RY - ham2RY)^2) + sqrt((ham2RX - ham3RX)^2 + (ham2RY - ham3RY)^2);
muscleLen.gluLenR = sqrt((glu1RX - glu2RX)^2 + (glu1RY - glu2RY)^2) + sqrt((glu2RX - glu3RX)^2 + (glu2RY - glu3RY)^2) + sqrt((glu3RX - glu4RX)^2 + (glu3RY - glu4RY)^2);
muscleLen.iliLenR = sqrt((ili1RX - ili2RX)^2 + (ili1RY - ili2RY)^2) + sqrt((ili2RX - ili3RX)^2 + (ili2RY - ili3RY)^2) + sqrt((ili3RX - ili4RX)^2 + (ili3RY - ili4RY)^2);
muscleLen.vasLenR = sqrt((vas1RX - vas2RX)^2 + (vas1RY - vas2RY)^2) + sqrt((vas2RX - vas3RX)^2 + (vas2RY - vas3RY)^2);
muscleLen.solLenR = sqrt((sol1RX - sol2RX)^2 + (sol1RY - sol2RY)^2);
muscleLen.tibLenR = sqrt((tib1RX - tib2RX)^2 + (tib1RY - tib2RY)^2) + sqrt((tib2RX - tib3RX)^2 + (tib2RY - tib3RY)^2);
muscleLen.gasLenL = sqrt((gas1LX - gas2LX)^2 + (gas1LY - gas2LY)^2);
muscleLen.hamLenL = sqrt((ham1LX - ham2LX)^2 + (ham1LY - ham2LY)^2) + sqrt((ham2LX - ham3LX)^2 + (ham2LY - ham3LY)^2);
muscleLen.gluLenL = sqrt((glu1LX - glu2LX)^2 + (glu1LY - glu2LY)^2) + sqrt((glu2LX - glu3LX)^2 + (glu2LY - glu3LY)^2) + sqrt((glu3LX - glu4LX)^2 + (glu3LY - glu4LY)^2);
muscleLen.iliLenL = sqrt((ili1LX - ili2LX)^2 + (ili1LY - ili2LY)^2) + sqrt((ili2LX - ili3LX)^2 + (ili2LY - ili3LY)^2) + sqrt((ili3LX - ili4LX)^2 + (ili3LY - ili4LY)^2);
muscleLen.vasLenL = sqrt((vas1LX - vas2LX)^2 + (vas1LY - vas2LY)^2) + sqrt((vas2LX - vas3LX)^2 + (vas2LY - vas3LY)^2);
muscleLen.solLenL = sqrt((sol1LX - sol2LX)^2 + (sol1LY - sol2LY)^2);
muscleLen.tibLenL = sqrt((tib1LX - tib2LX)^2 + (tib1LY - tib2LY)^2) + sqrt((tib2LX - tib3LX)^2 + (tib2LY - tib3LY)^2);


end