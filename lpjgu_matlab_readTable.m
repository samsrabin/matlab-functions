function out_table = lpjgu_matlab_readTable(in_file,varargin)

p = inputParser ;
addRequired(p,'in_file',@ischar) ;
addOptional(p,'dont_save_MAT',false,@islogical) ;
addOptional(p,'do_save_MAT',true,@islogical) ;
addOptional(p,'verbose',false,@islogical) ;
addOptional(p,'verboseIfNoMat',true,@islogical) ;
addOptional(p,'dispPrefix','',@ischar) ;
addOptional(p,'force_as_gridlist',false,@islogical) ;
parse(p,in_file,varargin{:});

pFields = fieldnames(p.Results) ;
Nfields = length(pFields) ;
for f = 1:Nfields
    thisField = pFields{f} ;
    if ~exist(thisField,'var')
        eval([thisField ' = p.Results.' thisField ' ;']) ;
    end
    clear thisField
end ; clear f
clear p


if dont_save_MAT && do_save_MAT
    warning('dont_save_MAT and do_save_MAT can''t both be true. Assuming no save.')
    do_save_MAT = false ;
end
if verboseIfNoMat && verbose
    %     warning('Because verboseIfNoMat==true, setting verbose=false.')
    verbose = false ;
end

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

if strcmp(in_file(end-2:end),'.gz')
    in_file = in_file(1:end-3) ;
end

in_matfile = [in_file '.mat'] ;
if exist(in_matfile,'file')
    if verbose
        disp([dispPrefix '   Loading table from MAT-file...'])
    end
    try
        load(in_matfile) ;
    catch ME
        warning('Problem loading MAT file. Will try again (once) in 10 minutes.\nIntercepted error message follows:\n%s\n', ...
            ME.message) ;
        pause(600)
    end
    
else
    did_unzip = gunzip_if_needed(in_file, verbose, verboseIfNoMat, dispPrefix) ;
    if verbose || verboseIfNoMat
        disp([dispPrefix '   Making table...'])
    end
    
    % Error if empty
    finfo = dir(in_file) ;
    if finfo.bytes == 0
        error('lpjgu_matlab_readTable:fileEmpty', '%s: file is empty!', in_file)
    end
    
    out_table = import_this_to_table( ...
        in_file, verbose, verboseIfNoMat, dispPrefix, force_as_gridlist) ;
    if ~dont_save_MAT
        if do_save_MAT
            try
                save(in_matfile,'out_table','-v7.3') ;
            catch
                warning('Unable to save %s', in_matfile)
            end
        else
            prompt_to_save(in_matfile, verbose, verboseIfNoMat, dispPrefix) ;
        end
    end
    if did_unzip
        if verbose || verboseIfNoMat
            disp([dispPrefix '      Deleting unzipped in_file...'])
        end
        err2 = system(['rm "' in_file '"']) ;
        if err2~=0
            error('Error in rm.')
        end
    end
end

% Standardize column names
try
    out_table = standardize_colnames(out_table) ;
catch ME
    keyboard
end



end


function did_unzip = gunzip_if_needed(in_file, verbose, verboseIfNoMat, dispPrefix)
did_unzip = false ;
in_file = get_link_target(in_file) ;
if ~exist(in_file,'file')
    in_file_gz = [in_file '.gz'] ;
    in_file_gz = get_link_target(in_file_gz) ;
    if exist(in_file_gz,'file')
        if verbose || verboseIfNoMat
            disp([dispPrefix '   Unzipping in_file...'])
        end
        err1 = system(['gunzip < "' in_file_gz '" > "' in_file '"']) ;
        if err1~=0
            error('Error in gunzip.')
        end
        did_unzip = true ;
    else
        error('lpjgu_matlab_readTable:fileNotFound', '%s: in_file.mat, in_file, and in_file.gz not found.', in_file)
    end
end
end


function out_table = import_this_to_table( ...
    in_file, verbose, verboseIfNoMat, dispPrefix, force_as_gridlist)
% Read header to get field names
in_header = read_header(in_file) ;

% Read data
%%% Based on http://de.mathworks.com/matlabcentral/answers/89374-importdata-fails-to-import-large-files
if verbose || verboseIfNoMat
    disp([dispPrefix '      Reading data...'])
end
fid = fopen(in_file) ;
firstline = ftell(fid) ;  % Remember where we are
numcols = length(regexp(fgetl(fid), '\s+', 'split')) ;    %read line, split it into columns, count them
if length(in_header)==2
    if verbose || verboseIfNoMat
        warning('Not skipping first line.')
    end
    fseek(fid, firstline, 'bof') ;                    %reposition to prior line
