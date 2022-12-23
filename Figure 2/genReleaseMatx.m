function [relMatx probRelease] = genReleaseMatx(file)
% display image showing release locations, calculate spatial release
%load image
% [fn, dname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'});
% 
% openFile = [dname fn];
% numFrames = 1250;
% for i = 1:numFrames
%     img(:,:,i) = imread(openFile,i);
% end
% [fp,name,~] = fileparts([dname fn]);
% % Display image with grid overlapping
% figure; imagesc(mean(img,3)); 
% x = file.rotateDegrees; % change input here
% img = imrotate(img,x);
% colormap gray
% imshow(mean(img,3),[0 10000]); truesize;
relVec = zeros(1,size(file.ISCstruct.rois,2));
for i=1:length(file.ISCstruct.event)
    relVec(file.ISCstruct.event(i).startLoc) = relVec(file.ISCstruct.event(i).startLoc) + 1;
    %hold on;
   % plot(file.ISCstruct.posInd(file.ISCstruct.event(i).startLoc,1:2:end),file.ISCstruct.posInd(file.ISCstruct.event(i).startLoc,2:2:end),'Color','r');
end

% generate release matrix for comparisons
col = 1;
row = 1;
relMatx = zeros(12,100);
for x = 1:length(relVec)
    if x == 1
        relMatx(1,1) = relVec(x);
    else
        if file.ISCstruct.posInd(x,1) == file.ISCstruct.posInd(x-1,1)
            row = row + 1;
            relMatx(row,col) = relVec(x);
        else
            row = 1;
            col = col + 1;
            relMatx(row,col) = relVec(x);
        end
    end
end

probRelease = sum(relMatx,2)/length(file.ISCstruct.event);

end

