function F = subtractNeuropil(Fall, perc)
%SUBTRACTNEUROPIL Summary of this function goes here
%   Fall: the datastructure saved by suite2p
%   perc: the percentage of neuropil signal to subtract
    if nargin < 2
      perc = 0.7;
    end
    F = Fall.F - perc*Fall.Fneu;
    F = F(Fall.iscell(:,1)==1,:); %only return cells identified as cells from suite2p
end

