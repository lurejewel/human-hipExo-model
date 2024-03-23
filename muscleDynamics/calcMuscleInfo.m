% -------------------------------------------------------------------------- %
% The OpenSim API is a toolkit for musculoskeletal modeling and simulation.  %
% See http:%opensim.stanford.edu and the NOTICE file for more information.  %
% OpenSim is developed at Stanford University and supported by the US        %
% National Institutes of Health (U54 GM072970, R24 HD065690) and by DARPA    %
% through the Warrior Web program.                                           %
%                                                                            %
% Copyright (c) 2005-2012 Stanford University and the Authors                %
% Author(s): Matthew Millard                                                 %
%                                                                            %
% Licensed under the Apache License, Version 2.0 (the 'License'); you may    %
% not use this file except in compliance with the License. You may obtain a  %
% copy of the License at http:%www.apache.org/licenses/LICENSE-2.0.         %
%                                                                            %
% Unless required by applicable law or agreed to in writing, softNware        %
% distributed under the License is distributed on an 'AS IS' BASIS,          %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   %
% See the License for the specific language governing permissions and        %
% limitations under the License.                                             %
% -------------------------------------------------------------------------- %
%
% Derivative work
% Authors(s): Millard
% Updates   : ported to code to Matlab
%
% If you use this code in your work please cite this paper
%
%  Millard, M., Uchida, T., Seth, A., & Delp, S. L. (2013).
%    Flexing computational muscle: modeling and simulation of
%    musculotendon dynamics. Journal of biomechanical engineering,
%    135(2), 021005.
%% 函数名
% function mtInfo = calcMuscleInfo(...
%     activationState,... % 肌肉激活度序列
%     pathState, ... % 肌肉+肌腱变化速度 & 长度
%     muscleState,... % 沿肌腱方向的肌肉变化速度 & 长度
%     muscleArchitecture,... % 肌肉的相关结构参数
%     normMuscleCurves,... % 几个特征曲线、它们的近似 & 逆
%     modelConfig) % 模型的相关参数（阻尼、迭代次数、容许度、最小激活度等）

function mtInfo = calcMuscleInfo(activationState, pathState, muscleState, muscleArchitecture, normMuscleCurves, modelConfig) %#codegen


