function out = sum2(in,dims2sum)
% SUM2
%%% Wrapper for SUM that allows the specification of multiple dimensions
%%% over which summing should occur.
%%% Sam Rabin, 2018-05-07

i = 1 ;
out = in ;
while i<=length(dims2sum)
    
    thisDim = dims2sum(i) ;
    out = sum(out,thisDim) ;
    i = i+1 ;
end