function varargout = map_several_tables(xres,yres,varargin)

%     disp('Checking lat/lon lists...')
%     table1 = varargin{1} ;
%     table1_latlon = [table1.Lat table1.Lon] ;
%     disp(['   ' inputname(3)])
%     for n = 2:length(varargin)
%         tableN = varargin{n} ;
%         disp(['   ' inputname(2+n)])
%         if ~isequal(table1_latlon, [tableN.Lat tableN.Lon])
%             error('Input tables do not have the same lat/lon lists.')
%         end
%     end
if isempty(varargin)
    error('Must provide at least one file for reading.')
end

for f = 1:length(varargin)
    
    % Get filename parts
    in_file = varargin{f} ;
    [in_path,in_name,in_ext] = fileparts(in_file) ;
    disp(['Reading ' in_name in_ext '...'])
    
    % Just read MAT-file if it exists and user wants that
    in_matfile = [in_file '.maps.mat'] ;
    matfile_read = false ;
    if exist(in_matfile,'file')
        % Ask to read from MAT-file
        ok = false ;
        while ~ok
            str = input('   Read from MAT-file? Y or N: ','s') ;
            if strcmp(str,'y') || strcmp(str,'Y')
                ok = true ;
                matfile_read = true ;
                disp('   Reading MAT-file...')
                load(in_matfile) ;
            elseif strcmp(str,'n') || strcmp(str,'N')
                ok = true ;
            end
        end
    end
    if matfile_read
        varargout{f} = out_struct ;
        if f==1
            list_to_map = out_struct.list_to_map ;
        end
        continue
    end
    
    % Read table
    disp('   Reading table...')
    in_table = readtable(in_file) ;
    while ~any(~isnan(table2array(in_table(:,end))))
        in_table(:,end) = [] ;
    end
    
    % Get list_to_map if needed
    if ~exist('list_to_map','var')
        
        
    end
end


end