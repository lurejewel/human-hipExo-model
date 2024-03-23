%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Name: cal_gaitPhase
% Function:
% - 根据当前时刻的人体运动姿态及地反力，推测当前所处的步态阶段。
% Parameter(s):
% - i: loop number
% - skeletonPose: struct that records the motion and gait phase of the
% rigid model during simulation.
% - GRF: ground reaction force, including friction forces and normal forces
% Author: Jin Wei
% Last Update: 2022/11/22
% Log:
% #1 basic functionalities
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function skeletonPose = cal_gaitPhase(i, simT, skeletonPose, GRF, modelConfig)
%% 参数设置

BW = modelConfig.boneMass.all * modelConfig.g; % body weight (N)
stanceTh = 0.23137978; % for EarlyStance phase detection

%% 读取当前运动姿态和地反力

px      = skeletonPose.pos.pelvisX(i);
pq      = skeletonPose.pos.pelvisTilt(i);
hipR    = skeletonPose.pos.hipR(i);
kneeR   = skeletonPose.pos.kneeR(i);
ankleR  = skeletonPose.pos.ankleR(i);
hipL    = skeletonPose.pos.hipL(i);
kneeL   = skeletonPose.pos.kneeL(i);
ankleL  = skeletonPose.pos.ankleL(i);

FnL = GRF(7) + GRF(8);
FnR = GRF(5) + GRF(6);

thetaL = pq + hipL + kneeL + ankleL;
thetaR = pq + hipR + kneeR + ankleR;

pelvisCOMX = px - 7.07/100 * cos(pq);
femurAxisX = px - 7.07/100 * cos(pq) + 6.61/100 * sin(pq);
tibiaAxisXR = femurAxisX + 39.6/100 * sin(pq+hipR);
tibiaAxisXL = femurAxisX + 39.6/100 * sin(pq+hipL);
ankleAxisXR = tibiaAxisXR + 43/100 * sin(pq+hipR+kneeR);
ankleAxisXL = tibiaAxisXL + 43/100 * sin(pq+hipL+kneeL);
calcnCOMXR = ankleAxisXR - (4.877-10)/100 * cos(thetaR) + (4.195-3)/100 * sin(thetaR);
calcnCOMXL = ankleAxisXL - (4.877-10)/100 * cos(thetaL) + (4.195-3)/100 * sin(thetaL);

%% 确定步态阶段

if i > 1
    
    phaseL = skeletonPose.gaitPhaseL(i-1);
    phaseR = skeletonPose.gaitPhaseR(i-1);
    
    switch phaseL
        case 0 % Early Stance -> Late Stance
            if calcnCOMXL < pelvisCOMX
                phaseL = 1;
            end
        case 1 % Late Stance -> Liftoff
            if FnR/BW > stanceTh || calcnCOMXL+1 < pelvisCOMX
                phaseL = 2;
                % update gait cycle time
                if skeletonPose.lastGaitEventL == -1 % 1st cycle
                    skeletonPose.gaitCycleL = 1.2;
                else
                    skeletonPose.gaitCycleL = 0.33 * skeletonPose.gaitCycleL + 0.67 * (i*simT-skeletonPose.lastGaitEventL);
                end
                % update gait event time
                skeletonPose.lastGaitEventL = i*simT;
            end
        case 2 % Liftoff -> Swing
            if FnL/BW < stanceTh
                phaseL = 3;
            end
        case 3 % Swing -> Landing
            if calcnCOMXL > pelvisCOMX
                phaseL = 4;
            end
        case 4 % Landing -> Early Stance
            if FnL/BW > stanceTh
                phaseL = 0;
            end
        otherwise
            error('invalid step phase.');
    end
    
    switch phaseR
        case 0 % Early Stance -> LateStance
            if calcnCOMXR < pelvisCOMX
                phaseR = 1;
            end
        case 1 % Late Stance -> Liftoff
            if FnL/BW > stanceTh || calcnCOMXR+1 < pelvisCOMX
                phaseR = 2;
                % update gait cycle time
                if skeletonPose.lastGaitEventR == -1 % 1st cycle
                    skeletonPose.gaitCycleR = 1.2;
                else
                    skeletonPose.gaitCycleR = 0.33 * skeletonPose.gaitCycleR + 0.67 * (i*simT-skeletonPose.lastGaitEventR);
                end
                % update gait event time
                skeletonPose.lastGaitEventR = i*simT;
            end
        case 2 % Liftoff -> Swing
            if FnR/BW < stanceTh
                phaseR = 3;
            end
        case 3 % Swing -> Landing
            if calcnCOMXR > pelvisCOMX
                phaseR = 4;
            end
        case 4 % Landing -> Early Stance
            if FnR/BW > stanceTh
                phaseR = 0;
            end
        otherwise
            error('invalid step phase');
    end
    
elseif i == 1
    
    phaseL = skeletonPose.gaitPhaseL(1);
    phaseR = skeletonPose.gaitPhaseR(1);
    
else
    
    error('loop number should be positive.');
    
end

skeletonPose.gaitPhaseL(i) = phaseL;
skeletonPose.gaitPhaseR(i) = phaseR;
if skeletonPose.lastGaitEventL ~= -1
    skeletonPose.gaitPercentL = (i*simT - skeletonPose.lastGaitEventL) / skeletonPose.gaitCycleL * 100;
end
if skeletonPose.lastGaitEventR ~= -1
    skeletonPose.gaitPercentR = (i*simT - skeletonPose.lastGaitEventR) / skeletonPose.gaitCycleR * 100;
end

end