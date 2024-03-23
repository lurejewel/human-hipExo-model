%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Name: measure
%
% Function: evaluate the result of this result regarding the metabolic
% expenditure, excessive ground reaction force, walking speed, angle
% constraints, pelvis height, etc.
%
% Parameter(s):
%   - npts: number of control points
%   - simT: simulation time step
%   - skeletonPose: pose and motion of the model in whole simulation time
%   - GRF: ground reaction force in whole simulation time
%   - muscleRecord: record of all muscles in whole simulation time for
%   calculating metabolic expenditure
%   - simSpeed: speed constriant
%
% Author(s): Wei Jin
%
% Affiliation: Fudan Univ., China
%
% Update Log
% #6 add interactive friction force term
% #5 select type of measurement through variable 'stage'
% #4 replace minimum speed for speed constraint
% #3 add metabolic effort term
% #2 modify inputs
% #1 basic functionalities
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function fit = measure(stage, npts, simT, tEnd, skeletonPose, GRF, muscleRecord, interForce, simSpeed, simSlope)

if stage == 1 % not to fall down
    fit = 10*simSpeed - sqrt(simSlope^2+1) * skeletonPose.pos.pelvisX(npts);
    
elseif stage == 2 % minimize combined fitness
    %% basic initialization
    
    mass = 74.5314; % mass of the human; neglect mass of exoskeleton
    g = 9.80665; % acceleration of gravity
    
    % weight of each term
    weight.vel = 100;
    weight.knee = 0.01;
    weight.ankle = 0.1;
    weight.effort = 1; % 0.1;
    weight.grf = 10;
    weight.friction = 0.1;
    
    % threshold
    % min_vel = simSpeed;
    target_vel = simSpeed;
    % min_height = 0.85;
    min_ankle = -60;
    max_ankle = 60;
    max_grf = 1.5;
    
    %% step pelvis velocity & height
    
    threshold = 0.02; % 0.05;
    distance  = sqrt(simSlope^2+1) * skeletonPose.pos.pelvisX(npts+1);
    sum_vel_err = 0;
    for i = 1 : npts
        sum_vel_err = sum_vel_err + (sqrt(simSlope^2+1) * skeletonPose.vel.pelvisX(i+1) - target_vel)^2 * (abs(skeletonPose.vel.pelvisX(i+1)-target_vel) > threshold);
    end
    avg_vel_err = sum_vel_err / npts;
    step_vel  = distance / (npts*simT);
    % end_height = skeletonPose.pos.pelvisY(end);
    
    % loss.vel  = weight.vel * ( max(min_vel-step_vel, 0) * (min_vel-step_vel > threshold) + (npts < tEnd/simT-1));
    %                                           speed constraint                              fall prevention
