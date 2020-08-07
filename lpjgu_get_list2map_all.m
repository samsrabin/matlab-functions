function list2map_all = lpjgu_get_list2map_all(list2map, map_size, reps_size)

Nreps = prod(reps_size) ;
Ncells = length(list2map) ;

list2map_all = nan(Ncells*Nreps, 1, 'double') ; % single fails uniqueness test
for r = 1:Nreps
    i1 = (r-1)*Ncells + 1 ;
    iN = r*Ncells ;
    list2map_all(i1:iN) = (r-1)*prod(map_size) + list2map ;
end

% Sanity checks
if any(isnan(list2map_all))
    error('NaN(s) in list2map_all')
elseif any(list2map_all<=0)
    error('Non-positive value(s) in list2map_all')
elseif length(unique(list2map_all)) ~= length(list2map_all)
    error('Non-unique(s) in list2map_all')
end


end