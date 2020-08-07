function lpjgu_matlab_cropTable_years(in_file,out_file,yearList,yearRange,varargin)

% Set up & parse input arguments
p = inputParser ;
addRequired(p,'in_file',@ischar) ;
addRequired(p,'out_file',@ischar) ;
addRequired(p,'yearList',@isnumeric) ;
addRequired(p,'yearRange',...
    @(x) isnumeric(x) & numel(x)==2) ;
addParameter(p,'Ncells',-1,@isPositiveIntegerValuedNumeric) ;
% addParameter(p,'outWidth',5,@isPositiveIntegerValuedNumeric) ;
% addParameter(p,'varNameAlign','L',...
%     @(x) strcmpi(x,'L') || strcmpi(x,'R')) ;
% addParameter(p,'dataAlign','L',...
%     @(x) strcmpi(x,'L') || strcmpi(x,'R')) ;
% addParameter(p,'fancy',false,@islogical) ;
addParameter(p,'progress_step_pct',5,@isnumeric) ;
addParameter(p,'save_every_n',-1,@isint) ;
% addParameter(p,'delimiter',' ',@ischar) ;
addParameter(p,'overwrite',false,@islogical) ;
parse(p,in_file,out_file,yearList,yearRange,varargin{:});

% Check for existing file
if ~p.Results.overwrite && exist(out_file,'file')
    error('out_file exists. Set overwrite=true to overwrite. Aborting.')
end

% Open files
did_unzip = gunzip_if_needed(in_file) ;
fileID_in = fopen(in_file) ;
if p.Results.Ncells < 0
    Ncells = linecount(fileID_in) / length(yearList) ;
    if ~isint(Ncells)
        error('Can''t determine Ncells.')
    end
else
    Ncells = p.Results.Ncells ;
end
fileID_out = fopen(out_file, 'w') ;

% Read & write header
in_header_str = fgetl(fileID_in) ;
fprintf(fileID_out,'%s\n',in_header_str) ;

% Get years info
Nyears = length(min(yearRange):max(yearRange)) ;
% OKyears = find(yearList>=min(yearRange) & yearList<=max(yearRange)) ;

% Write data line-by-line, saving every p.Results.save_every_n lines
Nrows = Ncells * Nyears ;
progress = 0 ;
isopen = false ;
disp('Saving...')
tic ;
for c = 1:Ncells
    for y = 1:Nyears
        i = (c-1)*Nyears + y ;
        
        % Re-open file if just closed
        if ~isopen
            fileID_out = fopen(out_file,'a') ;
            isopen = true ;
        end
        
        % Write line
        thisLine = fgetl(fileID_in) ;
        thisYear = yearList(y) ;
        if thisYear>=min(yearRange) && thisYear<=max(yearRange)
            fprintf(fileID_out,'%s\n',thisLine) ;
        end
        
        % Close file every p.Results.save_every_n lines
        if rem(i,p.Results.save_every_n)==0
            fclose(fileID_out) ;
            isopen = false ;
        end
        
        % Update progress every progress_step_pct%
        if rem(i,ceil(Nrows*p.Results.progress_step_pct/100))==0
            progress = progress + p.Results.progress_step_pct ;
            disp(['   ' num2str(progress) '% complete (' toc_hms(toc) ')'])
        end
    end
end

% Close files
fclose all ;
if did_unzip
    disp('      Deleting unzipped in_file...')
    err2 = system(['rm ' in_file]) ;
    if err2~=0
        error('Error in rm.')
    end
end


    function n = linecount(fid)
        n = 0;
        tline = fgetl(fid);
        while ischar(tline)
            tline = fgetl(fid);
            n = n+1;
        end
    end


    function did_unzip = gunzip_if_needed(in_file)
        did_unzip = false ;
        if ~exist(in_file,'file')
            in_file_gz = [in_file '.gz'] ;
            if exist(in_file_gz,'file')
                disp('   Unzipping in_file...')
                err1 = system(['gunzip < ' in_file_gz ' > ' in_file]) ;
                if err1~=0
                    error('Error in gunzip.')
                end
                did_unzip = true ;
            else
                error('in_file and in_file.gz not found.')
            end
        end
    end

end