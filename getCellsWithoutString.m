function tf_out = getCellsWithoutString(cell_in, str_in)

tf_out = cellfun('isempty', strfind(cell_in, str_in)) ;


end