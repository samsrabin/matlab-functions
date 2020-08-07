function [i_lat,i_lon,i_year] = lpjgu_matlab_getLatLonYrCols(in_header_cell)

% Strip padding
for c = 1:length(in_header_cell)
    thisCol = in_header_cell{c} ;
    while strcmp(thisCol(1),' ')
        thisCol = thisCol(2:end) ;
    end
    while strcmp(thisCol(end),' ')
        thisCol = thisCol(1:end-1) ;
    end
    in_header_cell{c} = thisCol ;
end

if any(find(strcmp(in_header_cell,'lon')))
    lon_name = 'lon' ;
elseif any(find(strcmp(in_header_cell,'Lon')))
    lon_name = 'Lon' ;
elseif any(find(strcmp(in_header_cell,'Lon.')))
    lon_name = 'Lon.' ;
else
    error('Could not identify longitude column!')
end
i_lon = find(strcmp(in_header_cell,lon_name)) ;
if any(find(strcmp(in_header_cell,'lat')))
    lat_name = 'lat' ;
elseif any(find(strcmp(in_header_cell,'Lat')))
    lat_name = 'Lat' ;
elseif any(find(strcmp(in_header_cell,'Lat.')))
    lat_name = 'Lat.' ;
else
    error('Could not identify latitude column!')
end
if any(find(strcmp(in_header_cell,'year')))
    year_name = 'year' ;
elseif any(find(strcmp(in_header_cell,'Year')))
    year_name = 'Year' ;
else
    year_name = '' ;
end
if ~isempty(year_name)
    i_year = find(strcmp(in_header_cell,year_name)) ;
else
    i_year = -1 ;
end
i_lat = find(strcmp(in_header_cell,lat_name)) ;



end