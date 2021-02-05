function out_xz = lpjgu_YXz_to_xz(in_YXz, matrix_size, list2map)

Ncells = length(list2map) ;

if ~isnumeric(in_YXz) || ndims(in_YXz)~=3
    error('in_YXz must be a 3d array')
elseif matrix_size(1) ~= Ncells
    error('matrix_size(1) (%d) must equal length of list2map (%d)', ...
        matrix_size(1), Ncells)
end

Nreps = size(in_YXz, 3) ;
map_size = [size(in_YXz, 1) size(in_YXz, 2)] ;
list2map_all = lpjgu_get_list2map_all(list2map, map_size, Nreps) ;

out_xz = in_YXz(list2map_all) ;
out_xz = reshape(out_xz, [Ncells Nreps]) ;


end