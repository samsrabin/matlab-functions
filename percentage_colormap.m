function percentage_colormap(handles, this_cmap_name, top, varargin)
% Based on https://www.mathworks.com/matlabcentral/answers/152435-adjusting-color-in-colorbar-automatically

% Set up parser
p = inputParser ;
addRequired(p,'handles') ;
addRequired(p,'this_cmap_name') ;
addRequired(p,'top') ;
addParameter(p,'ncol',64,@isint) ;
addParameter(p,'bot_new',-100,@isreal) ;
% addParameter(p,'shorten',[]) ;

% Parse inputs
parse(p,...
    handles, this_cmap_name, top, ...
    varargin{:});
pFields = fieldnames(p.Results) ;
Nfields = length(pFields) ;
for f = 1:Nfields
    thisField = pFields{f} ;
    if ~exist(thisField,'var')
        eval([thisField ' = p.Results.' thisField ' ;']) ;
    end
    clear thisField
end ; clear f
clear p
% if ~isempty(shorten)
%     Nshort = ncol/2 * shorten ;
%     if ~isint(Nshort)
%         error('Nshort must be an integer')
%     end
%     Nlong = ncol/2 - Nshort ;
%     lengthen = (1 - shorten^2) / (1 - shorten) ;
% end

if top < 100
    error('Why would you do this')
end
bot_old = -top ;

cmap = brewermap(ncol,this_cmap_name) ;
cmap = cmap*255 ;

lim_step_1 = (top - bot_old)/ncol ;
lim_1 = bot_old:lim_step_1:top ;

lim_step_2 = (0 - bot_new)/(ncol/2) ;
lim_2 = bot_new:lim_step_2:0 ;

lim = lim_1 ;
lim(lim<=0) = lim_2 ;

% if ~isempty(shorten)
%     lim2 = 
%     c1 = ncol/2 + 1 ;
%     c2 = c1 + Nshort - 1 ;
%     lim(c1:c2) = lim(c1):(lim_step_1*shorten):lim(c2) ;
%     c1 = c2 + 1 ;
%     lim(c1:end) = lim(c1):(lim_step_1*lengthen):top ;
% end

ctable = [lim(1:end-1)' cmap lim(2:end)' cmap];

tmp_filename = sprintf('mycol.%d.cpt', floor(rand*1e6)) ;
if exist(tmp_filename,'file')
    delete(tmp_filename)
end
save(tmp_filename, 'ctable', '-ascii') ;

for ii = 1:length(handles)
    cptcmap(tmp_filename, handles(ii), ...
        'mapping', 'direct', 'ncol', ncol);
end
delete(tmp_filename)

end