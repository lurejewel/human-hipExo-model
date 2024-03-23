%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name: init_jointTorque
% Function: zeroize the joint torques through whole simulation time
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function jointTorque = init_jointTorque(tEnd, T)

npts = fix(tEnd/T); % 控制点数

jointTorque.hipR   = zeros(1, npts);
jointTorque.kneeR  = zeros(1, npts);
jointTorque.ankleR = zeros(1, npts);
jointTorque.hipL   = zeros(1, npts);
jointTorque.kneeL  = zeros(1, npts);
jointTorque.ankleL = zeros(1, npts);

end