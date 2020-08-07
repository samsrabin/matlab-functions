function param_results5(origRun,new,...
                        run_nums_rej, SSE_rej, ...
                        run_nums_acc, SSE_acc, ...
                        accptd, iii, ...
                        varargin)

% Set up & parse input arguments
p = inputParser ;
ischar_or_isstruct = @(x) ischar(x) || isstruct(x) ;
isintarray = @(x) (iscolumn(x) || isrow(x)) && all(isint(x)) ;

addRequired(p,'origRun',ischar_or_isstruct) ;
addRequired(p,'new',@isstruct) ;
addRequired(p,'run_nums_rej',@isnumeric) ;
addRequired(p,'SSE_rej',@isnumeric) ;
addRequired(p,'run_nums_accj',@isnumeric) ;
addRequired(p,'SSE_acc',@isnumeric) ;
addRequired(p,'accptd',@islogical) ;
addRequired(p,'iii',@isint) ;
addOptional(p,'thetaRHlim',NaN,@isnumeric) ;
addOptional(p,'MarkerSize',40,@isint) ;
addOptional(p,'LineWidth',3,@isint) ;
addOptional(p,'subplot_spacing',0.1,@isnumeric) ;
addOptional(p,'FontSize',16,@isint) ;
addOptional(p,'Position',[1 41 1440 764],isintarray) ;
addOptional(p,'highlightThisIteration',true,@islogical) ;
addOptional(p,'log10sse',false,@islogical) ;
addOptional(p,'showSSEtrace',true,@islogical) ;
parse(p,origRun,new,run_nums_rej,SSE_rej,run_nums_acc,SSE_acc,accptd,iii,varargin{:});
thetaRHlim = abs(p.Results.thetaRHlim) ;

new_ColorOrder = [  0.60      0.60      0.60 ;
                       0    0.4470    0.7410 ;
                  0.8500    0.3250    0.0980] ;
% new_ColorOrder = zeros(3,3) ; hold on

Nruns = length(accptd) ;


%% Get old parameters

asLi = get_params_set('orig') ;

if ischar(origRun)
    old = get_params_set(origRun) ;
else
    old = origRun ;
end



%% Calculate

% Anthropogenic ignitions and suppression
popD = 0:0.01:1000 ;
Ia(1,:) = calc_Ia(old,popD) ;
Ia(2,:) = calc_Ia(new,popD) ;
Ia(3,:) = calc_Ia(asLi,popD) ;
frac_supp(1,:) = calc_fn_popDnf(old,popD) ;
frac_supp(2,:) = calc_fn_popDnf(new,popD) ;
frac_supp(3,:) = calc_fn_popDnf(asLi,popD) ;
Ia_supp = Ia .* (1-frac_supp);

% AGB
agb = 0:0.001:2 ;
% agb = 0:0.01:10 ;
fn_agb = nan(3,length(agb)) ;
fn_agb(1,:) = calc_fn_AGB(old,agb) ;
fn_agb(2,:) = calc_fn_AGB(new,agb) ;
fn_agb(3,:) = calc_fn_AGB(asLi,agb) ;

% RH
rh = 0.01:0.01:1 ;
fn_rh = nan(3,length(rh)) ;
fn_rh(1,:) = calc_fn_RH(old,rh) ;
fn_rh(2,:) = calc_fn_RH(new,rh) ;
fn_rh(3,:) = calc_fn_RH(asLi,rh) ;

% Soil moisture
theta = 0.01:0.01:1 ;
fn_theta(1,:) = calc_fn_theta(old,theta) ;
fn_theta(2,:) = calc_fn_theta(new,theta) ;
fn_theta(3,:) = calc_fn_theta(asLi,theta) ;

% Combined RH and soil moisture
% IGNORING "AS LI"
if ~isequal(size(fn_rh),size(fn_theta))
    error('fn_rh and fn_theta must be the same size for this to work.')
end ; clear this* r
fn_rh_theta_total_old = nan(size(fn_rh,2),size(fn_theta,2)) ;
fn_rh_theta_total_new = nan(size(fn_rh,2),size(fn_theta,2)) ;
for r = 1:size(fn_rh,2)
    thisFnRH = fn_rh(1,r) ;
    if old.theta_ROSeffect_asFnTheta
        fn_rh_theta_total_old(r,:) = (thisFnRH.^3) .* (fn_theta(1,:).^3) ;
    else
        fn_theta_likeRH = calc_fn_RH(old,theta) ;
        fn_rh_theta_total_old(r,:) = (thisFnRH.^3) .*  fn_theta(2,:) .* (fn_theta_likeRH.^2) ;
    end ; clear this* r
