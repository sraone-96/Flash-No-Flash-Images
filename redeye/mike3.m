clear;
clc;close all;
A=imread('mike_01_no_flash.jpg');
F=imread('mike_02_flash.jpg');
Ac=A;
Fc=F;
%A=im2double(A);
%F=im2double(F);
Aycbcr = rgb2ycbcr(A);
Fycbcr = rgb2ycbcr(F);
R = (Fycbcr(:,:,3) - Aycbcr(:,:,3));
%R=im2double(R);
figure;
imshow(R);
title('R');
mean = 0;
for i = 1 : size(R,1)
    for j = 1:size(R,2)
        mean = double(R(i,j))+mean;
    end
end
mean = mean/(size(R,1)*size(R,2));
variance = 0;
for i = 1 : size(R,1)
    for j = 1:size(R,2)
        variance = ((abs(double(R(i,j))-mean))^2) + variance;
    end
end
variance = variance/((size(R,1)-1)*(size(R,2)-1));
% mask = cat(3,R,R,R);
% maskrgb = ycbcr2rgb(mask);
mask  = zeros(size(R,1),size(R,2));
count = 0;
for i = 1 : size(R,1)
    for j = 1:size(R,2)
%         if R(i,j) > 0.6
        if (R(i,j) > max(0.6,(mean + (3*variance))))
             
             if (A(i,j,1) < 100)
             mask(i,j) = 1;
              end
        else
            mask(i,j) = 0;
        end
    end
end
T = -200;
size(A)
size(F)
if size(A,3)>1
    gA=double(rgb2gray(A));
    gF=double(rgb2gray(F));
else
    gA=double(A);
    gF=double(F);
end
mf=zeros(size(A,1),size(A,2)); %initialization of shadow mask
ms=zeros(size(A,1),size(A,2)); %initialization of specularitiy mask
diff=gF-gA; 
mf(diff<=T)=1; %detect shadow
ms((gF/max(gF(:)))>0.9)=1; %detect specularities

M=zeros(size(A,1),size(A,2),size(A,3)); %initialization of mask
 se= strel('disk',2);
for i=1:size(A,3) %build the flash mask
    m=mf|ms; %merge two masks
    M(:,:,i) = imdilate(m,se);
end
figure,imshow(M);title('M')

figure;
imshow(mask);
title('mask');
newmask=mask-M;

figure;
imshow(newmask);
title('newmask');



img=mask;
BW=img;
cc = bwconncomp(BW);
size(A)
size(F)
stats = regionprops(cc, 'Area','Eccentricity','MajorAxisLength','MinorAxisLength'); 
idx = find([stats.Area] > 40 & [stats.Eccentricity] < 0.9 & [stats.MajorAxisLength] < 50 & [stats.MinorAxisLength] < 50); 
L=labelmatrix(cc);
BW2 = ismember(labelmatrix(cc), idx);
BW2=double(BW2);
figure,imshow((BW2));title('BW2');
BW3 = imgaussfilt(BW2,2);
figure,imshow(uint8(BW3*255));title('BW3');
BW4 = im2bw(BW3,0.4);
figure,imshow((BW4));title('BW4');
BW4=uint8(BW4);
BW4=cat(3,BW4,BW4,BW4);
out=BW4.*(Ac)+(1-BW4).*(Fc);
figure,imshow(out);