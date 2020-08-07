function map_1to1(xdata,ydata,varargin)

% Set up & parse input arguments
p = inputParser ;
addRequired(p,'xdata',@isnumeric) ;
addRequired(p,'ydata',@isnumeric) ;
addParameter(p,'xlab','',@ischar) ;
addParameter(p,'ylab','',@ischar) ;
addParameter(p,'slope',[],@isnumeric) ;
addParameter(p,'intercept',[],@isnumeric) ;

parse(p,xdata,ydata,varargin{:});
pr = p.Results ;

figure ;
plot(xdata,ydata,'.b','MarkerSize',20)
if ~isempty(pr.xlab)
    xlabel(pr.xlab)
end
if ~isempty(pr.ylab)
    ylabel(pr.ylab)
end
axLim = max([max(get(gca,'XLim')) max(get(gca,'YLim'))]) ;
set(gca,'XLim',[0 axLim],'YLim',[0 axLim],'FontSize',12)
hold on
plot([0 axLim],[0 axLim],'-k')
hold off

% Plot best-fit line
if ~isempty(pr.slope) || ~isempty(pr.intercept)
    % Process inputs
    slope = 0 ;
    intercept = 0 ;
    if ~isempty(pr.slope)
        slope = pr.slope ;
    end
    if ~isempty(pr.intercept)
        intercept = pr.intercept ;
    end
    % Calculate line endpoints
    xdata2 = [min(xdata) max(xdata)] ;
    ydata2 = slope*xdata2 + intercept ;
    % Plot
    hold on
    plot(xdata2,ydata2,'--k')
    hold off
end


