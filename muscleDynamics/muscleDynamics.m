%%
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
% Authors(s): Millard, Jin Wei
% Updates   : - ported to code to Matlab (Millard)
%             - compute muscle dynamics according to the muscle length and
%             activation data read from SCONE (Jin Wei)
%             - enable parallel computation (Jin Wei)
%
% Last Update: 2022/10/31
%
% If you use this code in your work please cite this paper
%
%  Millard, M., Uchida, T., Seth, A., & Delp, S. L. (2013).
%    Flexing computational muscle: modeling and simulation of
%    musculotendon dynamics. Journal of biomechanical engineering,
%    135(2), 021005.
%%

function [record, muscleState0] = muscleDynamics(i, simT, muscleSim, benchConfig, muscleState0, muscleArch, normMuscleCurves, muscleConfig, record, muscleStateRecord, skeletonPose)
%% 仿真
% i          1            2         ...
% tspan  [0, 0.005]  [0.005, 0.01]  ... (assuming simT = 0.005)

tspan  = [(i-1)*simT, i*simT];

% benchRecord = init_benchRecord();
parfor muscleIdx = muscleSim % 第muscleIdx个肌肉
    
    % 根据模型计算动力学的函数重定义
    calMuscleInfoFcn = @(actState1,pathState2,mclState3)calcMuscleInfo(actState1, pathState2, mclState3, muscleArch(muscleIdx), normMuscleCurves, muscleConfig);
    calInitMuscleStateFcn = @(actState1,pathState2,calcMuscleInfo3, initConfig4)calcInitialMuscleState(actState1, pathState2, muscleArch(muscleIdx), calcMuscleInfo3, initConfig4);
    
    %%%%%%%%%%
    % 主程序 %
    %%%%%%%%%%
    this_benchRecord = runMillard2012ComputationalBenchmark(calMuscleInfoFcn, calInitMuscleStateFcn,...
        benchConfig, muscleIdx, record, tspan, muscleState0(muscleIdx), muscleStateRecord, skeletonPose);
    benchRecord(muscleIdx) = this_benchRecord;
end

%% 赋值

for muscleIdx = muscleSim
    
    record(muscleIdx).activationState(i)             = benchRecord(muscleIdx).activationState(end);
    record(muscleIdx).excitationState(i)             = benchRecord(muscleIdx).excitation(end);
    record(muscleIdx).muscleState(i)                 = benchRecord(muscleIdx).muscleState(end);
    
    record(muscleIdx).normFiberLength(i)             = benchRecord(muscleIdx).normFiberLength(end);
%     record(muscleIdx).FiberLength(i)                 = benchRecord(muscleIdx).FiberLength(end);
%     record(muscleIdx).normTendonLength(i)            = benchRecord(muscleIdx).normTendonLength(end);
%     record(muscleIdx).TendonLength(i)                = benchRecord(muscleIdx).TendonLength(end);
%     record(muscleIdx).pathLength(i)                  = benchRecord(muscleIdx).pathLength(end);
%     record(muscleIdx).pennationAngle(i)              = benchRecord(muscleIdx).pennationAngle(end);
    
%     record(muscleIdx).pennationAngVelocity(i)        = benchRecord(muscleIdx).pennationAngVelocity(end);
%     record(muscleIdx).fiberStiffnessAlongTendon(i)   = benchRecord(muscleIdx).fiberStiffnessAlongTendon(end);
%     record(muscleIdx).tendonStiffnessAlongTendon(i)  = benchRecord(muscleIdx).tendonStiffnessAlongTendon(end);
%     record(muscleIdx).muscleStiffness(i)             = benchRecord(muscleIdx).muscleStiffness(end);
    
%     record(muscleIdx).pathVelocity(i)                = benchRecord(muscleIdx).pathVelocity(end);
%     record(muscleIdx).normFiberVelocity(i)           = benchRecord(muscleIdx).normFiberVelocity(end);
    record(muscleIdx).fiberVelocity(i)               = benchRecord(muscleIdx).fiberVelocity(end);
%     record(muscleIdx).fiberVelocityAlongTendon(i)    = benchRecord(muscleIdx).fiberVelocityAlongTendon(end);
%     record(muscleIdx).tendonVelocity(i)              = benchRecord(muscleIdx).tendonVelocity(end);
    
    record(muscleIdx).activeFiberForce(i)            = benchRecord(muscleIdx).activeFiberForce(end);
    record(muscleIdx).passiveFiberForce(i)           = benchRecord(muscleIdx).passiveFiberForce(end);
%     record(muscleIdx).tendonForce(i)                 = benchRecord(muscleIdx).tendonForce(end);
%     record(muscleIdx).dampingForce(i)                = benchRecord(muscleIdx).dampingForce(end);
    record(muscleIdx).normfiberForceAlongTendon(i)   = benchRecord(muscleIdx).normfiberForceAlongTendon(end);

end

end