% This function calculates the kinematics, forces, powers, stored elastic
% energy of the elements in a lumped parameter muscle model. This muscle
% model can be configured such that the tendon is rigid or elastic, and
% also so that the classic state equations are used or the updated damped
% equilibrium equations are used to model musculotendon dynamics. This is a
% Matlab port of the model described in
%
%  Millard, M., Uchida, T., Seth, A., & Delp, S. L. (2013).
%    Flexing computational muscle: modeling and simulation of
%    musculotendon dynamics. Journal of biomechanical engineering,
%    135(2), 021005.
%
% @param activationState: scalar of the muscle activation [0,1]
%
% @param pathState: 2x1 vector
%                   pathState(1) : lengthening velocity of the path in m/s
%                   pathState(2) : length of the path in m
%
% @param muscleState: this is dependent on the settings in modelConfig:
%        If modelConfig.useElasticTendon is 0: this field is ignored
%
%        If modelConfig.useElasticTendon is 0: then
%           muscleState is a scalar of fiberLengthAlongTendon
%
%        If muscleState is a 2x1 vector of
%          [fiberVelocityAlongTendon; fiberLengthAlongTendon]
%           then the model is put into initialization mode and the value of
%           the equilibrium equation is evaluated, rather than using it to
%           solve for the fiber velocity. This is ugly, I know.
%
% @param muscleArchtecture: a structure containing the architecture
%        information about the muscle. This structure has fields of:
%
%
%     .name    : string name of the muscle. e.g. 'soleus leftN'
%
%     .abbr    : abbreviated name e.g. 'solL'
%
%     .fiso    : maximum isometric force (n) of the muscle when the fiber
%                is at its optimal length, and it is static. e.g. 3800
%
%     .optimalFiberLength : length (m) of the muscle fiber when it
%                           generates its maximum isometric force
%                           e.g. 0.044m
%
%     .maximumNormalizedFiberVelocity : maximum velocity the fiber can
%                              contract or lengthen at in units
%                              of fiber lengths per second. This
%                              is normally set to 10 fiber lengths/second.
%
%     .pennationAngle : the angle (radians) between the fiber and the
%                       tendon when the fiber is at its optimal length.
%
%     .tendonSlackLength : the unloaded length (m) of tendon.
%
%     .minimumFiberLength : the minimum physical length (m) the fiber is
%                           allowed to achieve.
%
%     .minimumFiberLengthAlongTendon : the minimum length (m) of the fiber
%                                      projected along the tendon
%
%     .pennationAngleAtMinumumFiberLength : the pennation angle (radians)
%                                  of the fiber when it is at its minimum
%                                  length.
%
% @param normMuscleCurves: a structure containing the parameters needed to
%                          evaluate the normalized muscle curves (below)
%                          using the function calcBezierYFcnXDerivative.
%                          This structure must have the fields
%
%  .activeForceLengthCurve      : gen. by createActiveForceLengthCurve.m
%
%  .activeForceLengthCurveHACK  : gen. by createActiveForceLengthCurve.m
%                                 s.t. the minimum value is > 0
%
%  .fiberForceVelocityCurve: gen. by createFiberForceVelocityCurve.m
%
%  .fiberForceVelocityCurveHACK: gen. by createFiberForceVelocityCurve.m
%                                s.t. d(fvN)/d(dlceN) > 0
%
%  .fiberForceVelocityInverseCurveHACK gen.
%                             by createFiberForceVelocityInverseCurve.m
%                             s.t. d(fvN)/d(dlceN) > 0
%
%  .fiberForceLengthCurve: gen. by createFiberForceLengthCurve.m
%
%  .tendonForceLengthCurve: gen by createTendonForceLengthCurve.m
%
% @param modelConfig: a structure with the fields
%
%     .useFiberDamping  : 0: no damping element in the fiber
%                         1: Adds a damping element into the fiber. If the
%                            tendon is elastic then using fiber damping
%                            also changes the way the fiber velocity is
%                            calculated to a faster method
%
%     .useElasticTendon = 0: rigid tendon is used, and the model is
%                            stateless. If tendonSlackLength is less
%                            than the optimalFiberLength, this is a good
%                            option; otherwise a compromise is made on
%                            the accuracy of the predicted fiber forces
%                         1: the tendon element is treated as being elastic
%
%     .damping          = 0.1: the amount of damping to apply to the fiber
%                         if useFiberDamping is used. Note that the
%                         damping force is calculated as damping*dlceN,
%                         and so this coefficent represents the maximum
%                         damping force ever applied to the fiber.
%
%     .iterMax          = maximum number of Newton iterations permitted
%                         when solving the damped equilibrium equation
%
%     .tol              = normalized force tolerance used when solving the
%                         damped equilibrium equation.
%
%     .minActivation    = minimum activation level permitted. When the
%                         classic elastic model is used (useFiberDamping
%                         = 0 and useElasticTendon = 1) this value must be
%                        greater than 0.
%
% @returns mtInfo: A giant structure containing just about everything you
% might want to know about the muscle:
%
% 长度、角度相关
% mtInfo.muscleLengthInfo.fiberLength                 	  %length            m
% mtInfo.muscleLengthInfo.fiberLengthAlongTendon      	  %length            m
% mtInfo.muscleLengthInfo.normFiberLength             	  %length/length     m/m
% mtInfo.muscleLengthInfo.tendonLength                	  %length            m
% mtInfo.muscleLengthInfo.normTendonLength            	  %length/length     m/m
% mtInfo.muscleLengthInfo.tendonStrain                	  %length/length     m/m
% mtInfo.muscleLengthInfo.pennationAngle              	  %angle             1/s
% mtInfo.muscleLengthInfo.cosPennationAngle           	  %NA                NA
% mtInfo.muscleLengthInfo.sinPennationAngle           	  %NA                NA
% mtInfo.muscleLengthInfo.fiberPassiveForceLengthMultiplier %NA                NA
% mtInfo.muscleLengthInfo.fiberActiveForceLengthMultiplier  %NA                NA
% 速度相关
% mtInfo.fiberVelocityInfo.fiberVelocity                  %length/time           m/s
% mtInfo.fiberVelocityInfo.fiberVelocityAlongTendon       %length/time           m/s
% mtInfo.fiberVelocityInfo.normFiberVelocity              %(length/time)/length (m/s)/m
% mtInfo.fiberVelocityInfo.pennationAngularVelocity       %angle/time            rad/s
% mtInfo.fiberVelocityInfo.tendonVelocity                 %length/time           m/s
% mtInfo.fiberVelocityInfo.normTendonVelocity             %(length/time)/length  (m/s)/m
% mtInfo.fiberVelocityInfo.fiberForceVelocityMultiplier   %force/force           NA
% 力、功、能相关
% mtInfo.muscleDynamicsInfo.activation                	% of muscle active   NA
% mtInfo.muscleDynamicsInfo.fiberForce                	% force                N
% mtInfo.muscleDynamicsInfo.fiberForceAlongTendon     	% force                N
% mtInfo.muscleDynamicsInfo.normFiberForce            	% force/force          N/N
% mtInfo.muscleDynamicsInfo.activeFiberForce          	% force                N
% mtInfo.muscleDynamicsInfo.passiveFiberForce         	% force                N
% mtInfo.muscleDynamicsInfo.tendonForce               	% force                N
% mtInfo.muscleDynamicsInfo.normTendonForce           	% force/force          N/N
% mtInfo.muscleDynamicsInfo.fiberStiffness            	% force/length         N/m
% mtInfo.muscleDynamicsInfo.fiberStiffnessAlongTendon 	% force/length         N/m
% mtInfo.muscleDynamicsInfo.tendonStiffness           	% force/length         N/m
% mtInfo.muscleDynamicsInfo.muscleStiffness           	% force/length         N/m
% mtInfo.muscleDynamicsInfo.fiberActivePower          	% power   			   W
% mtInfo.muscleDynamicsInfo.fiberPassivePower         	% power   			   W
% mtInfo.muscleDynamicsInfo.tendonPower               	% power   			   W
% mtInfo.muscleDynamicsInfo.musclePower               	% power   			   W
% mtInfo.musclePotentialEnergyInfo.fiberPotentialEnergy   %energy   J
% mtInfo.musclePotentialEnergyInfo.tendonPotentialEnergy  %energy    J
% mtInfo.musclePotentialEnergyInfo.musclePotentialEnergy  %energy    J (Nm)
%
% %This field does not appear in the OpenSim model
% mtInfo.muscleDynamicsInfo.fiberParallelElementPower 	% power   			   W
% mtInfo.muscleDynamicsInfo.dampingForces             	% force   			   N
% mtInfo.muscleDynamicsInfo.dampingPower              	% power   			   W
% mtInfo.muscleDynamicsInfo.boundaryPower             	% power   			   W
%
% mtInfo.state.value
% mtInfo.state.derivative
%
% mtInfo.initialization.err                               % force/force           N/N
% mtInfo.initialization.Derr_DlceAT                      % (force/force) / (m/s) (N/N)/(m/s)

