function Index = find_string_in_cell_exact(in_cell,in_string)

IndexC = strfind(in_cell, in_string);
Index = find(not(cellfun('isempty', IndexC)));

end