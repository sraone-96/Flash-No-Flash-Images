close all;
clear;
clc;
value=0.02;
%A=imread('potsdetail_03_our_result.tif');
A=imread('potsWB_01_noflash.jpg');
F=imread('potsWB_00_flash.jpg');
A=imresize(A,[size(F,1),size(F,2)]);
A=im2double(A);
Ac=A;
F=im2double(F);
figure,imshow(A);
figure,imshow(F);
delta=F-A;
%figure,imshow(delta);
 for k=1:3
d=delta(:,:,k);
threshold=value*max(d(:));
for i=1:size(A,1)
    for j=1:size(A,2)   
    if(delta(i,j,k)==0)
        delta(i,j,k)=1;
        Ac(i,j,k)=0;
    elseif(delta(i,j,k)<threshold)
            delta(i,j,k)=1;
    end
    end
end
 end
 %{
 for k=1:3
d=Ac(:,:,k);
threshold=value*max(d(:));
for i=1:size(A,1)
    for j=1:size(A,2)   
    if(delta(i,j,k)<threshold)
            Ac(i,j,k)=0;
    end
    end
end
end
%}
 
 
Cp=Ac./delta;

%Cp=im2double(Cp);
%figure,imshow(Cp);
m=zeros(3);
for k=1:3
    temp(:,:)=Cp(:,:,k);
Th=max(temp(:))/200;
disp(Th);
mean=0;
for i=1:size(A,1)
for j=1:size(A,2)
    if(Cp(i,j,k)<Th)
    Cp(i,j,k)=0;
    end
    mean=mean+Cp(i,j,k);
end
end
m(k)=mean/(size(A,1)*size(A,2));
%disp(m(k));
end
for k=1:3
out(:,:,k)=A(:,:,k)/m(k);
end
%out=im2double(out);
%out=uint8(255*out);
out=out/1.5;
figure,imshow((out));
result=imread('potsWB_02_whitebalanced.jpg');
result=imresize(result,[size(A,1),size(A,2)]);
result=im2double(result);
figure,imshow(result);
%imshow(out-result);