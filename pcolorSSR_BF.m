function pcolorSSR_BF(map_data,bin_edges,labels,colormap_in,varargin)

if ~isempty(varargin)
    cbarpos = varargin{1} ;
    if ~ischar(cbarpos) ; error('cbarpos must be a string!') ; end
    if length(varargin)>1
        fontSize = varargin{2} ;
        if ~isreal(fontSize) ; error('fontSize must be a number!') ; end
    else
        fontSize = 14 ;
    end
else
    cbarpos = [] ;
    fontSize = 14 ;
end

% Get original colormap
% colormap_orig = colormap ;

% % TESTING
% for i = 1:length(bin_edges)
%     map_data(1,i) = bin_edges(i) ;
% end

[~,indices] = histc(map_data,bin_edges);

indices(map_data>max(bin_edges)) = max(indices(:)) ;

indices(isnan(map_data)) = NaN ;
indices(isinf(map_data)) = NaN ;

pcolor(indices-1) ; shading flat
set(gca,'XTick',[],'YTick',[])

colormap(gca,colormap_in);
if ~isempty(cbarpos)
    h = colorbar(cbarpos) ;
else
    h = colorbar;
end
caxis([0 length(bin_edges)-1])
% if strcmp(cbarpos,'southoutside') || strcmp(cbarpos,'south')
%     h.XTickLabel = labels ;
% else
%     h.YTickLabel = labels ;
% end

set(h,'FontSize',fontSize,'Ticks',0:(length(bin_edges)-1),'TickLabels',labels)

% colormap(colormap_orig) ;