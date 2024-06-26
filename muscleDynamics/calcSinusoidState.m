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
function sinState = calcSinusoidState(t,a,b,omega)
%%
% This function evaluates the value and derivative of a sine function that
% varies by b and is offset by a.
%
% @param t: time
% @param a: offset
% @param b: amplitude of the sine function
% @param omega: frequency of the sine funtion in radians/sec
%
% @returns sinState 2x1 vector:
%          sinState(1) = dy(t)/dt 
%          sinState(2) =  y(t)
%
%%
load pp
% % % % % % % % % % % % sinState = zeros(2,1);
% sinState(2)=ppval(pp_soleus_r_mtu_length,t);
% sinState(1)=fnval(fnder(pp_soleus_r_mtu_length,1),t);
% % % % % % % % % % % % sinState(2)=ppval(pp_vasti_r_mtu_length,t);
% % % % % % % % % % % % sinState(1)=fnval(fnder(pp_vasti_r_mtu_length,1),t);
% sinState(1) = b*cos(omega*t)*omega;
% sinState(2) = a + b*sin(omega*t);
