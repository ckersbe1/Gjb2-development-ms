%%2P grid analysis 
% CJK 2020, modified from Travis' and Calvin's version of ISCGridAnalysis

%load image
[fn, dname] = uigetfile({'*.tif';'*.TIF';'*.tiff';'*.TIFF'});
ICstruct = struct();
openFile = [dname fn];
numFrames = 2000;
for i = 1:numFrames
    img(:,:,i) = imread(openFile,i);
end
[fp,name,~] = fileparts([dname fn]);


%% Create grid overlay
widthImg = size(img,2);
heightImg = size(img,1);
sizeSq = 10;
maxTime = 500; % in seconds (need to check) 
[indices,miniIndices] = getGrid(widthImg,heightImg,sizeSq);
imagesc(mean(img,3)); truesize;

for i=1:size(indices,1)
    hold on;
    plot(indices(i,1:2:end),indices(i,2:2:end),'Color','g');
end

%%
%bleachCorrect
img = bleachCorrect(img,1);
rois = normalizeGridImg(img,10,indices);

[t,n] = size(rois);
ICstruct.rois = rois;

numToShow = 100;
temp = randperm(n)';
temp = sort(temp(1:numToShow));
figure; plot(rois(:,temp) - 1*repmat(1:numToShow,t,1),'Color','k');

%% 
roiSignal = ICstruct.rois;
medSig = median(roiSignal);
stdSig = mean(std(roiSignal,1));
% much happier with these parameters
roiThr = roiSignal > medSig + 2*stdSig;

%%
imgbinary = zeros(floor(size(img,1)/10)-2,floor(size(img,2)/10)-2,2000);

for i = 1:size(miniIndices)
    imgbinary(miniIndices(i,1),miniIndices(i,2),:) = roiThr(:,i);
end

imgbinary = imgbinary > 0;
labels = bwlabeln(imgbinary,26); % every single connection point for cube in 3D space
count = 0; number = []; 

newlabels = zeros(size(labels));
labelcount = 1;
for i=1:max(labels,[],'all') 
    [i1,i2,i3] = ind2sub(size(labels),find(labels(:)==i)); %get x,y,t coordinates for label i
    
    if max(i3)-min(i3) <= 6 || size(i1,1) <= 10 %scrub any events that last less than 6 frames or has less than 10 connected squares
        count = count + 1;
%     elseif size(i1,1) > 1000 % large events - are they single or multiple? 
%         temp = (labels == i) .* labels;
%         singleLabel = labelsToRois(temp, miniIndices,size(roiThr));
%         generateActivityMovie_labels2(img(:,:,min(i3):max(i3)),singleLabel(min(i3):max(i3),:)',indices,[],[0 500]);
%         drawnow;
%         
%        x = queryEventNum();
%        
%        satisfied = 0;
%        
%        xscale = 1;
%        yscale = 1;
%        tscale = 2;
%        while ~satisfied
%            if x == 1
%                satisfied = 1;
%                newlabels(labels == i) = labelcount;
%                labelcount = labelcount + 1;
%            else
%                indices = kmeans([i1/xscale i2/yscale i3/tscale],x); %cluster data into x number of groups
%                temp(sub2ind(size(labels),i1,i2,i3)) = indices; %store these clusters temporarily
%                singleLabel = labelsToRois(temp, miniIndices,size(roiThr)); %convert into ROIs for generate activity movie function
%                generateActivityMovie_labels2(img(:,:,min(i3):max(i3)),singleLabel(min(i3):max(i3),:)',indices,[],[0 500]);
%                
%                satisfied = querySatisfaction();
%                
%                if ~satisfied
%                    [xscale, yscale, tscale] = queryScale(xscale,yscale,tscale);
%                else
%                    for j = 1:max(indices)
%                         newlabels(temp == j) = labelcount;
%                         labelcount = labelcount + 1;
%                    end
%                end
%            end
%        end
    else %if small, just add label into new labels
        newlabels(labels == i) = labelcount;
        labelcount = labelcount + 1;
    end
end
disp([num2str(count) ' events were scrubbed.'])
%%
labelRoi = labelsToRois(newlabels, miniIndices, size(roiThr));
%%
generateActivityMovie_labels(img,labelRoi',indices,[fp '\' name '_ActiveMovie'],[0 400]);
%% analysis
ICstruct.activeArea = sum(sum(labelRoi,1) > 1) / size(labelRoi,2)
for i = 1:max(newlabels,[],'all')
    [i1,i2,i3] = ind2sub(size(newlabels),find(newlabels(:)==i)); %get x,y,t coordinates for label i
    ICstruct.event(i).timeStart = min(i3);
    ICstruct.event(i).timeEnd = max(i3);
    ICstruct.event(i).eventDuration = max(i3) - min(i3);
    ICstruct.event(i).area = size(unique([i1 i2],'rows'),1);
end

[fp,name,~] = fileparts([dname fn]);
save([fp '\' name '_ICdata.mat'],'ICstruct');


%%
function labelRoi = labelsToRois(labels, miniIndices, sizeRois)
    labelRoi = zeros(sizeRois);
    for i = 1:size(miniIndices)
        labelRoi(:,i) = squeeze(labels(miniIndices(i,1),miniIndices(i,2),:));
    end
end

function numEvents = queryEventNum()
    x = input('How many events do you see? ');
    
       while 1
           if isnumeric(x) && x > 0
               numEvents = x;
               return
           else
             x = input('How many events do you see? (Enter a postive number) ');
           end
       end
end

function satisfied = querySatisfaction()
    satisfied = input('Satisfied?');
    
    while 1
       if isnumeric(satisfied) && satisfied >= 0 && satisfied <=1
           return
       else
         satisfied = input('Are you satisfied? (0) No (1) Yes');
       end
    end
end

function [xscale,yscale,tscale] = queryScale(xscale,yscale,tscale)
    xscale = xscale; yscale = yscale; tscale = tscale;
    x = input(['Which scale would you like to alter to adjust clustering?\n' ... 
        '(1) x, Current value: ' num2str(xscale) '\n' ...
        '(2) y, Current value: ' num2str(yscale) '\n' ...
        '(3) t, Current value: ' num2str(tscale) '\n']);
    
    while 1
       if x > 0 && x <= 3
           if x == 1
                xscale = input('What is the new scale? ');
                while 1
                     if isnumeric(xscale)
                           return
                     else
                        xscale = input('What is the new scale? (Must be numeric) ');
                     end
                end
           elseif x == 2
                yscale = input('What is the new scale?');
                while 1
                     if isnumeric(yscale)
                           return
                     else
                        yscale = input('What is the new scale? (Must be numeric) ');
                     end
                end
           elseif x == 3
                tscale = input('What is the new scale?');
                while 1
                     if isnumeric(tscale)
                           return
                     else
                        tscale = input('What is the new scale? (Must be numeric) ');
                     end
                end
           end
       else
         x = input(['Which scale would you like to alter to adjust clustering?\n' ... 
        '(1) x, Current value: ' num2str(xscale) '\n' ...
        '(2) y, Current value: ' num2str(yscale) '\n' ...
        '(3) t, Current value: ' num2str(tscale) '\n']);
       end
   end
end



