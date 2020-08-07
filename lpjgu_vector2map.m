function map_YX = lpjgu_vector2map(in_vec, map_size, list2map)

if ~ismatrix(in_vec) || min(size(in_vec))~=1
    error('in_vec must be an Nx1 or 1xN vector')
elseif length(in_vec) ~= length(list2map)
    error('in_vec (length %d) must be same length as list2map (length %d)', length(in_vec), length(list2map))
end

map_YX = nan(map_size) ;
map_YX(list2map) = in_vec ;


end