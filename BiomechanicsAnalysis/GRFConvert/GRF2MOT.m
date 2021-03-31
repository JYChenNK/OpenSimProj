%% 读取ControlDesk数据

CutOff_Freq = 15;
delayR = 0.05;
delayL = 0.05;

[FileName, PathName] = uigetfile({'*.mat'},'MultiSelect', 'on');

if ischar(FileName)
    FileName = {FileName};
end

FileLen = length(FileName);

for FileIndex = 1:FileLen
    
    fprintf('Processing File %d\n',FileIndex)
    
    filename = FileName{FileIndex};
    pathname = PathName;
    
    data = LOADandFILTER(pathname,filename,CutOff_Freq);

    %% 根据同步信号选择数据区间
    SynList = find(data.Syn == 1);
    SynListR = SynList + delayR*500;
    SynListL = SynList + delayL*500;
    SynH = SynListR(1);
    SynE = SynListR(end);
    SynTime = data.time(SynListR) - data.time(SynListR(1));

    %% 数据提取
    DATA = [];
    data.copZ_R = zeros(1,length(data.time));
    data.copZ_L = data.copZ_R;
    data.copX_R = data.copZ_R;data.copX_L = data.copZ_R;
    data.copY_R = data.copZ_R;data.copY_L = data.copZ_R;
    
       
%     [data.copX_R,data.copY_R] = calCop(data.Fz_R,data.Fx_R,data.Fy_R,data.Mx_R,data.My_R);
%     [data.copX_L,data.copY_L] = calCop(data.Fz_L,data.Fx_L,data.Fy_L,data.Mx_L,data.My_L);
%     
%     [data.copX_R, data.copY_R] = reSmoothCOP(data.Fz_R, data.copX_R, data.copY_R);
%     [data.copX_L, data.copY_L] = reSmoothCOP(data.Fz_L, data.copX_L, data.copY_L);

    DATA = [SynTime'...
        data.Fx_R(SynListR)' data.Fy_R(SynListR)' data.Fz_R(SynListR)'...
        data.copX_R(SynListR)' data.copY_R(SynListR)' data.copZ_R(SynListR)'...
        data.Fx_L(SynListL)' data.Fy_L(SynListL)' data.Fz_L(SynListL)'...
        data.copX_L(SynListL)' data.copY_L(SynListL)' data.copZ_L(SynListL)'...
        data.Mx_R(SynListR)' data.My_R(SynListR)' data.Mz_R(SynListR)'...
        data.Mx_L(SynListL)' data.My_L(SynListL)' data.Mz_L(SynListL)'];

    %% 坐标系配准
    GRF_Data = [DATA(:,1)...
        -DATA(:,3) DATA(:,4) DATA(:,2)...
        DATA(:,5) -DATA(:,7) -DATA(:,6)...
        -DATA(:,9) DATA(:,10) DATA(:,8)...
        DATA(:,11) -DATA(:,13) -DATA(:,12)...
        -DATA(:,15) DATA(:,16) DATA(:,14)...
        -DATA(:,18) DATA(:,19) DATA(:,17)];

    % Right Side
    GRF_Data(:,5) = GRF_Data(:,5) - 0.7;
    GRF_Data(:,6) = GRF_Data(:,6) - 0.018;
    GRF_Data(:,7) = GRF_Data(:,7) + 0.56;
    % Left Side
    GRF_Data(:,11) = GRF_Data(:,11) - 0.7;
    GRF_Data(:,12) = GRF_Data(:,12) - 0.018;
    GRF_Data(:,13) = GRF_Data(:,13) - 0.56;

    GRF_Data = GRF_Data(1:end,:);


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
    range = [SynTime(1), SynTime(end)];                                              

    % if length(colnamesTotal) ~= datacols
    %     error('表头(%d)与数据(%d)数量不匹配\n',length(colnamesTotal), datacols);      %若表头与数据数量不匹配则报错
    % end

    %% 写入表头
    filename = [filename(1:end-3), 'mot'];
    filepath = [pathname, filename];  % 存储文件路径+名称
    fid = fopen(filepath, 'w');                                                         %创建新的mot文件
    if fid < 0
        fprintf('\n错误:文件创建失败%s\n', filename);                                                    %创建失败就报错并退出函数
        return
    end
    fprintf(fid, '%s\nnRows=%d\nnColumns=%d\n\n', filename, datarows, datacols);                        %输入第一段表头
    fprintf(fid, 'name %s\ndatacolumns %d\ndatarows %d\nrange %f %f\nendheader\n', ...                  %输入第二段表头
        filename, datacols, datarows, range(1), range(2));

    cols = [];                                                                                          %初始化字符串
    for FileIndex = 1:datacols
        cols = [cols, sprintf('%s\t', colnamesTotal{FileIndex})];                                               %在字符串中间添加TAB
    end
    cols = [cols, '\n'];                                                                                %在字符串最后换行
    fprintf(fid, cols);                                                                                 %输入第三段表头

    %% 写入数据
    for FileIndex = 1:datarows
        fprintf(fid, '%20.10f\t', GRF_Data(FileIndex,:));                                                          %输入数据，保留10位小数
        fprintf(fid, '\n');
    end
    fclose(fid);                                                                                       %关闭文件
    
end

fprintf('Process Done\n');                                                     %保存完毕后提示


