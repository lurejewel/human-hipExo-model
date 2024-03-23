function interForce = cal_interForce(i, skeletonPose, coef, peakForce, interForce)

if peakForce == 0
    peakForce = 0.01;
end

x1 = skeletonPose.pos.exoR(i);
x2 = skeletonPose.vel.exoR(i);
%     gaitPercent = skeletonPose.gaitPercentR;

X0 = 1;
X1 = [x1, x1^2, x1^3, x1^4, x1^5, ...
    x2, x2^2, x2^3, x2^4, x2^5];
X2 = [x1.*x2, x1.*x2.^2, x1.*x2.^3, x1.*x2.^4, ...
    x1.^2.*x2, x1.^2.*x2.^2, x1.^2.*x2.^3, ...
    x1.^3.*x2, x1.^3.*x2.^2, ...
    x1.^4.*x2];
X = [X0, X1, X2];

interForce.S1FxR(i) = X*coef(round(peakForce*100)).S1Fx;
interForce.S1FyR(i) = X*coef(round(peakForce*100)).S1Fy;
interForce.S2FxR(i) = X*coef(round(peakForce*100)).S2Fx;
interForce.S2FyR(i) = X*coef(round(peakForce*100)).S2Fy;
interForce.S2FzR(i) = X*coef(round(peakForce*100)).S2Fz;
interForce.S3FxR(i) = X*coef(round(peakForce*100)).S3Fx;
interForce.S3FyR(i) = X*coef(round(peakForce*100)).S3Fy;

%% 

x1 = -skeletonPose.pos.hipL(i); % exoL(i);
x2 = -skeletonPose.vel.hipL(i); % exoL(i);
%     gaitPercent = skeletonPose.gaitPercentR;

X0 = 0;
X1 = [x1, x1^2, x1^3, x1^4, x1^5, ...
    x2, x2^2, x2^3, x2^4, x2^5];
X2 = [x1.*x2, x1.*x2.^2, x1.*x2.^3, x1.*x2.^4, ...
    x1.^2.*x2, x1.^2.*x2.^2, x1.^2.*x2.^3, ...
    x1.^3.*x2, x1.^3.*x2.^2, ...
    x1.^4.*x2];
X = [X0, X1, X2];

interForce.S1FxL(i) = X*coef(round(peakForce*100)).S1Fx;
interForce.S1FyL(i) = X*coef(round(peakForce*100)).S1Fy;
interForce.S2FxL(i) = X*coef(round(peakForce*100)).S2Fx;
interForce.S2FyL(i) = X*coef(round(peakForce*100)).S2Fy;
interForce.S2FzL(i) = X*coef(round(peakForce*100)).S2Fz;
interForce.S3FxL(i) = X*coef(round(peakForce*100)).S3Fx;
interForce.S3FyL(i) = X*coef(round(peakForce*100)).S3Fy;

end