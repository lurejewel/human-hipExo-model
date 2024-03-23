%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Name: init_calMuscleActExc
% Function: initialize the muscle activation, muscle fiber length, muslce
%           force along tendon, knee angle, knee angular velocity, pelvis
%           tilt angle, and pelvis tilt angular velocity for muscle acti-
%           vation and excitation calculation.
% Parameters: 
% - normalGait: all data collected from SCONE simulation.
% Output:
% - initMuscleArch: initial data needed for muscleExcFcn and muscleAcnFcn.
%
% Author: Jin Wei
% Last Update: 2022/11/4
% Update Note:
% #1 basic function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function initMuscleArch = init_calMuscleActExc(initArch)

% activation
initMuscleArch.a(1) = initArch.act.vasR; % vas R
initMuscleArch.a(2) = initArch.act.hamR; % ham R
initMuscleArch.a(3) = initArch.act.gluR; % glu R
initMuscleArch.a(4) = initArch.act.iliR; % ili R
initMuscleArch.a(5) = initArch.act.gasR; % gas R
initMuscleArch.a(6) = initArch.act.solR; % sol R
initMuscleArch.a(7) = initArch.act.tibR; % tib R
initMuscleArch.a(8) = initArch.act.vasL; % vas L
initMuscleArch.a(9) = initArch.act.hamL; % ham L
initMuscleArch.a(10) = initArch.act.gluL; % glu L
initMuscleArch.a(11) = initArch.act.iliL; % ili L
initMuscleArch.a(12) = initArch.act.gasL; % gas L
initMuscleArch.a(13) = initArch.act.solL; % sol L
initMuscleArch.a(14) = initArch.act.tibL; % tib L

% normalized force
initMuscleArch.f(1) = initArch.force.vasR;
initMuscleArch.f(2) = initArch.force.hamR;
initMuscleArch.f(3) = initArch.force.gluR;
initMuscleArch.f(4) = initArch.force.iliR;
initMuscleArch.f(5) = initArch.force.gasR;
initMuscleArch.f(6) = initArch.force.solR;
initMuscleArch.f(7) = initArch.force.tibR;
initMuscleArch.f(8) = initArch.force.vasL;
initMuscleArch.f(9) = initArch.force.hamL;
initMuscleArch.f(10) = initArch.force.gluL;
initMuscleArch.f(11) = initArch.force.iliL;
initMuscleArch.f(12) = initArch.force.gasL;
initMuscleArch.f(13) = initArch.force.solL;
initMuscleArch.f(14) = initArch.force.tibL;

% normalized fiber length
initMuscleArch.l(1) = initArch.lenN.vasR;
initMuscleArch.l(2) = initArch.lenN.hamR;
initMuscleArch.l(3) = initArch.lenN.gluR;
initMuscleArch.l(4) = initArch.lenN.iliR;
initMuscleArch.l(5) = initArch.lenN.gasR;
initMuscleArch.l(6) = initArch.lenN.solR;
initMuscleArch.l(7) = initArch.lenN.tibR;
initMuscleArch.l(8) = initArch.lenN.vasL;
initMuscleArch.l(9) = initArch.lenN.hamL;
initMuscleArch.l(10) = initArch.lenN.gluL;
initMuscleArch.l(11) = initArch.lenN.iliL;
initMuscleArch.l(12) = initArch.lenN.gasL;
initMuscleArch.l(13) = initArch.lenN.solL;
initMuscleArch.l(14) = initArch.lenN.tibL;

end