%% 读取ControlDesk数据
clear
pathname = 'GRF_Flie\';
filename = 'LX_20210320_001.mat'; 
data = AFODataLoading(pathname,filename);

%% 根据同步信号选择数据区间
Syn_start = 0.6*5000;
Syn_end = length(data.time);
IndexRange = Syn_start:Syn_end;

% colnamesTotal = {'time','ground_force_vx','ground_force_vy','ground_force_vz',...       
%     'ground_force_px','ground_force_py','ground_force_pz',...
%     '1_ground_force_vx','1_ground_force_vy','1_ground_force_vz',...
%     '1_ground_force_px','1_ground_force_py','1_ground_force_pz',...
%     'ground_torque_x','ground_torque_y','ground_torque_z',...
%     '1_ground_torque_x','1_ground_torque_y','1_ground_torque_z'};

%% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  %% 
% 校准 
DATA = [];
data.copZ_R = zeros(1,length(data.time));
data.copZ_L = data.copZ_R;

DATA = [data.time(1:(Syn_end-Syn_start+1))'...
    data.Fx_R(IndexRange)' data.Fy_R(IndexRange)' filter(Lowpass6, data.Fz_R(IndexRange))'...
    filter(Lowpass6,data.copX_R(IndexRange))' data.copY_R(IndexRange)' data.copZ_R(IndexRange)'...
    data.Fx_L(IndexRange)' data.Fy_L(IndexRange)' data.Fz_L(IndexRange)'...
    data.copX_L(IndexRange)' data.copY_L(IndexRange)' data.copZ_L(IndexRange)'...
    data.Mx_R(IndexRange)' data.My_R(IndexRange)' data.Mz_R(IndexRange)'...
    data.Mx_L(IndexRange)' data.My_L(IndexRange)' data.Mz_L(IndexRange)'];
% % 右侧用用7000-7200之间的数据作为校准值
% for i = [2:4 14:16]
%     DATA(:,i) = DATA(:,i) - mean(DATA(7000:7200,i));
% end
% % 左侧用用99000-10000之间的数据作为校准值
% for i = [8:10 17:19]
%     DATA(:,i) = DATA(:,i) - mean(DATA(9900:10000,i));
% end
% 计算COP
% h = 0.015;
% cop_x = (-h*Fx-My)/Fz;
% cop_y = (h*Fy+Mx)/Fz;
% for i = 1:length(DATA(:,4))
%     if DATA(i,4) > 100
%         DATA(i,5) = (-h*DATA(i,2)-DATA(i,15))./DATA(i,4);
%         DATA(i,6) = (h*DATA(i,3)+DATA(i,14))./DATA(i,4);
%     else
%         DATA(i,5) = 0;
%         DATA(i,6) = 0;
%     end
%     if DATA(i,10) > 100
%         DATA(i,11) = (-h*DATA(i,8)-DATA(i,18))./DATA(i,10);
%         DATA(i,12) = (h*DATA(i,9)+DATA(i,17))./DATA(i,10);
%     else
%         DATA(i,11) = 0;
%         DATA(i,12) = 0;
%     end
% end

%% 关于方向：opensim坐标系与动捕坐标系已统一，opensim的x是跑台的y，opensim的y是跑台的-z，opensim的z是跑台的-x 
% 力和力矩方向转换关系：
% 人受力方向与跑台方向相反：人在跑台上的受力坐标系与opensim坐标系相比：opensim的x对应-y，opensim的y对应z，opensim的z对应x
% 坐标转换关系：
% 跑台左侧和右侧原点不同：(单位统一)
% x = yr -0.7663;
% y = -zr +0.01865;
% z = -xr +0.5623;
% z = -xl -0.5801;

% 转换力和力矩方向：
GRF_Data = [DATA(:,1)...
    -DATA(:,3) DATA(:,4) DATA(:,2)...
    DATA(:,5) -DATA(:,7) -DATA(:,6)...
    -DATA(:,9) DATA(:,10) DATA(:,8)...
    DATA(:,11) -DATA(:,13) -DATA(:,12)...
    -DATA(:,15) DATA(:,16) DATA(:,14)...
    -DATA(:,18) DATA(:,19) DATA(:,17)];
% 转换位置坐标
% r:
GRF_Data(:,5) = GRF_Data(:,5) - 1;
GRF_Data(:,6) = GRF_Data(:,6) - 0.01865;
GRF_Data(:,7) = GRF_Data(:,7) + 0.57;
% l:
GRF_Data(:,11) = GRF_Data(:,11) - 1;
GRF_Data(:,12) = GRF_Data(:,12) - 0.01865;
GRF_Data(:,13) = GRF_Data(:,13) - 0.57;


% figure;
% plot(GRF_Data(:,5));
% hold on
% plot(GRF_Data(:,6));
% hold on
% plot(GRF_Data(:,7));
% 
% figure;
% plot(GRF_Data(:,11));
% hold on
% plot(GRF_Data(:,12));
% hold on
% plot(GRF_Data(:,13));

GRF_Data = GRF_Data(1:50:end,:);


%% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  %% 
% mot文件表头
colnamesTotal = {'time',...
    'ground_force_vx','ground_force_vy','ground_force_vz',...       
    'ground_force_px','ground_force_py','ground_force_pz',...
    '1_ground_force_vx','1_ground_force_vy','1_ground_force_vz',...
    '1_ground_force_px','1_ground_force_py','1_ground_force_pz',...
    'ground_torque_x','ground_torque_y','ground_torque_z',...
    '1_ground_torque_x','1_ground_torque_y','1_ground_torque_z'};

datacols = 19;
datarows = size(GRF_Data,1);
%提取时间列
time = data.time;         
%提取首末时间值
range = [time(Syn_start), time(Syn_end)];                                              

% if length(colnamesTotal) ~= datacols
%     error('表头(%d)与数据(%d)数量不匹配\n',length(colnamesTotal), datacols);      %若表头与数据数量不匹配则报错
% end

%% 写入表头
filepath = 'GRF_MOT_File\GRF_LX_20210320_walk_1.mot';  % 存储文件路径+名称
fid = fopen(filepath, 'w');                                                         %创建新的mot文件
if fid < 0
    fprintf('\n错误:文件创建失败%s\n', filename);                                                    %创建失败就报错并退出函数
    return
end
fprintf(fid, '%s\nnRows=%d\nnColumns=%d\n\n', filename, datarows, datacols);                        %输入第一段表头
fprintf(fid, 'name %s\ndatacolumns %d\ndatarows %d\nrange %f %f\nendheader\n', ...                  %输入第二段表头
    filename, datacols, datarows, range(1), range(2));

cols = [];                                                                                          %初始化字符串
for i = 1:datacols
    cols = [cols, sprintf('%s\t', colnamesTotal{i})];                                               %在字符串中间添加TAB
end
cols = [cols, '\n'];                                                                                %在字符串最后换行
fprintf(fid, cols);                                                                                 %输入第三段表头

%% 写入数据
for i = 1:datarows
    fprintf(fid, '%20.10f\t', GRF_Data(i,:));                                                          %输入数据，保留10位小数
    fprintf(fid, '\n');
end
fclose(fid);                                                                                       %关闭文件
fprintf('足底力mot文件保存为: %s\n', filepath);                                                     %保存完毕后提示


