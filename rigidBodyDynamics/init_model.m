%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 名称：modelConfig_init.m
% 作者：靳葳
% 最后修改时间：2022/9/27
% 功能：
% 1. 参考SCONE中的H0914M人体模型，配置相关模型参数。
% 2. 设定人体初始姿态和初始速度。
% 输出：
% - modelConfig：存储模型参数和控制信息
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function modelConfig = init_model(simSlope)
%% 模型参数 [m, kg, sec, rad]

% 各骨骼长度
lf      = 0.4996; % 股骨长度 
lt      = 0.4123; % 胫骨长度
lc      = 0.24; % 跟骨（足）长度
le      = 0.3; % 外骨骼腿部长度

% 各骨骼质量 & 质量矩阵
mp      = 11.777; % 盆骨质量
mtorso  = 34.2366; % 躯干质量
mws     = 1.493; % 腰部外骨骼质量
mbs     = 1.904; % 外骨骼背包质量
me      = 0.593; % 外骨骼腿部质量
mf      = 9.3014; % 股骨质量
mt      = 3.7075; % 胫骨质量
mc      = 1.25; % 跟骨（足）质量
mp_     = mp + mws; % 盆骨+外骨骼腰部惯量
mtorso_ = mtorso + mbs; % 躯干+外骨骼背包惯量
mMatrix = diag([mp_ mtorso_ mf mt mc me mf mt mc me mp_ mtorso_ mf mt mc me mf mt mc me]);
mAll    = mp_ + mtorso_ + 2 * (mf + mt + mc + me); % 人+外骨骼总重

% 各骨骼惯量 & 惯量矩阵
Ip_     = 0.141; % 盆骨+外骨骼腰部惯量
Itorso_ = 1.4844; % 躯干+外骨骼背包惯量
If      = 0.1412; % 股骨惯量
It      = 0.0511; % 胫骨惯量
Ic      = 0.0041; % 跟骨（足）惯量
Ie      = 0.0058; % 外骨骼腿部惯量
iMatrix = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
            0, 0, Ip_+Itorso_+2*(If+It+Ic+Ie), If+It+Ic+Ie, It+Ic, Ic, Ie, If+It+Ic+Ie, It+Ic, Ic, Ie;
            0, 0, If+It+Ic+Ie, If+It+Ic+Ie, It+Ic, Ic, Ie, 0, 0, 0, 0;
            0, 0, It+Ic, It+Ic, It+Ic, Ic, 0, 0, 0, 0, 0;
            0, 0, Ic, Ic, Ic, Ic, 0, 0, 0, 0, 0;
            0, 0, Ie, Ie, 0, 0, Ie, 0, 0, 0, 0;
            0, 0, If+It+Ic+Ie, 0, 0, 0, 0, If+It+Ic+Ie, It+Ic, Ic, Ie;
            0, 0, It+Ic, 0, 0, 0, 0, It+Ic, It+Ic, Ic, 0;
            0, 0, Ic, 0, 0, 0, 0, Ic, Ic, Ic, 0;
            0, 0, Ie, 0, 0, 0, 0, Ie, 0, 0, Ie];

% 重力向量
g       = 9.794;
gVec    = [mp_*g; mtorso_*g; mf*g; mt*g; mc*g; me*g; mf*g; mt*g; mc*g; me*g];

% 足底接触
R       = 0.03; % 接触球半径

%% 约束力矩参数
% [NOTE] 这里的上下界单位为deg，因此需要首先执行rad2deg
% 忽略了过渡区间[transition angle]
kneeKup     = 2; % 上边界刚度
kneeKlo     = 2; % 下边界刚度
kneeLup     = -5; % 角度上界（deg）
kneeLlo     = -120; % 角度下界（deg）
kneeDamp    = 0.2; % 模型阻尼系数
kneeThresh  = 10; % 最大约束力矩，自己定的
ankleKup    = 2; % 上边界刚度
ankleKlo    = 2; % 下边界刚度
ankleLup    = 30; % 角度上界（deg）
ankleLlo    = -15; % 角度下界（deg）
ankleDamp   = 0.2; % 模型阻尼系数
ankleThresh = 20; % 最大约束力矩，自己定的

%% 交互力矩参数[working...]
% 暂时用KV模型
stiffness   = 100; % 交互力刚度系数
viscidity   = 75; % 交互力粘性系数

%% 赋值
modelConfig.g                           = g; % 重力加速度
modelConfig.r                           = R; % 接触球半径

modelConfig.boneLength.femur            = lf; % 股骨长度
modelConfig.boneLength.tibia            = lt; % 胫骨长度
modelConfig.boneLength.calcn            = lc; % 跟骨长度
modelConfig.boneLength.exo              = le; % 外骨骼腿部长度

modelConfig.boneMass.pelvis             = mp_; % 盆骨+外骨骼腰部质量
modelConfig.boneMass.torso              = mtorso_; % 躯干+外骨骼背包质量
modelConfig.boneMass.femur              = mf; % 股骨质量
modelConfig.boneMass.tibia              = mt; % 胫骨质量
modelConfig.boneMass.calcn              = mc; % 跟骨质量
modelConfig.boneMass.exo                = me; % 外骨骼腿部质量
modelConfig.boneMass.matrix             = mMatrix; % 质量矩阵
modelConfig.boneMass.all                = mAll; % 身体总重

modelConfig.boneInertia.pelvis          = Ip_; % 盆骨+外骨骼腰部惯量
modelConfig.boneInertia.torso           = Itorso_; % 躯干+背包惯量
modelConfig.boneInertia.femur           = If; % 股骨惯量
modelConfig.boneInertia.tibia           = It; % 胫骨惯量
modelConfig.boneInertia.calcn           = Ic; % 跟骨惯量
modelConfig.boneInertia.exo             = Ie; % 外骨骼腿部惯量
modelConfig.boneInertia.matrix          = iMatrix; % 惯量矩阵 

modelConfig.LimitForce.knee.Kup         = kneeKup; % 膝关节上边界刚度
modelConfig.LimitForce.knee.Klo         = kneeKlo; % 膝关节下边界刚度
modelConfig.LimitForce.knee.Lup         = kneeLup; % 膝关节角度上界
modelConfig.LimitForce.knee.Llo         = kneeLlo; % 膝关节角度下界
modelConfig.LimitForce.knee.d           = kneeDamp; % 膝关节约束模型阻尼系数
modelConfig.LimitForce.knee.th          = kneeThresh; % 膝关节最大约束力矩
modelConfig.LimitForce.ankle.Kup        = ankleKup; % 踝关节上边界刚度
modelConfig.LimitForce.ankle.Klo        = ankleKlo; % 踝关节下边界刚度
modelConfig.LimitForce.ankle.Lup        = ankleLup; % 踝关节角度上界
modelConfig.LimitForce.ankle.Llo        = ankleLlo; % 踝关节角度下界
modelConfig.LimitForce.ankle.d          = ankleDamp; % 踝关节约束模型阻尼系数
modelConfig.LimitForce.ankle.th         = ankleThresh; % 踝关节最大约束力矩

modelConfig.interForce.k                = stiffness; % 交互力刚度系数
modelConfig.interForce.v                = viscidity; % 交互力粘性系数

modelConfig.vec.gVec                    = gVec; % 重力向量

modelConfig.slope                       = simSlope; % 坡度

end