mtInfo = [];

%% Get the model configuration 模型配置

% 是否为第一次调用（=1则进入初始化模式）
useInitializationCode = 0;
if(isempty(muscleState) == 0) % 不为空，√
    if(length(muscleState) == 2) % 只有在第一次调用该函数时 == 2，以后都 == 4
        useInitializationCode = 1;
    end
end

% 阻尼系数
beta = modelConfig.damping;

%% Break out the input state vectors and model parameters into local variables

a            = clampActivation(activationState(1), modelConfig.minActivation, 1); % 肌肉活跃度，限制在[min,1]之间
dlp          = pathState(1); % 肌肉肌腱变化速度（沿肌腱方向）
lp           = pathState(2); % 肌肉肌腱长度（沿肌腱方向）
fiso         = muscleArchitecture.fiso; % 最大肌肉主动力
lceOpt       = muscleArchitecture.optimalFiberLength; % 最大力对应的肌纤维长度
alphaOpt     = muscleArchitecture.pennationAngle; % 最大力对应的羽状角（注意，肌肉主动力最大时，羽状角并非最大，因而肌肉并非最短）
ltSlk        = muscleArchitecture.tendonSlackLength; % 松弛时的肌腱
dlceMaxN     = muscleArchitecture.maximumNormalizedFiberVelocity; % 归一化的最大速度,10 fiber lengths/second
lceMin       = muscleArchitecture.minimumFiberLength; % 理论最短肌肉长度
lceATMin     = muscleArchitecture.minimumFiberLengthAlongTendon; % 上述长度沿肌腱方向的分量

