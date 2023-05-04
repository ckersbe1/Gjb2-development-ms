% Single image processing to add crenation images to stat file

%list = loadFileList('.\*.tif');
%imgList = list(~contains(list,'Washout'));
%list = loadFileList('.\Data\Crenations\P7_MRS_CJK_PT\*.mat');
%statList = list(~contains(list,'Washout'));
dname = 'C:\Destop\tmem16a\ISCs';
[imgname dname] = uigetfile([dname '\*.tif']);
    img = loadTif(imgname,8);
    [m,n,t] = size(img);
    offset = 5;

    img1 = double(img(:,:,1:end-offset));
    img2 = double(img(:,:,1+offset:end));

    imgSubt = img2-img1;
    imgMean = mean(imgSubt,3);
    imgSTD = std(imgSubt,1,3);
    imgThrP = imgMean + 3*imgSTD;
    imgThrN = imgMean - 3*imgSTD;
    imgThr = imgSubt > imgThrP | imgSubt < imgThrN;
    [fname dname] = uigetfile([dname '\*.mat']);
    load(fname);
    events = getCrenationAreas(imgThr,Crens.locs);
    Crens.crenationImg = events;
    
    save(fname,'Crens');
