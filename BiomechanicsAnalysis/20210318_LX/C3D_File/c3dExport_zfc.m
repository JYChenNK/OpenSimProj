% ----------------------------------------------------------------------- %
% The OpenSim API is a toolkit for musculoskeletal modeling and           %
% simulation. See http://opensim.stanford.edu and the NOTICE file         %
% for more information. OpenSim is developed at Stanford University       %
% and supported by the US National Institutes of Health (U54 GM072970,    %
% R24 HD065690) and by DARPA through the Warrior Web program.             %
%                                                                         %
% Copyright (c) 2005-2018 Stanford University and the Authors             %
% Author(s): James Dunne                                                  %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

%% Example of using the Matlab-OpenSim class 

%% Load OpenSim libs
import org.opensim.modeling.*

%% Get the path to a C3D file
% 手动选择c3d文件
% [filename, path] = uigetfile('*.c3d');
% c3dpath = fullfile(path,filename);

% 确定c3d文件保存路径,和文件名称，循环读取和保存
subject_name = 'LX';
exp_date = '20210318';
exp_type = 'walk'; % 'static' or 'walk'
Path =  ['C:\Users\dell\Documents\OpenSim\4.1\' exp_date];
pathC3D = ['C:\Users\dell\Documents\OpenSim\4.1\' exp_date '\C3D_File'];
for exp_label = 3:4
%     filename = [subject_name '_' exp_date '_' exp_type '_000' num2str(exp_label)];
    filename = [subject_name '_' exp_date '_' exp_type '_000' num2str(exp_label) '.c3d'];
    c3dpath = fullfile(pathC3D,filename);
    
    %% Construct an opensimC3D object with input c3d path
    % Constructor takes full path to c3d file and an integer for forceplate
    % representation (1 = COP).
    c3d = osimC3D(c3dpath,1);
    
    %% Get some stats...
    % Get the number of marker trajectories
    nTrajectories = c3d.getNumTrajectories();
    % Get the marker data rate
    rMakers = c3d.getRate_marker();
    % % Get the number of forces
    % nForces = c3d.getNumForces();
    % % Get the force data rate
    % rForces = c3d.getRate_force();
    
    % Get Start and end time
    t0 = c3d.getStartTime();
    tn = c3d.getEndTime();
    
    %% Rotate the data
%     c3d.rotateData('y',180)
%     c3d.rotateData('x',90)%%%%%%%%%%%%%%%%%
    
    %% Get the c3d in different forms
    % Get OpenSim tables
    markerTable = c3d.getTable_markers();
    % forceTable = c3d.getTable_forces();
    % Get as Matlab Structures
    [markerStruct, forceStruct] = c3d.getAsStructs();
    
    %% Convert COP (mm to m) and Moments (Nmm to Nm)
    % c3d.convertMillimeters2Meters();
    
    %% Write the marker and force data to file
    if exist('TRC_File')==0              %判断是否已经存在名为TRC_File的文件夹
         mkdir([Path '\TRC_File']) 
%         system('mkdir TRC_File')         %在当前目录下，创建名为TRC_File的文件件
    end
    SavePath = [Path '\TRC_File'];
    SaveName = [subject_name '_' exp_date '_' exp_type '_000' num2str(exp_label) '.trc'];
    c3d.writeTRC(fullfile(SavePath,SaveName));  %Write to defined path input path.
%     c3d.writeTRC('C:\Users\dell\Documents\OpenSim\4.1\20200809\zfc_20200809_motion0006.trc')  %Write to defined path input path.

    
    % Write force data to mot file.
    % c3d.writeMOT()                       Write to dir of input c3d.
    % c3d.writeMOT('Walking.mot')          Write to dir of input c3d with defined file name.
    % c3d.writeMOT('C:/data/Walking.mot')  Write to defined path input path.
    %
    % This function assumes point and torque data are in mm and Nmm and
    % converts them to m and Nm. If your C3D is already in M and Nm,
    % comment out the internal function convertMillimeters2Meters()
    % c3d.writeMOT('test_data_forces.mot');
    
end