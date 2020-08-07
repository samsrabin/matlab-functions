function out_str = v73_or_append(in_file)

if exist(in_file,'file')
    out_str = '-append' ;
else
    out_str = '-v7.3' ;
end

end