function [h c yAxisNorm h1 sizeEvents h2] = drawCrenations(events,locs,totalTime,baseImg,dname)

    h = figure;
    imshow(baseImg); hold on;
    cm = hsv; 
    c = regionprops(events, 'Centroid');
    
    for i = 1:size(locs,1)
       b = bwboundaries(events(:,:,i));
      
       for j = 1:size(b,1)
           temp = b{j};
           patch(smooth(temp(:,2)),smooth(temp(:,1)),cm(round(locs(i)/totalTime*256),:),'FaceAlpha',0.4,'LineStyle','none');
       end
    end
    
    h2 = colorTicks(locs,totalTime);
    
    % distribution of centroid location, in Y
    sizeEvents = sum(arrayfun(@(c) ~isempty(c(:).Centroid),c))
    figure
    [imgname dname] = uigetfile([dname '\*.tif']);
    baseImg = loadTif(imgname,8);
    imshow(baseImg); hold on;
    %get y coordinate of IHC nuceli
    [IHCx,IHCy] = ginput(1);
    for i = 1:sizeEvents
        yAxis(i) = c(i).Centroid(2);
        yAxisNorm(i) = (yAxis(i)-IHCy)/3.4; % 6.8 pixels / micron
        if yAxisNorm(i) < 0
            yAxisNorm(i) = 0;
        end
    end
    
   
    % bin by calcium imaging size
    gridSize = 10;
    binSize = [0 10:gridSize:120 1000];
    h1 = histcounts(yAxisNorm,binSize);
    h2 = histcounts(yAxisNorm,binSize)/sizeEvents;
end

