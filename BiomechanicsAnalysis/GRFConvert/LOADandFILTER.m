function data = LOADandFILTER(pathname,filename,CutOffFreq)

%% PROCESS RAW DATA (FROM CONTROLDESK)
% clear;
% pathname = 'C:\Users\dell\Documents\OpenSim\4.1\20210318\GRF_MAT_File\';
% filename = 'LX_20210318_003.mat'; 

% a = sprintf('Processing raw data...'); disp(a);
% eval(['load(''' filename '.mat'');']); %load the data file
str = [pathname filename];
load(str);
filename = filename(1:(length(filename)-4));
eval('if length(filename)>31 filename=filename([1:31]); end;');

eval(['time = ' filename '.X(1).Data;']); %transfer xdata
eval(['ydata = ' filename '.Y;']); %transfer ydata
data = [];
data.time = time;
for i = 1:length(ydata) %parse through ydata
    namestr = ydata(i).Name;
    if strcmp(namestr,'Value') || ~isempty(strfind(namestr,'In'))
        pathstr = ydata(i).Path;
        pathind = strfind(pathstr,'/');
        if isempty(pathind)
            namestr = pathstr;
        else
            namestr = pathstr(pathind(end)+1:end);
        end
    end
    if exist(namestr,'var')
        namestr(end+1) = '1';
    end
    if strcmp(namestr, 'Value')
        tt =ydata(i).Path;
        idx = find(tt=='\');
        namestr = tt((idx(end)+1):end);
    end
    
    namestr([strfind(namestr,' '),...
        strfind(namestr,'{'),...
        strfind(namestr,'}'),...
        strfind(namestr,'('),...
        strfind(namestr,')'),...
        strfind(namestr,'['),...
        strfind(namestr,']')]) = '_';
    if namestr(end) == '_'
        namestr = namestr(1:end-1);
    end
    if strcmp(namestr, 'Syn')
        eval([namestr ' = ydata(' num2str(i) ').Data;']);
    else
        eval([namestr ' = filter(Lowpass' num2str(CutOffFreq) ',ydata(' num2str(i) ').Data);']);
    end
    if eval(['length(' namestr ') ~= length(time)'])
        eval([namestr '= double(' namestr ');']);
        eval([namestr ' = ones(1,length(time))*' namestr '(1);']);
    end
    eval(['data.',namestr,' = ',namestr,';']);
end
% save (['D:\MATLAB\bin\ΩÁ√Ê_new0726\','data.mat'],'data');