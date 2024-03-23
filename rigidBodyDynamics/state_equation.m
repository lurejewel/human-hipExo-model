function dindt = state_equation(t, in, modelConfig, jointTorque, exoTorque)
% 动力学方程：
% (iMatrix+Jxb'*mMatrix*Jxb) * ddq + Jxb'*mMatrix*dJxb*dq + Jy'*gVec = Tau + Jgrf'*Fgrf

% t: 当前计算时刻的时间
% in: 当前状态量   px    py    pq    hipR   kneeR  ankleR  exoR   hipL   kneeL  ankleL  exoL
%                  1     2     3      4      5      6      7       8       9      10    11
%    dpx    dpy    dpq    dhipR   dkneeR  dankleR  dexoR   dhipL   dkneeL   dankleL  dexoL
%     12     13    14      15      16      17      18       19      20        21      22
if ~isreal(in)
    in = real(in);
end
iMatrix = modelConfig.boneInertia.matrix; % 惯性矩阵
mMatrix = modelConfig.boneMass.matrix; % 质量矩阵
gVec = modelConfig.vec.gVec; % 重力项

% 计算肌肉长度（后续将和计算肌肉速度一同单独封装，在complete flow的muscleDynamics之前调用）
% muscleLen = cal_musLen(in);

% 计算雅克比
[Jxb, Jy, Jgrf, dJxb] = cal_Jacobi(in);

% 计算外力
[Fgrf, Tau] = cal_force(t, in, modelConfig, jointTorque, exoTorque);

% 求解方程
dq = in(12:22);
% ddq = (iMatrix + Jxb'*mMatrix*Jxb) \ (Tau + Jgrf'*Fgrf - Jy'*gVec - Jxb'*mMatrix*dJxb*dq);
ddq = pinv(iMatrix + Jxb'*mMatrix*Jxb) * (Tau + Jgrf'*Fgrf - Jy'*gVec - Jxb'*mMatrix*dJxb*dq);

% 赋值
dindt(1:11,1) = dq;
dindt(12:22,1) = ddq;

end