end ; clear this* r
for r = 1:size(fn_rh,2)
    thisFnRH = fn_rh(2,r) ;
    if new.theta_ROSeffect_asFnTheta
        fn_rh_theta_total_new(r,:) = (thisFnRH.^3) .* (fn_theta(2,:).^3) ;
    else
        fn_theta_likeRH = calc_fn_RH(new,theta) ;
        fn_rh_theta_total_new(r,:) = (thisFnRH.^3) .*  fn_theta(2,:) .* (fn_theta_likeRH.^2) ;
    end ; clear this* r
end ; clear this* r
fn_rh_theta_total_diff = fn_rh_theta_total_new - fn_rh_theta_total_old ;


%% Make figure

figure('Name','New vs. old parameters','Position',p.Results.Position,'color','w') ;

% Anthropogenic ignitions
subplot_tight(4,6,[1 2],p.Results.subplot_spacing)
semilogx(popD,Ia(3,:),'-',popD,Ia(2,:),'-',popD,Ia(1,:),'--','LineWidth',p.Results.LineWidth)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
semilogx(popD,Ia(3,:),'-',popD,Ia(2,:),'-',popD,Ia(1,:),'--','LineWidth',p.Results.LineWidth)
hold off
set(gca,'FontSize',p.Results.FontSize,'XLim',[0.01 1000],'XTick',10.^(-2:3))
% set(gca,'FontSize',p.Results.FontSize,'XLim',[0.01 1000],'XTick',10.^(-2:3),'XTickLabel','')
xlabel('Population density (people km^{-2})')
hyl = ylabel('I_a') ;
legend ; clear this* r('New','Old','Location','northwest')
letterlabel_alignYlab('a',1.02,p.Results.FontSize,hyl) ;

% Anthropogenic suppression
subplot_tight(4,6,[7 8],p.Results.subplot_spacing)
semilogx(popD,1-frac_supp(3,:),'-',popD,1-frac_supp(2,:),'-',popD,1-frac_supp(1,:),'--','LineWidth',p.Results.LineWidth)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
semilogx(popD,1-frac_supp(3,:),'-',popD,1-frac_supp(2,:),'-',popD,1-frac_supp(1,:),'--','LineWidth',p.Results.LineWidth)
hold off
set(gca,'FontSize',p.Results.FontSize,...
    'XLim',[0.01 1000],'XTick',10.^(-2:3),'YTick',0:0.2:1)
xlabel('Population density (people km^{-2})')
hyl = ylabel('1 - f_{supp}') ;
letterlabel_alignYlab('b',1.02,p.Results.FontSize,hyl) ;

% Suppressed anthropogenic ignitions
subplot_tight(4,6,[3 4 9 10],p.Results.subplot_spacing)
semilogx(popD,Ia_supp(3,:),'-',popD,Ia_supp(2,:),'-',popD,Ia_supp(1,:),'--','LineWidth',p.Results.LineWidth)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
semilogx(popD,Ia_supp(3,:),'-',popD,Ia_supp(2,:),'-',popD,Ia_supp(1,:),'--','LineWidth',p.Results.LineWidth)
hold off
set(gca,'FontSize',p.Results.FontSize,'XLim',[0.01 1000],'XTick',10.^(-2:3))
xlabel('Population density (people km^{-2})')
hyl = ylabel('I_a \times (1-f_{supp})') ;
letterlabel_alignYlab('e',1.02,p.Results.FontSize,hyl) ;

% AGB
if p.Results.showSSEtrace
    subplot_tight(4,6,[5 6 11 12],p.Results.subplot_spacing)
else
    subplot_tight(4,6,[11 12 17 18],p.Results.subplot_spacing)
end
plot(agb,fn_agb(3,:),'-',agb,fn_agb(2,:),'-',agb,fn_agb(1,:),'--','LineWidth',p.Results.LineWidth)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
plot(agb,fn_agb(3,:),'-',agb,fn_agb(2,:),'-',agb,fn_agb(1,:),'--','LineWidth',p.Results.LineWidth)
hold off
set(gca,'FontSize',p.Results.FontSize,...
        'XLim',[0 2],'YTick',0:0.2:1)
% set(gca,'FontSize',p.Results.FontSize,'YTick',0:0.2:1)
xlabel('Aboveground biomass (kg C m^{-2})')
hyl = ylabel('f_{AGB}') ;
letterlabel_alignYlab('g',1.02,p.Results.FontSize,hyl) ;