% Create function handles for the curves to make the code easier to read
calcFalDer = @(arg1, arg2)calcBezierYFcnXDerivative(arg1, ...       % X值
    normMuscleCurves.activeForceLengthCurve, ...                    % 特征曲线1（肌肉主动力-肌纤维长度关系）
    arg2);                                                          % 阶数

calcFvDer = @(arg1, arg2)calcBezierYFcnXDerivative(arg1, ...        % X值
    normMuscleCurves.fiberForceVelocityCurve, ...                   % 特征曲线2（肌力-速度关系）
    arg2);                                                          % 阶数

calcFvInvHACKDer = @(arg1, arg2)calcBezierYFcnXDerivative(arg1, ... % X值
    normMuscleCurves.fiberForceVelocityInverseCurveHACK, ...        % 特征曲线2的近似的逆
    arg2);                                                          % 阶数

calcFpeDer = @(arg1, arg2)calcBezierYFcnXDerivative(arg1, ...       % X值
    normMuscleCurves.fiberForceLengthCurve, ...                     % 特征曲线3（肌肉被动力-肌纤维长度关系）
    arg2);                                                          % 阶数

calcFtDer = @(arg1, arg2)calcBezierYFcnXDerivative(arg1, ...        % X值
    normMuscleCurves.tendonForceLengthCurve, ...                    % 特征曲线4（肌腱力-肌腱长度关系）
    arg2);                                                          % 阶数

%% Check the model inputs

assert( a >= 0       && a <= 1     ,   'Check activation model should be [0, 1]');
assert( lp < 1       && lp >= 0    ,   'Check Units: path length in m!');
assert( alphaOpt < pi/2            ,   'Check Units: Pennation angle must be in radians!');
assert( lceOpt < 0.5 && lceOpt > 0 ,   'Check Units: fiber length in m!');
assert( ltSlk < 0.5  && ltSlk >= 0 ,   'Check Units: tendon slack length in m!');

%% Calculate the fiber velocity by satisfying the equilibrium equation 解算肌肉速度

%Short hand variable name conventions
%
% Quantity
%   l : length
%   e : strain
%   d : d/dt
%   D : a partial derivative
%   f : force
%   k : stiffness
%
%   alpha: pennation angle of the fiber w.r.t. tendon
%
% Parts
%   p  : path, as in the path the musuclotendon follows.
%   ce : contractile element
%   pe : parallel element
%   t  : tendon
%
% Modifier
%   N  : normalized. what this means is dependent on the quantity
%        for a precise definition refer to the Millard 2010 paper
%   AT : (a)long (t)endon. The projection of the quantity along the
%        direction of the tendon.
%
%   Slk: slack length

