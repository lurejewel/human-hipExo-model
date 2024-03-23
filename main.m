%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Jiaqi Liu, Wei Jin
% Affiliation: Fudan Univ., China
%
% Basic function of the musculoskeleton model simulation.
% Based on the kinematic data of the skeleton model (pelvis displacement,
% joint angle, joint angular velocity, etc), we can calculate the muscle
% length and muscle velocity in a geometrical way, which are subsequently
% one of the sources for computing muscle forces; meanwhile we can derive
% the muscle excitation based on the skeleton pose and the controller we
% designed, and the muscle moment arm, an important part to calculate the
% joint moments from muscle forces (can be positive or negative).
% Then muscle activation is derived based on the muscle activation dynamics
% model (simply a first-order ODE). Now that we have the muscle activation,
% muscle length, muscle velocity, we can compute the muscle forces through
% the muscle contraction dynamics model.
% Finally, the moment of muscles can be calculated by multiplying muscle
% forces and the moment arms. And the joint moments are the sum of the
% corresponding muscle moments. In this way the human skeleton model is
% drived by the joint moments and move for one simulation step.
%
% The simulation diagram is as follows:
%         —————————
%        |                   ↓
%        |             muscle excitation
%        |                   |
%        |                   |  muscle activation dynamics
%        |                   ↓
%        |             muscle activation
%        |                   |
%        |                   |  muscle contraction dynamics
%        |                   ↓
%        |             muscle forces
%        |                   |
%        |  neural           |  muscle moment arm
%        |  controller       ↓
%        |             muscle moments
%        |                   |
%        |                   |  addition
%        |                   ↓
%        |             joint moments
%        |                   |
%        |                   |  rigid-body dynamics &
%        |                   |  ground reaction force
%        |                   ↓
%        |           skeleton movement
%        |                   |
%         —————————
%
%
% The 9 DOF of the model is: pelvis displacement in x axis(coronal vertical
% axis), pelvis displacement in y axis(transverse vertical axis), pelvis
% tilt in sagittal plane, left & right hip extension/flexion, left & right
% knee extension/flexion, left & right ankle plantarflexion(extension)/
% dorsiflexion.
%
% The 14 MUSCLES of the model is: left & right gluteus maximus, left &
% right iliopsoas, left & right hamstrings, left & right vastus, left &
% right gastrocnemius, left & right soleus, left & right tibialis anterior.
% The skeleton and muscle configuration of the model is in accordance with
% the OpenSim model "H0914M.osim":
%   - Delp S L, et al. OpenSim: Open-Source software to create and analyze
%   dynamic simulations of movement[J]. IEEE Transactions on Biomedical
%   Engineering, 2007, 54(11): 1940-1950.
%
% The HUMAN GAIT CONTROL algorithm is designed based on the controller
% proposed by Geyer & Herr 2010:
%   - Geyer H and Herr H. A muscle-reflex model that encodes principles
%   of legged mechanics produces human walking dynamics and muscle
%   activities[J]. IEEE Transactions on Neural Systems and Rehabilitation
%   Engineering, 2010, 18(3): 263-273.
%
% The MUSCLE CONTRACTION DYNAMICS MODEL is developed based on the work
% by Millard 2012:
%   - Millard M, et al. Flexing computational muscle: modeling and
%   simulation of musculotendon dynamics[J]. Journal of biomechanical
%   engineering, 2013, 135(2).
%
% The INITIAL VALUES of the model and the parameters, including initial
% skeleton pose & velocity, initial muscle excitation & activation & fiber
% length & fiber contract velocity, initial values of the motion feedback
% parameters to be optimized, are derived from the optimization results in
% SCONE Tutorial 4a - Gait.
%
% The GAIT PHASE DETECTION algorithm is derived from SCONE. See
% documentation:
%   https://scone.software/doku.php?id=ref:gait_state_controller
% for details.
%
% The OPTIMIZATION ALGORITHM is utilized in finding the best set of muscle
% feedback parameters ('para' as the input in muscleExcFcn.m). CMA-ES (
% Evolution Strategy with Covariance Matrix Adaptation for nonlinear
% funtion minimization) is chosen for optimization:
%   - Hansen N, et al. Reducing the Time Complexity of the Derandomized
%   Evolution Strategy with Covariance Matrix Adaptation (CMA-ES)[J].
%   Evolutionary Computation, 2003, 11(1): 1-18.
%
% The OBJECTIVE FUNCTION is designed based on SCONE, a software written by
% a talented professor, Thomas Geijtenbeek, and Wang 2012 model:
%   - Geijtenbeek T. Scone: Open source software for predictive simulation
%   of biological motion[J]. Journal of Open Source Software, 2019, 4(38):
%   1421.
%   - Wang J M, et al. Optimizing locomotion controllers using
%   biologically-based actuators and objectives[J]. ACM Transactions on
%   Graphics, 2012, 31(4): 1-11.
%
%
% Update Log
% #15 modify muscle reflex mechanism of VAS and HAM
% #14 add function: record the state of the global best particle
% #13 walking speed constraint and the surface slope can be changed now
% #12 add hip exoskeleton and the interaction force in the neuromusculo-
% tendon model
% #11 fix bug in muscle excitation feedback
% #10 modify the CMA-ES algorithm by adding 3 global best particles; remove
% redundant functions and variables
% #9 the animation function is now replaced into the "debug" function,
% where the muscle excitation, muscle contraction, joint torque curve, etc
% are available to be visualized
% #8 substitute the build-in ODE solving function with 4th-order Runge-
% Kutta algorithm
% #7 simulation stops when the model falls
% #6 fix bug that contact depth between foot and ground may be negative
% under some circumstances
% #5 the muscles are now shown in the animation
% #4 complete functions:
%   - record the joint torque during the simulation
%   - animate the motion of the rigid-body model after the simulation
% #3 complete functions:
%   - compute joint torque based on muscle forces and the corresponding
%   moment arms derived from skeleton model posture. skeleton model is now
%   driven by muscles!
%   - determine gait phase in real-time based on ground reaction force and
%   skeleton model posture
% #2 complete functions:
%   - compute skeleton model posture and motion in one simulation time step
%   through rigid-body dynamics based on real-time ground reaction forces
%   and joint torques as input, a huuuuge function
% #1 complete basic functions:
%   - calculate muslce length & velocity <muscleStateRecord> based on
%   skeleton posture and historical record information at tStart of tSpan
%   (cal_muscleState)
%   - calculate muscle length & velocity based on muscleStateRecord at any
%   time of tSpan (muscleStateFcn)
%   - calculate muscle forces from muscle activation, a huuuuge project
%   - calculate muscle activation from muscle excitation (muscleActFcn)
%   - calculate muscle excitation from historical information of muscle and
%   kinematic data provided by SCONE (gait phase, joint angle, etc.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
clc; close all; clear all; tic;
addpath('muscleDynamics\'); % muscle level dynamics [muscle activation & contraction; excitation feedback]
addpath('rigidBodyDynamics\'); % skeleton-exoskeleton level dynamics [joint torque generation; rigid body dynamics]
simSpan  = [0 10]; % 仿真时间：0 ~ <simTime> sec
simT     = 0.005; % 仿真步长
simSlope = 0.0; % 仿真坡度
simSpeed = 1.0; % 仿真步速

peakForce = 17.7; % 峰值拉力
exoPara = [30 55 70]; % [startTime peakTime endTime]

%% LOOK AT THIS
% 在加入外骨骼后可以先研究的点：
% - 这28个参数的优化方向
% - best & elite & overall 的变化趋势，与SCONE在同起点下对比
% - 固定参数，进行初值优化

% 开启并行计算
% if isempty(gcp('nocreate'))
%     parpool(maxNumCompThreads);
% end

%% SCONE设置

load('initArch.mat');
initMuscleArch = init_calMuscleActExc(initArch); % 存储SCONE中与计算肌肉兴奋和激活相关的变量初值

%% 优化设置

paraNum   = 28+1; % 28 muscle reflex para + 1 desired exoskeleton peak force para
initPara  = [1.14339427675597;0.683965164606834;-0.654937183750042;1.44526338204981;1               ;-2.54053931319423;-0.666188349877246;0.0496818438178654;0.109481378880035;0.388522196081861;0.266059683859970;0.748599386315988;0.543366924759648;0.598978415045811;-2.81541067233053;0.377854695673883;2.18759273326043;0.657016639688066;-0.298290360392486;0.300063335235475;1.81474706127338;0.00878201304411728;0.510662826532988;1.15502124130598;1.97028072512268;0.479041225785079;0.568851978040139;-0.188673608490112];
%              tib.KL           tib.L0            tib_sol.KF         sol.KF           gas.KF           ili_pq.KP         ili_pq.KV          ili.pq.C0           ili.C0           ili.KL            ili.L0           ili_pq.P02       ili_pq.KP2        ili_pq.KV2           ili_ham.KL       ili_ham.L0        ham_pq.KP           ham_pq.KV        ham_pq.C0           ham.KF           glu_pq.KP        glu_pq.KV         glu_pq.C0          glu.KF            vas.KF1          vas.KF2           vas.C0            vas_knee.pos_max
                                                                                     % 1.70706773704484
% para      = arx2para(initPara);
load('best_1_assisted_torqueOptimzed.mat'); para = best.para; para.peakForce = peakForce;
% load('sconePara.mat'); para = sconePara; % SCONE的初值

sigma     = 0.0;
stage     = 2;
optConfig = init_CMAES(para, paraNum, sigma, stage);

%% 交互力模型设置

load('coefAssist.mat');

%% 肌肉设置

muscleNum      = 14; % 先 R 后 L
muscleSim      = 1:14; % 参与仿真的肌肉
muscleAbbrList = {'vasti', 'ham', 'glu', 'ili', 'gas', 'sol', 'tib'}; % 名字在arnold2010LegArch.abbrevation列表里

% 肌肉的四个特征曲线参数
muscleCurvePara.activeForceLengthCurve.minimumValue                     = 0;
muscleCurvePara.forceVelocityCurve.concentricSlopeAtVMax                = 0;
muscleCurvePara.forceVelocityCurve.concentricSlopeNearVMax              = 0;
muscleCurvePara.forceVelocityCurve.isometricSlope                       = 5;
muscleCurvePara.forceVelocityCurve.eccentricSlopeAtVMax                 = 0;
muscleCurvePara.forceVelocityCurve.eccentricSlopeNearVMax               = 0.15;
muscleCurvePara.forceVelocityCurve.maxEccentricVelocityForceMultiplier  = 1.4;

% 肌肉激活动力学参数
maximumNormalizedFiberVelocity  = 10; % in units of norm fiber lengths/second 归一化后的最大肌肉收缩/舒张速度
maximumPennationAngle           = 89*(pi/180); % if we go to 90 the classic formulation goes singular. 避免π/2的奇异点
muscleConfig.damping            = 0.1; % 阻尼值为0.1
muscleConfig.iterMax            = 100; % 最大迭代次数
muscleConfig.tol                = 1e-6; % 容许度
muscleConfig.minActivation      = 0.01; % 最小的肌肉激活度
muscleConfig.tendonStrainAtOneNormForce  = -1; % If this is greater than 0 this value will be used to make the tendon-force-length curve. Otherwise the default of 0.049 is taken. 肌腱应力，根据肌腱长度与受力曲线（特征曲线4）得到

% 肌肉结构参数整合
unitsMKSN         = 1; % N, m, rad
arnold2010LegArch = getArnold2010LegMuscleArchitecture(unitsMKSN); % 得到所有肌肉的结构参数，是个结构体数组
normMuscleCurves = createDefaultNormalizedMuscleCurves(muscleAbbrList{1}, muscleCurvePara, muscleConfig.tendonStrainAtOneNormForce); % 肌肉对应的特征曲线，肌肉名称不重要（反正曲线都是一样的）
for muscleIdx = muscleSim % all simulated muscles
    muscleArch(muscleIdx).idx                 = getArnold2010MuscleIndex(muscleAbbrList{mod(muscleIdx+6,7)+1}, arnold2010LegArch.abbrevation); % 肌肉编号
    muscleArch(muscleIdx).name                = arnold2010LegArch.names{muscleArch(muscleIdx).idx}; % 肌肉全称
    muscleArch(muscleIdx).abbr                = muscleAbbrList{mod(muscleIdx+6,7)+1}; % 肌肉缩写
    muscleArch(muscleIdx).fiso                = arnold2010LegArch.peakForce(muscleArch(muscleIdx).idx); % 最大力
    muscleArch(muscleIdx).optimalFiberLength  = arnold2010LegArch.optimalFiberLength(muscleArch(muscleIdx).idx); % 最优纤维长度
    muscleArch(muscleIdx).maximumNormalizedFiberVelocity = maximumNormalizedFiberVelocity; % 归一化后的最大肌肉收缩/舒张速度
    muscleArch(muscleIdx).pennationAngle      = arnold2010LegArch.pennationAngle(muscleArch(muscleIdx).idx); % 羽状角
    muscleArch(muscleIdx).tendonSlackLength   = arnold2010LegArch.tendonSlackLength(muscleArch(muscleIdx).idx); % 松弛时的肌腱长度
    
    minimumActiveFiberNormalizedLength = normMuscleCurves.activeForceLengthCurve.xEnd(1); % 主动力能收缩到的最小肌肉长度（归一化的值） = 主动收缩单元的力-肌肉长度曲线（特征曲线中的1st）左端点
    minFiberKinematics = calcFixedWidthPennatedFiberMinimumLength(...
        minimumActiveFiberNormalizedLength,... % 主动力能收缩到的最小肌肉长度（差不多最优长度的一半）
        maximumPennationAngle,... % 最大羽状角 = 89/(pi*180)
        muscleArch(muscleIdx).optimalFiberLength,... % 最优肌肉长度
        muscleArch(muscleIdx).pennationAngle); % 羽状角
    muscleArch(muscleIdx).minimumFiberLength = minFiberKinematics.minimumFiberLength; % 考虑羽状角 & 肌纤维收缩极限时的最小肌肉长度
    muscleArch(muscleIdx).minimumFiberLengthAlongTendon = minFiberKinematics.minimumFiberLengthAlongTendon; % 上述的基础上，沿肌腱的长度
    muscleArch(muscleIdx).pennationAngleAtMinumumFiberLength = minFiberKinematics.pennationAngleAtMinimumFiberLength; % 肌纤维最短时的羽状角
end
muscleDynamics_ = @(i, benchConfig, muscleState0, muscleRecord, muscleStateRecord, skeletonPose)muscleDynamics(i, simT, muscleSim, benchConfig, muscleState0, muscleArch, normMuscleCurves, muscleConfig, muscleRecord, muscleStateRecord, skeletonPose);

%% 姿态和力矩设置

modelConfig  = init_model(simSlope); % 身体物理参数赋值
skeletonDynamics_ = @(i, skeletonPose, jointTorque, exoTorque)skeletonDynamics(i, simT, modelConfig, skeletonPose, jointTorque, exoTorque);

%% 仿真设置

benchConfig.relTol               = 1e-6; % 相对容许误差 relavant tolerance
benchConfig.absTol               = 1e-6; % 绝对容许误差 absolute tolerance
benchConfig.activation           = 0; % 肌肉激活度的初始值
benchConfig.minimumActivation    = muscleConfig.minActivation; % 最小肌肉激活度，0.01
benchConfig.actFcn               = @(t, muscleIdx, excitation, record)muscleActFcn(t, simT, muscleIdx, excitation, record, initMuscleArch); % 肌肉激活函数 activation
benchConfig.pathFcn              = @(t, muscleIdx, muscleStateRecord)muscleStateFcn(t, simT, muscleIdx, muscleStateRecord); % 肌肉状态函数 length & velocity

%% 开始仿真

tic;

countEval  = 1;
stopEval   = 1000;
% fit curve
F          = zeros(1, stopEval); % minimum fitness for every iteration
% gBest
gBest.maxN = 3; % store the best 3 para. of particles
gBest.para = []; % para. of particles with global best fit
gBest.arx  = []; % identity to para, only in different types
gBest.arz  = []; % for particle update
gBest.fit  = 999*ones(1, gBest.maxN); % the global best fitness, initialized to 999
% fitness
bestFit    = []; % show the fit of the best particle every iter
eliteFit   = []; % show the average fit of the 6 elite particles every iter
allFit     = []; % show the average fit of all particles every iter
% best of gBest
best.para = [];
best.arx  = [];
best.arz  = [];
best.fit  = [];
best.musRec = [];
best.torque = [];
best.pose = [];
best.vel = [];

while countEval <= stopEval
    
    % generate & evaluate lambda offspring
    arz = randn(paraNum, optConfig.lambda); % standard normally distributed vector
    arx = zeros(paraNum, optConfig.lambda); % allocate space for points
    fit = zeros(1, optConfig.lambda); % fitness function + standard Gaussian random noise
    fitRecord = fit; % real fitness function
    
    for k = 1 : optConfig.lambda % simulate for each point & evaluate fitness
        
        % initial record structures
        [muscleRecord, muscleStateRecord, muscleState0, skeletonPose, torqueRecord, interForce] = initialization(simSpan, simT, muscleNum, initArch);
        
        % generate particle
        if countEval == 1 && k == 1 % the first evaluation
            arx(:, k) = optConfig.xmean; % evaluate the initial para config at first
        else
            arx(:, k) = optConfig.xmean + optConfig.sigma * (optConfig.B*optConfig.D*arz(:,k)); % add mutation
        end
        arx(:, k) = fixPara(arx(:, k));
        para = arx2para(arx(:, k)); % xmean (for optimization) -> para (for dynamic simulation)
        benchConfig.excFcn = @(muscleIdx, record, skeletonPose)muscleExcFcn(muscleIdx, record, para, initMuscleArch, skeletonPose); % muscle excitation
        
        % dynamic simulation
        GRF = zeros(8, simSpan(end)/simT);
        for i = 1 : simSpan(end)/simT % tspan = [(i-1)*simT, i*simT]; loopNum = i
           
            % skeleton pose -> ground reaction force
            GRF(:,i) = cal_GRF(i, skeletonPose, modelConfig);
            
            % skeleton pose -> gait phase
            skeletonPose = cal_gaitPhase(i, simT, skeletonPose, GRF(:,i), modelConfig);
            
            % skeleton pose -> muscle length & velocity (at tSpan(1))
            muscleStateRecord = cal_muscleState(i, simT, skeletonPose, muscleStateRecord);
            % TODO：把muscleStateRecord的值整合进muscleRecord, 后面就少传一个参
            
            % muscle states & model pose at tSpan(1) -> muscle states at tspan(2)
            [muscleRecord, muscleState0] = muscleDynamics_(i, benchConfig, muscleState0, muscleRecord, muscleStateRecord, skeletonPose);
            % TODO: muscle delay
            
            % hip angle & angular velocity -> interactive frictional forces
            interForce = cal_interForce(i, skeletonPose, coefAssist, para.peakForce, interForce);
            
            % muscle & gait states -> joint & exoskeleton torque
            exoTorque    = cal_exoTorque(i, skeletonPose, exoPara, para.peakForce, interForce); % gait state -> exoskeleton torque
            jointTorque  = cal_jointTorque(i, muscleRecord, skeletonPose); % muscle force -> muscle moment -> joint torque
            torqueRecord = rec_jointTorque(i, jointTorque, exoTorque, torqueRecord); % record torque
            
            % joint torque -> rigid body posture & motion
            skeletonPose = skeletonDynamics_(i, skeletonPose, jointTorque, exoTorque); % 输入tspan(1)的关节力矩和人体姿态，输出tspan(end)时刻的运动结果
            
            if skeletonPose.pos.pelvisY(i+1) < 0.6 + simSlope * (skeletonPose.pos.pelvisX(i+1)-skeletonPose.pos.pelvisX(1)) % fall
                break;
            end
            
            % after the dynamics
            for muscleIdx = muscleSim
                muscleState0(muscleIdx) = muscleRecord(muscleIdx).muscleState(i); % 将本次步长结束时刻的肌纤维长度速度作为下次步长肌纤维长度速度的初值
                muscleRecord(muscleIdx).loopNum = muscleRecord(muscleIdx).loopNum + 1; % 循环数+1 （计算肌肉兴奋、激活等会用到）
            end
            muscleStateRecord.loopNum = muscleStateRecord.loopNum + 1;
            % TODO: 后续直接使用muscleRecord(x).loopNum
        end
        
        %%%debug%%%
%         debug(simSpan, skeletonPose, torqueRecord, muscleRecord, simSlope); % animation
%         toc;
        %%%debug%%%
        
        % compute fitness
        this_fit = measure(optConfig.stage, i, simT, simSpan(end), skeletonPose, GRF, muscleRecord, interForce, simSpeed, simSlope);
%         目前d把正压力的阻尼增大到10倍
        % stage 1 -> stage 2
        if optConfig.stage == 1 && this_fit < 0
            disp(['stage 1 completed, fitness: ' num2str(this_fit)]);
            optConfig.stage = 2; % switch to stage 2
            this_fit = measure(optConfig.stage, i, simT, simSpan(end), skeletonPose, GRF, muscleRecord, interForce, simSpeed, simSlope);
            disp(['stage 2 fitness: ' num2str(this_fit)]);
            gBest.fit(:) = 999; % overwrite gBest           
        end
        
        % record fitness
        if countEval == 1 && k <= gBest.maxN % init gBest
            % assign value
            gBest.fit(k) = this_fit;
            gBest.para   = [gBest.para, para];
            gBest.arx    = [gBest.arx,  arx(:,k)]; % [paraNum, gBest.maxN] i.e. [28, 3]
            gBest.arz    = [gBest.arz,  arz(:,k)]; % [paraNum, gBest.maxN] i.e. [28, 3]
            % sort the queue
            if k == gBest.maxN
                [gBest.fit, idx] = sort(gBest.fit);
                gBest.para = gBest.para(idx);
                gBest.arx  = gBest.arx(:,idx);
                gBest.arz  = gBest.arz(:,idx);
                disp([num2str(gBest.maxN) ' global best fitnesses: ' num2str(gBest.fit)]);
            end
        elseif this_fit < gBest.fit(end) % update gBest
            % assign value
            gBest.fit(end)   = this_fit;
            gBest.para(end)  = para;
            gBest.arx(:,end) = arx(:,k);
            gBest.arz(:,end) = arz(:,k);
            % sort the queue
            [gBest.fit, idx] = sort(gBest.fit);
            gBest.para = gBest.para(idx);
            gBest.arx  = gBest.arx(:,idx);
            gBest.arz  = gBest.arz(:,idx);
            disp([num2str(gBest.maxN) ' global best fitnesses: ' num2str(gBest.fit)]);
            %             gBest.arx(:,1)'                                                                                  %% 输出
        end
        if this_fit == gBest.fit(1) % this particle is the best of gBest
            best.fit = this_fit;
            best.para = gBest.para(1);
            best.arx = gBest.arx(:,1);
            best.arz = gBest.arz(:,1);
            best.musRec = muscleRecord;
            best.torque = torqueRecord;
            best.pose = skeletonPose;
            best.GRF = GRF;
            best.fitRecord = F;
            best.interForce = interForce;
            save(['best_' num2str(simSpeed) '_assisted.mat'], 'best');
        end
        
        if optConfig.stage == 2 && best.fit < 10
            debugFlag = 1;
        end
        
        fitRecord(k) = this_fit; % real fitness
        fit(k) = this_fit + optConfig.noise * randn; % fitness with noise
        
    end
    
    % sort by fitness and compute weighted mean into xme an
    fit = [fit, gBest.fit];
    arx = [arx, gBest.arx];
    arz = [arz, gBest.arz];
    [fit, idx] = sort(fit); % find min
    optConfig.xmean = arx(:, idx(1:optConfig.mu)) * optConfig.weights; % recombination
    zmean = arz(:, idx(1:optConfig.mu)) * optConfig.weights;
    
    % the best, elite avg & overall avg fit
    bestFit   = [bestFit, gBest.fit(1)];
    fitRecord = sort(fitRecord);
%     eliteFit  = [eliteFit, mean(fitRecord(1:optConfig.mu))];
%     allFit    = [allFit, mean(fitRecord)];
    disp(['the ' num2str(countEval) 'th iteration, target ' num2str(simSpeed) ' m/s, best fit: ' num2str(bestFit(end)) ', peak force: ' num2str(para.peakForce)]); % ', elite fit: ' num2str(eliteFit(end)) ', overall fit: ' num2str(allFit(end))])
    
    % cumulation: update evolution paths
    optConfig.ps = (1-optConfig.cs) * optConfig.ps + (sqrt(optConfig.cs*(2-optConfig.cs)*optConfig.mueff)) * (optConfig.B * zmean);
    hsig = norm(optConfig.ps)/sqrt(1-(1-optConfig.cs)^(2*countEval/optConfig.lambda))/optConfig.chiN < 1.4+2/(paraNum+1);
    optConfig.pc = (1-optConfig.cc)*optConfig.pc + hsig * sqrt(optConfig.cc*(2-optConfig.cc)*optConfig.mueff) * (optConfig.B*optConfig.D*zmean);
    
    % adapt covariance matrix C
    optConfig.C = (1-optConfig.c1-optConfig.cmu) * optConfig.C ... % regard old matrix
        + optConfig.c1 * (optConfig.pc*optConfig.pc' ... % plus rand one update
        + (1-hsig)*optConfig.cc*(2-optConfig.cc)*optConfig.C) ... % minor correction
        + optConfig.cmu ... % plus rank mu update
        * (optConfig.B * optConfig.D * arz(:, idx(1:optConfig.mu))) ...
        * diag(optConfig.weights) * (optConfig.B*optConfig.D*arz(:,idx(1:optConfig.mu)))';
    
    % adapt step-size sigma
    optConfig.sigma = optConfig.sigma * exp((optConfig.cs/optConfig.damps)*(norm(optConfig.ps)/optConfig.chiN-1));
    
    % update B & D from C
    optConfig.C = triu(optConfig.C) + triu(optConfig.C, 1)'; % enforce symmetry
    [B, D] = eig(optConfig.C); % eigen decomposition, B == normalized eigenvectors
    optConfig.B = B;
    optConfig.D = diag(sqrt(diag(D))); % D contains standard deviations now
    
    optConfig.Record = [optConfig.Record, optConfig.xmean];
    countEval = countEval + 1;
    F(countEval) = min(fit);
    %     waitbar(countEval/stopEval, bar, 'optimizing...');
    toc;
end

% toc;