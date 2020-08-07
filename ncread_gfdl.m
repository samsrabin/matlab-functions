function output = ncread_gfdl( filename , varname , varargin )
%NCREAD_GFDL Imports data from a NetCDF variable that comes from GFDL.
%   Switches E and W hemispheres, rotates so that dimensions are 
%   LAT x LON x ... instead of LON x LAT x ... .
%
%   Optional arguments (assign [] to skip): 
%   regions.map: Force a value of 0 on land when no
%     land use of the imported type is present. (Not always necessary, but
%     avoids transmitting unnecessary NaN values sometimes.)
%   times_to_include: Two-element vector giving the time indices to
%     include.

if length(varargin) > 2
    error('At most two optional arguments are allowed (regions.map, times_to_include).')
end

if length(varargin) >= 1
    regions_map = varargin{1} ;
else regions_map = [] ;
end
if length(varargin) >= 2
    times_to_include = varargin{2} ;
else times_to_include = [] ;
end

output = ncread(filename,varname) ;

num_dims = ndims(output) ;
if num_dims > 4
    error('Code currently works only with variables of up to 4 dimensions.')
end

% Permute
dim_indices = 1:num_dims ;
dim_indices(1) = 2 ;
dim_indices(2) = 1 ;
output = permute(output,dim_indices) ;

% Trim off extra months, if needed
if ~isempty(times_to_include)
    output = output(:,:,times_to_include(1):times_to_include(2)) ;
end

% Switch hemispheres
lon_size = size(output,2) ;
ehem_end = lon_size / 2 ;
whem_start = ehem_end + 1 ;
if num_dims==2 || num_dims==3
    E_hem = output(:,1:ehem_end,:) ;
    W_hem = output(:,whem_start:lon_size,:) ;
elseif num_dims == 4
    E_hem = output(:,1:ehem_end,:,:) ;
    W_hem = output(:,whem_start:lon_size,:,:) ;
end
output = cat(2,W_hem,E_hem) ;

% Force land NaNs to zero
if ~isempty(regions_map)
    output(isnan(output) & ~isnan(repmat(regions_map,[1 1 size(output,3)]))) = 0 ;
end


end