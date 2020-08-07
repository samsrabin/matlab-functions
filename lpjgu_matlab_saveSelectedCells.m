function out_table = lpjgu_matlab_saveSelectedCells(in_table,selected_cells,in_file,out_file,varargin)

% Set up input arguments
p = inputParser ;
addRequired(p,'in_map',@istable) ;
errorMsg = 'selected_cells must be 2-d numeric array, or path to a gridlist file.' ; 
validationFcn = @(x) assert((ismatrix(x) && length(size(x))==2) || ischar(x),errorMsg);
addRequired(p,'selected_cells',validationFcn) ;
addRequired(p,'in_file',@ischar) ;
addRequired(p,'out_file',@ischar) ;
addOptional(p,'yearList',[],@isnumeric) ;
parse(p,in_table,selected_cells,in_file,out_file,varargin{:});

% Import gridlist, if necessary
if ischar(selected_cells)
    filename = selected_cells ;
    selected_cells = table2array(readtable(filename)) ;
end

% Get selected
ok = false(size(in_table.Lon)) ;
progress = 0 ;
progress_step_pct = 10 ;
tic ;
disp('Cropping to selected gridcells...')
for c = 1:size(selected_cells,1)
    thisCell = selected_cells(c,:) ;
    ok(in_table.Lon==thisCell(1) & in_table.Lat==thisCell(2)) = true ;
    % Update progress every X%
    if rem(c,ceil(size(selected_cells,1)*progress_step_pct/100))==0
        progress = progress + progress_step_pct ;
        disp(['   ' num2str(progress) '% complete (' toc_hms(toc) ')'])
    end
end
if ~isempty(p.Results.yearList)
    disp('Cropping to selected years...')
    bad_byYear = true(size(ok)) ;
    for y = 1:length(p.Results.yearList)
        thisYear = p.Results.yearList(y) ;
        bad_byYear(in_table.Year==thisYear) = false ;
    end
    ok(bad_byYear) = false ;
end

out_table = in_table(ok,:) ;

% Save
lpjgu_matlab_saveTable(in_file,out_table,out_file)
writetable(out_table,out_file,'Delimiter','tab')

disp('Done.')


end