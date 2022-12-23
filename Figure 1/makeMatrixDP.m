function [dp8,dp12,dp16,dp20,dp24] = makeMatrixDP(fname)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

dp8 = [];
dp12 = [];
dp16 = [];
dp20 = [];
dp24 = [];

for i = 1:13
    dp8 = [dp8; fname(1,i).trace];
end
for i = 14:26
    dp12 = [dp12; fname(1,i).trace];
end


end

