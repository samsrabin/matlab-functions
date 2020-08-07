function h = shademap( variable , maintitle , cmap)
% Easy way to make a pcolor plot with flat shading.
%
%   shademap(MATRIX, MAIN_TITLE, COLORMAP)
%       Makes a pcolor plot (shading flat) of MATRIX, with title 
%       MAINTITLE and colormap COLORMAP.
%
%   shademap(MATRIX, MAIN_TITLE)
%       Makes a pcolor plot (shading flat) of MATRIX, with title
%       MAINTITLE and colormap 'jet'.
%
%   shademap(MATRIX)
%       Makes a pcolor plot (shading flat) of MATRIX, with no title
%       and colormap 'jet'.

if nargin == 1
    maintitle = ' ' ;
    cmap = 'jet' ;
elseif nargin == 2
    cmap = 'jet' ;
end

h = figure ;
colormap(cmap)
variable_sq = squeeze(variable) ;
pcolor(double(variable_sq))
shading flat
colorbar
title(maintitle, 'FontSize', 16, 'FontWeight', 'bold')

end