% %Fiber and tendon lengths 长度
% lce    = NaN; % 肌肉收缩单元长度（肌纤维长度？）
% lceAT  = NaN; % 上述长度在肌腱方向的投影
% alpha  = NaN; % 羽状角
% lt     = NaN; % 肌腱长度
% lceN   = NaN; % 归一化的肌肉收缩单元长度
% ltN    = NaN; % 归一化的肌腱长度
% etN    = NaN; % 归一化的肌腱应变？
% 
% sinAlpha = NaN; % 羽状角的正弦
% cosAlpha = NaN; % 羽状角的余弦
% 
% %Fiber and tendon velocities 速度
% dlce   = NaN; % 肌肉收缩单元速度
% dlceAT = NaN; % 上诉速度在肌腱方向的投影
% dalpha = NaN; % 羽状角角速度
% dlt    = NaN; % 肌腱速度
% dlceN  = NaN; % 归一化的肌肉收缩单元速度
% dltN   = NaN; % 归一化的肌腱速度
% 
% %Normalized musculotendon curve values 特征曲线
% falN        = NaN; % 归一化的肌肉主动力-肌肉长度曲线
% DfalN_DlceN = NaN; % 上述曲线对肌肉收缩单元长度（肌肉长度）求偏导
% fvN         = NaN; % 归一化的肌肉力-速度曲线
% fpeN        = NaN; % 归一化的肌肉被动力（平行单元力）-肌肉长度曲线
% DfpeN_DlceN = NaN; % 上述曲线对肌肉收缩单元长度（肌肉长度）求偏导
% ftN         = NaN; % 归一化的肌腱力-肌腱长度曲线
% DftN_DltN   = NaN; % 上述曲线对肌腱长度求偏导
% 
% %Forces, Stiffnesses 刚度
% ffaN       = NaN; %(f)orce (f)iber (a)ctive normalized 归一化的主动收缩力
% ffpN       = NaN; %(f)orce (f)iber (p)assive normalized 归一化的被动拉伸力
% ffN        = NaN; %fiber force 肌肉力（两者相加？）
% 
% kt         = NaN; %tendon stiffness in N/m 肌腱刚度
% kf         = NaN; %fiber stiffness in N/m 肌肉刚度
% kfAT       = NaN; %fiber stiffness along the tendon 肌肉刚度沿肌腱的投影
% km         = NaN; %stiffness of the entire muscle % 肌肉+肌腱的刚度

% Equations for the initialization error
init              = [];
init.err          = NaN;
init.Derr_DlceAT  = NaN; % 误差 对 肌肉主动收缩单元长度沿肌腱方向分量 的 偏导

% 给肌肉长度 & 速度（沿肌腱方向）赋值
if(useInitializationCode == 1) % 第一次调用
    dlceAT = muscleState(1); % 沿肌腱方向的肌肉速度初值
    lceAT  = muscleState(2); % 沿肌腱方向的肌肉长度初值
else % 第二次及以后调用：只知道长度。速度需要算
    dlceAT = NaN;
    lceAT  = muscleState(1);
end

% Clamp the fiber 限制肌肉长度
fiberState = clampFiberStateAlongTendon(lceAT,dlceAT,lceATMin);
lceAT      = fiberState.lceAT; % 肌肉沿肌腱长度
dlceAT     = fiberState.dlceAT; % 肌肉沿肌腱速度
% isClamped  = fiberState.isClamped; % 是否做了限幅

% Calculate the pennation angle and fiber 根据沿肌腱方向的肌肉长度速度 反算 羽状角、羽状角速度、肌肉长度速度
fiberKinematics = calcFixedWidthPennatedFiberKinematics(lceAT, dlceAT, lceOpt, alphaOpt);
lce     = fiberKinematics.fiberLength; % 肌肉长度
dlce    = fiberKinematics.fiberVelocity; % 肌肉速度
alpha   = fiberKinematics.pennationAngle; % 羽状角
% dalpha  = fiberKinematics.pennationAngularVelocity; % 羽状角角速度

lceN    = lce/lceOpt; % 归一化后的肌肉长度（÷最大肌主动肌肉力时的肌肉长度）
cosAlpha= cos(alpha);
sinAlpha= sin(alpha);

lt = lp-lceAT; % 肌腱长度
ltN= lt/ltSlk; % 归一化后的肌腱长度（÷松弛时的肌腱长度）
% etN= ltN-1; % 肌腱应变

% Normalized musculotendon curve values that are common to both the damped and inverted musculotendon models.
% 根据特征曲线3，求该肌肉长度下的被动力和偏导
fpeN        =  calcFpeDer(lceN,0);
DfpeN_DlceN =  calcFpeDer(lceN,1);
% 根据特征曲线4，求该肌腱长度下的力和偏导
ftN         =  calcFtDer(ltN, 0);
DftN_DltN   =  calcFtDer(ltN, 1);
% 根据特诊曲线1和肌肉长度计算主动力和偏导
falN       = calcFalDer(lceN,0);
DfalN_DlceN = calcFalDer(lceN,1);