% SSE trace plot
if p.Results.showSSEtrace
    % subplot_tight(4,6,[17 18 23 24],p.Results.subplot_spacing)
    subplot(4,6,[17 18 23 24])
    % set(gca,'YScale','log')
    if p.Results.log10sse
        SSE_rej = log10(SSE_rej) ;
        SSE_acc = log10(SSE_acc) ;
    end
    %     disp('wljngowrut4')
    % %     semilogy(run_nums_rej,SSE_rej,'.r','MarkerSize',p.Results.MarkerSize)
    % %     hold on
    % %     semilogy(run_nums_acc(accptd),SSE_acc(accptd),'-b','LineWidth',p.Results.LineWidth)
    % %     semilogy(run_nums_acc,SSE_acc,'-b','LineWidth',p.Results.LineWidth)
    %     semilogy(run_nums_acc,SSE_acc,'.b','MarkerSize',p.Results.MarkerSize)
    %     if p.Results.highlightThisIteration
    %         semilogy(iii,SSE_acc(iii),'.c','MarkerSize',p.Results.MarkerSize)
    %     end
    %     hold off
    % else
    plot(run_nums_rej,SSE_rej,'.r','MarkerSize',p.Results.MarkerSize)
    hold on
    plot(run_nums_acc(accptd),SSE_acc(accptd),'-b','LineWidth',p.Results.LineWidth)
    plot(run_nums_acc,SSE_acc,'-b','LineWidth',p.Results.LineWidth)
    plot(run_nums_acc,SSE_acc,'.b','MarkerSize',p.Results.MarkerSize)
    if p.Results.highlightThisIteration
        plot(iii,SSE_acc(iii),'.c','MarkerSize',p.Results.MarkerSize)
    end
    hold off
    % end
    set(gca,'XLim',[1 Nruns],'FontSize',p.Results.FontSize,'Color',[0.85 0.85 0.85])
    box(gca,'off')
    xlabel('Iteration')
    hyl = ylabel('Sum of squared errors') ;
    letterlabel_alignYlab('h',1.02,p.Results.FontSize,hyl) ;
end

% RH
subplot_tight(4,6,[13 14],p.Results.subplot_spacing)
plot(100*rh,fn_rh(3,:),'-',100*rh,fn_rh(2,:),'-',100*rh,fn_rh(1,:),'--','LineWidth',p.Results.LineWidth)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
plot(100*rh,fn_rh(3,:),'-',100*rh,fn_rh(2,:),'-',100*rh,fn_rh(1,:),'--','LineWidth',p.Results.LineWidth)
hold off
set(gca,'FontSize',p.Results.FontSize,'YTick',0:0.2:1)
xlabel('Relative humidity (%)')
hyl = ylabel('f_{RH}') ;
letterlabel_alignYlab('c',1.02,p.Results.FontSize,hyl) ;

% Soil moisture
subplot_tight(4,6,[19 20],p.Results.subplot_spacing)
plot(theta,fn_theta(3,:),'-',theta,fn_theta(2,:),'-',theta,fn_theta(1,:),'--','LineWidth',p.Results.LineWidth)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
plot(theta,fn_theta(3,:),'-',theta,fn_theta(2,:),'-',theta,fn_theta(1,:),'--','LineWidth',p.Results.LineWidth)
hold off
set(gca,'FontSize',p.Results.FontSize,'YTick',0:0.2:1)
xlabel('Soil moisture (\Theta)')
hyl = ylabel('f_{\Theta}') ;
letterlabel_alignYlab('d',1.02,p.Results.FontSize,hyl) ;

% Combined RH and soil moisture
subplot_tight(4,6,[15 16 21 22],p.Results.subplot_spacing)
pcolor(fn_rh_theta_total_diff) ; shading flat
% pcolor(fn_rh_theta_total_diff./fn_rh_theta_total_old) ; shading flat
axis equal tight
if isnan(thetaRHlim)
    caxis([-max(abs(caxis)) max(abs(caxis))])
    disp(num2str(max(abs(caxis))))
else
    caxis([-thetaRHlim thetaRHlim])
end
% colormap(gca,flipud(brewermap(64,'rdbu_ssr')))
colormap(gca,flipud(brewermap(64,'rdbu')))
hcb = colorbar ;
axis equal tight
% title(hcb,'Difference: New - Old') ;
set(gca,'FontSize',p.Results.FontSize,'YTick',[20 40 60 80 100])
xticks = get(gca,'XTick') ;
xticklabels = {} ;
for t = 1:length(xticks)
    xticklabels{t} = num2str(xticks(t)/100) ;
end
set(gca,'XTickLabel',xticklabels) ;
xlabel('Soil moisture (\Theta)')
hyl = ylabel('Relative humidity (%)') ;
letterlabel_alignYlab('f',1.02,p.Results.FontSize,hyl) ;


end