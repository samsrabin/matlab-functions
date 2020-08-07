function tf_out = getCellsWithString(cell_in, str_in)

tf_out = not(cellfun('isempty', strfind(cell_in, str_in))) ;


end