iterMax = modelConfig.iterMax; % = 100
tol     = modelConfig.tol; % 1e-6
err     = 10*tol;
iter    = 1;

% Ddlce_DdlceN = (lceOpt*dlceMaxN); % 未使用？下面那个也是
% 
% Dalpha_Dlce = calcFixedWidthPennationDalphaDlce(alpha,...
%     lce,...
%     lceOpt,...
%     alphaOpt);

if(useInitializationCode == 0)
    
    % 根据那个公式求肌肉速度
    fvN    = ((ftN/cos(alpha)) - fpeN) / (a*falN + 1e-8); % + 1e-8可能是防止分母为零
    dlceN = calcFvInvHACKDer(fvN,0);
    % 对速度进行限幅
    if(dlceN > 1)
        dlceN = a*0.99;
    end
    if(dlceN < -1)
        dlceN = -a*0.99;
    end    
    
    % use Newton's method to polish the root to high precision
    while abs(err) > tol && iter < iterMax
        
        % 因为刚刚对速度进行了限幅，所以重新求肌肉力和偏导
        fvN         = calcFvDer(dlceN,0);
        DfvN_DdlceN = calcFvDer(dlceN,1);
        
        %Tension is +
        %shortening is -
        % ... thus the sign of beta is +
        ffN         = a*(falN*fvN) + fpeN + beta*dlceN; % 总肌肉力（主动力 + 被动力）
        DffN_DdlceN = (a*(falN*DfvN_DdlceN) + beta); % 偏导 根据求导公式得到
        
        err = ffN*cosAlpha - ftN; % 沿肌腱方向的总肌肉力投影 = 肌腱力 (+ error)
        Derr_DdlceN  = DffN_DdlceN*cosAlpha;
        
        if(abs(err) > tol && abs(Derr_DdlceN) > eps*10) % 牛顿迭代法
            delta = -err/Derr_DdlceN;
            dlceN = dlceN + delta;
            
        elseif( abs(err) > tol && abs(Derr_DdlceN) <= eps*10)
            %This code should never be entered given that
            %the smallest gradient is beta*cos(maxPennAngle)
            %which is approx 0.0017 when beta is 0.1 and
            %the max pennation angle is 89 degrees. If the
            %parameters are chosen to be particularly aggressive
            %the gradient may hit zero as dlceN -> dlceMaxN. In
            %this case we set dlceN to the ends of the fvN curve
            %that have a nonzero slope and hope for the best.
            if(dlceN < dlceNNearMaxShortening)
                dlceN = dlceNNearMaxShortening;
            elseif(dlceN > dlceNNearMaxLengthening)
                dlceN = dlceNNearMaxLengthening;
            else
                msg=['Damped equilibrium Newton method has a\n',...
                    ' zero gradient for an unexpected reason\n',...
                    ' lceNMin %e \n lceN %e ',...
                    ' \n alpha %e  \n dlceN %e\n'];
                assert(0,sprintf(msg,lceMin,lceN,alpha,dlceN));
            end
            
        end
        iter = iter+1;
    end % 牛顿迭代法结束
    
    % Clamp the fiber velocity if necessary 限制最短肌肉长度和对应肌肉速度
    dlce       = dlceN * lceOpt * dlceMaxN;
    fiberState = clampFiberState(lce,dlce,lceMin);
    isClamped  = fiberState.isClamped;
    dlce       = fiberState.dlce;
    
    if(isClamped == 0 && abs(err) > tol)
        msg=['Damped equilibrium eqn not satisified\n',...
            ' lceNMin %e \n lceN %e ',...
            ' \n alpha %e  \n dlceN %e\n'];        
        smsg  = sprintf(msg,lceMin,lceN,alpha,dlceN);        
        assert(0, smsg);
    end
    
end

% 因为刚刚做了限幅，所以现在重新计算肌肉速度和对应的肌肉力
dlceN  = dlce/(lceOpt*dlceMaxN);
fvN    = calcFvDer(dlceN, 0);

