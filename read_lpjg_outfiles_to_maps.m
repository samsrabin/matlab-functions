function varargout = read_lpjg_outfiles_to_maps(xres,yres,varargin)

warning('gridlist_to_map() not updated to include lat_extent or lat_orient as fields of out_struct')

% auto_load_from_matfile = false ;
% if ~isempty(varargin)
%     auto_load_from_matfile = varargin{1} ;
%     if ~islogical(auto_load_from_matfile)
%         error('load_from_matfile must be a logical.')
%     end
%     if length(varargin) > 1
%         warning('Only first optional input is being read.')
%     end
% end
if isempty(varargin)
    error('Must provide at least one file for reading.')
end

% Check that all files exist
force_mat_file = false(size(varargin)) ;
for f = 1:length(varargin)
    thisFile = varargin{f} ;
    if ~exist(thisFile,'file')
        if exist([thisFile '.mat'],'file')
            force_mat_file(f) = true ;
        else
            error(['File ' num2str(f) ' does not exist: ' thisFile])
        end
    end
end ; clear thisFile f

for f = 1:length(varargin)
    in_file = varargin{f} ;
    
    % Get filename parts
    [~,NAME,EXT] = fileparts(in_file) ;
    disp([NAME EXT ':'])
    
    % Load fom MAT-file if it exists and user requests it
    in_matfile = [in_file '.mat'] ;
    matfile_loaded = false ;
    if exist(in_matfile,'file')
        
        % Test for compatibility
        tmp = whos('-file',in_matfile) ;
        if isempty(tmp) || ~strcmp(tmp(1).name,'out_struct')
            warning('   Incompatible MAT-file found. Skipping.')
            break
        end
        clear tmp
        
        % Ask & read MAT-file
        if force_mat_file(f)
            disp('   Original does not exist. Loading from MAT-file...')
            load(in_matfile) ;
            ok = true ;
            matfile_loaded = true ;
        else
            ok = false ;
        end
        while ~ok
            disp('   Load from MAT-file? [Y] or N. 10 seconds...')
            dbl = getkeywait_ssr(10) ;
            if dbl==-1
                ok = true ;
                disp('   Defaulting to Y. Loading from MAT-file...')
                load(in_matfile) ;
                matfile_loaded = true ;
            elseif isnan(dbl)
                error('Breaking out of function.')
            elseif strcmp(char(dbl),'y') || strcmp(char(dbl),'Y')
                ok = true ;
                disp('   Loading from MAT-file...')
                load(in_matfile) ;
                matfile_loaded = true ;
            elseif strcmp(char(dbl),'n') || strcmp(char(dbl),'N')
                ok = true ;
            else
                warning(['   Input (' char(dbl) ') not recognized.'])
            end
        end
    end
    if matfile_loaded
        if f==1
            list_to_map = out_struct.list_to_map ;
            found = out_struct.found ;
        end
        varargout{f} = out_struct ;
        continue
    end
    
    % If MAT-file not loaded, import table
    disp('   Importing to table...')
    in_table = import_this_to_table(in_file) ;
    
    % Standardize column names
    varNames = in_table.Properties.VariableNames ;
    for v = 1:length(varNames)
        if strcmp(varNames{v},'lon')
            in_table.Properties.VariableNames{'lon'} = 'Lon' ;
        elseif strcmp(varNames{v},'lat')
            in_table.Properties.VariableNames{'lat'} = 'Lat' ;
        elseif strcmp(varNames{v},'year')
            in_table.Properties.VariableNames{'year'} = 'Year' ;
        end
    end
    
    % Get table info
    [lons,lats,Ncells,years,Nyears,multi_yrs,yearList,...
     colNames,varNames,Nvars] = get_table_info(in_table) ;
    if f==1
        lons1 = lons ;
        lats1 = lats ;
        years1 = years ;
    elseif exist('lons1','var')
        if ~isequal(lons,lons1)
            error('Longitude column does not equal that of first file.')
        elseif ~isequal(lats,lats1)
            error('Latitude column does not equal that of first file.')
        elseif ~isequal(years,years1)
            error('Years column does not equal that of first file.')
        end
    end
    
    [map_lons,lons_map,map_lats,lats_map] = setup_maps(lons,lats,xres,yres) ;
    
    % If first file, get indices for list_to_map
    if f==1
        [list_to_map,found] = get_list2map(lons,lats,lons_map,lats_map,xres,yres) ;
    end
    
    % Convert list to maps
    disp('   Converting list to maps...')
    if multi_yrs
        maps_YXvy = nan(length(map_lats),length(map_lons),Nvars,Nyears) ;
    else
        maps_YXv = nan(length(map_lats),length(map_lons),Nvars) ;
    end
    for v = 1:Nvars
        thisVar = varNames{v} ;
        disp(['      ' thisVar ' (' num2str(v) ' of ' num2str(Nvars) ')...'])
        if multi_yrs
            for y = 1:Nyears
                thisYear = yearList(y) ;
                tmp = nan(length(map_lats),length(map_lons)) ;
                tmp(list_to_map) = table2array(in_table(years==thisYear,thisVar)) ;
                maps_YXvy(:,:,v,y) = tmp ;
            end
        else
            tmp = nan(length(map_lats),length(map_lons)) ;
            tmp(list_to_map) = table2array(in_table(found,thisVar)) ;
            maps_YXv(:,:,v) = tmp ;
        end
    end
    
    % Save output structure
    out_struct.list_to_map = list_to_map ;
    out_struct.found = found ;
    out_struct.varNames = varNames ;
    out_struct.lons_YX = lons_map ;
    out_struct.lats_YX = lats_map ;
    if multi_yrs
        out_struct.maps_YXvy = maps_YXvy ;
        out_struct.yearList = yearList ;
    else
        out_struct.maps_YXv = maps_YXv ;
    end
    varargout{f} = out_struct ;
    
    % Ask to save to MAT-file
    ok = false ;
    while ~ok
        if exist(in_matfile,'file')
            disp('Save, overwriting existing MAT-file? Y or [N]. 10 seconds...')
            default_save = false ;
        else
            disp('Save to MAT-file? [Y] or N. 10 seconds...')
            default_save = true ;
        end
        dbl = getkeywait_ssr(10) ;
        if (dbl==-1 && default_save) || strcmp(char(dbl),'y') || strcmp(char(dbl),'Y')
            ok = true ;
            disp('   Saving MAT-file...')
            save(in_matfile,'out_struct','-v7.3') ;
        elseif (dbl==-1 && ~default_save) || strcmp(char(dbl),'n') || strcmp(char(dbl),'N')
            ok = true ;
        else
            warning(['   Input (' char(dbl) ') not recognized.'])
        end
    end ; clear ok
    
    clear in_table out_struct maps_YXv
