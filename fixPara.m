function xmean_fix = fixPara(xmean)

xmean_fix(1) = minMax(xmean(1), -10, 10); % para.tib.KL
xmean_fix(2) = minMax(xmean(2), 0.5, 0.8); % para.tib.L0
xmean_fix(3) = minMax(xmean(3), -10, 10); % para.tib_sol.KF
xmean_fix(4) = minMax(xmean(4), -10, 10); % para.sol.KF 
xmean_fix(5) = minMax(xmean(5), -10, 10); % para.gas.KF
xmean_fix(6) = minMax(xmean(6), -10, 10); % para.ili_pelvis_tilt.KP
xmean_fix(7) = minMax(xmean(7), -10, 10); % para.ili_pelvis_tilt.KV
% xmean_fix(8) = minMax(xmean(8), -0.5, 0.5); % para.pelvis_tilt.P0
xmean_fix(8) = minMax(xmean(8), -1, 1); % para.ili_pelvis_tilt.C0
xmean_fix(9) = minMax(xmean(9), -1, 1); % para.ili.C0
xmean_fix(10) = minMax(xmean(10), -10, 10); % % para.ili.KL
xmean_fix(11) = minMax(xmean(11), 0, 2); % para.ili.L0
xmean_fix(12) = minMax(xmean(12), -1, 1); % para.ili_pelvis_tilt.P02
xmean_fix(13) = minMax(xmean(13), -10, 10); % para.ili_pelvis_tilt.KP2
xmean_fix(14) = minMax(xmean(14), -10, 10); % para.ili_pelvis_tilt.KV2
xmean_fix(15) = minMax(xmean(15), -10, 10); % para.ili_ham.KL
xmean_fix(16) = minMax(xmean(16), 0, 2); % para.ili_ham.L0
xmean_fix(17) = minMax(xmean(17), -10, 10); % para.ham_pelvis_tilt.KP
xmean_fix(18) = minMax(xmean(18), -10, 10); % para.ham_pelvis_tilt.KV
xmean_fix(19) = minMax(xmean(19), -1, 1); % para.ham_pelvis_tilt.C0
xmean_fix(20) = minMax(xmean(20), 0, 10); % para.ham_glu.KF
xmean_fix(21) = minMax(xmean(21), -10, 10); % para.glu_pelvis_tilt.KP
xmean_fix(22) = minMax(xmean(22), -10, 10); % para.glu_pelvis_tilt.KV
xmean_fix(23) = minMax(xmean(23), -1, 1); % para.glu_pelvis_tilt.C0
xmean_fix(24) = minMax(xmean(24), -10, 10); % para.glu.KF
% xmean_fix(25) = minMax(xmean(25), -1, 1); % para.glu.C0
xmean_fix(25) = minMax(xmean(25), -10, 10); % para.vas.KF1
xmean_fix(26) = minMax(xmean(26), -10, 10); % para.vas.KF2
xmean_fix(27) = minMax(xmean(27), -1, 1); % para.vas.C0
xmean_fix(28) = minMax(xmean(28), -1, 0); % para.vas_knee.pos_max
xmean_fix(29) = minMax(xmean(29), 0, 30); % peakForce

end