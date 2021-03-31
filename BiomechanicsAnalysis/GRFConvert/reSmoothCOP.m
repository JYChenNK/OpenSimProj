function [reCopX, reCopY] = reSmoothCOP(Fz, CopX, CopY)

Fs = 500;

step_sta_index = [];
step_end_index = [];
reCopX = CopX;
reCopY = CopY;

for i = 1:length(Fz)-1
    if Fz(i) < 100 && Fz(i+1) > 100
        step_sta_index = [step_sta_index, i];
    end
end

for i = 1:length(Fz)-1
    if Fz(i) > 100 && Fz(i+1) < 100
        step_end_index = [step_end_index, i];
    end
end

if step_end_index(1) > step_sta_index(1)
    step_end_index = [1,step_end_index];
end

if length(step_end_index) > length(step_sta_index)
   step_end_index = step_end_index(1:end-1); 
end


for i = 1:length(step_end_index)
    if step_end_index(i) - Fs/4 > 1
        
        [~, delta_index] = min(CopX(step_end_index(i)-Fs/4:step_end_index(i)));
        step_end_index(i) = step_end_index(i) - Fs/4 + delta_index;
    end
end

for i = 1:length(step_sta_index)
    if step_sta_index(i) + Fs/4 < length(CopX)
        [~, delta_index] = max(CopX(step_sta_index(i):step_sta_index(i)+Fs/4));
        step_sta_index(i) = step_sta_index(i) + delta_index;
    end
end

for i = 1:length(step_end_index)
    step_list = [step_end_index(i),step_end_index(i)+1,step_sta_index(i)-1:step_sta_index(i)];
    reCopX(step_end_index(i):step_sta_index(i)) = interp1(step_list,CopX(step_list),step_end_index(i):step_sta_index(i),'spline');
    reCopY(step_end_index(i):step_sta_index(i)) = interp1(step_list,CopY(step_list),step_end_index(i):step_sta_index(i),'spline');
end

