function [nanmask_YX, map2list] = gridlist_to_nanmask(lonlats, res)

lons = (-180 + res/2) : res : (180 - res/2) ;
lats = (-90 + res/2) : res : (90 - res/2) ;

if ~any(lons==lonlats(1,1))
    lons = lons - res/2 ;
    lats = lats - res/2 ;
    if ~any(lons==lonlats(1,1))
        error('No matching coordinates!')
    end
end

lons_YX = repmat(lons, [length(lats) 1]) ;
lats_YX = repmat(lats', [1 length(lons)]) ;

lonlats = sortrows(lonlats,[1 2]) ;
lons_in = lonlats(:,1) ;
lats_in = lonlats(:,2) ;
unique_lons = unique(lons_in) ;
nanmask_YX = true(size(lons_YX)) ;
map2list = zeros(length(lons_in),1,'uint32') ;
x = 0 ;
for o = 1:length(unique_lons)
    thisLon = unique_lons(o) ;
    theseLats = lats_in(lons_in==thisLon) ;
    for a = 1:length(theseLats)
        x = x + 1 ;
        thisLat = theseLats(a) ;
        thisInd = find(lons_YX==thisLon & lats_YX==thisLat) ;
        nanmask_YX(thisInd) = false ;
        map2list(x) = thisInd ;
    end
end


end