%% ��ȡControlDesk����

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

    %% ����ͬ���ź�ѡ����������
    SynList = find(data.Syn == 1);
    SynListR = SynList + delayR*500;
    SynListL = SynList + delayL*500;
    SynH = SynListR(1);
    SynE = SynListR(end);
    SynTime = data.time(SynListR) - data.time(SynListR(1));

    %% ������ȡ
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

    %% ����ϵ��׼
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
    % mot�ļ���ͷ
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
    %     error('��ͷ(%d)������(%d)������ƥ��\n',length(colnamesTotal), datacols);      %����ͷ������������ƥ���򱨴�
    % end

    %% д���ͷ
    filename = [filename(1:end-3), 'mot'];
    filepath = [pathname, filename];  % �洢�ļ�·��+����
    fid = fopen(filepath, 'w');                                                         %�����µ�mot�ļ�
    if fid < 0
        fprintf('\n����:�ļ�����ʧ��%s\n', filename);                                                    %����ʧ�ܾͱ����˳�����
        return
    end
    fprintf(fid, '%s\nnRows=%d\nnColumns=%d\n\n', filename, datarows, datacols);                        %�����һ�α�ͷ
    fprintf(fid, 'name %s\ndatacolumns %d\ndatarows %d\nrange %f %f\nendheader\n', ...                  %����ڶ��α�ͷ
        filename, datacols, datarows, range(1), range(2));

    cols = [];                                                                                          %��ʼ���ַ���
    for FileIndex = 1:datacols
        cols = [cols, sprintf('%s\t', colnamesTotal{FileIndex})];                                               %���ַ����м����TAB
    end
    cols = [cols, '\n'];                                                                                %���ַ��������
    fprintf(fid, cols);                                                                                 %��������α�ͷ

    %% д������
    for FileIndex = 1:datarows
        fprintf(fid, '%20.10f\t', GRF_Data(FileIndex,:));                                                          %�������ݣ�����10λС��
        fprintf(fid, '\n');
    end
    fclose(fid);                                                                                       %�ر��ļ�
    
end

fprintf('Process Done\n');                                                     %������Ϻ���ʾ


