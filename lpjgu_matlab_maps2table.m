function [out_array, out_header_cell] = lpjgu_matlab_maps2table(in_struct,list_to_map,varargin)

% Set up & parse input arguments
p = inputParser ;
addRequired(p, 'in_struct', @isstruct) ;
addRequired(p, 'list_to_map', @isvector) ;
parse(p,in_struct, list_to_map, varargin{:});

% Prepare
Ncells_out = length(list_to_map) ;

% Are we saving years? Also, rename maps field.
if isfield(in_struct,'maps_YXvy') && isfield(in_struct,'yearList')
    with_years = true ;
    in_maps = double(in_struct.maps_YXvy) ;
    in_struct = rmfield(in_struct,'maps_YXvy') ;
    Nyears = length(in_struct.yearList) ;
elseif isfield(in_struct,'maps_YXv') && ~isfield(in_struct,'yearList')
    with_years = false ;
    in_maps = double(in_struct.maps_YXv) ;
    in_struct = rmfield(in_struct,'maps_YXv') ;
else
    error('Error in checking validity of in_struct!')
end
in_struct.maps = in_maps ;
clear in_maps

% Set up lon/lat maps
xres = 360/size(in_struct.maps,2) ;
yres = 180/size(in_struct.maps,1) ;
lons = (-180+(xres/2)):xres:(180-(xres/2)) ;
lats = (-90+(yres/2)):yres:(90-(yres/2)) ;
lons_map = repmat(lons,[length(lats) 1]) ;
lats_map = repmat(lats',[1 length(lons)]) ;

% Get array
if with_years
    out_array = nan(Ncells_out*Nyears, 3+length(in_struct.varNames), 'double') ;
else
    out_array = nan(Ncells_out,        2+length(in_struct.varNames), 'double') ;
end
for c = 1:Ncells_out
    thisIndex = list_to_map(c) ;
    thisLon = lons_map(thisIndex) ;
    thisLat = lats_map(thisIndex) ;
    [I,J] = ind2sub(size(lons_map),thisIndex) ;
    if with_years
        thisCell_yv = permute(in_struct.maps(I,J,:,:),[4 3 2 1]) ;
        thisLonLatYr = [thisLon*ones(Nyears,1) thisLat*ones(Nyears,1) in_struct.yearList] ;
        theseRows = [thisLonLatYr thisCell_yv] ;
        c1 = (c-1)*Nyears + 1 ;
        cN = c*Nyears ;
        try
            out_array(c1:cN,:) = theseRows ;
        catch ME
            keyboard
        end

    else
        out_array(c,:) = [thisLon thisLat squeeze(in_struct.maps(I,J,:))'] ;
    end
end

% Sanity check
if any(isnan(out_array))
    error('At least one member of out_array is NaN!')
end

% Get out_header_cell
if with_years
    out_header_cell = [{'Lon','Lat','Year'},in_struct.varNames] ;
else
    out_header_cell = [{'Lon','Lat'},in_struct.varNames] ;
end


end