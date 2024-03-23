%/* -------------------------------------------------------------------------- *
% *                           singleMuscleBench.cpp                            *
% * -------------------------------------------------------------------------- *
% * The OpenSim API is a toolkit for musculoskeletal modeling and simulation.  *
% * See http://opensim.stanford.edu and the NOTICE file for more information.  *
% * OpenSim is developed at Stanford University and supported by the US        *
% * National Institutes of Health (U54 GM072970, R24 HD065690) and by DARPA    *
% * through the Warrior Web program.                                           *
% *                                                                            *
% * Copyright (c) 2005-2012 Stanford University and the Authors                *
% * Author(s): Matthew Millard                                                 *
% *                                                                            *
% * Licensed under the Apache License, Version 2.0 (the "License"); you may    *
% * not use this file except in compliance with the License. You may obtain a  *
% * copy of the License at http://www.apache.org/licenses/LICENSE-2.0.         *
% *                                                                            *
% * Unless required by applicable law or agreed to in writing, software        *
% * distributed under the License is distributed on an "AS IS" BASIS,          *
% * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
% * See the License for the specific language governing permissions and        *
% * limitations under the License.                                             *
% * -------------------------------------------------------------------------- */
%
% Derivative work
% Date      : March 2015
% Authors(s): Millard
% Updates   : Ported to code to Matlab which included some major rework
%
% If you use this code in your work please cite this paper
%
%  Millard, M., Uchida, T., Seth, A., & Delp, S. L. (2013).
%    Flexing computational muscle: modeling and simulation of
%    musculotendon dynamics. Journal of biomechanical engineering,
%    135(2), 021005.
%%
function benchRecord = ...
    runMillard2012ComputationalBenchmark(calcMuscleInfoFcn,...
    calcInitialMuscleStateFcn,...
    benchConfig,...
    muscleIdx,...
    record,...
    tspan,...
    muscleState0,...
    muscleStateRecord,...
    skeletonPose)
%%
% This function runs the computational benchmark that is described in this
% paper.
%
%    Millard, M., Uchida, T., Seth, A., & Delp, S. L. (2013).
%    Flexing computational muscle: modeling and simulation of
%    musculotendon dynamics. Journal of biomechanical engineering,
%    135(2), 021005.
%
% @param calcMuscleInfoFcn: a function handle to a muscle function
%                      like (calcMillard2012DampedEquilibriumMuscleInfo.m)
%                      and takes arguments of activation, pathState, and
%                      muscle state
%
% @param calcInitialMuscleStateFcn: a function handle to a function that
%                                 takes arguments of activation, path
%                                 state, calcMuscleInfoFcn, and
%                                 a struct initConfig (see
%                                 calcInitialMuscleState.m for details)
%                                 and returns a muscle state that satisfies
%                                 the equilibrium equation
%
% @param benchConfig: a structure that configures this constant activation
% sinusoidal stretch benchmark simulation:
%
%   benchConfig.npts                 : number of points to evaluate the
%                                      model at during a 1 second constant
%                                      activation sinusoidal stretch
%                                      simulation
%
%   benchConfig.numberOfMuscleStates : 0 for rigid tendon,
%                                      1 for elastic tendon
%
%   benchConfig.minimumActivation    : 0 unless the classic elastic tendon
%                                      model is being used, then it should
%                                      be > 0, and probably 0.05
%
%   benchConfig.name                 : short musclemodel name e.g.
%                                      'soleusRigidTendon'
%
% @param figBasicInfo   : handle to an empty figure
%
% @param figEnergyInfo  : handle to an empty figure
%
% @param figPowerInfo   : handle to an empty figure
%
% @return benchRecord: A structure containing a set of matricies, where
%                      each column represents the data of 1
%                      constant-activation sinusoidal-stretch simulation.
%
%     benchRecord.activation
%     benchRecord.cpuTime
%     benchRecord.normfiberForceAlongTendon
%     benchRecord.normFiberLength
%     benchRecord.pennationAngle
%     benchRecord.normFiberVelocity
%     benchRecord.pennationAngVelocity
%     benchRecord.fiberStiffnessAlongTendon
%     benchRecord.tendonStiffnessAlongTendon
%     benchRecord.muscleStiffness
%     benchRecord.pathLength
%     benchRecord.pathVelocity

%% 初始化

a       = benchConfig.activation; % 激活度起始值，这里是一个数（时间序列由pathFcn指定）
if(min(a) < benchConfig.minimumActivation) % 如果小于肌肉规定的最小激活度，则限制为最小激活度值（一般0.01）
    [~, idx] = min(a);
    a(idx)   = benchConfig.minimumActivation;
end

pathFcn = benchConfig.pathFcn;
actFcn  = benchConfig.actFcn;
excFcn  = benchConfig.excFcn;

benchRecord = [];
muscleStateV = [];

% 得到肌肉状态的导数和一些功率信息【状态方程】
dfcn = @(argt,argState)...
    calcPrescribedMusculotendonStateDerivativeWrapper(...
    argt,...
    muscleIdx,...
    argState,...
    pathFcn,...
    excFcn,...
    actFcn,...
    calcMuscleInfoFcn,...
    record,...
    muscleStateRecord,...
    skeletonPose);

