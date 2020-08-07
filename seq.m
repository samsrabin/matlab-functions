function out_vec = seq(in_pair)

if numel(in_pair) ~= 2
    error('in_pair must be a 2-element vector.')
end
out_vec = in_pair(1):in_pair(2) ;

end