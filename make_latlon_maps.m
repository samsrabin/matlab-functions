function [lon_YX, lat_YX] = make_latlon_maps(res_or_targetYX)
% Makes centered latitude and longitude maps. res_or_targetYX can take
% three forms:
%  RES:                Equal latitude and longitude resolution
%  [RES_LON RES_LAT]:  Specify latitude and longitude resolutions separately
%  TARGET_YX:          An array whose size will be matched by the maps


ndims_ssr = length(find(size(res_or_targetYX)>1)) ;
if ndims_ssr==0
    res_lon = res_or_targetYX ;
    res_lat = res_or_targetYX ;
elseif ndims_ssr==1
    res_lon = res_or_targetYX(2) ;
    res_lat = res_or_targetYX(1) ;
    if isint(res_lon) && res_lon>5
        warning('res_lon = %d. Did you specify an array size instead of [RES_LON RES_LAT]?', res_lon)
    end
    if isint(res_lat) && res_lat>5
        warning('res_lat = %d. Did you specify an array size instead of [RES_LON RES_LAT]?', res_lon)
    end
elseif ndims_ssr==2
    res_lon = 360/size(res_or_targetYX,2) ;
    res_lat = 180/size(res_or_targetYX,1) ;
else
    error('Something wrong with res_or_targetYX')
end

size_lon = 360 / res_lon ;
size_lat = 180 / res_lat ;
if ~isint(size_lon)
    error('res_lon (%0.1f) must be evenly divisible into 360!', res_lon)
elseif ~isint(size_lat)
    error('res_lon (%0.1f) must be evenly divisible into 180!', res_lat)
end

lon_YX = repmat((-180+res_lon/2):res_lon:(180-res_lon/2),[size_lat 1]) ;
lat_YX = repmat(transpose((-90+res_lat/2):res_lat:(90-res_lat/2)),[1 size_lon]) ;


end