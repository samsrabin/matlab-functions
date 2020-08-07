function [ result ] = isequaln_within( a1 , a2, margin )
%ISEQUALN_WITHIN Tests whether corresponding elements in arrays are equal
%within some custom tolerance, counting NaNs as equal.
%
% Input arguments
%   a1 , a2     The arrays to be compared
%   margin      The tolerance one wishes to allow
%
% Example
%   >> x = [1 2 3 ; 4 5 6 ; 7 8 9 NaN] ;
%   >> y = [1 2 3 ; 4 5 6 ; 7 8 9.000001 NaN] ;
%   >> isequaln(x,y)
%   ans =
%         0
%   >> isequaln_within(x,y,0.001)
%   ans =
%         1
%
%
% (c) Sam S. Rabin, 2017

if margin<=0
    error('Margin must be a positive number.')
end

inv_margin = 1/margin ;

a1_rounded = round(a1*inv_margin) * margin ;
a2_rounded = round(a2*inv_margin) * margin ;

result = isequaln(a1_rounded,a2_rounded) ;


end

