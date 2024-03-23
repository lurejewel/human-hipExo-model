%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name: cal_GRF
% Function: 
% - calculate normal ground reaction force and friction force based on pose
% and motion of the skeleton model
% Author: Jin Wei
% Last Update: 2022/11/21
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Fgrf = cal_GRF(i, skeletonPose, modelConfig)

if i > 0
    px      = skeletonPose.pos.pelvisX(i);      dpx     = skeletonPose.vel.pelvisX(i);
    py      = skeletonPose.pos.pelvisY(i);      dpy     = skeletonPose.vel.pelvisY(i);
    pq      = skeletonPose.pos.pelvisTilt(i);   dpq     = skeletonPose.vel.pelvisTilt(i);
    hipR    = skeletonPose.pos.hipR(i);         dhipR   = skeletonPose.vel.hipR(i);
    kneeR   = skeletonPose.pos.kneeR(i);        dkneeR  = skeletonPose.vel.kneeR(i);
    ankleR  = skeletonPose.pos.ankleR(i);       dankleR = skeletonPose.vel.ankleR(i);
    hipL    = skeletonPose.pos.hipL(i);         dhipL   = skeletonPose.vel.hipL(i);
    kneeL   = skeletonPose.pos.kneeL(i);        dkneeL  = skeletonPose.vel.kneeL(i);
    ankleL  = skeletonPose.pos.ankleL(i);       dankleL = skeletonPose.vel.ankleL(i);
    
elseif i == 0 % called in 'cal_force.m'
    px      = skeletonPose.pos.pelvisX;         dpx     = skeletonPose.vel.pelvisX;
    py      = skeletonPose.pos.pelvisY;         dpy     = skeletonPose.vel.pelvisY;
    pq      = skeletonPose.pos.pelvisTilt;      dpq     = skeletonPose.vel.pelvisTilt;
    hipR    = skeletonPose.pos.hipR;            dhipR   = skeletonPose.vel.hipR;
    kneeR   = skeletonPose.pos.kneeR;           dkneeR  = skeletonPose.vel.kneeR;
    ankleR  = skeletonPose.pos.ankleR;          dankleR = skeletonPose.vel.ankleR;
    hipL    = skeletonPose.pos.hipL;            dhipL   = skeletonPose.vel.hipL;
    kneeL   = skeletonPose.pos.kneeL;           dkneeL  = skeletonPose.vel.kneeL;
    ankleL  = skeletonPose.pos.ankleL;          dankleL = skeletonPose.vel.ankleL;
    
else    
    error('loop number must be non-negative.')    
end

% 复合位置和速度
qhR     = pq + hipR;                        dqhR    = dpq + dhipR;
qhkR    = pq + hipR + kneeR;                dqhkR   = dpq + dhipR + dkneeR;
qhkaR   = pq + hipR + kneeR + ankleR;       dqhkaR  = dpq + dhipR + dkneeR + dankleR;
qhL     = pq + hipL;                        dqhL    = dpq + dhipL;
qhkL    = pq + hipL + kneeL;                dqhkL   = dpq + dhipL + dkneeL;
qhkaL   = pq + hipL + kneeL + ankleL;       dqhkaL  = dpq + dhipL + dkneeL + dankleL;

%% 脚跟脚尖位置

slope = modelConfig.slope; % 坡度的正切（deg = arctan(slope)；slope=0.1 → deg≈5.7106°）

heelXR = px + 0.0661*sin(pq) - 0.0707*cos(pq) + 0.396*sin(qhR) + 0.43*sin(qhkR) + 0.027*sin(qhkaR) - 0.0338*cos(qhkaR);
heelXL = px + 0.0661*sin(pq) - 0.0707*cos(pq) + 0.396*sin(qhL) + 0.43*sin(qhkL) + 0.027*sin(qhkaL) - 0.0338*cos(qhkaL);

