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
function minFiberKinematics =...
    calcFixedWidthPennatedFiberMinimumLength(...
                         minimumActiveFiberNormalizedLength,...
                         maximumPennationAngle,...
                         optimalFiberLength,...
                         pennationAngleAtOptimalFiberLength)
%%
% This function calculates the minimum length the fiber can contract to
% without exceeding a given maximum pennation angle, nor falling below the
% minimum physical limit.
%
% @param minimumActiveFiberNormalizedLength approximately 0.5 * lceOpt (m)
% @param maximumPennationAngle usually slightly less than pi/2 (radians)
% @param optimalFiberLength (m)
% @param pennationAngleAtOptimalFiberLength (radians)
%
% @return minFiberKinematics, a structure with the fields
%
%         .minimumFiberLength            
%         .minimumFiberLengthAlongTendon 
%         .pennationAngleAtMinimumFiberLength          

%
%%
lceOpt      = optimalFiberLength; % 最优长度，即主动力最大时的长度，m
lceActMin   = lceOpt*minimumActiveFiberNormalizedLength; % 主动收缩的极限长度，m


minFiberLength             = [];
minFiberLengthAlongTendon  = [];
pennationAngleAtLceMin     = [];

epsRoot = eps^0.5;
if(pennationAngleAtOptimalFiberLength > epsRoot) % 如果该肌肉的羽状角大于零
    alphaOpt    = pennationAngleAtOptimalFiberLength; % 赋值过去
    h           = lceOpt*sin(alphaOpt); %the height/thickness of the pennated fiber, which is constant 高度/宽度/厚度
    lcePenMin                 = h/sin(maximumPennationAngle); % 理论的最小肌肉长度，约等于 h

    minFiberLength            = max([lcePenMin,lceActMin]); % 其实应该还是后者

    assert( minFiberLength > epsRoot, ...
            ['Minimum fiber length is too close to 0!',...
             'A fiber length of 0 will cause singularities',...
             ' in the pennation model']);
   
    pennationAngleAtLceMin    = asin( h/minFiberLength ); % 对应的羽状角（看这个意思好像是，主动力通过改变羽状角来改变肌肉长度）
    minFiberLengthAlongTendon = minFiberLength*cos(pennationAngleAtLceMin); % 沿肌腱方向的羽状角

else
    minFiberLength            = lceActMin;
    minFiberLengthAlongTendon = lceActMin;
    pennationAngleAtLceMin    = 0;
end



assert( pennationAngleAtLceMin < pi/2 - epsRoot, ...
    ['Maximum pennation angle too close to pi/2!',...
     'If reached this will cause singularities',...
     ' in the pennation model']);

assert( minFiberLength > epsRoot, ...
    ['Minimum fiber length is too close to 0!',...
     'A fiber length of 0 will cause singularities',...
     ' in the pennation model']);

 
 
minFiberKinematics.minimumFiberLength       = minFiberLength;
minFiberKinematics.minimumFiberLengthAlongTendon ...
                                            = minFiberLengthAlongTendon;
minFiberKinematics.pennationAngleAtMinimumFiberLength ...
                                            =  pennationAngleAtLceMin;

