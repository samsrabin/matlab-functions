function out_struct = lpjgu_matlab_read2geoArray(in_file,varargin)

% Set up & parse input arguments
is_2elem_cell = @(x) iscell(x) && numel(x)==2 ;
p = inputParser ;
addRequired(p,'in_file',@ischar) ;
addOptional(p,'xres',NaN,@isnumeric) ;
addOptional(p,'yres',NaN,@isnumeric) ;
addOptional(p,'lat_orient','',@isstr) ;
addOptional(p,'lon_orient','',@isstr) ;
addOptional(p,'verbose',false,@islogical) ;
addOptional(p,'verboseIfNoMat',true,@islogical) ;
addOptional(p,'force_mat_save',true,@islogical) ;
addOptional(p,'force_mat_nosave',false,@islogical) ;
addOptional(p,'dataType','double',@isstr) ;
addOptional(p,'in_prec',2,@isint) ;
% addOptional(p,'lonlats_target',[],is_Nx2_array) ;
% addOptional(p,'list2map_target',[]) ;
addOptional(p,'target',{},is_2elem_cell) ;
addOptional(p,'trimfirstyear_ifneeded',false,@islogical) ;
parse(p,in_file,varargin{:});

pFields = fieldnames(p.Results) ;
Nfields = length(pFields) ;
for f = 1:Nfields
    thisField = pFields{f} ;
    if ~exist(thisField,'var')
        eval(['global ' thisField ';']) ;
        eval([thisField ' = p.Results.' thisField ' ;']) ;
    end
    clear thisField
end ; clear f
clear p pFields

had_yxv = false ;

% Check inputs
if ~isempty(lat_orient) && ~(strcmp(lat_orient,'lower') || strcmp(lat_orient,'center')  || strcmp(lat_orient,'upper'))
    error(['If providing lat_orient, it must be either lower, center, or upper. (' lat_orient ')'])
end
if ~isempty(lon_orient) && ~(strcmp(lon_orient,'left') || strcmp(lon_orient,'center')  || strcmp(lon_orient,'right'))
    error(['If providing lon_orient, it must be either left, center, or right. (' lon_orient ')'])
end
if force_mat_nosave && force_mat_save
    warning('force_mat_save and force_mat_nosave can''t both be true. MATfile will not be saved.')
    force_mat_save = false ;
end
if verboseIfNoMat && verbose %#ok<*NODEF>
%     warning('Because verboseIfNoMat==true, setting verbose=false.')
    verbose = false ;
end

% Process target gridlist
lonlats_target = [] ;
list2map_target = [] ;
if ~isempty(target) %#ok<USENS>
    lonlats_target = target{1} ; %#ok<IDISVAR>
    if ~(ismatrix(lonlats_target) && size(lonlats_target,2)==2)
        error('lonlats_target is malformed (must be Nx2 array)')
    end
    list2map_target = target{2} ;
    if ~isvector(list2map_target)
        error('list2map_target is malformed (must be vector)')
    end
end

% Okay to save?
ok_to_save = ~force_mat_nosave && isempty(target) ;

% Find file
[in_file, NAME, EXT] = process_filename(in_file, verbose) ;

% Import
if contains(in_file, '.garr.mat') && strcmp('.garr.mat', in_file(end-(length('.garr.mat')-1):end))
    in_matfile_garr = in_file ;
else
    in_matfile_garr = [in_file '.garr.mat'] ;
end
in_matfile_garr = get_link_target(in_matfile_garr) ;
in_matfile_garr = get_link_target(strrep(in_matfile_garr, '.gz', '')) ;

