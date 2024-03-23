%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name: init_muscleState
% 
% Function: 初始化肌肉长度 & 速度结构体数组变量。
% 
% Parameter(s):
% - tEnd: 仿真结束时间，用于计算控制点数 end time of simulation, used for 
% calculating number of points (size of array)
% - T: 仿真步长 simulation step
% - L: 肌肉数 number of muscles
% - normalGait: SCONE导出的仿真数据，用于初始化0时刻的肌肉长度和速度 simulation
% data exported from SCONE, used for initializing muscle-tendon length and
% velocity at time t = 0
% 
% Output(s):
% - muscleStateRecord: 存储整个时程肌肉长度和速度数据的结构体数组 structural 
% array that stores the muscle length and velocity data through whole 
% simulation time
% 
% Last Update: 2022/11/12
% 
% Log:
% #2 add element <loopNum>; change the way len & vel store
% #1 basic functionalities
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function muscleStateRecord = init_muscleState(tEnd, simT, muscleNum, initArch)

npts = fix(tEnd/simT); % 控制点数

muscleStateRecord.len       = -ones(muscleNum, npts);
muscleStateRecord.vel       = -ones(muscleNum, npts);
muscleStateRecord.loopNum   = 0;

% t = 0 时的肌肉肌腱长度 & 速度
muscleStateRecord.len(1,1) = initArch.lenMT.vasR;
muscleStateRecord.vel(1,1) = initArch.velMT.vasR;

muscleStateRecord.len(2,1) = initArch.lenMT.hamR;
muscleStateRecord.vel(2,1) = initArch.velMT.hamR;

muscleStateRecord.len(3,1) = initArch.lenMT.gluR;
muscleStateRecord.vel(3,1) = initArch.velMT.gluR;

muscleStateRecord.len(4,1) = initArch.lenMT.iliR;
muscleStateRecord.vel(4,1) = initArch.velMT.iliR;

muscleStateRecord.len(5,1) = initArch.lenMT.gasR;
muscleStateRecord.vel(5,1) = initArch.velMT.gasR;

muscleStateRecord.len(6,1) = initArch.lenMT.solR;
muscleStateRecord.vel(6,1) = initArch.velMT.solR;

muscleStateRecord.len(7,1) = initArch.lenMT.tibR;
muscleStateRecord.vel(7,1) = initArch.velMT.tibR;

muscleStateRecord.len(8,1) = initArch.lenMT.vasL;
muscleStateRecord.vel(8,1) = initArch.velMT.vasL;

muscleStateRecord.len(9,1) = initArch.lenMT.hamL;
muscleStateRecord.vel(9,1) = initArch.velMT.hamL;

muscleStateRecord.len(10,1) = initArch.lenMT.gluL;
muscleStateRecord.vel(10,1) = initArch.velMT.gluL;

muscleStateRecord.len(11,1) = initArch.lenMT.iliL;
muscleStateRecord.vel(11,1) = initArch.velMT.iliL;

muscleStateRecord.len(12,1) = initArch.lenMT.gasL;
muscleStateRecord.vel(12,1) = initArch.velMT.gasL;

muscleStateRecord.len(13,1) = initArch.lenMT.solL;
muscleStateRecord.vel(13,1) = initArch.velMT.solL;

muscleStateRecord.len(14,1) = initArch.lenMT.tibL;
muscleStateRecord.vel(14,1) = initArch.velMT.tibL;

end
