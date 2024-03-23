function [tauInterR, tauInterL] = cal_inter(skeletonPose, modelConfig)

K = modelConfig.interForce.k;
V = modelConfig.interForce.v;

tauInterR = K * skeletonPose.pos.exoR + V * skeletonPose.vel.exoR;
tauInterL = K * skeletonPose.pos.exoL + V * skeletonPose.vel.exoL;

end