is_no_mat = true ;
if exist(in_matfile_garr,'file')
    if isempty(target)
        if verbose
            disp([NAME EXT ':'])
            disp('   Loading geoArray MAT-file...')
        end
        try
            load(in_matfile_garr) ; %#ok<LOAD>
        catch ME
            warning('Problem loading MAT file. Will try again (once) in 10 minutes.\nIntercepted error message follows:\n%s\n', ...
                ME.message) ;
            pause(600)
        end

        is_no_mat = false ;

        had_yxv = isfield(out_struct, 'garr_yxv') ;
        if had_yxv
            if ~ok_to_save
                warning('%s contains garr_yxv! Permuting...', in_matfile_garr)
            else
                warning('%s contains garr_yxv! Permuting and re-saving...', in_matfile_garr)
            end
            tmp = permute(out_struct.garr_yxv, [2 3 1]) ;
            out_struct = rmfield(out_struct, 'garr_yxv') ;
            out_struct.garr_xvy = tmp ;
            clear tmp
        end

        unnecessary_yrdim = isfield(out_struct, 'garr_xvy') && size(out_struct.garr_xvy,3)==1 ;
        if unnecessary_yrdim
            warning('%s contains unnecessary year dimension. Removing. Will re-save.', in_matfile_garr)
            tmp = out_struct.garr_xvy ;
            out_struct = rmfield(out_struct, 'garr_xvy') ;
            out_struct.garr_xv = tmp ;
            clear tmp
        end

        has_years = isfield(out_struct, 'garr_xvy') ;
    else
        
        % Try reading garray and forcing to conform
        if verbose
            disp([NAME EXT ':'])
            disp('   Loading geoArray MAT-file...')
        end
        try
            load(in_matfile_garr) ; %#ok<LOAD>
        catch ME
            warning('Problem loading MAT file. Will try again (once) in 10 minutes.\nIntercepted error message follows:\n%s\n', ...
                ME.message) ;
            pause(600)
        end
        
        if ~isequal(target{1}, out_struct.lonlats)
            in_struct = out_struct ;
            clear out_struct

            [~,~,IB_lonlats] = intersect(target{1}, in_struct.lonlats, 'stable', 'rows') ;
            [~,~,IB_list2map] = intersect(target{2}, in_struct.list2map, 'stable') ;
            if isequal(IB_lonlats, IB_list2map)
                out_struct.lonlats = target{1} ;
                out_struct.list2map = target{2} ;
                out_struct.varNames = in_struct.varNames ;
                in_fields = fieldnames(in_struct) ;
                in_fields(contains(in_fields, {'lonlats', 'list2map', 'varNames'})) = [] ;
                if isfield(in_struct, 'yearList')
                    out_struct.yearList = in_struct.yearList ;
                    in_fields(strcmp(in_fields, 'yearList')) = [] ;
                end
                if isfield(in_struct, 'garr_xvy')
                    out_struct.garr_xvy = in_struct.garr_xvy ;
                    in_fields(strcmp(in_fields, 'garr_xvy')) = [] ;
                end
                if isfield(in_struct, 'garr_xv')
                    out_struct.garr_xv = in_struct.garr_xv ;
                    in_fields(strcmp(in_fields, 'garr_xv')) = [] ;
                end
                if ~isempty(in_fields)
                    warning('Translating original garray to match target: Ignoring %d fields', length(in_fields))
                end

            end
        end
                
    end
end

