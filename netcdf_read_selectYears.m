function out_YXy = netcdf_read_selectYears(file_in, varName, yearList_in)
% Assumes contiguous yearList

% Open file
NCID = netcdf.open(file_in) ;

% Get year info
DIMID_TIME = netcdf.inqDimID(NCID,'time') ;
DIMID_LON = netcdf.inqDimID(NCID,'lon') ;
DIMID_LAT = netcdf.inqDimID(NCID,'lat') ;
yearList = netcdf.getVar(NCID,netcdf.inqVarID(NCID,'time')) ;
START = ones(1,3) ;
START(DIMID_TIME+1) = find(yearList==min(yearList_in)) - 1 ;
COUNT = inf(1,3) ;
COUNT(DIMID_TIME+1) = length(yearList_in) ;

START = flip(START,2) ;
COUNT = flip(COUNT,2) ;

% Read
tmp = ncread(file_in, varName, START, COUNT) ;
out_YXy = flip(permute(tmp, 3-[DIMID_LON DIMID_LAT DIMID_TIME]), 1) ;

% Close file
netcdf.close(NCID) ;


end