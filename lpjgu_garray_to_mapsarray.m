function out_struct = lpjgu_garray_to_mapsarray(in_struct)

out_struct.list2map = in_struct.list2map ;
out_struct.varNames = in_struct.varNames ;
if isfield(in_struct, 'lat_extent')
    out_struct.lat_extent = in_struct.lat_extent ;
end
if isfield(in_struct, 'lat_orient')
    out_struct.lat_orient = in_struct.lat_orient ;
end
Nvars = length(in_struct.varNames) ;

% Get map array size and list2map (do not trust in_struct.list2map)
if isfield(in_struct, 'garr_xvy')
    in_size = size(in_struct.garr_xvy) ;
    out_ndims = 4 ;
    out_struct.yearList = in_struct.yearList ;
    Nyears = length(in_struct.yearList) ;
elseif isfield(in_struct, 'garr_xv')
    in_size = size(in_struct.garr_xv) ;
    out_ndims = 3 ;
else
    error('in_struct.maps_YXv(y) not found')
end
% Ncells = length(list2map) ;
% Nreps = prod(in_size(2:end)) ;

if ~isfield(in_struct, 'map_size')
    warning('Assuming 360x720')
    map_size = [360 720] ;
else
    map_size = in_struct.map_size ;
end

list2map_all = lpjgu_get_list2map_all(in_struct.list2map, map_size, in_size(2:end)) ;

if out_ndims == 4
    out_struct.maps_YXvy = nan([map_size Nvars Nyears]) ;
    out_struct.maps_YXvy(list2map_all) = in_struct.garr_xvy ;
elseif out_ndims == 3
    out_struct.maps_YXv = nan([map_size Nvars]) ;
    out_struct.maps_YXv(list2map_all) = in_struct.garr_xv ;
else
    error('???')
end


end