function [thresh] = getThresh5files5step(file1,file2,file3,file4,file5)

noAtten = [102 105 107 103 104 103 102 100 110 109 110 110 108];
Atten5 = noAtten - 5;
Atten10 = noAtten - 10;
Atten15 = noAtten - 15;
Atten20 = noAtten - 20;
Atten25 = noAtten - 25;
Atten30 = noAtten - 30;
Atten35 = noAtten - 35;
Atten40 = noAtten - 40;
Atten45 = noAtten - 45;
Atten50 = noAtten - 50;
Atten60 = noAtten - 60;
Atten70 = noAtten - 70;

attenMatx = [noAtten;Atten10;Atten20;Atten30;Atten40;Atten50;Atten60;Atten70];

for i = 1:13
    if file1(i) == 0
       thresh(i) = noAtten(i);
    else
        if file2(i) == 0
            thresh(i) = Atten5(i);
        else
            if file3(i) == 0
                thresh(i) = Atten15(i);
            else
                if file4(i) == 0
                    thresh(i) = Atten25(i);
                else
                    if file5(i) == 0
                    thresh(i) = Atten35(i);
                    else
                    thresh(i) = Atten45(i);
                    end
                end
            end
        end
    end
end



end

