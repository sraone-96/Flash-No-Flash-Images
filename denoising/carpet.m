clear;
close all;
clc;
A=imread('carpet_01_noflash.tif');
F=imread('carpet_00_flash.tif');
n=15;
sigma1=5;
sigma2=0.35;
T=-250;

eps=0.02; 
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
ms((gF/max(gF(:)))>0.6)=1; %detect specularities

M=zeros(size(A,1),size(A,2),size(A,3)); %initialization of mask
 se= strel('disk',2);
for i=1:size(A,3) %build the flash mask
    m=mf|ms; %merge t   wo masks
    M(:,:,i) = imdilate(m,se);
end
figure,imshow(M);
display('calculate A_base...');
A_base=double(bifilter2(A,A,n,sigma1,sigma2));
%A_base=imresize(A_base,[size(A,1),size(A,2)]);
imshow((A_base));
display('calculate A_NR...');
A_nr=double(bifilter2(A,F,n,sigma1,sigma2));
%A_nr=imresize(A_nr,[size(A,1),size(A,2)]);
imshow((A_nr));
display('calculate F_Base...');
F_base=double(bifilter2(F,F,n,sigma1,sigma2));
display('calculate F_Details...');
%F_base=imresize(F_base,[size(F,1),size(F,2)]);
figure,imshow((F_base));
F_details=(double(F)+eps)./(double(F_base)+eps);
figure,imshow(uint8(F_details));
display('almost done..!');
x=((1-M).*A_nr.*F_details);
y=(M.*A_base);
%temp=y.*255;
%out=x+temp;
tempy=uint8(y*255);
figure,imshow(uint8(x)+tempy);
% out=(x+y);
% figure,imshow(x);
% figure,imshow(y);
% out=uint8(out);