end
disp('Done.')


function out_table = import_this_to_table(in_file)
    % Read data
    %%% Based on http://de.mathworks.com/matlabcentral/answers/89374-importdata-fails-to-import-large-files
    disp('   Reading data...')
    fid = fopen(in_file) ;
    fgetl(fid) ;         % Skip 1 line
    here = ftell(fid) ;  % Remember where we are
    vars = regexp(fgetl(fid), '\s+', 'split') ;  %read line, split it into columns
    numcols = length(vars) ;                   %count them
    fseek(fid, here, 'bof') ;                    %reposition to prior line
    fmt = repmat('%f', 1, numcols) ;             %maybe %d if entries are integral
    datacell = textscan( fid, fmt, 'CollectOutput', 1) ;  %read file
    fclose(fid) ;
    A = datacell{1};
    
    % Get rid of empty columns at the end
    while ~any(~isnan(A(:,numcols)))
        A(:,numcols) = [] ;
        numcols = numcols - 1 ;
    end
    
    % Read header
    disp('   Making table...')
    fid = fopen(in_file) ;
    H = fgetl(fid) ;
    fclose(fid) ;
    vars = regexp(H, '\s+', 'split') ;
    while isempty(vars{1})
        vars = vars(2:end) ;
    end
    while isempty(vars{end})
        vars = vars(1:end-1) ;
    end
    for vv = 1:length(vars)
        if isempty(vars{vv})
            error('Empty variable name!')
        end
    end
    
    if length(vars) ~= size(A,2)
        error('Length of column name list does not match horizontal dimension of array.')
    end
    
    % Make table
    out_table = array2table(A,'VariableNames',vars) ;
end


