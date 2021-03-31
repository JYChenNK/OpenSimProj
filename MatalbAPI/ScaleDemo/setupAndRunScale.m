
import org.opensim.modeling.*
ModelVisualizer.addDirToGeometrySearchPaths('B:\OpenSim\OpenSim 4.1\Geometry');

scaleTool = ScaleTool('ScaleSet.xml');
scaleTool.run();
[totalE0,rmsE0,maxE0,maxName0] = getRes();

totalE = zeros(100,6);
rmsE = zeros(100,6);
maxE = zeros(100,6);
maxName = cell(100,6);

best_individal = 0;
adjustName = maxName0;

for i = 1:30
    for j = 1:1
        
        adjustpos = zeros(1,3);
        adjustpos(j) = 0.00;
        creatModel(i-1,best_individal,i,j,adjustName, adjustpos);
        
        creatScaleSet(i,j);
        scaleTool = ScaleTool('ScaleSetOpt.xml');
        scaleTool.run();
        
        [totalE(i,j),rmsE(i,j),maxE(i,j),maxName{i,j}] = getRes();
    end
    
%     for j = 4:6
%         adjustpos = zeros(1,3);
%         adjustpos(j-3) = -0.01;
%         creatModel(i-1,best_individal,i,j,adjustName, adjustpos);
%         
%         creatScaleSet(i,j);
%         scaleTool = ScaleTool('ScaleSetOpt.xml');
%         scaleTool.run();
%         
%         [totalE(i,j),rmsE(i,j),maxE(i,j),maxName{i,j}] = getRes();
%     end
    
%     [~,best_individal] = min(maxE(i,:));
    best_individal = 1;
    adjustName = maxName{i,best_individal};
end




