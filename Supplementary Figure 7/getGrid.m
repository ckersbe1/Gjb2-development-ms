function [indices,miniIndices] = getGrid(imgWidth,imgHeight,sizeGrid)
    index = 1;
    indices = []; %contains indices to draw boxes in real pixel dimensions
    miniIndices = []; %contains indices of boxes only, i.e. top left box is [1 1], box below that is [2 1], etc.

    index = 1;
    for i = 1:floor(imgWidth/sizeGrid)-2
        for j = 1:floor(imgHeight/sizeGrid)-2
            it = i + (i-1)*sizeGrid;
            jt = j + (j-1)*sizeGrid;
            indices(index,:) = [it jt it+sizeGrid jt it+sizeGrid jt+sizeGrid it jt+sizeGrid];
            miniIndices(index,:) = [i j];
            index = index + 1;
        end
    end
end