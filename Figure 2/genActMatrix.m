function [actMatx] = genActMatrix(numPks, positiveIndices)

col = 1;
row = 1;
actMatx = zeros(10,100);
for x = 1:length(numPks)
    if x == 1
        actMatx(1,1) = numPks(x);
    else
        if positiveIndices(x,1) == positiveIndices(x-1,1)
            row = row + 1;
            actMatx(row,col) = numPks(x);
        else
            row = 1;
            col = col + 1;
            actMatx(row,col) = numPks(x);
        end
    end


end

