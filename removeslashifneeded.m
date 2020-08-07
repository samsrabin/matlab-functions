function str_out = removeslashifneeded(str_in)

if ~isstr(str_in) || min(size(str_in))>1
    error('str_in must be a string!')
end

str_out = str_in ;
while strcmp(str_out(end),'/')
    str_out = str_out(1:end-1) ;
end

end