%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name: init_skeletonPose
% Function: 
% - 根据仿真时长和步长，为骨骼姿态结构体分配空间
% - 初始化 t = 0.00 s 时的骨骼姿态和速度
% Author: Jin Wei
% Last Update: 2022/11/14
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function skeletonPose = init_skeletonPose(tEnd, T, initArch)
%% 根据仿真设置分配内存

npts = fix(tEnd/T) + 1; % 控制点数，+1是因为要初始化t=0时刻的姿态

skeletonPose.pos.pelvisX            = -ones(1, npts);
skeletonPose.pos.pelvisY            = -ones(1, npts);
skeletonPose.pos.pelvisTilt         = -ones(1, npts);
skeletonPose.pos.hipR               = -ones(1, npts);
skeletonPose.pos.hipL               = -ones(1, npts);
skeletonPose.pos.exoR               = -ones(1, npts);
skeletonPose.pos.exoL               = -ones(1, npts);
skeletonPose.pos.kneeR              = -ones(1, npts);
skeletonPose.pos.kneeL              = -ones(1, npts);
skeletonPose.pos.ankleR             = -ones(1, npts);
skeletonPose.pos.ankleL             = -ones(1, npts);

skeletonPose.vel.pelvisX            = -ones(1, npts);
skeletonPose.vel.pelvisY            = -ones(1, npts);
skeletonPose.vel.pelvisTilt         = -ones(1, npts);
skeletonPose.vel.hipR               = -ones(1, npts);
skeletonPose.vel.hipL               = -ones(1, npts);
skeletonPose.vel.exoR               = -ones(1, npts);
skeletonPose.vel.exoL               = -ones(1, npts);
skeletonPose.vel.kneeR              = -ones(1, npts);
skeletonPose.vel.kneeL              = -ones(1, npts);
skeletonPose.vel.ankleR             = -ones(1, npts);
skeletonPose.vel.ankleL             = -ones(1, npts);

skeletonPose.gaitPhaseR             = -ones(1, npts);
skeletonPose.gaitPhaseL             = -ones(1, npts);
skeletonPose.gaitPercentR           = -1;
skeletonPose.gaitPercentL           = -1;
skeletonPose.lastGaitEventR         = -1;
skeletonPose.lastGaitEventL         = -1;
skeletonPose.gaitCycleR             = 1.2;
skeletonPose.gaitCycleL             = 1.2;

%% t = 0.00 s 时刻的姿态初始化

% 初始角度和位移
skeletonPose.pos.pelvisX(1)           = 0; % 盆骨横向运动
skeletonPose.pos.pelvisY(1)           = initArch.pose.pY; % 盆骨纵向运动
skeletonPose.pos.pelvisTilt(1)        = initArch.pose.pq; % 盆骨转动
skeletonPose.pos.hipR(1)              = initArch.pose.hipR; % 右髋关节转动
skeletonPose.pos.hipL(1)              = initArch.pose.hipL; % 左髋关节转动
skeletonPose.pos.exoR(1)              = initArch.pose.exoR; % 右外骨骼转动
skeletonPose.pos.exoL(1)              = initArch.pose.exoL; % 左外骨骼转动
skeletonPose.pos.kneeR(1)             = initArch.pose.kneeR; % 右膝关节转动
skeletonPose.pos.kneeL(1)             = initArch.pose.kneeL; % 左膝关节转动
skeletonPose.pos.ankleR(1)            = initArch.pose.ankleR; % 右踝关节转动
skeletonPose.pos.ankleL(1)            = initArch.pose.ankleL; % 左踝关节转动

% 初始角速度和速度
skeletonPose.vel.pelvisX(1)           = initArch.vel.pX; % 盆骨横向运动速度
skeletonPose.vel.pelvisY(1)           = initArch.vel.pY; % 盆骨纵向运动速度
skeletonPose.vel.pelvisTilt(1)        = initArch.vel.pq; % 盆骨转动角速度
skeletonPose.vel.hipR(1)              = initArch.vel.hipR; % 右髋关节转动角速度
skeletonPose.vel.hipL(1)              = initArch.vel.hipL; % 左髋关节转动角速度
skeletonPose.vel.exoR(1)              = initArch.vel.exoR; % 右外骨骼转动角速度
skeletonPose.vel.exoL(1)              = initArch.vel.exoL; % 左外骨骼转动角速度
skeletonPose.vel.kneeR(1)             = initArch.vel.kneeR; % 右膝关节转动角速度
skeletonPose.vel.kneeL(1)             = initArch.vel.kneeL; % 左膝关节转动角速度
skeletonPose.vel.ankleR(1)            = initArch.vel.ankleR; % 右踝关节转动角速度
skeletonPose.vel.ankleL(1)            = initArch.vel.ankleL; % 左踝关节转动角速度

% 初始步态阶段
skeletonPose.gaitPhaseL(1)            = initArch.gaitPhaseL; % 左腿所处步态阶段
skeletonPose.gaitPhaseR(1)            = initArch.gaitPhaseR; % 右腿所处步态阶段

end