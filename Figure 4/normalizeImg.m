function [dFoF, Fo, img] = normalizeImg(img, percentile)
%normalizeImg Normalizes image based on percentile chosen after bleach correction. 
%   On a block by block basis, Fo is created by taking the pixel value at
%   the xth percentile. This is subtracted off of the original image; the
%   resulting image is then divided by Fo. 

    [m,n,T] = size(img);
    
    %Normalize by taking Xth percentile
    
   % Xreshape = reshape(img,m*n,T)';
    Fo = prctile(img,percentile,1);
   % Fo = reshape(Fo',m,n);
    
   % Fo = prctile(img,percentile,1);
    dFoF = (single(img) - single(Fo)) ./ single(Fo);
end