heelYR = py - 0.0661*cos(pq) - 0.0707*sin(pq) - 0.396*cos(qhR) - 0.43*cos(qhkR) - 0.027*cos(qhkaR) - 0.0338*sin(qhkaR) - slope * heelXR;
heelYL = py - 0.0661*cos(pq) - 0.0707*sin(pq) - 0.396*cos(qhL) - 0.43*cos(qhkL) - 0.027*cos(qhkaL) - 0.0338*sin(qhkaL) - slope * heelXL;

toeXR = heelXR + 0.17*cos(qhkaR);
toeXL = heelXL + 0.17*cos(qhkaL);

toeYR = heelYR + 0.17*sin(qhkaR) - slope * (toeXR-heelXR);
toeYL = heelYL + 0.17*sin(qhkaL) - slope * (toeXL-heelXL);

%% 接触点接触深度 & 脚跟脚尖纵向速度

r = modelConfig.r; % 接触球半径

depthHeelR = max(r-heelYR, 0); % maxWithZero(1000*(r - heelYR))/1000;
depthHeelL = max(r-heelYL, 0); % maxWithZero(1000*(r - heelYL))/1000;
depthToeR  = max(r-toeYR, 0); % maxWithZero(1000*(r - toeYR))/1000;
depthToeL  = max(r-toeYL, 0); % maxWithZero(1000*(r - toeYL))/1000;

depthHeelVR = -(dpy - 0.0707*cos(pq)*dpq + 0.0661*sin(pq)*dpq + 0.396*sin(qhR)*dqhR + 0.43*sin(qhkR)*dqhkR - 0.0338*cos(qhkaR)*dqhkaR + 0.027*sin(qhkaR)*dqhkaR);
depthHeelVL = -(dpy - 0.0707*cos(pq)*dpq + 0.0661*sin(pq)*dpq + 0.396*sin(qhL)*dqhL + 0.43*sin(qhkL)*dqhkL - 0.0338*cos(qhkaL)*dqhkaL + 0.027*sin(qhkaL)*dqhkaL);
depthToeVR  = -(dpy - 0.0707*cos(pq)*dpq + 0.0661*sin(pq)*dpq + 0.396*sin(qhR)*dqhR + 0.43*sin(qhkR)*dqhkR + 0.1362*cos(qhkaR)*dqhkaR + 0.027*sin(qhkaR)*dqhkaR);
depthToeVL  = -(dpy - 0.0707*cos(pq)*dpq + 0.0661*sin(pq)*dpq + 0.396*sin(qhL)*dqhL + 0.43*sin(qhkL)*dqhkL + 0.1362*cos(qhkaL)*dqhkaL + 0.027*sin(qhkaL)*dqhkaL);

%% 正压力

k = 2e6/12.5; % stiffness
c = 10; % dissipation coefficient
n = 3/2;

% 正压力限幅：[0, threshFn]
Frhn = maxWithZero( k * depthHeelR^n * ( 1 + n * c * depthHeelVR ) ); % right heel, normal force
Frtn = maxWithZero( k * depthToeR^n * ( 1 + n * c * depthToeVR ) ); % right toe
Flhn = maxWithZero( k * depthHeelL^n * ( 1 + n * c * depthHeelVL ) ); % left heel
Fltn = maxWithZero( k * depthToeL^n * ( 1 + n * c * depthToeVL ) ); % left toe

% threshFn = 1.5 * modelConfig.g * modelConfig.boneMass.all; % 1096.4 N
% Frhn = minWithNum( Frhn, threshFn );
% Frtn = minWithNum( Frtn, threshFn );
% Flhn = minWithNum( Flhn, threshFn );
% Fltn = minWithNum( Fltn, threshFn );

%% 脚跟脚尖水平速度 & 接触点水平速度

acx = 4.877/100; % ankle-calcn x
acy = 4.195/100; % ankle-calcn y
ctx = 18.5/100; % calcn-toe x
chx = 1.5/100; % calcn-heel x
chy = 1.5/100; % calcn-heel y

