%% ��ȡControlDesk����
clear
pathname = 'GRF_Flie\';
filename = 'LX_20210320_001.mat'; 
data = AFODataLoading(pathname,filename);

%% ����ͬ���ź�ѡ����������
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
% У׼ 
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
% % �Ҳ�����7000-7200֮���������ΪУ׼ֵ
% for i = [2:4 14:16]
%     DATA(:,i) = DATA(:,i) - mean(DATA(7000:7200,i));
% end
% % �������99000-10000֮���������ΪУ׼ֵ
% for i = [8:10 17:19]
%     DATA(:,i) = DATA(:,i) - mean(DATA(9900:10000,i));
% end
% ����COP
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

%% ���ڷ���opensim����ϵ�붯������ϵ��ͳһ��opensim��x����̨��y��opensim��y����̨��-z��opensim��z����̨��-x 
% �������ط���ת����ϵ��
% ��������������̨�����෴��������̨�ϵ���������ϵ��opensim����ϵ��ȣ�opensim��x��Ӧ-y��opensim��y��Ӧz��opensim��z��Ӧx
% ����ת����ϵ��
% ��̨�����Ҳ�ԭ�㲻ͬ��(��λͳһ)
% x = yr -0.7663;
% y = -zr +0.01865;
% z = -xr +0.5623;
% z = -xl -0.5801;

% ת���������ط���
GRF_Data = [DATA(:,1)...
    -DATA(:,3) DATA(:,4) DATA(:,2)...
    DATA(:,5) -DATA(:,7) -DATA(:,6)...
    -DATA(:,9) DATA(:,10) DATA(:,8)...
    DATA(:,11) -DATA(:,13) -DATA(:,12)...
    -DATA(:,15) DATA(:,16) DATA(:,14)...
    -DATA(:,18) DATA(:,19) DATA(:,17)];
% ת��λ������
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
%��ȡʱ����
time = data.time;         
%��ȡ��ĩʱ��ֵ
range = [time(Syn_start), time(Syn_end)];                                              

% if length(colnamesTotal) ~= datacols
%     error('��ͷ(%d)������(%d)������ƥ��\n',length(colnamesTotal), datacols);      %����ͷ������������ƥ���򱨴�
% end

%% д���ͷ
filepath = 'GRF_MOT_File\GRF_LX_20210320_walk_1.mot';  % �洢�ļ�·��+����
fid = fopen(filepath, 'w');                                                         %�����µ�mot�ļ�
if fid < 0
    fprintf('\n����:�ļ�����ʧ��%s\n', filename);                                                    %����ʧ�ܾͱ����˳�����
    return
end
fprintf(fid, '%s\nnRows=%d\nnColumns=%d\n\n', filename, datarows, datacols);                        %�����һ�α�ͷ
fprintf(fid, 'name %s\ndatacolumns %d\ndatarows %d\nrange %f %f\nendheader\n', ...                  %����ڶ��α�ͷ
    filename, datacols, datarows, range(1), range(2));

cols = [];                                                                                          %��ʼ���ַ���
for i = 1:datacols
    cols = [cols, sprintf('%s\t', colnamesTotal{i})];                                               %���ַ����м����TAB
end
cols = [cols, '\n'];                                                                                %���ַ��������
fprintf(fid, cols);                                                                                 %��������α�ͷ

%% д������
for i = 1:datarows
    fprintf(fid, '%20.10f\t', GRF_Data(i,:));                                                          %�������ݣ�����10λС��
    fprintf(fid, '\n');
end
fclose(fid);                                                                                       %�ر��ļ�
fprintf('�����mot�ļ�����Ϊ: %s\n', filepath);                                                     %������Ϻ���ʾ


