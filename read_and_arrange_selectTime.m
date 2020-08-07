function [out_YXtp, fillValue] = read_and_arrange_selectTime(fileName, ...
    Nlons, Nlats, Ntimes, varName, verbose, do_byPFT, ...
    date1)

out_YXtp = [] ;
fillValue = [] ;

% Extract file
if verbose
    disp('    Extracting...')
end
fileName_gz = sprintf('%s.gz', fileName) ;
if ~exist(fileName_gz,'file') && ~exist(fileName,'file')
    % Try nc4 file instead
    fileName = [fileName '4'] ;
    fileName_gz = sprintf('%s.gz', fileName) ;
    if ~exist(fileName_gz,'file') && ~exist(fileName,'file')
        error('File does not exist; skipping (%s)', fileName_gz)
    end
end
if ~exist(fileName,'file')
    [status, result] = unix(sprintf('gunzip < "%s" > "%s"', fileName_gz, fileName)) ;
    if status ~= 0
        warning('SKIPPING. Error in gunzip: status %d:\n%s', status, result)
        return
    end
end

% Get variable size
finfo = ncinfo(fileName, varName) ;
var_size = finfo.Size ;
i_lat = find(var_size==Nlats) ;
if length(i_lat) ~= 1
    error('Error finding i_lat (%d found)', length(i_lat))
end
i_lon = find(var_size==Nlons) ;
if length(i_lon) ~= 1
    error('Error finding i_lon (%d found)', length(i_lon))
end
i_time = find(var_size==Ntimes) ;
if length(i_time) ~= 1
    error('Error finding i_time (%d found)', length(i_time))
end

% Get time steps of interest
if ~isempty(date1)
    if length(var_size)==4
        error('Rework this function to work with 4-d data')
    end
    [years_out, months_out, days_out] = ...
        get_times_from_netcdf(fileName) ;
    t1 = find(years_out==date1(1) ...
            & months_out==date1(2) ...
            & days_out==date1(3)) ;
    start = zeros(3,1) ;
    start(i_time) = t1-1 ;
    count = nan(3,1) ;
    count(i_lon) = Nlons ;
    count(i_lat) = Nlats ;
    count(i_time) = 1 ;
    Ntimes = 1 ;
    var_size(i_time) = Ntimes ;
end

% Read variable
ncid = netcdf.open(fileName,'NC_NOWRITE') ;
try
    varid = netcdf.inqVarID(ncid, varName) ;
catch
    % Get list of variables
    nci = ncinfo(fileName) ;
    varList = {nci.Variables.Name} ;
    varList_lower = lower(varList) ;
    i_found = find(contains(varList_lower, lower(varName))) ;
    if length(i_found) ~= 1
        error('Error finding variable %s in file', varName)
    end
    varName = varList{i_found} ;
    varid = netcdf.inqVarID(ncid, varName) ;
end
if isempty(date1)
    out_YXtp = netcdf.getVar(ncid, varid, 'single') ;
else
    out_YXtp = netcdf.getVar(ncid, varid, start, count, 'single') ;
end

% Get PFT list, if needed
if do_byPFT
    try
        pft = ncread(fileName, 'vegtype') ;
    catch
        try
            pft = ncread(fileName, 'lev') ;
        catch
            pft = ncread(fileName, 'lev_4') ;
        end
    end
    Npfts = length(pft) ;
end

% Get list of variable attributes
ME = [] ;
attList = {} ;
a = 0 ;
while isempty(ME)
    try
        attList{end+1} = netcdf.inqAttName(ncid, varid, a) ;
    catch
        break
    end
    a = a+1 ;
end
attList_lower = lower(attList) ;

% Get fill value, if there is one specified
isfillval = contains(attList_lower, 'fill') ;
fillValue_name = '' ;
if length(find(isfillval)) == 1
    fillValue_name = attList{find(isfillval)} ; %#ok<FNDSB>
elseif any(strcmp(attList, '_FillValue'))
    fillValue_name = '_FillValue' ;
end
if ~isempty(fillValue_name)
    fillValue = netcdf.getAtt(ncid, varid, fillValue_name) ;
end
netcdf.close(ncid) ;

% If no fill value specified, check whether there's an obvious fill value
if isempty(fillValue)
     negVals = unique(out_YXtp(out_YXtp<0)) ;
     if length(negVals) == 1
         fillValue = negVals ;
%      elseif length(negVals) > 1
%          negThresh = -1e20 ;
%          if min(negVals) > negThresh
%              warning('Negative values present but all >%0.1g; setting to zero.', negThresh)
%              out_YXtp(out_YXtp<0) = 0 ;
%          else
%              error('Multiple different negative values!')
%          end
     else
         maxValue = max(max(max(max(out_YXtp)))) ;
         if maxValue>1e16
             fillValue = maxValue ;
         end
     end
end
if isempty(fillValue)
    warning('No fill value found')
end

% Remove work files
if exist(fileName_gz,'file')
    if verbose
        disp('    Removing work file...')
    end
    unix(sprintf('rm "%s"', fileName)) ;
end

% Reorder dimensions, if necessary
while var_size(end)==1
    var_size = var_size(1:end-1) ;
end
size_out = size(out_YXtp) ;
if ~isequal(var_size, size_out)
    error('~isequal(var_size, size_out)')
end
if ndims(out_YXtp)==4
    if do_byPFT
        i_pft = find(size_out==Npfts) ;
    else
        warning('Not expecting by-PFT, but array has 4 dimensions. Will sum over fourth dimension.')
        i_pft = 1:4 ;
        i_pft([i_lat i_lon i_time]) = [] ;
    end
    if length(i_pft) ~= 1
        error('Error finding i_pft (%d found)', length(i_pft))
    end
    if ~isequal([i_lat i_lon i_time i_pft], 1:4)
        out_YXtp = permute(out_YXtp, [i_lat i_lon i_time i_pft]) ;
    end
else
    if ~isequal([i_lat i_lon i_time], 1:3)
        out_YXtp = permute(out_YXtp, [i_lat i_lon i_time]) ;
    end
end

% Check for dimension mismatch
if size(out_YXtp,1) ~= Nlats
    error('Dimension mismatch: size(out_YXtp,1) ~= Nlats (%d ~= %d)', size(out_YXtp,1), Nlats)
elseif size(out_YXtp,2) ~= Nlons
    error('Dimension mismatch: size(out_YXtp,2) ~= Nlons (%d ~= %d)', size(out_YXtp,2), Nlons)
elseif size(out_YXtp,3) ~= Ntimes
    error('Dimension mismatch: size(out_YXtp,3) ~= Ntimes (%d ~= %d)', size(out_YXtp,3), Ntimes)
end

% NaN-ify fill value
if ~isempty(fillValue)
    if verbose
        disp('    NaN-ifying fill values...')
    end
    out_YXtp(out_YXtp==fillValue) = NaN ;
end

% Warn about any negative values
if any(any(any(any(out_YXtp<0))))
    warning('Negative values present! "Worst" %0.3g', min(min(min(min(out_YXtp)))))
end


end