function tf_out = find_members(A,B)
% Finds indices of elements in A that match elements in B
tf_out = false(size(A)) ;
for i = 1:length(B)
    is_match = find(strcmp(A,B{i})) ;
    if isempty(is_match)
        error([B{i} ' not found in A!'])
    elseif length(is_match)>1
        error([B{i} ' repeated in A!'])
    end
    tf_out(is_match) = true ;
end

end