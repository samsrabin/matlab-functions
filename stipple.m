function stipple(R, field, linetype)
%stipples a geographic map, field must be a logical array

if nargin == 2; linetype = 'kx'; end

[row, col] = find(field);

if ~isempty(row)
    [lat, lon] = pix2latlon(R,row,col);
    plotm(lat,lon,linetype)
else
    %warning('stipple:nothigToSt','There is no data to stipple')

end