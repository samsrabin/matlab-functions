function tf_out = getCellsWithString_wc(cell_in, str_in)

tf_out = not(cellfun('isempty', strfindw(cell_in, str_in))) ;


end