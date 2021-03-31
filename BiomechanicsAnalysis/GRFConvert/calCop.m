function [CopX, CopY] = calCop(Fz,Fx,Fy,Mx,My)

h=0.015;

CopY = (-h.*Fx-My)./Fz;
CopX = (h.*Fy+Mx)./Fz;