% 右脚跟
distance = sqrt((acx - chx + heelYR*sin(qhkaR))^2 + (acy - chy + heelYR*cos(qhkaR))^2); % 踝关节到接触点的距离
tmp = atan2(acy - chy + heelYR*cos(qhkaR), acx - chx + heelYR*sin(qhkaR)) + qhkaR; % 踝关节到接触点连线与水平面的夹角
ankleVRX = dpx + 0.0661*cos(pq)*dpq + 0.0707*sin(pq)*dpq + 0.43*cos(qhkR)*dqhkR + 0.396*cos(qhR)*dqhR; % 踝关节水平速度
contactHeelVR = ankleVRX + (dankleR+dkneeR+dhipR+dpq) * distance * sin(tmp); % 脚跟接触点水平速度                                              改

% 左脚跟
distance = sqrt((acx - chx + heelYL*sin(qhkaL))^2 + (acy - chy + heelYL*cos(qhkaL))^2);
tmp = atan2(acy - chy + heelYL*cos(qhkaL), acx - chx + heelYL*sin(qhkaL)) + qhkaL;
ankleVLX = dpx + 0.0661*cos(pq)*dpq + 0.0707*sin(pq)*dpq + 0.43*cos(qhkL)*dqhkL + 0.396*cos(qhL)*dqhL;
contactHeelVL = ankleVLX + (dankleL+dkneeL+dhipL+dpq) * distance * sin(tmp);

% 右脚尖
distance = sqrt((ctx - acx - toeYR*sin(qhkaR))^2 + (acy - chy + toeYR*cos(qhkaR))^2);
tmp = atan2(acy - chy + toeYR*cos(qhkaR), ctx - acx - toeYR*sin(qhkaR)) - qhkaR;
contactToeVR = ankleVRX + (dankleR+dkneeR+dhipR+dpq) * distance * sin(tmp);

% 左脚尖
distance = sqrt((ctx - acx - toeYL*sin(qhkaL))^2 + (acy - chy + toeYL*cos(qhkaL))^2);
tmp = atan2(acy - chy + toeYL*cos(qhkaL), ctx - acx - toeYL*sin(qhkaL)) - qhkaL;
contactToeVL = ankleVLX + (dankleL+dkneeL+dhipL+dpq) * distance * sin(tmp);

%% 摩擦力

us = 0.9; % static friction
ud = 0.6; % dynamic friction
uv = 0.6; % viscous friction
vt = 0.15; % transition velocity threshold

Frhf = Frhn * ( minWithNum(1000*contactHeelVR/vt,1000)/1000 * (ud+2*(us-ud)./(1+(contactHeelVR/vt)^2)) + uv*contactHeelVR );
Frtf = Frtn * ( minWithNum(1000*contactToeVR/vt,1000)/1000 * (ud+2*(us-ud)./(1+(contactToeVR/vt)^2)) + uv*contactToeVR );
Flhf = Flhn * ( minWithNum(1000*contactHeelVL/vt,1000)/1000 * (ud+2*(us-ud)./(1+(contactHeelVL/vt)^2)) + uv*contactHeelVL);
Fltf = Fltn * ( minWithNum(1000*contactToeVL/vt,1000)/1000 * (ud+2*(us-ud)./(1+(contactToeVL/vt)^2)) + uv*contactToeVL );

% 摩擦力限幅 [-threshFf, threshFf]
threshFf = 200;
Frhf = maxWithZero( Frhf+threshFf ) - threshFf;
Frtf = maxWithZero( Frtf+threshFf ) - threshFf;
Flhf = maxWithZero( Flhf+threshFf ) - threshFf;
Fltf = maxWithZero( Fltf+threshFf ) - threshFf;
Frhf = minWithNum( Frhf, threshFf );
Frtf = minWithNum( Frtf, threshFf );
Flhf = minWithNum( Flhf, threshFf );
Fltf = minWithNum( Fltf, threshFf );

Fgrf = [-Frhf; -Frtf; -Flhf; -Fltf; Frhn; Frtn; Flhn; Fltn]; % 地反力（摩擦力 & 正压力）

end