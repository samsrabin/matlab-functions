function lpjgu_tcrop(in_file,y1,yN,varargin)

% Setup defaults for optional inputs
%%% Output filename
[in_path,in_name,in_ext] = fileparts(in_file) ;
if y1==yN
    out_file = [in_path '/' in_name '.' num2str(y1) in_ext] ;
else
    out_file = [in_path '/' in_name '.' num2str(y1) '-' num2str(yN) in_ext] ;
end

% Parse optional inputs
if ~isempty(varargin)
    if ~isempty(varargin{1})
        out_file = varargin{1} ;
        if ~ischar(out_file)
            error('First optional argument (out_file) must be char.')
        end
    end
    if length(varargin)>1
        warning('All but first optional argument is ignored.')
    end
end

disp([in_file ':'])

% Import to table
disp('   Importing...')
in_table = lpjgu_matlab_readTable(in_file) ;

% Get output table
disp('   Doing tcrop...')
out_table = in_table(in_table.Year>=y1 & in_table.Year<=yN,:) ;

% Save output table
disp('   Saving...')
lpjgu_matlab_saveTable(in_file,out_table,out_file)


disp('Done.')




end