% 重新计算总肌肉力（主动+被动）
ffaN       = a*(falN*fvN);
ffpN       = fpeN + beta*dlceN;
ffN        = ffaN + ffpN;

%d/dlce   a*falN*fvN + fpeN + beta*dlceN
%   =     d(ffN)/d(lce)
%   =     a*DfalN_DlceN*fvN + DfpeN_DlceN)*dlceNdlce
kf         = fiso*(a*DfalN_DlceN*fvN + DfpeN_DlceN)*(1/lceOpt); % 当前肌肉长度下的总肌肉刚度（总肌肉力）

Dalpha_Dlce = calcFixedWidthPennationDalphaDlce( alpha,...
    lce,...
    lceOpt,...
    alphaOpt);
% d/dlce    fiso*ffN*cos(alpha)
%     =     kf*cos(alpha) - fiso*ffN*sin(alpha)*Dalpha_Dlce
%
kfAT       = kf*cosAlpha - fiso*ffN*sinAlpha*Dalpha_Dlce; %  当前肌肉长度下的总肌肉刚度（总肌肉力沿肌腱方向的分量）

%Fiber and tendon velocities 根据前面得到的肌肉长度、速度计算羽状角角速度 及 沿肌腱方向的肌肉&肌腱变化速度
fiberKinematics = ...
    calcFixedWidthPennatedFiberKinematicsAlongTendon( lce,...
    dlce,...
    lceOpt,...
    alphaOpt);
dlceAT = fiberKinematics.fiberVelocityAlongTendon;
% dalpha = fiberKinematics.pennationAngularVelocity;

% dlt    = dlp - dlceAT;
% dltN   = dlt/ltSlk;

% 当前肌腱长度下的肌腱刚度，根据特征曲线4可直接得到，与模型中是否含阻尼项无关
ktN = DftN_DltN;
kt  = ktN * (fiso / ltSlk);

%This can blow up: look at the denominator
%                  then go look at the slope of
%                  the active force length curve and the fiber force
%                  length curve.
% km  = kfAT*kt / (kt + kfAT); % 串联刚度

%Initialization Equations
%  We need:
%      ffAT - ftN = 0
%  And the partial derivative
%      DffAT_DlceAT - DftN_DlceAT
init.err        = fiso*( (ffaN + ffpN)*cosAlpha - ftN ); % 残余力

Dff_DlceAT   = kfAT;
DftN_Dlt     = kt;
% lt         = lp - lceAT
% dlt_dlceAT = -1
Dlt_DlceAT   = -1; % 因为lt+lceAT即肌肉肌腱总长度只与时间有关，所以这两个变量此消彼长
DftN_DlceAT  = DftN_Dlt * Dlt_DlceAT;

init.Derr_DlceAT = Dff_DlceAT - DftN_DlceAT;

%% Populate the muscle length and velocity information 将前面算得的长度和速度信息整合入mtInfo中

mtInfo.muscleLengthInfo.normFiberLength              = lceN;       %length/length     m/m
mtInfo.muscleLengthInfo.pennationAngle               = alpha;      %angle             1/s
mtInfo.fiberVelocityInfo.fiberVelocity               = dlce;    %length/time           m/s

%% Populate the dynamics and energy information structures

mtInfo.muscleDynamicsInfo.normFiberForce            = ffN;            % force/force          N/N
mtInfo.muscleDynamicsInfo.activeFiberForce          = ffaN*fiso;      % force                N
mtInfo.muscleDynamicsInfo.passiveFiberForce         = ffpN*fiso;      % force                N
mtInfo.muscleDynamicsInfo.fiberStiffnessAlongTendon = kfAT;           % force/length         N/m
mtInfo.muscleDynamicsInfo.tendonStiffness           = kt;             % force/length         N/m

% %This field does not appear in the OpenSim model
mtInfo.initialization = init;

mtInfo.state.value      = lceAT; % 肌肉沿肌腱方向的投影长度
mtInfo.state.derivative = dlceAT; % 上述长度的变化率