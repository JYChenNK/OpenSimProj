function creatScaleSet(gen,ind)

ScaledSetFile=fopen('ScaleSet.xml','r+');% ��Ҫ��ȡ���ļ�
ScaledSetOptFile=fopen('ScaleSetOpt.xml','w');% ��Ҫ��ȡ���ļ�
i=0;
while ~feof(ScaledSetFile)
    tline=fgetl(ScaledSetFile);%��ȡһ��
    %fprintf(fidout,'%s\n',tline);       
    i = i+1;
    
    if i==15   
        fprintf(ScaledSetOptFile,['			<model_file>Scaled/Model_g' num2str(gen) 'p' num2str(ind) '.osim</model_file>\r\n']);
    elseif i == 572
        fprintf(ScaledSetOptFile,['			<output_model_file>Scaled/ScaledModel_g' num2str(gen) 'p' num2str(ind) '.osim</output_model_file>\r\n']);
    else
        fprintf(ScaledSetOptFile,'%s\r\n',tline);
    end
end
fclose(ScaledSetFile);
fclose(ScaledSetOptFile);