function exoTorque = cal_exoTorque(i, skeletonPose, exoPara, peakForce, interForce)

% tR = gaitPercent.tR;
% tL = gaitPercent.tL;

% a cubic spline curve of the generated exoskeleton torque with respect to
% gait percent...

a = exoPara(1); % start time of assistive torque
b = exoPara(2); % peak time
c = exoPara(3); % end time
p = peakForce; % peak force

x1 = -0.317; y1 = 0.144;
h = 0.265; w = 0.056;

x = skeletonPose.gaitPercentL;
theta = skeletonPose.pos.exoL(i);

if x < a
    y = 0;
elseif x < b
    y = p/2 * (1 - cos(pi*(x-a)/(b-a)));
elseif x < c
    y = p/2 * (1 + cos(pi*(x-b)/(c-b)));
else
    y = 0;
end
feedfoward = 0.1 * (sqrt(abs(interForce.S1FxL(i))) + sqrt(abs(interForce.S1FyL(i))) + sqrt(abs(interForce.S2FxL(i))) + sqrt(abs(interForce.S2FyL(i))) + sqrt(abs(interForce.S3FxL(i))) + sqrt(abs(interForce.S3FyL(i))));
FL = max(y - feedfoward, 0);

x2 = h*sin(theta)-w*cos(theta);
y2 = -h*cos(theta)-w*sin(theta);
exoTorque.exoL = FL * abs(x1*y2-x2*y1) / sqrt((x1-x2)^2+(y1-y2)^2);

%% 

x = skeletonPose.gaitPercentR;
theta = skeletonPose.pos.exoR(i);

if x < a
    y = 0;
elseif x < b
    y = p/2 * (1 - cos(pi*(x-a)/(b-a)));
elseif x < c
    y = p/2 * (1 + cos(pi*(x-b)/(c-b)));
else
    y = 0;
end
feedfoward = 0.1 * (sqrt(abs(interForce.S1FxR(i))) + sqrt(abs(interForce.S1FyR(i))) + sqrt(abs(interForce.S2FxR(i))) + sqrt(abs(interForce.S2FyR(i))) + sqrt(abs(interForce.S3FxR(i))) + sqrt(abs(interForce.S3FyR(i))));
FR = max(y - feedfoward, 0);

x2 = h*sin(theta)-w*cos(theta);
y2 = -h*cos(theta)-w*sin(theta);
exoTorque.exoR = FR * abs(x1*y2-x2*y1) / sqrt((x1-x2)^2+(y1-y2)^2);

end