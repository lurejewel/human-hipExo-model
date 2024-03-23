%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 功能：根据当前所处的步态阶段、肌肉长度、肌肉速度、关节运动信息，计算指定肌肉兴奋。
% 参数：
% - muscleIdx: 肌肉编号
% - normalGait: SCONE中人正常行走的运动-动力-肌肉数据
% - Record：存储肌肉长度和速度
% - para：存储肌肉参数
% - initMuslceArch：存储初始时刻的肌肉力、长度、激活度
% 返回：
% - muscleExc: 肌肉兴奋
% Log：
% #3 use angle & angular velocity from skeleton pose, instead of SCONE data
% #2 use gait phase and muscle length calculated from skeleton pose,
% instead of SCONE data
% #1 basic functionalities
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function muscleExc = muscleExcFcn(muscleIdx, record, para, initMuscleArch, skeletonPose)
   %% TODO
   
   % 1. delay设置一下 前10ms不变好像
   
   %% 参数和变量设置
   
   % muscle parameters to be optimized
   KL_tib                  = para.tib.KL;
   L0_tib                  = para.tib.L0;
   KF_tib_sol              = para.tib_sol.KF;
   KF_sol                  = para.sol.KF;
   KF_gas                  = para.gas.KF;
   KF1_vas                 = para.vas.KF1;
   KF2_vas                 = para.vas.KF2;
   C0_vas                  = para.vas.C0;
   Max_vas_knee            = para.vas_knee.pos_max;
   KP_ham_pq               = para.ham_pelvis_tilt.KP;
   KV_ham_pq               = para.ham_pelvis_tilt.KV;
   C0_ham_pq               = para.ham_pelvis_tilt.C0;
   KP_glu_pq               = para.glu_pelvis_tilt.KP;
   KV_glu_pq               = para.glu_pelvis_tilt.KV;
   C0_glu_pq               = para.glu_pelvis_tilt.C0;
   KP_ili_pq               = para.ili_pelvis_tilt.KP;
   KV_ili_pq               = para.ili_pelvis_tilt.KV;
   C0_ili_pq               = para.ili_pelvis_tilt.C0;
   C0_ili                  = para.ili.C0;
   % C0_glu                  = para.glu.C0;
   KL_ili                  = para.ili.KL;
   L0_ili                  = para.ili.L0;
   P0_pq                   = -0.1944;
   P0_ili_pq2              = para.ili_pelvis_tilt.P02;
   KP2_ili_pq              = para.ili_pelvis_tilt.KP2;
   KV2_ili_pq              = para.ili_pelvis_tilt.KV2;
   KL_ili_ham              = para.ili_ham.KL;
   L0_ili_ham              = para.ili_ham.L0;
