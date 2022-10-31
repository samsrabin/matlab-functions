function lat_extent = lpjgu_get_lat_extent(lat_orient, drop_northpole, drop_southpole, yres)
% Note that this describes the map that WOULD be the actual extent if all cells were in the dataset.

if (drop_northpole || drop_southpole) && ~strcmp(lat_orient, 'center')
    error('You asked to drop north and/or south pole, but lat_orient is %s', lat_orient)
end

lat_extent = [-90 90] ;
if strcmp(lat_orient, 'center')
    if drop_northpole
        lat_extent(2) = lat_extent(2) - yres/2 ;
    end
    if drop_southpole
        lat_extent(1) = lat_extent(1) + yres/2 ;
    end
elseif ~any(strcmp(lat_orient, {'upper', 'lower'}))
    error('lpjgu_process_resolution() doesn''t know how to handle lat_orient %s', lat_orient)
end

end