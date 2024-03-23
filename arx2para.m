%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name: arx2para
% Function: mapping from point for optimization (xmean) to structure for
% dynamic simulation (para)
% Parameter(s):
%   - xmean
% Output(s):
%   - para
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function para = arx2para(xmean)

para.tib.KL                     = xmean(1);
para.tib.L0                     = xmean(2);
para.tib_sol.KF                 = xmean(3);
para.sol.KF                     = xmean(4);
para.gas.KF                     = xmean(5);
para.ili_pelvis_tilt.KP         = xmean(6);
para.ili_pelvis_tilt.KV         = xmean(7);
para.ili_pelvis_tilt.C0         = xmean(8);
para.ili.C0                     = xmean(9);
para.ili.KL                     = xmean(10);
para.ili.L0                     = xmean(11);
para.ili_pelvis_tilt.P02        = xmean(12);
para.ili_pelvis_tilt.KP2        = xmean(13);
para.ili_pelvis_tilt.KV2        = xmean(14);
para.ili_ham.KL                 = xmean(15);
para.ili_ham.L0                 = xmean(16);
para.ham_pelvis_tilt.KP         = xmean(17);
para.ham_pelvis_tilt.KV         = xmean(18);
para.ham_pelvis_tilt.C0         = xmean(19);
% para.ham.KF                     = xmean(20);
para.ham_glu.KF                 = xmean(20);
para.glu_pelvis_tilt.KP         = xmean(21);
para.glu_pelvis_tilt.KV         = xmean(22);
para.glu_pelvis_tilt.C0         = xmean(23);
para.glu.KF                     = xmean(24);
% para.glu.C0                     = xmean(25);
para.vas.KF1                    = xmean(25); % 26 -> 25
para.vas.KF2                    = xmean(26);
para.vas.C0                     = xmean(27);
para.vas_knee.pos_max           = xmean(28);
para.peakForce                  = xmean(29);

end