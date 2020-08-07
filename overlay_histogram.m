function overlay_histogram(var1,var2,varargin)
% Sam Rabin, 2015-02-07
% Based on code from Walter Roberson at:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/165551

if ~isempty(varargin) > 0
    nBins = varargin{1} ;
    if length(varargin) > 1
        error('Maximum one optional variable.')
    end
else
    nBins = 10 ;
end

[n1, xout1] = hist(var1,nBins);
bar(xout1,n1,'b') ;
hold on
[n2, xout2] = hist(var2,xout1);
bar(xout2,n2,'r');
hold off


end