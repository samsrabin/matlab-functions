function out_yvx = lpjgu_table2yvx(table_in,Nyears,Ncells)

isLatLonYear = strcmp(table_in.Properties.VariableNames,'Lat') ...
             | strcmp(table_in.Properties.VariableNames,'Lon') ...
             | strcmp(table_in.Properties.VariableNames,'Year') ;
        
array_in = table2array(table_in(:,~isLatLonYear)) ;
Nvars = size(array_in,2) ;

out_yvx = nan(Nyears,Nvars,Ncells) ;
for i = 1:Ncells
    i1 = (i-1)*Nyears + 1 ;
    iN = i*Nyears ;
    out_yvx(:,:,i) = array_in(i1:iN,:) ;
end


end