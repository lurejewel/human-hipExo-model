%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name: init_interForce
% Function: 
% - 根据仿真时长和步长，为交互力结构体分配空间
% Author: Jin Wei
% Last Update: 2024/1/22
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function interForce = init_interForce(tEnd, T)

npts = fix(tEnd/T) + 1; 

interForce.S1FxR = zeros(1, npts);
interForce.S1FyR = zeros(1, npts);
interForce.S3FxR = zeros(1, npts);
interForce.S3FyR = zeros(1, npts);
interForce.S2FxR = zeros(1, npts);
interForce.S2FyR = zeros(1, npts);
interForce.S2FzR = zeros(1, npts);
interForce.S1FxL = zeros(1, npts);
interForce.S1FyL = zeros(1, npts);
interForce.S3FxL = zeros(1, npts);
interForce.S3FyL = zeros(1, npts);
interForce.S2FxL = zeros(1, npts);
interForce.S2FyL = zeros(1, npts);
interForce.S2FzL = zeros(1, npts);

end