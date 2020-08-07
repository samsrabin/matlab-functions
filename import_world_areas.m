function [gcel_area_YX, land_area_YX, gcel_area_x, land_area_x] = import_world_areas(varargin)

gcel_area_x = [] ;
land_area_x = [] ;

nanmask_YX = [] ;
if ~isempty(varargin)
    nanmask_YX = varargin{1} ;
    if length(varargin) > 1
        error('varargin can have at most 1 element (nanmask_YX)')
    end
end

% Import land area (km2)
landarea_file = '/Users/Shared/PLUM/crop_calib_data/other/staticData_quarterdeg.nc' ;
gcel_area_YXqd = transpose(ncread(landarea_file,'carea')) ;
land_frac_YXqd = 1 - flipud(transpose(ncread(landarea_file,'icwtr'))) ;
land_area_YXqd = gcel_area_YXqd .* land_frac_YXqd ;

% Convert to half-degree
tmp = gcel_area_YXqd(:,1:2:1440) + gcel_area_YXqd(:,2:2:1440) ;
gcel_area_YX = tmp(1:2:720,:) + tmp(2:2:720,:) ;
tmp = land_area_YXqd(:,1:2:1440) + land_area_YXqd(:,2:2:1440) ;
land_area_YX = tmp(1:2:720,:) + tmp(2:2:720,:) ;

% Convert to m2
land_area_YX = land_area_YX*1e6 ;
gcel_area_YX = gcel_area_YX*1e6 ;

% Mask
if ~isempty(nanmask_YX)
    gcel_area_YX(nanmask_YX) = NaN ;
    land_area_YX(nanmask_YX) = NaN ;
    gcel_area_x = gcel_area_YX(~nanmask_YX) ;
    land_area_x = land_area_YX(~nanmask_YX) ;
end


end