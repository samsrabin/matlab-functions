function binaryshapewrite(filename,A,R)
% BINARYSHAPEWRITE
% Given a logical matrix, writes it to a shapefile with polygons around the
% TRUE values. Uses GEOTIFFWRITE_SSR for intermediate files.

if ~islogical(A) || ~ismatrix(A)
    error('A must be a logical matrix!')
end

A = double(A) ;
A(~A) = NaN ;

if ~strcmp(filename(end-3:end),'.shp')
    filename = [filename '.shp'] ;
end

if exist(filename,'file')
    unix(['rm ' filename(1:end-4) '*'])
end

filename_tif = [filename '.tif'] ;
geotiffwrite_ssr(filename_tif,A,R,-999) ;


[s,w] = unix(['source ~/.bash_profile; gdal_polygonize.py -f "ESRI Shapefile" ' filename_tif ' ' filename]);
if s~=0
    error(w)
end
[s,w] = unix(['rm ' filename_tif]) ;
if s~=0
    error(w)
end