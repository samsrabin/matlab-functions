function [verts,faces,cdata]=image2patch(image_array)
%This function converts an image array into arrays that can be used with the
%patch function.
%   image_array must be an array nxmx3 unit8
%
%Example (image processing toolbox needed for the example):
%
%   [image_array,map] = imread('ngc6543a.jpg');
%   image_array = imresize(image_array, [128 128]);
%   [verts,faces,cdata]=image2patch(image_array)
%    patch('Faces',faces,'Vertices',verts,'FaceColor','flat','FaceVertexCData',cdata,'EdgeColor','none');
%
%This function was written by :
%                             Héctor Corte
%                             B.Sc. in physics 2010
%                             M.Sc. in Complex physics systems 2012
%                             NPL (National Physical Laboratory), London,
%                             United kingdom.
%                             Email: leo_corte@yahoo.es
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a,b,~]=size(image_array);
verts=zeros(a*b,2);
faces=zeros(a*b,4);
cdata=zeros(a*b,3);
m=1;
n=1;
for k=0:a-1
    for j=0:b-1
        verts(m,1)=1/b*j;
        verts(m,2)=1/a*k;
        verts(m+1,1)=1/b*j;
        verts(m+1,2)=1/a*(k+1);
        verts(m+2,1)=1/b*(j+1);
        verts(m+2,2)=1/a*(k+1);
        verts(m+3,1)=1/b*(j+1);
        verts(m+3,2)=1/a*k;
        faces(n,:)=[m, m+1, m+2, m+3];       
        cdata(n,1)=double(image_array(a-(k),j+1,1))/255;
        cdata(n,2)=double(image_array(a-(k),j+1,2))/255;
        cdata(n,3)=double(image_array(a-(k),j+1,3))/255;
        m=m+4;  
        n=n+1;
    end
end


