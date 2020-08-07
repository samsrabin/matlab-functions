function hcb = pcolorSSR_BFdiff(map_data,varargin)

if ~isempty(varargin)
    orientation = varargin{1} ;
    if length(varargin) > 1
        cbartitle = varargin{2} ;
    else
        cbartitle = '' ;
    end
else
    orientation = '' ;
    cbartitle = '' ;
end

% pcolor(map_data(15:90,:)) ; shading flat
pcolor(map_data) ; shading flat
axis equal tight
set(gca,'XTick',[],'YTick',[])
caxis([-max(abs(caxis)) max(abs(caxis))])
colormap(gca,flipud(brewermap(64,'rdbu_ssr')))
if isempty(orientation)
    hcb = colorbar ;
else
    hcb = colorbar(orientation) ;
end
if ~isempty(cbartitle)
    h = title(hcb,cbartitle) ;
    h.Position = [153 -25 0] ;
end