function [ output ] = minmax_ssr( input, varargin )
%MINMAX_SSR Gives minimum and maximum of all elements in array.
%

if istable(input)
    input = table2array(input) ;
end

ignore_inf = false ;
if ~isempty(varargin)
    ignore_inf = varargin{1} ;
end

if ignore_inf
    minimum = min(input(~isinf(input))) ;
    maximum = max(input(~isinf(input))) ;
else
    minimum = min(input(:)) ;
    maximum = max(input(:)) ;
end

output = [minimum maximum] ;


end

