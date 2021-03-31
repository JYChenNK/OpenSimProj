function creatModel(gen_o,ind_o,gen,ind,MakerName,d_pos)

RefModel=fopen(['Scaled/ScaledModel_g' num2str(gen_o) 'p' num2str(ind_o) '.osim'],'r+');% 需要读取的文件
NewModel=fopen(['Scaled/Model_g' num2str(gen) 'p' num2str(ind) '.osim'],'w+');% 需要读取的文件
flag = 0;

while ~feof(RefModel)
    tline=fgetl(RefModel);%读取一行
    %fprintf(fidout,'%s\n',tline);       
    if strfind(tline, MakerName) > 0
        flag = 1;
    end
    if flag == 1 & strfind(tline, '<location>') > 0 
        num = regexp(tline, '-?\d*\.?\d*', 'match');
        num = str2double(num);
        px = num(1);py = num(2);pz = num(3);
        fprintf(NewModel,['					<location>' num2str(px+d_pos(1),18) ' ' num2str(py+d_pos(2),18) ' ' num2str(pz+d_pos(3),18) '</location>\r\n']);
        flag = 0;
    else
        fprintf(NewModel,'%s\r\n',tline);
    end
end

fclose(RefModel);
fclose(NewModel);