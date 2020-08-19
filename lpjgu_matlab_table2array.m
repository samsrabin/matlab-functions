function out_yxc = lpjgu_matlab_table2array(in_array, target_size)

Ndims_in = length(find(size(in_array)>1)) ;
Ndims_out = length(target_size) ;

if ~((Ndims_in==1 && any(Ndims_out==[2 3])) || (Ndims_in==2 && Ndims_out==3))
    error('This only works with 1d-to-(2d or 3d) or 2d-to-3d')
elseif numel(in_array) ~= prod(target_size)
    error('Mismatch in number of elements from in to out')
end

if istable(in_array)
    in_array = table2array(in_array) ;
end

if Ndims_in == 1
    out_yxc = reshape(in_array, target_size) ;
elseif Ndims_in == 2
    out_yxc = nan(target_size) ;
    for c = 1:target_size(3)
        out_yxc(:,:,c) = reshape(in_array(:,c), target_size(1:2)) ;
    end
end

end