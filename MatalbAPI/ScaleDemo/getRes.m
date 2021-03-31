function [totalE,rmsE,maxE,maxName] = getRes()

ResFile=fopen('out.log','r+');% ��Ҫ��ȡ���ļ�
totalE = 100;
rmsE = 100;
maxE = 100;
maxName = 'null';

while ~feof(ResFile)
    tline=fgetl(ResFile);%��ȡһ��
    %fprintf(fidout,'%s\n',tline);       
    if strfind(tline,'total squared error') > 0
        num = regexp(tline, '-?\d*\.?\d*', 'match');
        num = str2double(num);
        NameIndexL = strfind(tline(16:end),'(') + 16;
        NameIndexR = strfind(tline(16:end),')') + 16-2;
        
        totalE = num(2);rmsE = num(3);maxE = num(4);
        maxName = tline(NameIndexL:NameIndexR);
        break;
    end
end

fclose(ResFile);
ResFile=fopen('out.log','w+');% ��Ҫ��ȡ���ļ�
fclose(ResFile);