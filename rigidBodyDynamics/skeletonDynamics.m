function skeletonPose = skeletonDynamics(i, simT, modelConfig, skeletonPose, jointTorque, exoTorque)

%% 初始化

tspan = [(i-1)*simT, i*simT];
initPose          = [skeletonPose.pos.pelvisX(i), skeletonPose.pos.pelvisY(i), skeletonPose.pos.pelvisTilt(i),...
                skeletonPose.pos.hipR(i), skeletonPose.pos.kneeR(i), skeletonPose.pos.ankleR(i), skeletonPose.pos.exoR(i),...
                skeletonPose.pos.hipL(i), skeletonPose.pos.kneeL(i), skeletonPose.pos.ankleL(i), skeletonPose.pos.exoL(i),...
                skeletonPose.vel.pelvisX(i), skeletonPose.vel.pelvisY(i), skeletonPose.vel.pelvisTilt(i),...
                skeletonPose.vel.hipR(i), skeletonPose.vel.kneeR(i), skeletonPose.vel.ankleR(i), skeletonPose.vel.exoR(i),...
                skeletonPose.vel.hipL(i), skeletonPose.vel.kneeL(i), skeletonPose.vel.ankleL(i), skeletonPose.vel.exoL(i)];

%% 代入动力学方程求解

[~, out] = ode15s(@(t,in)state_equation(t, in, modelConfig, jointTorque, exoTorque), tspan, initPose);

%% 赋值

% 只要out的最后一个值
skeletonPose.pos.pelvisX(i+1) = out(end, 1);
skeletonPose.pos.pelvisY(i+1) = out(end, 2);
skeletonPose.pos.pelvisTilt(i+1) = out(end, 3);
skeletonPose.pos.hipR(i+1) = out(end, 4);
skeletonPose.pos.kneeR(i+1) = out(end, 5);
skeletonPose.pos.ankleR(i+1) = out(end, 6);
skeletonPose.pos.exoR(i+1) = out(end, 7);
skeletonPose.pos.hipL(i+1) = out(end, 8);
skeletonPose.pos.kneeL(i+1) = out(end, 9);
skeletonPose.pos.ankleL(i+1) = out(end, 10);
skeletonPose.pos.exoL(i+1) = out(end, 11);

skeletonPose.vel.pelvisX(i+1) = out(end, 12);
skeletonPose.vel.pelvisY(i+1) = out(end, 13);
skeletonPose.vel.pelvisTilt(i+1) = out(end, 14);
skeletonPose.vel.hipR(i+1) = out(end, 15);
skeletonPose.vel.kneeR(i+1) = out(end, 16);
skeletonPose.vel.ankleR(i+1) = out(end, 17);
skeletonPose.vel.exoR(i+1) = out(end, 18);
skeletonPose.vel.hipL(i+1) = out(end, 19);
skeletonPose.vel.kneeL(i+1) = out(end, 20);
skeletonPose.vel.ankleL(i+1) = out(end, 21);
skeletonPose.vel.exoL(i+1) = out(end, 22);

end