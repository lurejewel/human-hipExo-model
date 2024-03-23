function record = init_record(tEnd, T, L)
%% global init 全时程初始化

npts    = fix(tEnd/T); % 控制点数

for i = 1 : L % for all muscles
    
    record(i).activationState              = -ones(1, npts);
    record(i).excitationState              = -ones(1, npts);
    record(i).muscleState                  = -ones(1, npts);
%     
%     record(i).pennationAngle               = -ones(1, npts);
%     record(i).fiberStiffnessAlongTendon    = -ones(1, npts);
%     record(i).tendonStiffnessAlongTendon   = -ones(1, npts);
%     record(i).muscleStiffness              = -ones(1, npts);
    
    record(i).normFiberLength              = -ones(1, npts);
%     record(i).FiberLength                  = -ones(1, npts);
%     record(i).normTendonLength             = -ones(1, npts);
%     record(i).TendonLength                 = -ones(1, npts);
%     record(i).pathLength                   = -ones(1, npts);
%     
%     record(i).fiberVelocity                = -ones(1, npts);
%     record(i).fiberVelocityAlongTendon     = -ones(1, npts);
%     record(i).tendonVelocity               = -ones(1, npts);
%     record(i).normFiberVelocity            = -ones(1, npts);
%     record(i).pennationAngVelocity         = -ones(1, npts);
%     record(i).pathVelocity                 = -ones(1, npts);
%    
%     record(i).activeFiberForce             = -ones(1, npts);
%     record(i).tendonForce                  = -ones(1, npts);
%     record(i).dampingForce                 = -ones(1, npts);
%     record(i).tendonForce                  = -ones(1, npts);
%     record(i).passiveFiberForce            = -ones(1, npts);
    record(i).normfiberForceAlongTendon    = -ones(1, npts);
    
    record(i).loopNum                      = 0;

end


% % vasR
% record(1).init_FN = normalGait.vasti_rmtu_force_norm(1);
% record(1).init_LN = normalGait.vasti_rmtu_force_norm(1);
% 
% % hamR
% record(2).init_FN = normalGait.hamstrings_rmtu_force_norm(1);
% record(2).init_LN = normalGait.hamstrings_rfiber_length_norm(1);
% 
% % gluR
% record(3).init_FN = normalGait.glut_max_rmtu_force_norm(1);
% record(3).init_LN = normalGait.glut_max_rfiber_length_norm(1);
% 
% % iliR
% record(4).init_FN = normalGait.iliopsoas_rmtu_force_norm(1);
% record(4).init_LN = normalGait.iliopsoas_rfiber_length_norm(1);
% 
% % gasR
% record(5).init_FN = normalGait.gastroc_rmtu_force_norm(1);
% record(5).init_LN = normalGait.gastroc_rfiber_length_norm(1);
% 
% % solR
% record(6).init_FN = normalGait.soleus_rmtu_force_norm(1);
% record(6).init_LN = normalGait.soleus_rfiber_length_norm(1);
% 
% % tibR
% record(7).init_FN = normalGait.tib_ant_rmtu_force_norm(1);
% record(7).init_LN = normalGait.tib_ant_rfiber_length_norm(1);
% 
% % -------------------------------------------------------------------------
% 
% % vasL
% record(8).init_FN = normalGait.vasti_lmtu_force_norm(1);
% record(8).init_LN = normalGait.vasti_lmtu_force_norm(1);
% 
% % hamL
% record(9).init_FN = normalGait.hamstrings_lmtu_force_norm(1);
% record(9).init_LN = normalGait.hamstrings_lfiber_length_norm(1);
% 
% % gluL
% record(10).init_FN = normalGait.glut_max_lmtu_force_norm(1);
% record(10).init_LN = normalGait.glut_max_lfiber_length_norm(1);
% 
% % iliL
% record(11).init_FN = normalGait.iliopsoas_lmtu_force_norm(1);
% record(11).init_LN = normalGait.iliopsoas_lfiber_length_norm(1);
% 
% % gasL
% record(12).init_FN = normalGait.gastroc_lmtu_force_norm(1);
% record(12).init_LN = normalGait.gastroc_lfiber_length_norm(1);
% 
% % solL
% record(13).init_FN = normalGait.soleus_lmtu_force_norm(1);
% record(13).init_LN = normalGait.soleus_lfiber_length_norm(1);
% 
% % tibL
% record(14).init_FN = normalGait.tib_ant_lmtu_force_norm(1);
% record(14).init_LN = normalGait.tib_ant_lfiber_length_norm(1);

end