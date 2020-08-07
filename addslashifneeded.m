function str_out = addslashifneeded(str_in)

if ~isstr(str_in) || min(size(str_in))>1
    error('str_in must be a string!')
end

if ~strcmp(str_in(end),'/')
    str_out = [str_in '/'] ;
else
    str_out = str_in ;
end


end