%    KF_ham                  = para.ham.KF;
   KF_glu                  = para.glu.KF;
   KF_ham_glu              = para.ham_glu.KF;
   
   % loop number
   loopNum                 = record(muscleIdx).loopNum;
   
   % gait phase
   leg1_rstate             = skeletonPose.gaitPhaseR(loopNum+1);
   leg0_lstate             = skeletonPose.gaitPhaseL(loopNum+1);
   
   % joint angle & angular velocity
   kneeR                   = skeletonPose.pos.kneeR(loopNum+1);
   kneeRV                  = skeletonPose.vel.kneeR(loopNum+1);
   kneeL                   = skeletonPose.pos.kneeL(loopNum+1);
   kneeLV                  = skeletonPose.vel.kneeL(loopNum+1);
   pq                      = skeletonPose.pos.pelvisTilt(loopNum+1);
   pqV                     = skeletonPose.vel.pelvisTilt(loopNum+1);
   
   % initial muscle excitation
   muscleExc = 0;
   
   %% 归一化肌力/肌肉长度初始化
   if loopNum == 0 % 第一次执行runMillard函数
       
       vasR_FN = initMuscleArch.f(1);
       hamR_FN = initMuscleArch.f(2);
       gluR_FN = initMuscleArch.f(3);
       iliR_LN = initMuscleArch.l(4);
       hamR_LN = initMuscleArch.l(2);
       gasR_FN = initMuscleArch.f(5);
       solR_FN = initMuscleArch.f(6);
       tibR_LN = initMuscleArch.l(7);
       vasL_FN = initMuscleArch.f(8);
       hamL_FN = initMuscleArch.f(9);
       gluL_FN = initMuscleArch.f(10);
       iliL_LN = initMuscleArch.l(11);
       hamL_LN = initMuscleArch.l(9);
       gasL_FN = initMuscleArch.f(12);
       solL_FN = initMuscleArch.f(13);
       tibL_LN = initMuscleArch.l(14);
       
   else % 非零时刻的其他情况
       vasR_FN = record(1).normfiberForceAlongTendon(loopNum);
       hamR_FN = record(2).normfiberForceAlongTendon(loopNum);
       gluR_FN = record(3).normfiberForceAlongTendon(loopNum);
       iliR_LN = record(4).normFiberLength(loopNum);
       hamR_LN = record(2).normFiberLength(loopNum);
       gasR_FN = record(5).normfiberForceAlongTendon(loopNum);
       solR_FN = record(6).normfiberForceAlongTendon(loopNum);
       tibR_LN = record(7).normFiberLength(loopNum);
       vasL_FN = record(8).normfiberForceAlongTendon(loopNum);
       hamL_FN = record(9).normfiberForceAlongTendon(loopNum);
       gluL_FN = record(10).normfiberForceAlongTendon(loopNum);
       iliL_LN = record(11).normFiberLength(loopNum);
       hamL_LN = record(9).normFiberLength(loopNum);
       gasL_FN = record(12).normfiberForceAlongTendon(loopNum);
       solL_FN = record(13).normfiberForceAlongTendon(loopNum);
       tibL_LN = record(14).normFiberLength(loopNum);
       
   end
   
   %% 基于步态阶段的肌肉兴奋反馈回路
   
   switch muscleIdx
       
       case 1 % vasti 股前肌
%            if leg1_rstate == 0 || leg1_rstate == 1 % earlyStance & lateStance
%                muscleExc = C0_vas;
%                if kneeR < Max_vas_knee || kneeRV <= 0
%                    muscleExc = muscleExc + KF_vas * vasR_FN;
%                end
%            end
           if leg1_rstate == 0 % earlyStance
               muscleExc = C0_vas;
               if kneeR < Max_vas_knee || kneeRV <= 0
                   muscleExc = muscleExc + KF1_vas * vasR_FN;
               end
           end
           if leg1_rstate == 1 % lateStance
               muscleExc = C0_vas;
               if kneeR < Max_vas_knee || kneeRV <= 0
                   muscleExc = muscleExc + KF2_vas * vasR_FN;
               end
           end
           
       case 2 % hamstrings 腘绳肌
           if leg1_rstate == 0 || leg1_rstate == 1 % earlyStance & lateStance
               muscleExc = C0_ham_pq - ( KP_ham_pq*(pq-P0_pq) + KV_ham_pq*pqV );
           end
%            if leg1_rstate == 3 || leg1_rstate == 4 % swing & landing
%                muscleExc = KF_ham * hamR_FN;
%            end
           if leg1_rstate == 4 % landing
               muscleExc = KF_ham_glu * gluR_FN;
           end
           
       case 3 % glut max 臀大肌
           if leg1_rstate == 0 || leg1_rstate == 1 % earlyStance & lateStance
               muscleExc = C0_glu_pq - (KP_glu_pq*(pq-P0_pq) + KV_glu_pq*pqV);
           end
           if leg1_rstate == 3 || leg1_rstate == 4 % swing & landing
               muscleExc = KF_glu * gluR_FN;
           end
           
       case 4 % iliopsoas 髂腰肌
           if leg1_rstate == 0 || leg1_rstate == 1 % earlyStance & lateStance
               muscleExc = C0_ili_pq - (KP_ili_pq*(pq-P0_pq) + KV_ili_pq*pqV);
           end
           if leg1_rstate == 2 % liftoff
               muscleExc = C0_ili;
           end
           if leg1_rstate == 3 || leg1_rstate == 4 % swing & landing
               muscleExc = KL_ili*(iliR_LN-L0_ili) - (KP2_ili_pq*(pq-P0_ili_pq2)) + KL_ili_ham*(hamR_LN-L0_ili_ham) - KV2_ili_pq*pqV;
           end
           
       case 5 % gastroc 腓肠肌
           if leg1_rstate == 0 || leg1_rstate == 1 || leg1_rstate == 2 % earlyStance & lateStance & liftoff
               muscleExc = KF_gas * gasR_FN;
           end
           
       case 6 % soleus % 比目鱼肌
           if leg1_rstate == 0 || leg1_rstate == 1 || leg1_rstate == 2 % earlyStance & lateStance & liftoff
               muscleExc = KF_sol * solR_FN;
           end
           
       case 7 % tib ant % 胫骨前肌
           muscleExc = KL_tib * (tibR_LN - L0_tib) + KF_tib_sol * solR_FN;
           
       case 8 % vasti 股前肌
