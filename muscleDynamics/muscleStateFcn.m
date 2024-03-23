%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 功能：根据cal_muscleState函数的肌肉长度和速度，计算当前时刻的肌肉长度速度。
% （前者是仿真步长起始时刻的长度和速度，这里是仿真步长simT内的实时长度速度）
% （速度与cal_muscleState的计算结果相同，长度需要 len' = len + vel * △t）
% 
% 参数：
% - t: 时刻
% - muscleIdx: 肌肉编号
% - muscleStateRecord：全时程肌肉状态信息
%   - muslceStateRecord.vel(i,j): 第j个仿真步长下第i块肌肉的速度，下似
%   - muscleStateRecord.len(i,j): 肌肉长度
%   - muscleStateRecord.loopNum: 循环数
% 
% 返回：
% - 2 x 1 数组：[速度, 长度]
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function muscleState = muscleStateFcn(t, simT, muscleIdx, muscleStateRecord)

loopNum = muscleStateRecord.loopNum;
h = mod(t, simT); % h ∈ [0, simT]；loopNum*simT < t+h < (loopNum+1)*simT

vel = muscleStateRecord.vel(muscleIdx, loopNum+1);
len = muscleStateRecord.len(muscleIdx, loopNum+1) + vel * h;

muscleState(1) = vel;
muscleState(2) = len;

end