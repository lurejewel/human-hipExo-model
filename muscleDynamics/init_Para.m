%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name: init_Para
% Function: initialize the muscle feedback parameters to be optimized.
% Parameter(s):
%   (None)
% Output(s):
%   - para: initial value of the parameters for CMA-ES optimization.
%   - paraNum: number of the paramters.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [para, paraNum] = init_Para()

paraNum = 30;

para.tib.KL                     = 1.399650501990590;
para.tib.L0                     = 0.810084621536337;
para.tib_sol.KF                 = -0.178502775238455;
para.sol.KF                     = 1.038537119089160;
para.gas.KF                     = 1.385011053180380;
para.vas.KF                     = 0.694769614788694;
para.vas.C0                     = 0.440931424744121;
para.vas.Kphi                   = 0.3;
para.vas_knee.pos_max           = -0.239910313789709;
para.ham_pelvis_tilt.KP         = 2.048654565917500;
para.ham_pelvis_tilt.KV         = 0.421744533043114;
para.ham_pelvis_tilt.C0         = -0.174358643194022;
para.glu_pelvis_tilt.KP         = 1.987679122259760;
para.glu_pelvis_tilt.KV         = 0.346473404651719;
para.glu_pelvis_tilt.C0         = 0.047693021094191;
para.ili_pelvis_tilt.KP         = -2.370167650952400;
para.ili_pelvis_tilt.KV         = -0.330473778227932;
para.ili_pelvis_tilt.C0         = -0.007751943518068;
para.ili.C0                     = 0.531659310329193;
para.glu.C0                     = -0.050019384989767;
para.ili.KL                     = 0.359772329469555;
para.ili.L0                     = 0.478174733352115;
para.pelvis_tilt.P0             = -0.105;
para.ili_pelvis_tilt.P02        = 0.157980116712927;
para.ili_pelvis_tilt.KP2        = 0.740203043701762;
para.ili_pelvis_tilt.KV2        = 0.149956219480737;
para.ili_ham.KL                 = -2.108898305601810;
para.ili_ham.L0                 = 0.616448209263323;
para.ham.KF                     = 0.397334420137483;
para.glu.KF                     = 0.477150469826900;

end