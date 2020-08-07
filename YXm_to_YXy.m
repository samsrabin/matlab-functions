function out_YXy = YXm_to_YXy(in_YXm,style)

if ~strcmp(style,'mean') && ~strcmp(style,'sum')
    error('style must be either "mean" or "sum".')
end

nyears = size(in_YXm,3)/12 ;

out_YXy = nan(size(in_YXm,1),size(in_YXm,2),nyears) ;
for y = 1:nyears
    m1 = (y-1)*12 + 1 ;
    m12 = m1 + 11 ;
    if strcmp(style,'mean')
        out_YXy(:,:,y) = mean(in_YXm(:,:,m1:m12),3) ;
    elseif strcmp(style,'sum')
        out_YXy(:,:,y) = sum(in_YXm(:,:,m1:m12),3) ;
    end
end



end