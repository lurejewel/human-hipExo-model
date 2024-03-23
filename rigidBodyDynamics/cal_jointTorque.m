%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name
% 目的：根据Gait2392模型中的肌肉几何路径（路径点相对骨骼的位置)和关节角度（骨骼
%       之间的转动）计算肌肉施加力的力臂
% 已知：Gait2392模型
% 输入：关节角度
% 输出：肌肉对某关节的力臂

% Author: Jin Wei
% Last Update: 2022/9/7

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function jointTorque = cal_jointTorque(i, muscleRecord, skeletonPose)

% 读取角度 ( rad )
hipR   = skeletonPose.pos.hipR(i);
hipL   = skeletonPose.pos.hipL(i);
kneeR  = skeletonPose.pos.kneeR(i);
kneeL  = skeletonPose.pos.kneeL(i);
ankleR = skeletonPose.pos.ankleR(i);
ankleL = skeletonPose.pos.ankleL(i);

% 读取归一化肌肉力 ( 0 ~ 1 )
vasRN  = muscleRecord(1).normfiberForceAlongTendon(i);
hamRN  = muscleRecord(2).normfiberForceAlongTendon(i);
gluRN  = muscleRecord(3).normfiberForceAlongTendon(i);
iliRN  = muscleRecord(4).normfiberForceAlongTendon(i);
gasRN  = muscleRecord(5).normfiberForceAlongTendon(i);
solRN  = muscleRecord(6).normfiberForceAlongTendon(i);
tibRN  = muscleRecord(7).normfiberForceAlongTendon(i);
vasLN  = muscleRecord(8).normfiberForceAlongTendon(i);
hamLN  = muscleRecord(9).normfiberForceAlongTendon(i);
gluLN  = muscleRecord(10).normfiberForceAlongTendon(i);
iliLN  = muscleRecord(11).normfiberForceAlongTendon(i);
gasLN  = muscleRecord(12).normfiberForceAlongTendon(i);
solLN  = muscleRecord(13).normfiberForceAlongTendon(i);
tibLN  = muscleRecord(14).normfiberForceAlongTendon(i);

% 读取肌力最大值 ( N )
fiso.vas = 4530;
fiso.ham = 2594;
fiso.glu = 1944;
fiso.ili = 2342;
fiso.gas = 2241;
fiso.sol = 3549;
fiso.tib = 1759;

%% caculate moment arm of muscle to joint

% tib ant -> ankle
x1  = 3.29; y1 = 3.49;
x2  = 6.783*cos(ankleR) + 2.415*sin(ankleR);
y2  = -2.415*cos(ankleR) + 6.783*sin(ankleR);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.tib_ankleR = abs(-x1*y2 + x2*y1) / d12 / 100;

x2  = 6.783*cos(ankleL) + 2.415*sin(ankleL);
y2  = -2.415*cos(ankleL) + 6.783*sin(ankleL);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.tib_ankleL = abs(-x1*y2 + x2*y1) / d12 / 100;
    
% sol -> ankle
x1  = -0.24; y1 = 27.67;
x2  = -4.877 * cos(ankleR) + 1.095 * sin(ankleR);
y2  = -1.095 * cos(ankleR) - 4.877 * sin(ankleR);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.sol_ankleR = -abs(-x1*y2 + x2*y1) / d12 / 100;

x2  = -4.877 * cos(ankleL) + 1.095 * sin(ankleL);
y2  = -1.095 * cos(ankleL) - 4.877 * sin(ankleL);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.sol_ankleL = -abs(-x1*y2 + x2*y1) / d12 / 100;

% vasti -> knee
x1  = 3.35; y1 = 18.76;
x2  = 4 * cos(kneeR) - 2.5 * sin(kneeR);
y2  = 4 * sin(kneeR) + 2.5 * cos(kneeR);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.vas_kneeR = abs(-x1*y2 + x2*y1) / d12 / 100;

x2  = 4 * cos(kneeL) - 2.5 * sin(kneeL);
y2  = 4 * sin(kneeL) + 2.5 * cos(kneeL);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.vas_kneeL = abs(-x1*y2 + x2*y1) / d12 / 100;

% ili -> hip
x1  = 4.07; y1 = 5.61;
x2  = 3.3 * cos(hipR) + 3.5 * sin(hipR);
y2  = 3.3 * sin(hipR) - 3.5 * cos(hipR);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.ili_hipR = abs(-x1*y2 + x2*y1) / d12 / 100;

x2  = 3.3 * cos(hipL) + 3.5 * sin(hipL);
y2  = 3.3 * sin(hipL) - 3.5 * cos(hipL);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.ili_hipL = abs(-x1*y2 + x2*y1) / d12 / 100;

% glu max -> hip
x1  = -6.69; y1 = 1.41;
x2  = -4.26 * cos(hipR) + 5.3 * sin(hipR);
y2  = -4.26 * sin(hipR) - 5.3 * cos(hipR);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.glu_hipR = -abs(-x1*y2 + x2*y1) / d12 / 100;

