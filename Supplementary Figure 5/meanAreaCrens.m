function [mArea] = meanAreaCrens(Crens)

area = Crens.areas;
y = 1;
areaSz = [];
if isempty(area) == 1
    mArea = 0;
else
for x = 1:length(area)
    if area(x) ~= 0
        areaSz(y) = area(x)*(3.6^2)/(3.4^2);
        y = y +1;
    else
    end
end
mArea = mean(areaSz);
end
end

