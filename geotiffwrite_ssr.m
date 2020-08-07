function geotiffwrite_ssr(filename,A,R,ndval)
% GEOTIFFWRITE_SSR
% As GEOTIFFWRITE, but takes the extra step (using GDAL Utilities) of
% adding a NoData value where there are NaNs in A. Also automatically does
% flipud before writing.

if ~strcmp(filename(end-3:end),'.tif')
    filename = [filename '.tif'] ;
end
filename_tmp = [filename '2.tif'] ;

if exist(filename,'file')
    unix(sprintf('rm "%s"', filename)) ;
end

A2 = flipud(A) ;
A2(isnan(A2)) = ndval ;

geotiffwrite(filename_tmp,A2,R) ;

thisFmt = ['source ~/.bash_profile; gdal_translate -a_nodata %s "%s" "%s"'] ;
[s,w] = unix(sprintf(thisFmt, num2str(ndval), filename_tmp, filename)) ;
if s~=0
    error(w)
end
[s,w] = unix(sprintf('rm "%s"', filename_tmp)) ;
if s~=0
    error(w)
end

end