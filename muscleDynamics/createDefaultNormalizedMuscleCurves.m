% -------------------------------------------------------------------------- %
% The OpenSim API is a toolkit for musculoskeletal modeling and simulation.  %
% See http:%opensim.stanford.edu and the NOTICE file for more information.  %
% OpenSim is developed at Stanford University and supported by the US        %
% National Institutes of Health (U54 GM072970, R24 HD065690) and by DARPA    %
% through the Warrior Web program.                                           %
%                                                                            %
% Copyright (c) 2005-2012 Stanford University and the Authors                %
% Author(s): Matthew Millard                                                 %
%                                                                            %
% Licensed under the Apache License, Version 2.0 (the 'License'); you may    %
% not use this file except in compliance with the License. You may obtain a  %
% copy of the License at http:%www.apache.org/licenses/LICENSE-2.0.         %
%                                                                            %
% Unless required by applicable law or agreed to in writing, softNware        %
% distributed under the License is distributed on an 'AS IS' BASIS,          %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   %
% See the License for the specific language governing permissions and        %
% limitations under the License.                                             %
% -------------------------------------------------------------------------- %
%
% Derivative work
% Authors(s): Millard
% Updates   : ported to code to Matlab
%
% If you use this code in your work please cite this paper
%
%  Millard, M., Uchida, T., Seth, A., & Delp, S. L. (2013). 
%    Flexing computational muscle: modeling and simulation of 
%    musculotendon dynamics. Journal of biomechanical engineering, 
%    135(2), 021005.
%%
function normMuscleCurves = createDefaultNormalizedMuscleCurves(...
                muscleName,muscleCurvePara,tendonStrainAtOneNormForceInput)
%%
% This function constructs the default normalized muscle fiber and tendon
% characteristic curves that are used in the Millard2012EquilibriumMuscle
% model in OpenSim and puts them into a struct.
%
% @param muscleName: the name of the muscle. This string is used to give
%                    each of the curves a specific name
%
% @param flag_plotCurves: 0: nothing will happen
%                         1: each curves value, 1st, and 2nd derivative
%                         will be plotted over the full Beziercurve domain 
%                         and a little beyond so that you can see
%                         extrapolation. If the curve has an integral then
%                         its value too will be plotted
%                         
% @return normMuscleCurves: a struct containing the following fields
%
%          .activeForceLengthCurve 特征曲线1
%          .fiberForceLengthCurve 【就是passiveForceLengthCurve】 特征曲线3
%          .fiberForceVelocityCurve 特征曲线2
%          .tendonForceLengthCurve 特征曲线3
%
%          .activeForceLengthCurveHACK
%          .fiberForceVelocityInverseCurveHACK
%
%%
normMuscleCurves = [];

%% Active force length curve 特征曲线1
    lce0 = 0.47-0.0259;
    lce1 = 0.73;
    lce2 = 1.0;
    lce3 = 1.8123;
    minActiveForceLengthValue = muscleCurvePara.activeForceLengthCurve.minimumValue;
    curviness = 1.0;
    computeIntegral = 0;
    plateauSlope = 0.8616;

    activeForceLengthCurve = createFiberActiveForceLengthCurve( lce0,...
                                                                lce1, ...
                                                                lce2, ...
                                                                lce3, ...
                                                                minActiveForceLengthValue,...
                                                                plateauSlope, ...
                                                                curviness, ...
                                                                computeIntegral, ...
                                                                muscleName);  

    normMuscleCurves.activeForceLengthCurve = activeForceLengthCurve;

%% Fiber Passive Force 特征曲线3
    eZero = 0; 
    eIso  = 0.7;
    kLow  = 0.2;
    kIso  = 2/(eIso-eZero);
    curviness = 0.75;
    computeIntegral = 1;

    fiberForceLengthCurve = createFiberForceLengthCurve(eZero,...
                                                        eIso,...
                                                        kLow,...
                                                        kIso,...
                                                        curviness,...
                                                        computeIntegral,...
                                                        muscleName);        
    normMuscleCurves.fiberForceLengthCurve = fiberForceLengthCurve;

%% Fiber Force Velocity Curve 特征曲线2
    fmaxE         = 1.4;
    dydxC         = 0;
    dydxNearC     = 0.25;
    dydxIso       = 5.0; % SCONE里提到了但是这里没有用到
    dydxE         = 0;
    dydxNearE     = 0.15;
    flag_smoothenNonZeroDyDxC = 0;
    flag_usingOctave = 0;
    
    fvAtHalfVMax = 0.15; 
%   A fast/slow twitch force-velocity curve can be created by adjusting
%   fvAtHalfVMax:
%
%     Slow twitch: fvAtHalfVmax = 0.15
%     Fast twitch: fvAtHalfVmax = 0.22
%
%   These pameters come from Fig. 3a (fast) and Fig. 3b of Rantunga
%
%   Ranatunga, K. W. (1984). The force-velocity relation of rat
%   fast- and slow-twitch muscles examined at different temperatures.
%   The Journal of Physiology, 351, 517.

    concCurviness = 0.7;
    eccCurviness  = 0.9;
    computeIntegral = 0;