%            if leg0_lstate == 0 || leg0_lstate == 1 % earlyStance & lateStance
%                muscleExc = C0_vas;
%                if kneeL < Max_vas_knee || kneeLV <= 0
%                    muscleExc = muscleExc + KF_vas * vasL_FN;
%                end
%            end
           if leg0_lstate == 0 % earlyStance
               muscleExc = C0_vas;
               if kneeL < Max_vas_knee || kneeLV <= 0
                   muscleExc = muscleExc + KF1_vas * vasL_FN;
               end
           end
           if leg0_lstate == 1 % lateStance
               muscleExc = C0_vas;
               if kneeL < Max_vas_knee || kneeLV <= 0
                   muscleExc = muscleExc + KF2_vas * vasL_FN;
               end
           end
           
       case 9 % hamstrings 腘绳肌
           if leg0_lstate == 0 || leg0_lstate == 1 % earlyStance & lateStance
               muscleExc = C0_ham_pq - ( KP_ham_pq*(pq-P0_pq) + KV_ham_pq*pqV );
           end
%            if leg0_lstate == 3 || leg0_lstate == 4 % swing & landing
%                muscleExc = KF_ham * hamL_FN;
%            end
           if leg0_lstate == 4 % landing
               muscleExc = KF_ham_glu * gluL_FN;
           end
           
       case 10 % glut max 臀大肌
           if leg0_lstate == 0 || leg0_lstate == 1 % earlyStance & lateStance
               muscleExc = C0_glu_pq - (KP_glu_pq*(pq-P0_pq) + KV_glu_pq*pqV);
           end
           if leg0_lstate == 3 || leg0_lstate == 4 % swing & landing
               muscleExc = KF_glu * gluL_FN;
           end
           
       case 11 % iliopsoas 髂腰肌
           if leg0_lstate == 0 || leg0_lstate == 1 % earlyStance & lateStance
               muscleExc = C0_ili_pq - (KP_ili_pq*(pq-P0_pq) + KV_ili_pq*pqV);
           end
           if leg0_lstate == 2 % liftoff
               muscleExc = C0_ili;
           end
           if leg0_lstate == 3 || leg0_lstate == 4 % swing & landing
               muscleExc  = KL_ili*(iliL_LN-L0_ili) - (KP2_ili_pq*(pq-P0_ili_pq2)) + KL_ili_ham*(hamL_LN-L0_ili_ham) - KV2_ili_pq*pqV;
           end
           
       case 12 % gastroc 腓肠肌
           if leg0_lstate == 0 || leg0_lstate == 1 || leg0_lstate == 2 % earlyStance & lateStance & liftoff
               muscleExc = KF_gas * gasL_FN;
           end
           
       case 13 % soleus % 比目鱼肌
           if leg0_lstate == 0 || leg0_lstate == 1 || leg0_lstate == 2 % earlyStance & lateStance & liftoff
               muscleExc = KF_sol * solL_FN;
           end
           
       case 14 % tib ant % 胫骨前肌
           muscleExc = KL_tib*(tibL_LN-L0_tib) + KF_tib_sol*solL_FN;
           
       otherwise
           error('invalid muscle index.');
           
   end
   
   %% 肌肉激活度限幅
   if muscleExc < 0
       muscleExc = 0;
   elseif muscleExc > 1
       muscleExc = 1;
   end
   
   end