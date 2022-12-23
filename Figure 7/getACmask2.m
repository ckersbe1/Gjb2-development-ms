function [ACmask] = getACmask2(X)
    Xmean = mean(X,3);
    [m,n] = size(Xmean);
    
   h = figure;
    %h.Position([50 50 800 600]);
    h_im = imagesc(Xmean);
     
    AC = drawcircle('Center',[270 320],'Radius',150,'Color','r');
    %setResizable(AC,0);
    wait(AC);
    ACmask = createMask(AC, h_im);
    
end