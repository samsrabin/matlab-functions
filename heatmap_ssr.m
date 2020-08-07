function values = heatmap_ssr( xVar , yVar , numBins , varargin)
%HEATMAP Displays a "heat map" summarizing a scatter plot
%   Points on scatter plots are often too dense to permit visual analysis.
%   This script breaks a scatter plot into grid cells whose colors
%   correspond to the number of points they contain.
%
% Input arguments
%   xVar        The variable whose values will be on the X axis.
%   yVar        The variable whose values will be on the Y axis.
%   numBins     A two-element vector containing the number of bins for
%               the X and Y axes.
%   doLog10     Make log10 color scale. Either 'log10' or 'dont' (default).

if min(size(xVar))~=1 || min(size(yVar))~=1 || min(size(numBins))~=1
    error('Input arguments must be vectors.')
elseif length(xVar) ~= length(yVar)
    error('Input vectors must be the same length.')
elseif length(numBins) ~= 2
    error('numBins must be a two-element vector.')
end

if ~isempty(varargin)
    log10color = varargin{1} ;
else
    log10color = 'dont' ;
end

if size(xVar,1)==size(yVar,2) && size(xVar,2)==size(yVar,1)
    if size(xVar,1) == 1
        xVar = transpose(xVar) ;
    elseif size(yVar,1) == 1
        yVar = transpose(yVar) ;
    end
end

X = [xVar yVar] ;
[values bins] = hist3(X,[numBins(1) numBins(2)]) ;
values = permute(values,[2 1]) ;
values(values==0) = NaN ;
bincenters_X = bins{1} ;
bincenters_Y = bins{2} ;
colormap('jet')
if strcmp(log10color,'log10')
    pcolor(bincenters_X, bincenters_Y, log10(values+1))
else
    pcolor(bincenters_X, bincenters_Y, values)
end
shading flat
colorbar


end

