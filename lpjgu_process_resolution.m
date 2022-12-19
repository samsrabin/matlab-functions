function [xres_out, yres_out, lat_extent] = lpjgu_process_resolution(xres_in, yres_in,...
    in_lons, in_lats, lat_orient, drop_northpole, drop_southpole, verboseIfNoMat, verbose)

% Gridcells centered at the poles are very annoying! So just drop them.
unique_lats = unique(in_lats) ;
if (drop_northpole || drop_southpole) && ~strcmp(lat_orient, 'center')
    error('You asked to drop north and/or south pole, but lat_orient is %s', lat_orient)
end
if drop_northpole && any(unique_lats == 90)
    error('drop_northpole requested but 90° is in in_lats. Code to deal with that.')
    warning('Dropping gridcell with lat center 90°')
    Idrop = unique_lats==90 ;
    unique_lats(Idrop) = [] ;
end
if drop_southpole && any(unique_lats == -90)
    error('drop_southpole requested but -90° is in in_lats. Code to deal with that.')
    warning('Dropping gridcell with lat center -90°')
    Idrop = unique_lats==-90 ;
    unique_lats(Idrop) = [] ;
end

if xres_in>0 && yres_in>0
    xres_out = xres_in ;
    yres_out = yres_in ;
elseif xres_in>0 && ~(yres_in>0)
    % If only xres provided, set yres to same value
    xres_out = xres_in ;
    yres_out = xres_in ;
elseif ~(xres_in>0) && yres_in>0
    % If only yres provided, set xres to same value
    xres_out = yres_in ;
    yres_out = yres_in ;
else
    % Determine X and Y resolution
    if verboseIfNoMat || verbose
        disp('      Determining X and Y resolution...')
    end
    if ~(yres_in>0)
        yres_out = min(abs(unique_lats(1:end-1)-unique_lats(2:end))) ;
    end
    if ~(xres_in>0)
        unique_lons = unique(in_lons) ;
        xres_out = min(abs(unique_lons(1:end-1)-unique_lons(2:end))) ;
    end
    if verboseIfNoMat || verbose
        disp(['      Assuming X res. = ' num2str(xres_out) ', Y res. = ' num2str(yres_out)])
    end
end

% Get latitude extent. Note that this describes the map that WOULD be
% the actual extent if all cells were in the dataset.
lat_extent = lpjgu_get_lat_extent(lat_orient, drop_northpole, drop_southpole, yres_out) ;

end


