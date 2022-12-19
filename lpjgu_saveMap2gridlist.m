function lpjgu_saveMap2gridlist(in_map,out_file,varargin)

% Set up input arguments
p = inputParser ;
errorMsg = 'in_map must be 2-d numeric array with at least one value==1.' ; 
validationFcn = @(x) assert(ismatrix(x) && length(size(x))==2 && any(any(in_map==1)),errorMsg);
addRequired(p,'in_map',validationFcn) ;
addRequired(p,'out_file',@ischar) ;
default_orientation = 'mp' ;
errorMsg = 'Orientation must be ''mp'' (default) or ''ll''.' ; 
validationFcn = @(x) assert(ischar(x) && (strcmp(x,'mp') || strcmp(x,'ll')),errorMsg);
addOptional(p,'orientation',default_orientation,validationFcn) ;
addOptional(p,'randomize',false,@islogical) ;
parse(p,in_map,out_file,varargin{:});

% Set up maps
xres = 360 / size(in_map,2) ;
yres = 180 / size(in_map,1) ;
lon_min = -180 ;
lat_min = -90 ;
lon_max = 180-xres ;
lat_max = 90-yres ;
if strcmp(p.Results.orientation,'mp')
    lon_min = lon_min + xres/2 ;
    lat_min = lat_min + yres/2 ;
    lon_max = lon_max + xres/2 ;
    lat_max = lat_max + yres/2 ;
end
lons = lon_min:xres:lon_max ;
lats = lat_min:yres:lat_max ;
lons_map = repmat(lons,[length(lats) 1]) ;
lats_map = repmat(lats',[1 length(lons)]) ;

% Save results
found_lons = lons_map(in_map==1) ;
found_lats = lats_map(in_map==1) ;
out_data = [found_lons found_lats] ;
if p.Results.randomize
    % Get random order for output
    rng(20221001) ;
    Ncells_4gl = length(found_lons) ;
    rdmsam = randsample(Ncells_4gl,Ncells_4gl) ;
    out_data = out_data(rdmsam,:) ;
end
formatSpec = '%3.2f %3.2f\n' ;
fileID = fopen(out_file,'w') ;
fprintf(fileID,formatSpec,out_data') ;
fclose(fileID) ;

end