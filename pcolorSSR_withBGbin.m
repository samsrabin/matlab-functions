function pcolorSSR_withBGbin(bg_array,actual_array)
% ssrPlot_withBGbin(bg_array, actual_array)
%%% Uses pcolor to map a binary array, then pcolors another array
%%% (with transparent NaNs) on top of it.

% Get background plot
BGND_PLOT = double(bg_array); % background image matrix of size N x M
BGND_COLOR = zeros(size(bg_array)) ;
for nn=1:size(BGND_PLOT,1)
    for mm=1:size(BGND_PLOT,2)
        if (BGND_PLOT(nn,mm) == 0) % object label = 0
            BGND_COLOR(nn,mm) = 1; % black
        else
            BGND_COLOR(nn,mm) = 0.75; % white 
        end 
    end
end
BGND_CDATA = cat(3,BGND_COLOR,BGND_COLOR,BGND_COLOR);

% if ~isempty(figName)
%     figure('Name',figName) ;
% else
%     figure ;
% end

% Plot background
h_bgnd = pcolor(BGND_PLOT); shading flat
set(h_bgnd,'FaceColor','flat','CData',BGND_CDATA)
hold on

% Plot actual array
h_plot = pcolor(actual_array) ; shading flat ; axis equal tight
if length(find(~isnan(actual_array))) > 1
    if length(unique(actual_array(~isnan(actual_array)))) > 1
        caxis([min(minmax_ssr(actual_array)) max(minmax_ssr(actual_array))])
    else
        caxis([unique(actual_array(~isnan(actual_array))) unique(actual_array(~isnan(actual_array)))+1])
    end
end
set(h_plot, 'FaceAlpha',0.9) ;   % Control transparency of signal image

end