% If you didn't read a MAT file, try starting from scratch
if ~exist('out_struct', 'var')
    if verboseIfNoMat || verbose
        disp([NAME EXT ':'])
    end
    
    % Read table
    table_in = lpjgu_matlab_readTable(in_file,...
        'verbose',verbose,...
        'verboseIfNoMat',verboseIfNoMat,...
        'dont_save_MAT',true,...
        'do_save_MAT',false) ;
    is_gridlist = size(table_in,2)==2 ;
    if is_gridlist
        error('This file appears to be a gridlist. Will not make a geoArray.')
    end
    
    if verboseIfNoMat || verbose
        disp('    Getting metadata...')
    end
    
    % Get lat/lons and map indices
    lonlats_in = unique(table2array(table_in(:,1:2)), ...
        'rows', 'stable') ;
    out_struct.lonlats = lonlats_in ;
    Ncells = length(lonlats_in) ;
    if isempty(lonlats_target)
        out_struct.list2map = get_indices( ...
            lonlats_in, xres, yres, ...
            list2map_target, ...
            lat_orient, lon_orient, ...
            verboseIfNoMat, verbose, in_prec) ;
    end
    
    % Get variable names
    varNames = setdiff(table_in.Properties.VariableNames, ...
        {'Lon','Lat','Year'}, ...
        'stable') ;
    Nvars = length(varNames) ;
    out_struct.varNames = varNames ;
    
    
    
    % Get years (if necessary)
    has_years = any(strcmp(table_in.Properties.VariableNames,'Year')) ...
        && length(unique(table_in.Year)) > 1 ;
    if has_years
        yearList = unique(table_in.Year) ;
        Nyears = length(yearList) ;
        if trimfirstyear_ifneeded && length(find(table_in.Year==yearList(1))) < length(find(table_in.Year==yearList(2)))
            table_in(table_in.Year==yearList(1),:) = [] ;
            yearList = yearList(2:end) ;
            Nyears = length(yearList) ;
        end
        if length(table_in.Lon) ~= Ncells*Nyears
            if ~isempty(lonlats_target)
                % Remove cells and/or rearrange to match target
                tmp_lonlats_in = [table_in.Lon table_in.Lat] ;
                [missing_from_readin, M_in] = setdiff(lonlats_target, lonlats_in, 'rows') ;
                [missing_from_target, M_target] = setdiff(lonlats_in, lonlats_target, 'rows') ;
                if ~isempty(M_in)
                    error('Gridlist mismatch: Not all lonlats_target in out_struct.lonlats (e.g. %0.2f %0.2f)', ...
                        missing_from_readin(1,1), missing_from_readin(1,2))
                end
                if ~isempty(M_target)
                    warning('length(table_in.Lon) ~= Ncells*Nyears. Trying to fix by removing %d gridcells not in target', ...
                        length(M_target))
                    
                    lonlats_in(M_target,:) = [] ;
                    out_struct.list2map(M_target) = [] ;
                    out_struct.lonlats = lonlats_in ;
                    Ncells = size(lonlats_in,1) ;
                    for c = 1:size(missing_from_target,1)
                        thisLon = missing_from_target(c,1) ;
                        thisLat = missing_from_target(c,2) ;
                        table_in(table_in.Lon==thisLon & table_in.Lat==thisLat) = [] ;
                    end
                    if length(table_in.Lon) ~= Ncells*Nyears
                        error('length(table_in.Lon) ~= Ncells*Nyears, even after removing cells not in target gridlist')
                    end
                end
            else
                error('length(table_in.Lon) ~= Ncells*Nyears')
            end
        end
        out_struct.yearList = yearList ;
    end
    
    % Reshape to array
    if verboseIfNoMat || verbose
        disp('   Reshaping...')
    end
    if ~has_years
        garr_xv = table2array(table_in(:,3:end)) ;
        if ~strcmp(dataType, 'double')
            eval(sprintf('garr_xv = %s(garr_xv) ;', dataType)) ;
        end
        out_struct.garr_xv = garr_xv ;
    else
        garr_yxv = lpjgu_matlab_table2array(table_in(:,4:end), [Nyears Ncells Nvars]) ;
        if ~strcmp(dataType, 'double')
            eval(sprintf('garr_yxv = %s(garr_yxv) ;', dataType)) ;
        end
        out_struct.garr_xvy = permute(garr_yxv, [2 3 1]) ;
    end
    
end

% Remove cells and/or rearrange to match target
if ~isempty(lonlats_target)
    extra_cells = [] ;
    rearr_cells = [] ;
    if ~isequal(lonlats_target, out_struct.lonlats)
        C = intersect(lonlats_target, out_struct.lonlats, 'rows', 'stable') ;
        if ~isequal(C, lonlats_target)
            error('Gridlist mismatch: Not all lonlats_target in out_struct.lonlats')
        end
        [~, extra_cells] = setdiff(out_struct.lonlats, lonlats_target, 'rows', 'stable') ;
        if isempty(extra_cells)
            [~, ~, rearr_cells] = intersect(lonlats_target, out_struct.lonlats, 'rows', 'stable') ;
        else
            lonlats_in_minusExtra = out_struct.lonlats ;
            lonlats_in_minusExtra(extra_cells,:) = [] ;
            [~, ~, rearr_cells] = intersect(lonlats_target, lonlats_in_minusExtra, 'rows', 'stable') ;
        end
    end
    out_struct.list2map = list2map_target ;
    out_struct.lonlats = lonlats_target ;
    if ~isempty(extra_cells)
        if ~has_years
            out_struct.garr_xv(extra_cells,:) = [] ;
        else
            out_struct.garr_xvy(extra_cells,:,:) = [] ;
        end
    end
    if ~isempty(rearr_cells)
        if ~has_years
            out_struct.garr_xv = out_struct.garr_xv(rearr_cells,:) ;
        else
            out_struct.garr_xvy = out_struct.garr_xvy(rearr_cells,:,:) ;
        end
    end
