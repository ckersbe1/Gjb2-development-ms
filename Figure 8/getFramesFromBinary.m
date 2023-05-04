function frames = getFramesFromBinary(file,x_dim,y_dim,startFrame,endFrame)
%GETFRAMESFROMBINARY This function picks off frames from a binary file
%without bringing the whole binary into memory. Perfect for computing
%averages of particular frames from a very large time series.
%   file: path to the binary
%   x_dim,y_dim: dimensions of x and y
%   startFrame, endFrame: start through stop frames to extract
    bytes_per_pixel = 2;
    fileid = fopen(file,'r','l'); %this command does not load file into memory, just gets it ready for reading
    fseek(fileid, (startFrame-1)*x_dim*y_dim*bytes_per_pixel, -1);
    frames = fread(fileid, x_dim*y_dim*(endFrame-startFrame+1), '*uint16');
    frames = pagetranspose(reshape(frames,x_dim,y_dim,[])); %page transpose to get it into the same view as tiffs
    fclose(fileid);
end