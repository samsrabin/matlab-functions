function out_struct = lpjgu_convert_mapsstruct_to_garrstruct(in_struct)

% Get map array size and list2map (do not trust in_struct.list2map)
if isfield(in_struct, 'maps_YXvyB') && isfield(in_struct, 'maps_YXvyr')
    in_size_bl = size(in_struct.maps_YXvyB) ;
    list2map_bl = find(~isnan(mean(mean(in_struct.maps_YXvyB,4),3))) ;
    in_size_fu = size(in_struct.maps_YXvyr) ;
    list2map_fu = find(~isnan(mean(mean(mean(in_struct.maps_YXvyB,5),4),3))) ;
    if ~isequal(list2map_bl, list2map_fu)
        error('This code assumes isequal(list2map_bl, list2map_fu)')
    elseif ~isequal(in_size_bl(1:2), in_size_fu(1:2))
        error('This code assumes list2map_bl and list2map_fu have same map size')
    end
    list2map = list2map_bl ;
    in_size = in_size_bl ;
    clear list2map_*
elseif isfield(in_struct, 'maps_YXvs')
    in_size = size(in_struct.maps_YXvs) ;
    list2map = find(~isnan(mean(mean(in_struct.maps_YXvs,4),3))) ;
else
    if isfield(in_struct, 'maps_YXvy')
        in_size = size(in_struct.maps_YXvy) ;
        list2map = find(~isnan(mean(mean(in_struct.maps_YXvy,4),3))) ;
    elseif isfield(in_struct, 'maps_YXv')
        in_size = size(in_struct.maps_YXv) ;
        list2map = find(~isnan(mean(in_struct.maps_YXv,3))) ;
    else
        error('in_struct.maps_YXv(y) not found')
    end
end
Ncells = length(list2map) ;

% Get list2map_all
% disp('Getting list2map_all...')
if isfield(in_struct, 'maps_YXvyB') && isfield(in_struct, 'maps_YXvyr')
    list2map_all_bl = lpjgu_get_list2map_all(list2map, in_size(1:2), in_size_bl(3:end)) ;
    list2map_all_fu = lpjgu_get_list2map_all(list2map, in_size(1:2), in_size_fu(3:end)) ;
else
    list2map_all = lpjgu_get_list2map_all(list2map, in_size(1:2), in_size(3:end)) ;
end

% Fill tmp_xvy
% disp('Filling tmp_xvy...')
if isfield(in_struct, 'maps_YXvyB') && isfield(in_struct, 'maps_YXvyr')
    tmp_xvyB = nan([Ncells in_size_bl(3:end)]) ;
    tmp_xvyB(:) = in_struct.maps_YXvyB(list2map_all_bl) ;
    tmp_xvyr = nan([Ncells in_size_fu(3:end)]) ;
    tmp_xvyr(:) = in_struct.maps_YXvyr(list2map_all_fu) ;
elseif isfield(in_struct, 'maps_YXvs')
    tmp_xvs = nan([Ncells in_size(3:4)]) ;
    tmp_xvs(:) = in_struct.maps_YXvs(list2map_all) ;
elseif isfield(in_struct, 'maps_YXvy')
    tmp_xvy = nan([Ncells in_size(3:4)]) ;
    tmp_xvy(:) = in_struct.maps_YXvy(list2map_all) ;
elseif isfield(in_struct, 'maps_YXv')
    test_xv = nan([Ncells in_size(3)]) ;
    test_xv(:) = in_struct.maps_YXv(list2map_all) ;
else
    error('???')
end

% Put together out_struct
% disp('Getting out_struct...')
out_struct.list2map = list2map ;
out_struct.varNames = in_struct.varNames ;
out_struct.map_size = in_size(1:2) ;
if isfield(in_struct, 'maps_YXvyB') && isfield(in_struct, 'maps_YXvyr')
    out_struct.yearList = in_struct.yearList ;
    out_struct.garr_xvyB = tmp_xvyB ;
    out_struct.garr_xvyr = tmp_xvyr ;
else
    if isfield(in_struct, 'maps_YXvy')
        out_struct.yearList = in_struct.yearList ;
        out_struct.garr_xvy = tmp_xvy ;
    elseif isfield(in_struct, 'maps_YXvs')
        out_struct.years_incl = in_struct.years_incl ;
        out_struct.statHandles = in_struct.statHandles ;
        out_struct.statList = in_struct.statList ;
        out_struct.garr_xvs = tmp_xvs ;
    elseif isfield(in_struct, 'maps_YXv')
        out_struct.garr_xv = test_xv ;
    else
        error('???')
    end
end
