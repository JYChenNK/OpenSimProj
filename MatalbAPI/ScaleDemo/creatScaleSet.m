function creatScaleSet(gen,ind)

ScaledSetFile=fopen('ScaleSet.xml','r+');% 需要读取的文件
ScaledSetOptFile=fopen('ScaleSetOpt.xml','w');% 需要读取的文件
i=0;
while ~feof(ScaledSetFile)
    tline=fgetl(ScaledSetFile);%读取一行
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