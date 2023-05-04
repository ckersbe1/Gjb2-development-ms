function expDirs = getExpDirs(Fall_struct)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    expDirs = {};
    for i = 1:size(Fall_struct)
        parts = strsplit(Fall_struct(i).folder, '\');
        expDirs{i} = strjoin({parts{1:end-2}},'\');
    end
end