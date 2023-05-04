function Fall = loadFs(wdir)
%LOADFS loads flourescence values from all cells
%   Detailed explanation goes here
    file = wdir + "\suite2p\plane0\Fall.mat"
    exists = exist(file)
    if exists
        Fall = load(file)
    else
        error("Flourescence file is not in the correct location. \n Location tried: " + wdir + "\suite2p\plane0\Fall.mat")
    end
end

