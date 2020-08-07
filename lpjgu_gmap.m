function lpjgu_gmap(map,varargin)

% Set up input arguments
p = inputParser ;
addRequired(p,'map',@ismatrix) ;
default_outFile = '' ;
addParameter(p,'outFile',default_outFile,@ischar) ;
default_title = '' ;
addParameter(p,'title',default_title,@ischar) ;
default_position = [185 140 1049 494] ;
addParameter(p,'position',default_position,...
             @(x) isequal(size(x),[1 4])) ;
default_caxis = [min(map(~isnan(map))) max(map(~isnan(map)))] ;
addParameter(p,'caxis',default_caxis,...
             @(x) isequal(size(x),[1 2])) ;
default_fontSize = 14 ;
addParameter(p,'fontSize',default_fontSize,@isnumeric) ;

% Parse inputs
parse(p,map,varargin{:});

% Set up figure
hf = figure ;
set(hf,'color','w','Position',p.Results.position)

% Plot map
pcolor(map) ;
shading flat ;
axis equal tight off ;

% Figure accessories
set(gca,'FontSize',p.Results.fontSize)
if ~isempty(p.Results.title)
    title(p.Results.title)
end

% Deal with colors
caxis(p.Results.caxis) ;
colorbar ;

% Save to file, if outFile specified
if ~isempty(p.Results.outFile)
    export_fig(p.Results.outFile) ;
    close(hf) ;
end

end