%     fiberForceVelocityCurve =  createFiberForceVelocityCurve2012(...
%                                             fmaxE, ...
%                                             dydxC,dydxNearC, ...
%                                             dydxIso, ...
%                                             dydxE, dydxNearE,...
%                                             concCurviness, eccCurviness,...
%                                             computeIntegral, muscleName);

     fiberForceVelocityCurve =  createFiberForceVelocityCurve2018(...
                                             fmaxE, ...
                                             dydxE, ...
                                             dydxC, ...
                                             flag_smoothenNonZeroDyDxC,...
                                             dydxNearE,...
                                             fvAtHalfVMax,...
                                             eccCurviness,...
                                             muscleName);


    normMuscleCurves.fiberForceVelocityCurve = fiberForceVelocityCurve;
    
    %Now make an invertable version of this curve - the slopes at the
    %end must be finite. 
    fiberForceVelocityCurveHACK =  createFiberForceVelocityCurve2018(...
                                             fmaxE, ...
                                             dydxNearE, ... % 这里不一样
                                             dydxNearC, ... % 这里不一样
                                             flag_smoothenNonZeroDyDxC,...
                                             dydxNearE,...
                                             fvAtHalfVMax,...
                                             eccCurviness,...
                                             muscleName);


    normMuscleCurves.fiberForceVelocityCurveHACK = fiberForceVelocityCurveHACK;    
    
    %Finally invert the curve. This is used to create a very accurate
    %initial guess for the Newton routine that is used to solve for the 
    %fiber velocity. This is quite useful during very slow eccentric
    %contractions where the force-velocity curve has a very sharp corner.
    fiberForceVelocityInverseCurveHACK = createInverseBezierCurve(fiberForceVelocityCurveHACK);
    
    normMuscleCurves.fiberForceVelocityInverseCurveHACK = fiberForceVelocityInverseCurveHACK;
    
%% Tendon Force Length Curve 特征曲线4
    eIso            = 0.049;
    if(tendonStrainAtOneNormForceInput >= 0)
      eIso = tendonStrainAtOneNormForceInput;
    end
    
    kIso            = 1.375/eIso;
    fToe            = 2.0/3.0;
    curviness       = 0.5;
    computeIntegral = 1;

    tendonForceLengthCurve = ...
              createTendonForceLengthCurve( eIso, kIso, ...
                                            fToe, curviness, ...
                                            computeIntegral, ...
                                            muscleName);

    normMuscleCurves.tendonForceLengthCurve = tendonForceLengthCurve;

%%
    % HACKED 'Classic' muscle modeling curves
    %
    % Almost all classic elastic tendon Hill-type muscle models take the
    % tendon-fiber equilibrium force equation:  
    %
    %    a(fl(lce)*fv(dlce/dt) + fpe(lce))*cos(alpha) - ft(lt) = 0;
    %
    % and massage it into an ode:
    %
    %    dlce/dt = fv^-1 ( [ (ft / a*cos(alpha)) - fpe] / fl)
    %
    % Which goes singular when ever:
    %
    %  a -> 0
    %  cos(alpha) -> 0
    %  fl -> 0
    %  fv^-1 -> inf as dlce/dt -> vmax
    %
    % To use this model without causing singularities means
    %
    %  a > 0      : the muscle cannot turn off          -> not physically true
    %  alpha < 90 : the pennation angle cannot go to 90 -> probably correct
    %  fl > 0     : the fiber can always generate force -> not physically true
    %  fv^-1      : the fiber can generate force at all
    %               velocities, and can even generate
    %               compressive forces at high shortening
    %               velocities.                          -> not true.
    %               As long as the fiber is connected to
    %               an elastic tendon with a force-length
    %               curve that does not go negative, then
    %               the fiber cannot apply compressive
    %               forces to the model. In the case of a
    %               rigid tendon however, there is a risk
    %               that compressive force are applied at
    %               very high shortening velocities (beyond
    %               vmax in shortening).
    %%

%% *HACKED Fiber Active Force Length Curve

    lce0 = 0.47-0.0259;
    lce1 = 0.73;
    lce2 = 1.0;
    lce3 = 1.8123;
    minActiveForceLengthValue = 0.1; %*Here's the hack: minimum value > 0
    curviness = 1.0;                 % in many papers this value really 
    computeIntegral = 0;             % is 0.1! This is huge!
    plateauSlope = 0.8616;

    activeForceLengthCurveHack = createFiberActiveForceLengthCurve( lce0,...
                                                                lce1, ...
                                                                lce2, ...
                                                                lce3, ...
                                                                minActiveForceLengthValue,...
                                                                plateauSlope, ...
                                                                curviness, ...
                                                                computeIntegral, ...
                                                                muscleName);

    normMuscleCurves.activeForceLengthCurveHACK = activeForceLengthCurveHack;