x2  = -4.26 * cos(hipL) + 5.3 * sin(hipL);
y2  = -4.26 * sin(hipL) - 5.3 * cos(hipL);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.glu_hipL = -abs(-x1*y2 + x2*y1) / d12 / 100;

% ham -> hip & knee
x1  = -5.526; y1 = -3.647;
l   = -2.8*cos(kneeR) + 2*sin(kneeR);
h   = -39.6 - 2*cos(kneeR) - 2.8*sin(kneeR);
x2  = l*cos(hipR) - h*sin(hipR);
y2  = l*sin(hipR) + h*cos(hipR);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.ham_kneeR = -abs(-x1*y2 + x2*y1) / d12 / 100;
momentArm.ham_hipR  = momentArm.ham_kneeR;

l   = -2.8*cos(kneeL) + 2*sin(kneeL);
h   = -39.6 - 2*cos(kneeL) - 2.8*sin(kneeL);
x2  = l*cos(hipL) - h*sin(hipL);
y2  = l*sin(hipL) + h*cos(hipL);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.ham_kneeL = -abs(-x1*y2 + x2*y1) / d12 / 100;
momentArm.ham_hipL  = momentArm.ham_kneeL;

% gas -> knee & ankle
x1  = -2; y1 = 1;
l   = -4.877*cos(ankleR) + 1.095*sin(ankleR);
h   = -43 - 1.095*cos(ankleR) - 4.877*sin(ankleR);
x2  = l*cos(kneeR) - h*sin(kneeR);
y2  = l*sin(kneeR) + h*cos(kneeR);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.gas_kneeR  = -abs(-x1*y2 + x2*y1) / d12 / 100;
momentArm.gas_ankleR = momentArm.gas_kneeR;

l   = -4.877*cos(ankleL) + 1.095*sin(ankleL);
h   = -43 - 1.095*cos(ankleL) - 4.877*sin(ankleL);
x2  = l*cos(kneeL) - h*sin(kneeL);
y2  = l*sin(kneeL) + h*cos(kneeL);
d12 = sqrt((x2-x1)^2 + (y2-y1)^2);
momentArm.gas_kneeL  = -abs(-x1*y2 + x2*y1) / d12 / 100;
momentArm.gas_ankleL = momentArm.gas_kneeL;

%% calculate moment of muscle to joint

moment.tib_ankleR = tibRN * momentArm.tib_ankleR * fiso.tib;
moment.tib_ankleL = tibLN * momentArm.tib_ankleL * fiso.tib;
moment.sol_ankleR = solRN * momentArm.sol_ankleR * fiso.sol;
moment.sol_ankleL = solLN * momentArm.sol_ankleL * fiso.sol;
moment.vas_kneeR  = vasRN * momentArm.vas_kneeR  * fiso.vas;
moment.vas_kneeL  = vasLN * momentArm.vas_kneeL  * fiso.vas;
moment.ili_hipR   = iliRN * momentArm.ili_hipR   * fiso.ili;
moment.ili_hipL   = iliLN * momentArm.ili_hipL   * fiso.ili;
moment.glu_hipR   = gluRN * momentArm.glu_hipR   * fiso.glu;
moment.glu_hipL   = gluLN * momentArm.glu_hipL   * fiso.glu;
moment.ham_kneeR  = hamRN * momentArm.ham_kneeR  * fiso.ham;
moment.ham_kneeL  = hamLN * momentArm.ham_kneeL  * fiso.ham;
moment.ham_hipR   = hamRN * momentArm.ham_hipR   * fiso.ham;
moment.ham_hipL   = hamLN * momentArm.ham_hipL   * fiso.ham;
moment.gas_kneeR  = gasRN * momentArm.gas_kneeR  * fiso.gas;
moment.gas_kneeL  = gasLN * momentArm.gas_kneeL  * fiso.gas;
moment.gas_ankleR = gasRN * momentArm.gas_ankleR * fiso.gas;
moment.gas_ankleL = gasLN * momentArm.gas_ankleL * fiso.gas;

%% calculate joint torque

jointTorque.hipR   = moment.ili_hipR + moment.glu_hipR + moment.ham_hipR;
jointTorque.kneeR  = moment.vas_kneeR + moment.ham_kneeR + moment.gas_kneeR;
jointTorque.ankleR = moment.tib_ankleR + moment.sol_ankleR + moment.gas_ankleR;
jointTorque.hipL   = moment.ili_hipL + moment.glu_hipL + moment.ham_hipL;
jointTorque.kneeL  = moment.vas_kneeL + moment.ham_kneeL + moment.gas_kneeL;
jointTorque.ankleL = moment.tib_ankleL + moment.sol_ankleL + moment.gas_ankleL;

end