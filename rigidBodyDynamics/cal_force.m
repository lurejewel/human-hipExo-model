function [Fgrf, Tau] = cal_force(~, in, modelConfig, jointTorque, exoTorque)
% Fgrf = [-Frhf; -Frtf; -Flhf; -Fltf; Frhn; Frtn; Flhn; Fltn] 地反力
% τ = [0; 0; 0; 
%       τHipR+τinterR; τKneeR; τAnkleR; τExoR-τinterR; 
%       τHipL+τinterL; τKneeL; τAnkleL; τExoL-τinterL]：关节力矩+外骨骼力矩+交互力
% t: 当前计算时刻的时间
% in: 当前状态量   px    py    pq    hipR    kneeR   ankleR   exoR   hipL   kneeL   ankleL   exoL
%                  1     2     3      4       5        6       7      8      9       10      11
%                 dpx   dpy   dpq   dhipR   dkneeR  dankleR  dexoR  dhipL  dkneeL  dankleL  dexoL
%                  12    13    14     15      16      17      18      19     20      21      22

%% 转换为模型姿态
if ~isreal(in)
    in = real(in); % 出于未知原因 会算出复数
end
skeletonPose.pos.pelvisX     = in(1);   skeletonPose.vel.pelvisX    = in(12);
skeletonPose.pos.pelvisY     = in(2);   skeletonPose.vel.pelvisY    = in(13);
skeletonPose.pos.pelvisTilt  = in(3);   skeletonPose.vel.pelvisTilt = in(14);
skeletonPose.pos.hipR        = in(4);   skeletonPose.vel.hipR       = in(15);
skeletonPose.pos.kneeR       = in(5);   skeletonPose.vel.kneeR      = in(16);
skeletonPose.pos.ankleR      = in(6);   skeletonPose.vel.ankleR     = in(17);
skeletonPose.pos.exoR        = in(7);   skeletonPose.vel.exoR       = in(18);
skeletonPose.pos.hipL        = in(8);   skeletonPose.vel.hipL       = in(19);
skeletonPose.pos.kneeL       = in(9);   skeletonPose.vel.kneeL      = in(20);
skeletonPose.pos.ankleL      = in(10);  skeletonPose.vel.ankleL     = in(21);
skeletonPose.pos.exoL        = in(11);  skeletonPose.vel.exoL       = in(22);

%% 地反力

Fgrf = cal_GRF(0, skeletonPose, modelConfig);

%% 交互力

[tauInterR, tauInterL] = cal_inter(skeletonPose, modelConfig);

%% 关节 & 外骨骼驱动力

tauHipR   = jointTorque.hipR;
tauKneeR  = jointTorque.kneeR;
tauAnkleR = jointTorque.ankleR;
tauHipL   = jointTorque.hipL;
tauKneeL  = jointTorque.kneeL;
tauAnkleL = jointTorque.ankleL;
tauExoR   = -exoTorque.exoR;
tauExoL   = -exoTorque.exoL;

%% 约束力
% 膝关节
Kup = modelConfig.LimitForce.knee.Kup;
Klo = modelConfig.LimitForce.knee.Klo;
Lup = modelConfig.LimitForce.knee.Lup;
Llo = modelConfig.LimitForce.knee.Llo;
Damp = modelConfig.LimitForce.knee.d;
Th = modelConfig.LimitForce.knee.th;
% 右
kneeR = rad2deg(skeletonPose.pos.kneeR);
dkneeR = rad2deg(skeletonPose.vel.kneeR);
Kup_ = Kup * ( atan(5e2*(kneeR-Lup))/pi + 0.5 );
Klo_ = Klo * (-atan(5e2*(kneeR-Llo))/pi + 0.5 );
Fup = Kup_ * (Lup - kneeR);
Flo = Klo_ * (Llo - kneeR);
Fd  = -Damp * (Kup_/Kup + Klo_/Klo) * dkneeR;
tauLimitKneeR = Fup + Flo + Fd;
tauLimitKneeR = minWithNum(tauLimitKneeR, Th); % 限幅
% 左
kneeL = rad2deg(skeletonPose.pos.kneeL);
dkneeL = rad2deg(skeletonPose.vel.kneeL);
Kup_ = Kup * ( atan(5e2*(kneeL-Lup))/pi + 0.5 );
Klo_ = Klo * (-atan(5e2*(kneeL-Llo))/pi + 0.5 );
Fup = Kup_ * (Lup - kneeL);
Flo = Klo_ * (Llo - kneeL);
Fd  = -Damp * (Kup_/Kup + Klo_/Klo) * dkneeL;
tauLimitKneeL = Fup + Flo + Fd;
tauLimitKneeL = minWithNum(tauLimitKneeL, Th); % 限幅

tauKneeR = tauKneeR + tauLimitKneeR;
tauKneeL = tauKneeL + tauLimitKneeL;

% 踝关节
Kup = modelConfig.LimitForce.ankle.Kup;
Klo = modelConfig.LimitForce.ankle.Klo;
Lup = modelConfig.LimitForce.ankle.Lup;
Llo = modelConfig.LimitForce.ankle.Llo;
Damp = modelConfig.LimitForce.ankle.d;
Th = modelConfig.LimitForce.ankle.th;
% 右
ankleR = rad2deg(skeletonPose.pos.ankleR);
dankleR = rad2deg(skeletonPose.vel.ankleR);
Kup_ = Kup * ( atan(5e2*(ankleR-Lup))/pi + 0.5 );
Klo_ = Klo * (-atan(5e2*(ankleR-Llo))/pi + 0.5 );
Fup = Kup_ * (Lup - ankleR);
Flo = Klo_ * (Llo - ankleR);
Fd  = -Damp * (Kup_/Kup + Klo_/Klo) * dankleR;
tauLimitAnkleR = Fup + Flo + Fd;
tauLimitAnkleR = minWithNum(tauLimitAnkleR, Th); % 限幅
% 左
ankleL = rad2deg(skeletonPose.pos.ankleL);
dankleL = rad2deg(skeletonPose.vel.ankleL);
Kup_ = Kup * ( atan(5e2*(ankleL-Lup))/pi + 0.5 );
Klo_ = Klo * (-atan(5e2*(ankleL-Llo))/pi + 0.5 );
Fup = Kup_ * (Lup - ankleL);
Flo = Klo_ * (Llo - ankleL);
Fd  = -Damp * (Kup_/Kup + Klo_/Klo) * dankleL;
tauLimitAnkleL = Fup + Flo + Fd;
tauLimitAnkleL = minWithNum(tauLimitAnkleL, Th); % 限幅

tauAnkleR = tauAnkleR + tauLimitAnkleR;
tauAnkleL = tauAnkleL + tauLimitAnkleL;

%% 赋值

Tau = [0; 0; 0;...
      tauHipR+tauInterR; tauKneeR; tauAnkleR; tauExoR-tauInterR;...
      tauHipL+tauInterL; tauKneeL; tauAnkleL; tauExoL-tauInterL]; % 关节、外骨骼力矩

end