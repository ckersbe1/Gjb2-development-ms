%% load image
[fname, dname] = uigetfile('M:\Bergles Lab Data\Projects\In vivo imaging\*.tif','Multiselect','on');
X = loadTif([dname fname],16);
[m,n,t] = size(X);


%% get 10th percentiles
 [dFoF, Fo, img] = normalizeImg(X, 10, 1);
 %get Fo and display it

%% Fav - Fo ./Fo
[LICmask, RICmask, CTXmask] = getIC_SCmasks(X);
LICsignal = getMeanFromMask(dFoF, LICmask);
RICsignal = getMeanFromMask(dFoF, RICmask);
ctxsignal = getMeanFromMask(dFoF,CTXmask);

%%
[stats, pkData] = findICpeaksdFoF_P15(double([LICsignal RICsignal ctxsignal]),dname,'dFoF',1)
save([dname '\dFoFvars.mat'], 'Fo', 'stats');