end
fmt = repmat('%f', 1, numcols) ;             %maybe %d if entries are integral
datacell = textscan( fid, fmt, 'CollectOutput', 1) ;  %read file
fclose(fid) ;
A = datacell{1};

if isempty(A)
    error('A is empty!')
end

% Get rid of empty columns at the end   
while ~any(~isnan(A(:,numcols)))
    A(:,numcols) = [] ;
    numcols = numcols - 1 ;
    try
        A(:,numcols) ;
    catch ME
        keyboard
    end
end

is_gridlist = false ;
if size(A,2) < 2
    error('Input must be 2-d matrix.')
elseif force_as_gridlist
    A = A(:,1:2) ;
    in_header = in_header(1:2) ;
    colNames = {'Lon','Lat'} ;
    is_gridlist = true ;
elseif size(A,2) == 2
    if verbose || verboseIfNoMat
        warning('Assuming columns Lon, Lat.')
    end
    colNames = {'Lon','Lat'} ;
    is_gridlist = true ;
else
    colNames = in_header ;
end

if length(in_header) ~= size(A,2)
    error('Length of column name list does not match horizontal dimension of array.')
end

% Make table
varNames = strrep(colNames,'"','') ;
varNames = strrep(varNames,'-','_') ;
out_table = array2table(A,'VariableNames',varNames) ;

% Deal with doubled data in 2005 for N_fert_rcp85_6f.out
[~,in_name,in_ext] = fileparts(in_file) ;
if strcmp([in_name in_ext],'N_fert_rcp85_6f.out')
    bad = find(out_table.Year==2005) ;
    out_table(bad(2:2:end),:) = [] ;
end

end


function out_table = import_this_to_table2(in_file, verbose, verboseIfNoMat, dispPrefix)

if verbose || verboseIfNoMat
    disp([dispPrefix '      Reading data...'])
end

in_file_orig = in_file;
in_file = strrep(in_file, '.out', '.txt');
make_softlink = ~exist(in_file, 'file') ;
if make_softlink
    cmd = sprintf('ln -s %s %s', in_file_orig, in_file) ;
    [s,r] = unix(cmd) ;
    if s~=0
        error('Error making softlink: %s', r)
    end
end

% Get expected # columns
cmd = sprintf('head -n 1 "%s" | wc -w', in_file) ;
[s,r] = unix(cmd) ;
if s~=0
    error('Error getting # cols: %s', r)
end
Ncols = textscan(r, '%d') ;
Ncols = Ncols{1} ;
out_table = readtable(in_file) ;
if size(out_table, 2) ~= Ncols
    error('out_table does not have expected number of columns. Perhaps some line has smushed-together columns?')
end
keyboard

if make_softlink
    cmd = sprintf('rm %s', in_file) ;
    [s,r] = unix(cmd) ;
    if s~=0
        error('Error removing softlink: %s', r)
    end
end

end


function prompt_to_save(in_matfile, verbose, verboseIfNoMat, dispPrefix)
ok = false ;
while ~ok
    if exist(in_matfile,'file')
        disp([dispPrefix '      Save, overwriting existing MAT-file? Y or [N]. 10 seconds...'])
        default_save = false ;
    else
        disp([dispPrefix '      Save to MAT-file? [Y] or N. 10 seconds...'])
        default_save = true ;
    end
    dbl = getkeywait_ssr(10) ;
    if (dbl==-1 && default_save) || strcmp(char(dbl),'y') || strcmp(char(dbl),'Y')
        ok = true ;
        if verbose || verboseIfNoMat
            disp([dispPrefix '      Saving MAT-file...'])
        end
        try
            save(in_matfile,'out_table','-v7.3') ;
        catch
            warning('Unable to save %s', in_matfile)
        end
    elseif (dbl==-1 && ~default_save) || strcmp(char(dbl),'n') || strcmp(char(dbl),'N')
        ok = true ;
    elseif verbose || verboseIfNoMat
        warning(['Input (' char(dbl) ') not recognized.'])
    end
end
end


function out_table = standardize_colnames(out_table)
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
end


function out_header = read_header(in_file)
try
    fid = fopen(in_file) ;
catch ME
    keyboard
end

H = fgetl(fid) ;
fclose(fid) ;
in_header = regexp(H, '\s+', 'split') ;
out_header = in_header ;
if isempty(out_header{1})
    out_header = out_header(2:end) ;
end
if isempty(out_header{end})
    out_header = out_header(1:end-1) ;
end
for f = 1:length(out_header)
    if isempty(out_header{f})
        error('Empty variable name!')
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