%     loss.vel  = weight.vel * ( abs(target_vel-step_vel) * (abs(target_vel-step_vel) > threshold) + (npts < tEnd/simT-1) );
    loss.vel  = weight.vel * ( avg_vel_err + (npts < tEnd/simT-1) );
    
    %% knee force
    
    threshold   = 5;
    Kup         = 2;
    Klo         = 2;
    Lup         = -5;
    Llo         = -120;
    Damp        = 0.2;
    
    kneeL = rad2deg(skeletonPose.pos.kneeL);
    dkneeL = rad2deg(skeletonPose.vel.kneeL);
    Kup_ = Kup * ( atan(5e2*(kneeL-Lup))/pi + 0.5 );
    Klo_ = Klo * (-atan(5e2*(kneeL-Llo))/pi + 0.5 );
    Fup  = Kup_ .* (Lup - kneeL);
    Flo  = Klo_ .* (Llo - kneeL);
    Fd   = -Damp * (Kup_/Kup + Klo_/Klo) .* dkneeL;
    F    = Fup + Flo + Fd;
    
    loss.kneeL = weight.knee * sum(abs(F)) / npts * (sum(abs(F))/npts > threshold);
    
    kneeR = rad2deg(skeletonPose.pos.kneeR);
    dkneeR = rad2deg(skeletonPose.vel.kneeR);
    Kup_ = Kup * ( atan(5e2*(kneeR-Lup))/pi + 0.5 );
    Klo_ = Klo * (-atan(5e2*(kneeR-Llo))/pi + 0.5 );
    Fup  = Kup_ .* (Lup - kneeR);
    Flo  = Klo_ .* (Llo - kneeR);
    Fd   = -Damp * (Kup_/Kup + Klo_/Klo) .* dkneeR;
    F    = Fup + Flo + Fd;
    
    loss.kneeR = weight.knee * sum(abs(F)) / npts * (sum(abs(F))/npts > threshold);
    
    %% ankle angle penalty
    
    ankleL = rad2deg(skeletonPose.pos.ankleL);
    ankleR = rad2deg(skeletonPose.pos.ankleR);
    
    loss.ankleL = mean(((ankleL-min_ankle).*(ankleL<min_ankle)).^2 + ((ankleL-max_ankle).*(ankleL>max_ankle)).^2);
    loss.ankleR = mean(((ankleR-min_ankle).*(ankleR<min_ankle)).^2 + ((ankleR-max_ankle).*(ankleR>max_ankle)).^2);
    
    %% gronud reaction force
    
    % normalized according to body weight
    grfL = (GRF(7,:) + GRF(8,:)) / mass / g;
    grfR = (GRF(5,:) + GRF(6,:)) / mass / g;
    
    loss.grf = weight.grf * (mean((grfL-max_grf).*(grfL>max_grf)) + mean((grfR-max_grf).*(grfR>max_grf)));
    
    %% interactive friction force
    
    loss.friction = weight.friction * mean(sqrt(abs(interForce.S1FxR)) + sqrt(abs(interForce.S1FyR)) ...
                                        + sqrt(abs(interForce.S2FxR)) + sqrt(abs(interForce.S2FyR)) ...
                                        + sqrt(abs(interForce.S3FxR)) + sqrt(abs(interForce.S3FyR)) ...
                                        + sqrt(abs(interForce.S1FxL)) + sqrt(abs(interForce.S1FyL)) ...
                                        + sqrt(abs(interForce.S2FxL)) + sqrt(abs(interForce.S2FyL)) ...
                                        + sqrt(abs(interForce.S3FxL)) + sqrt(abs(interForce.S3FyL)));
    
    %% metabolic expenditure
    
    % ratio of type I fiber in each muscle
    lambda     = [0.5, 0.44, 0.5, 0.5, 0.54, 0.81, 0.7]; lambda = [lambda, lambda];
    % muscle mass
    muscleMass = [1.9, 1.2, 0.65, 0.87, 0.3, 0.63, 0.19]; muscleMass = [muscleMass muscleMass];
    Effort     = zeros(1, npts);
    for i = 1 : npts % time index
        
        muscleNum = length(muscleRecord); % # of muscles
        dE = zeros(1, muscleNum);
        
        for j = 1 : muscleNum % muscle index
            
            u = muscleRecord(j).excitationState(i);
            a = muscleRecord(j).activationState(i);
            lCE = muscleRecord(j).normFiberLength(i);
            vCE = max(-muscleRecord(j).fiberVelocity(i), 0);
            fCE = muscleRecord(j).activeFiberForce(i);
            fPE = muscleRecord(j).passiveFiberForce(i);
            fMTU = fCE + fPE;
            
            dA = muscleMass(j) * fAFcn(lambda(j), u); % muscle activation heat rate
            dM = muscleMass(j) * gFcn(lCE) * fMFcn(lambda(j), a); % muscle maintenance heat rate
            dS = 0.25 * fMTU * vCE; % muscle shortening heat rate
            dW = fCE * vCE; % positive mechanical work rate
            
            dE(j) = dA + dM + dS + dW; % metabolic expenditure of the j-th muscle at time i
        end
        
        Effort(i) = sum(dE); % overall metabolic expenditure at time i
        
    end
    
    loss.effort = weight.effort * sum(Effort) * simT / abs(distance) / mass;
    
    %% overall fit
    
    fit = loss.vel + loss.ankleL + loss.ankleR + loss.kneeL + loss.kneeR + loss.grf + loss.friction + loss.effort;
    
    
end

end