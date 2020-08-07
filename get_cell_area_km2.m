function area_YX = get_cell_area_km2(varargin)

if length(varargin)==2
    lon_res = varargin{1} ;
    lat_res = varargin{2} ;
    if length(lon_res) ~= 1
        error('lon_res needs to have 1 element (has %d)', length(lon_res))
    elseif length(lat_res) ~= 1
        error('lat_res needs to have 1 element (has %d)', length(lat_res))
    end
    bnd_W = -180:lon_res:(180-lon_res) ;
    bnd_S = -90:lat_res:(90-lat_res) ;
    Nlon = length(bnd_W) ;
    Nlat = length(bnd_S) ;
    bnd_W_YX = repmat(bnd_W, [Nlat 1]) ;
    bnd_S_YX = repmat(bnd_S', [1 Nlon]) ;
    bnd_E_YX = bnd_W_YX + lon_res ;
    bnd_N_YX = bnd_S_YX + lat_res ;
elseif length(varargin)==4
    bnd_W = varargin{1} ;
    bnd_E = varargin{2} ;
    bnd_S = varargin{3} ;
    bnd_N = varargin{4} ;
    Nlon = length(bnd_W) ;
    if Nlon ~= length(bnd_E)
        error('bnd_W and bnd_E are different lengths')
    end
    Nlat = length(bnd_S) ;
    if Nlat ~= length(bnd_S)
        error('bnd_S and bnd_N are different lengths')
    end
    bnd_W_YX = repmat(sort(bnd_W), [Nlat 1]) ;
    bnd_E_YX = repmat(sort(bnd_E), [Nlat 1]) ;
    bnd_S_YX = repmat(sort(shiftdim(bnd_S)), [1 Nlon]) ;
    bnd_N_YX = repmat(sort(shiftdim(bnd_N)), [1 Nlon]) ;
elseif isempty(varargin)
    error('Provide either (lon_res, lat_res) or (bnds_W, bnds_E, bnds_S, bnds_N)')
end

d2r = pi/180 ; % Degrees to radians
R = 6371.0 ; % Earth's radius (km)
area_YX = d2r*R^2 * abs(sin(d2r*bnd_N_YX)-sin(d2r*bnd_S_YX)) .* abs(bnd_E_YX-bnd_W_YX) ;
% shademap(area_YX);

end