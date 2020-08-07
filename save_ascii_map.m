function save_ascii_map(filename,A,out_header)

fid = fopen(filename,'w') ;
for h = 1:6
    fprintf(fid,'%s \n',out_header{h}) ;
end
A = flipud(A) ;
A(isnan(A)) = -9999 ;
dlmwrite(filename,A,'delimiter',' ','-append')
fclose(fid) ;

end