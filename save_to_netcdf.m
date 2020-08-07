function save_to_netcdf(out_file, array_YXt, out_varname, out_fill, out_unit, out_longname, time_vector, time_unit, time_longname)


nlat = size(array_YXt,1) ;
nlon = size(array_YXt,2) ;

if ~exist(out_file,'file')
    disp(['Setting up ' out_file '...'])
    
    % Set up output dimensions
    xres = 360/nlon ;
    yres = 180/nlat ;
    lons = (-180+xres/2):xres:(180-xres/2) ;
    lats = transpose((-90+yres/2):yres:(90-yres/2)) ;
    lons_map = repmat(lons,[length(lats) 1]) ;
    lats_map = repmat(lats,[1 length(lons)]) ;
    
    % Create longitude variable
    nccreate(   out_file, 'lon', 'Dimensions', { 'x', nlon, 'y', nlat });
    ncwrite(    out_file, 'lon', lons_map' );
    ncwriteatt( out_file, 'lon', 'long_name', 'Longitude' );
    ncwriteatt( out_file, 'lon', 'units', 'degrees_east' );
    
    % Create latitude variable
    nccreate(   out_file, 'lat', 'Dimensions', { 'x', nlon, 'y', nlat }, ...
        'DataType', 'double' );
    ncwrite(    out_file, 'lat', lats_map' );
    ncwriteatt( out_file, 'lat', 'long_name', 'Latitude' );
    ncwriteatt( out_file, 'lat', 'units', 'degrees_north' );
    
    % Create time variable
    nccreate(   out_file, 'time', 'Dimensions', { 'time', inf } );
    ncwrite(    out_file, 'time', time_vector );
    ncwriteatt( out_file, 'time', 'long_name', time_longname );
    ncwriteatt( out_file, 'time', 'units', time_unit );
end

% Check for existence of variable
var_exists = true ;
ncid = netcdf.open(out_file,'nowrite') ;
try
    netcdf.inqVarID(ncid,out_varname) ;
catch exception
    if strcmp(exception.identifier,'MATLAB:imagesci:netcdf:libraryFailure')
        var_exists = false ;
    else
        error('Something went wrong in netcdf.inqVarID.')
    end
end
netcdf.close(ncid) ;

% Save array_YXt
if ~var_exists
    disp(['Saving ' out_varname '...'])
    if size(array_YXt,3) > 1
        nccreate(out_file,out_varname,...
            'Dimensions', {'x',nlon,'y',nlat,'time',inf},...
            'FillValue', out_fill,...
            'DeflateLevel',5) ;
        ncwrite(out_file,out_varname,permute(array_YXt,[2 1 3])) ;
    else
        nccreate(out_file,out_varname,...
            'Dimensions', {'x',nlon,'y',nlat},...
            'FillValue', out_fill,...
            'DeflateLevel',5) ;
        ncwrite(out_file,out_varname,permute(array_YXt,[2 1])) ;
    end
    ncwriteatt(out_file,out_varname,'long_name',out_longname) ;
    ncwriteatt(out_file,out_varname,'units',out_unit) ;
else
    warning([out_varname ' already exists in out_file! Skipping.'])
end

end