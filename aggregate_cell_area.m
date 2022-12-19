function cell_area_YX_out = aggregate_cell_area(cell_area_YX_in,xres_out,yres_out)

cell_area_YX_in = double(cell_area_YX_in) ;

% Get info first
xres_in = 360 / size(cell_area_YX_in,2) ;
yres_in = 180 / size(cell_area_YX_in,1) ;
if xres_out < xres_in
    error(['xres_out ' num2str(xres_out) ' is too small given xres_in=' num2str(xres_in).'])
    
elseif yres_out < yres_in
    error(['yres_out ' num2str(yres_out) ' is too small given yres_in=' num2str(yres_in) '.'])
    
elseif xres_in~=xres_out || yres_in~=yres_out
    
    xratio = xres_out / xres_in ;
    yratio = yres_out / yres_in ;
    if ~isint(xratio) || ~isint(yratio)
        error(['xratio (' num2str(xratio) ') and yratio (' num2str(yratio) ') must both be integers!'])
    end
    
    % Aggregate X
    cell_area_YX_tmp = zeros(size(cell_area_YX_in,1),size(cell_area_YX_in,2)/xratio) ;
    for i = 1:xratio
        cell_area_YX_tmp = cell_area_YX_tmp + cell_area_YX_in(:,i:xratio:end) ;
    end
    
    % Check
    globalcell_area_in = sum(sum(cell_area_YX_in)) ;
    if abs(sum(sum(cell_area_YX_tmp)) - globalcell_area_in)>1e-4
        error('Error in X aggregation.')
    end
    
    % Aggregate Y
    cell_area_YX_out = zeros(size(cell_area_YX_in,1)/yratio,size(cell_area_YX_tmp,2)) ;
    for j = 1:yratio
        cell_area_YX_out = cell_area_YX_out + cell_area_YX_tmp(j:yratio:end,:) ;
    end
    
    % Check
    if abs(sum(sum(cell_area_YX_out)) - globalcell_area_in)>1e-4
        error('Error in Y aggregation.')
    end
    
else
    cell_area_YX_out = cell_area_YX_in ;
    
end


end