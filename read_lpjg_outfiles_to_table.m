function varargout = read_lpjg_outfiles_to_table(DUMMY,varargin)

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

% Decide whether to force skipping or saving MAT-file
if isempty(varargin)
    error('Must provide at least one file for reading.')
end
force_outMAT_skip = false ;
force_outMAT_save = false ;
if islogical(varargin{1})
    if varargin{1}
        force_outMAT_save = true ;
    else
        force_outMAT_skip = true ;
    end
    varargin_saved = {varargin{2:end}} ;
end
verbose = true ;
if islogical(varargin_saved{1}) && ~varargin_saved{1}
    verbose = false ;
    varargin_saved = {varargin_saved{2:end}} ;
end

for f = 1:length(varargin_saved)
    
    % Get filename and check
    in_file = varargin_saved{f} ;
    if ~ischar(in_file)
        error('Filenames must be char!')
    end
    
    % Get filename parts
    [~,NAME,EXT] = fileparts(in_file) ;
    if verbose
        disp([NAME EXT ':'])
    end
    
    in_matfile = [in_file '.mat'] ;
    if ~exist(in_matfile,'file')
        out_table = import_this_to_table(in_file) ;
        if ~force_outMAT_skip
            if force_outMAT_save
                if verbose
                    disp('   Saving MAT-file...')
                end
                save(in_matfile,'out_table') ;
            else
                ok = false ;
                while ~ok
                    str = input('   Save to MAT-file? Y or N: ','s') ;
                    if strcmp(str,'y') || strcmp(str,'Y')
                        ok = true ;
                        disp('   Saving MAT-file...')
                        save(in_matfile,'out_table') ;
                    elseif strcmp(str,'n') || strcmp(str,'N')
                        ok = true ;
                    end
                end
            end
        end
    elseif ~auto_load_from_matfile
        ok = false ;
        while ~ok
            str = input('   Load from MAT-file? Y or N: ','s') ;
            if strcmp(str,'y') || strcmp(str,'Y')
                ok = true ;
                disp('   Loading from MAT-file...')
                load(in_matfile) ;
            elseif strcmp(str,'n') || strcmp(str,'N')
                ok = true ;
                import_this_to_table()
            end
        end
    elseif auto_load_from_matfile
        if verbose
            disp('   Loading from MAT-file...')
        end
        load(in_matfile) ;
    end
    
    % Standardize column names
    varNames = out_table.Properties.VariableNames ;
    for v = 1:length(varNames)
        if strcmp(varNames{v},'lon')
            out_table.Properties.VariableNames{'lon'} = 'Lon' ;
        elseif strcmp(varNames{v},'lat')
            out_table.Properties.VariableNames{'lat'} = 'Lat' ;
        elseif strcmp(varNames{v},'year')
            out_table.Properties.VariableNames{'year'} = 'Year' ;
        end
    end
    
    varargout{f} = out_table ;
end
if verbose
    disp('Done.')
end


function out_table = import_this_to_table(in_file)
    % Read data
    %%% Based on http://de.mathworks.com/matlabcentral/answers/89374-importdata-fails-to-import-large-files
    if verbose
        disp('   Reading data...')
    end
    fid = fopen(in_file,'r') ;
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
    if verbose
        disp('   Making table...')
    end
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


end