%% 求解初始状态（肌肉沿肌腱方向投影的长度）
if (muscleState0 == 0) % 0~0.01秒的仿真
    
    initConfig.iterMax = 100;
    initConfig.tol     = 1e-8;
    initConfig.useStaticFiberSolution = 0; % 不把肌肉速度视为0（但端点加速度视为0）
    initSoln = calcInitialMuscleStateFcn(a,...
        pathFcn(0, muscleIdx, muscleStateRecord),...
        calcMuscleInfoFcn,...
        initConfig);
    
    if(initSoln.converged == 0 && initSoln.isClamped == 0) % 负刚度的情况
        %If we're here then we've been unlucky enough to be in the
        %negative stiffness region of the active force length curve and
        %we will have to settle for an initial condition where the
        %velocity of the fiber is 0 ... which often leads to force
        %transients at the beginning of the simulation.
        initConfig.useStaticFiberSolution = 1; % 只能把肌肉速度视为0，重新计算，但这样会导致整个仿真初始时会有一个大的瞬态
        initSoln = calcInitialMuscleStateFcn(a,...
            pathFcn(0, muscleIdx, muscleStateRecord),...
            calcMuscleInfoFcn,...
            initConfig);
        
        assert(initSoln.converged == 1 || initSoln.isClamped == 1,...
            'Failed to bring the muscle to a valid initial solution');
    end
    
    muscleState0 = initSoln.muscleState;
    
end
%% 时程内进行仿真计算
% options = odeset('RelTol',benchConfig.relTol, 'AbsTol',benchConfig.absTol, 'Stats','off'); % 求解完成后是否输出求解信息（成功步长的次数等）
% [xe, ye] = ode45(dfcn, tspan, [muscleState0], options); % tspan内进行仿真
% tV       = xe;

%% 龙格库塔法代替ode15s

h       = 0.0005;
tV      = tspan(1) : h : tspan(2);
% ye(1,:) = [muscleState0(:);0;0;0];
ye      = zeros(1, length(tV));
ye(1)   = muscleState0;
for xe = 1 : length(tV)-1
    t1 = tV(xe);
%     k1 = dfcn(t1, [ye(xe,1);ye(xe,2);ye(xe,3);ye(xe,4)]);
%     k2 = dfcn(t1+h/2, [ye(xe,1);ye(xe,2);ye(xe,3);ye(xe,4)]+h/2*k1);
%     k3 = dfcn(t1+h/2, [ye(xe,1);ye(xe,2);ye(xe,3);ye(xe,4)]+h/2*k2);
%     k4 = dfcn(t1+h, [ye(xe,1);ye(xe,2);ye(xe,3);ye(xe,4)]+h*k3);
%     ye(xe+1,:) = ye(xe,:) + h/6*(k1'+2*k2'+2*k3'+k4');
    k1 = dfcn(t1, ye(xe));
    k2 = dfcn(t1+h/2, ye(xe)+h/2*k1);
    k3 = dfcn(t1+h/2, ye(xe)+h/2*k2);
    k4 = dfcn(t1+h, ye(xe)+h*k3);
    ye(xe+1) = ye(xe) + h/6*(k1+2*k2+2*k3+k4);
end

%% 数据保存和记录

% muscleStateV = ye(:,1); % lceAT随时间的变化
muscleStateV = ye; % lceAT随时间的变化

for j = 1 : length(tV) % 收集每时刻的数据
    
%     muscleState = muscleStateV(j,:)';  % 肌肉沿肌腱方向的长度
    muscleState = muscleStateV(j);  % 肌肉沿肌腱方向的长度
    
    excitation      = excFcn(muscleIdx, record, skeletonPose);
    activation      = actFcn(tV(j), muscleIdx, excitation, record);
    pathState       = pathFcn(tV(j), muscleIdx, muscleStateRecord); % 预先设定的肌肉+肌腱速度&长度
        
    % 重新根据仿真得到的肌肉长度和预先设定值 算一下该时刻的肌肉信息
    mtInfo = calcMuscleInfoFcn(activation,...
        pathState,...
        muscleState);

    
    lceN    = mtInfo.muscleLengthInfo.normFiberLength;
    alpha   = mtInfo.muscleLengthInfo.pennationAngle;
    
    fNAT    = mtInfo.muscleDynamicsInfo.normFiberForce*cos(alpha);
    fpe     = mtInfo.muscleDynamicsInfo.passiveFiberForce;
    
    % force and kinematic information
    benchRecord.activationState(j)             = activation; % 第j时刻
    benchRecord.excitation(j)                  = excitation;
    benchRecord.normfiberForceAlongTendon(j)   = fNAT;
    benchRecord.normFiberLength(j)             = lceN;
    benchRecord.passiveFiberForce(j)           = fpe;
    benchRecord.muscleState(j)                 = muscleStateV(j);    
    benchRecord.fiberVelocity(j)               = mtInfo.fiberVelocityInfo.fiberVelocity;
    benchRecord.activeFiberForce(j)            = mtInfo.muscleDynamicsInfo.activeFiberForce;
    
end

benchRecord.muscleIdx = muscleIdx;