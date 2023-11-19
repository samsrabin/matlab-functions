function geotiffwrite_ssr(filename, A, R, ndval, varargin)
% GEOTIFFWRITE_SSR
% As GEOTIFFWRITE, but takes the extra step (using GDAL Utilities) of
% adding a NoData value where there are NaNs in A. Also automatically does
% flipud before writing.

verbose = true ;
add_nodata_value = true ;
if ~isempty(varargin)
    verbose = varargin{1} ;
    if length(varargin) > 1
        add_nodata_value = varargin{2} ;
        if length(varargin) > 2
            error('geotiffwrite_ssr() takes at most 2 optional arguments: verbose, add_nodata_value')
        end
    end
end

if add_nodata_value
    if ~exist('gdal_utils_path', 'file')
        error([ ...
            'gdal_utils_path.m must be on your path to use geotiffwrite_ssr() with ' ...
            'add_nodata_value true. This is a simple function that returns the ' ...
            'directory where the GDAL utilities are installed. geotiffwrite_ssr() ' ...
            'will look for gdal_translate there.'])
    end
    if ~exist(gdal_utils_path(), 'dir')
        error('Output of gdal_utils_path() not found: %s', gdal_utils_path())
    end
    gdal_translate_path = fullfile(gdal_utils_path(), 'gdal_translate') ;
    if ~exist(gdal_translate_path, 'file')
        error([ ...
            'gdal_translate, required for geotiffwrite_ssr() with add_nodata_value ' ...
            'true, not found in %s.'], ...
            gdal_utils_path())
    end
end

if ~strcmp(filename(end-3:end),'.tif')
    filename = [filename '.tif'] ;
end
filename_tmp = [filename '2.tif'] ;

if exist(filename,'file')
    unix(sprintf('rm "%s"', filename)) ;
end

A2 = flipud(A) ;
A2(isnan(A2)) = ndval ;

if verbose
    disp('Saving GeoTIFF...')
end
geotiffwrite(filename_tmp,A2,R) ;

if add_nodata_value
    if verbose
        disp('Embedding nodata value...')
    end
    thisFmt = '%s -a_nodata %s "%s" "%s"' ;
    [s,w] = unix(sprintf(thisFmt, gdal_translate_path, num2str(ndval), filename_tmp, filename)) ;
    if s~=0
        error(w)
    end
    [s,w] = unix(sprintf('rm "%s"', filename_tmp)) ;
    if s~=0
        error(w)
    end
end

end