end

% Save to MAT-file
if (~exist(in_matfile_garr,'file') || had_yxv || (exist('unnecessary_yrdim', 'var') && unnecessary_yrdim)) ...
   && ok_to_save
    lpjgu_matlab_save_to_matfile(out_struct,in_matfile_garr,force_mat_save,verboseIfNoMat,verbose) ;
end
if (verboseIfNoMat && is_no_mat) || verbose
    disp('   Done.')
end

end


function [in_file, NAME, EXT] = process_filename(in_file, verbose)

if strcmp(in_file(end-2:end),'.gz')
    in_file = in_file(1:end-3) ;
elseif strcmp(in_file(end-3:end),'.mat')
    in_file = in_file(1:end-4) ;
end

% % If in_file is symlink, replace it with its target
% [s,w] = unix(['[[ -L ' in_file ' ]] && echo true']) ;
% if s==0 && contains(w,'true') % is symlink
%     if verbose
%         disp('Symlink; pointing to target instead.')
%     end
%     [~,w] = unix(['stat -f "%Y" ' in_file]) ;
%     in_file = regexprep(w,'[\n\r]+','') ; % Remove extraneous newline
% end

% If in_file is symlink, replace it with its target
in_file = get_link_target(in_file) ;

% If file doesn't exist, check to see if its zipped version does. If so,
% but it's a symlink, replace it with its target.
in_file_gz = [in_file '.gz'] ;
in_file_gz_target = get_link_target(in_file_gz) ;
if ~strcmp(in_file_gz, in_file_gz_target)
    in_file = in_file_gz_target ;
end

% If in_file has wildcard, expand into full filename (fail if not exactly 1
% match)
if contains(in_file,'*')
    filelist = dir(in_file) ;
    if isempty(filelist)
        error('No match found for %s', in_file)
    elseif length(filelist) > 1
        keyboard
        error('More than one match found for %s', in_file)
    else
        tmp = sprintf('%s/%s', filelist(1).folder, filelist(1).name) ;
        fprintf('Resolving\n%s\ninto\n%s\n', in_file, tmp)
        in_file =  tmp ;
    end
end

% Get info
[~,NAME,EXT] = fileparts(in_file) ;

end


function list_to_map = get_indices(lonlats_in,xres,yres,list2map_target,lat_orient,lon_orient,verboseIfNoMat,verbose,in_prec)

% Get table info
in_lons = lonlats_in(:,1) ;
in_lats = lonlats_in(:,2) ;

% Sort out map resolution
[xres,yres] = lpjgu_process_resolution(xres,yres,in_lons,in_lats,verboseIfNoMat,verbose) ;

% Get ready for mapping
[lons_map,lats_map] = lpjgu_set_up_maps(xres,yres,in_lons,in_lats,lat_orient,lon_orient,verboseIfNoMat,verbose) ;

% Get indices for mapping
if isempty(list2map_target)
    list_to_map = lpjgu_get_map_indices(in_lons,in_lats,lons_map,lats_map,verboseIfNoMat,verbose,in_prec) ;
else
    if length(in_lons) ~= length(list2map_target)
        warning('length(in_lons) ~= length(list2map_target)! Ignoring list2map_target.')
        list_to_map = lpjgu_get_map_indices(in_lons,in_lats,lons_map,lats_map,verboseIfNoMat,verbose,in_prec) ;
    else
        list_to_map = list2map_target ;
    end
end

end


function path_out = get_link_target(path_in)

path_out = path_in ;

try
    % 1 if path_in and is a link; 0 otherwise
    [status, result] = system(sprintf('[[ -h %s ]] && printf 1 || printf 0', path_in)) ;

    % If it's a link, try to read it.
    command_list = { ...
        'printf $(readlink -f %s)' ;
        'printf $(greadlink -f %s)' ;
        'printf $(/sw/bin/greadlink -f %s)' ;
        } ;

    if status==0 && strcmp(result, '1')
        for c = 1:length(command_list)
            [status, result] = system(sprintf(command_list{c}, path_in)) ;
            if status == 0
                path_out = result ;
                break
            end
        end
    end
catch ME
end

end




