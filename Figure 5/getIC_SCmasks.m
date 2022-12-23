function [LICmask, RICmask, CTXmask] = getIC_SCmasks(X)
    Xmean = mean(X(:,:,100),3);
    [m,n] = size(Xmean);
    
    h = figure;
    
    %h.Position([50 50 800 600]);
    h_im = imagesc(Xmean);
    colormap gray;
    truesize;
     
    LIC = imellipse(gca,[60,35,150,85]);
    setResizable(LIC,0);
    wait(LIC);
    LICmask = createMask(LIC, h_im);
    
    RIC = imellipse(gca,[300,35,150,85]);
    setResizable(RIC,0);
    wait(RIC);
    RICmask = createMask(RIC, h_im);

    CTXmask = zeros(m,n);
    CTXmask(1:20,2:end-1) = 1;
    
end