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
function colData = readSingleColumnTextData(fileName, type)
%%
% This function reads in data from a text file that contains
% a single column of data. This is used to build tables out of
% text data
%
% @param fileName: string of the filename
% @param type: 0 if the data is numbers
%            : 1 if the data is a string
% @return cell vector of the data in the text file
%%
fid = fopen(fileName);

colData = [];

switch type % number则建立数组，string则建立元胞
    case 0 
        colData = zeros(50,1);
    case 1
        colData = cell(50,1);    
end

row = 1;

line = fgetl(fid); % 读取当前行的内容


while ischar(line)
    
    switch type
        case 0
            num = str2num(line); % 转换为数字
            if(isempty(num) == 0) % 此行不为空
               colData(row,1) = num; % 填入数组
            else
               colData(row,1) = NaN; % 原本为“-”，导致转换后变成空
            end        
        case 1
            colData{row,1} = line; % 直接填入字符串
        otherwise
            assert(0,'Variable type set incorrectly: 0 for numbers, 1 for strings\n');
    end
    
    
    
    row = row+1;
    if(row > length(colData)) % 如果肌肉数大于50个，则再增加50个位置（补零）
        switch type
            case 0
                tmp = zeros(50,1);                
                colData = [colData; tmp];
            case 1
                tmp = cell(50);
                colData = {colData{:};tmp{:}};   
                colData = cell(50,1); % 【还是只有50个？】   
        end                   
    end
    
    line = fgetl(fid); % 读取下一行内容

end
fclose(fid);

colData = colData(1:1:(row-1)); % 删除最后一行