function [out_lons,out_lats,out_Ncells,...
          out_years,out_Nyears,out_multiYrs,...
          out_yearList,out_colNames,...
          out_varNames,out_Nvars] = get_table_info(in_table)
    out_lons = in_table.Lon ;
    out_lats = in_table.Lat ;
    out_Ncells = length(out_lats) ;
    
    % Extract one-year lats/lons, if necessary
    out_colNames = in_table.Properties.VariableNames ;
    out_multiYrs = false ;
    for cc = 1:length(out_colNames)
        thisNameTmp = out_colNames{cc} ;
        if strcmp(thisNameTmp,'Year') && length(unique(in_table.Year))>1
            out_multiYrs = true ;
        end
        clear thisNameTmp
    end ; clear cc
    if out_multiYrs
        out_years = in_table.Year ;
        out_yearList = unique(out_years) ;
        out_Nyears = length(out_yearList) ;
        out_lons = out_lons(out_years==min(out_years)) ;
        out_lats = out_lats(out_years==min(out_years)) ;
        out_Ncells = length(out_lats) ;
    else
        out_years = [] ;
        out_yearList = [] ;
        out_Nyears = 1 ;
    end
    
    % Get names of variables other than Lat, Lon, and Year
    out_varNames = {} ;
    for c = 1:length(out_colNames)
        thisName = out_colNames{c} ;
        if ~(strcmp(thisName,'Lat') || strcmp(thisName,'Lon') || strcmp(thisName,'Year'))
            out_varNames{end+1} = thisName ;
        end
    end
    out_Nvars = length(out_varNames) ;
end


function [map_lons_out,lons_map_out,...
          map_lats_out,lats_map_out] = setup_maps(in_lons,in_lats,xres,yres)
    disp('   Getting indices to convert list to map...')
%     in_lons = in_table.Lon ;
%     in_lats = in_table.Lat ;
%     in_Ncells = length(in_lats) ;
%     
%     % Extract one-year lats/lons, if necessary
%     colNames = in_table.Properties.VariableNames ;
%     multi_yrs = false ;
%     for cc = 1:length(colNames)
%         thisNameTmp = colNames{cc} ;
%         if strcmp(thisNameTmp,'Year') && length(unique(in_table.Year))>1
%             multi_yrs = true ;
%         end
%         clear thisNameTmp
%     end ; clear cc
%     if multi_yrs
%         in_years = in_table.Year ;
%         yearList = unique(in_years) ;
%         Nyears = length(yearList) ;
%         in_lons = in_lons(in_years==min(in_years)) ;
%         in_lats = in_lats(in_years==min(in_years)) ;
%         in_Ncells = length(in_lats) ;
%     end
    
    % Set up maps
    lon_min = -180 ;
    lat_min = -90 ;
    lon_max = 180-xres ;
    lat_max = 90-yres ;
    if rem(in_lons(1)*100,50)~=0
        if 100*xres/2 ~= abs(rem(in_lons(1)*100,50))
            error('How do I deal with this orientation (lon.)?')
        end
        lon_min = lon_min + xres/2 ;
        lon_max = lon_max + xres/2 ;
    end
    if rem(in_lats(1)*100,50)~=0
        if 100*yres/2 ~= rem(in_lats(1)*100,50)
            error('How do I deal with this orientation (lat.)?')
        end
        lat_min = lat_min + yres/2 ;
        lat_max = lat_max + yres/2 ;
    end
    map_lons_out = lon_min:xres:lon_max ;
    map_lats_out = lat_min:yres:lat_max ;
    lons_map_out = repmat(map_lons_out,[length(map_lats_out) 1]) ;
    lats_map_out = repmat(map_lats_out',[1 length(map_lons_out)]) ;
end


function [list_to_map_out,found_out] = get_list2map(in_lons,in_lats,lons_map,lats_map,xres,yres)
    
    disp('   Getting list_to_map...')
    in_Ncells = length(in_lats) ;
    list_to_map_out = nan(in_Ncells,1) ;
    found_out = true(size(list_to_map_out)) ;
    progress = 0 ;
    progress_step_pct = 25 ;
    tic ;
    for cc = 1:in_Ncells
        thisIndex = find(lats_map==in_lats(cc) & lons_map==in_lons(cc)) ;
        if ~isempty(thisIndex)
            list_to_map_out(cc) = thisIndex ;
        else
            found_out(cc) = false ;
            if length(find(~found_out))==1
                warning(['      Some cells from input are getting ignored '...
                         'at output resolution ' num2str(xres) ' lon. x'...
                         num2str(yres) ' lat.'])
            end
        end
        
        % Update progress
        if rem(cc,ceil(in_Ncells*progress_step_pct/100))==0
            progress = progress + progress_step_pct ;
            disp(['      ' num2str(progress) '% complete (' toc_hms(toc) ')'])
        end
    end ; clear cc
    
    % There should be at least one cell mapped!
    if ~any(~isnan(list_to_map_out))
        error('Something went badly wrong.')
    end
    
    % Deal with skipped cells
    list_to_map_out(~found_out) = [] ;
    in_Ncells = length(find(found_out)) ;
    
    % Sanity checks
    if any(isnan(list_to_map_out))
        error('Somehow list_to_map_out contains NaN.')
    end
    if length(list_to_map_out) ~= in_Ncells
        error('length(list_to_map_out) ~= in_Ncells')
    end
    
end


end