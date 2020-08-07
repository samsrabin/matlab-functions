function param_results4(origRun,new,varargin)

% Set up & parse input arguments
p = inputParser ;
addRequired(p,'origRun',@ischar) ;
addRequired(p,'new',@isstruct) ;
addOptional(p,'thetaRHlim',NaN,@isnumeric) ;
parse(p,origRun,new,varargin{:});
thetaRHlim = abs(p.Results.thetaRHlim) ;

new_ColorOrder = [  0.60      0.60      0.60 ;
                       0    0.4470    0.7410 ;
                  0.8500    0.3250    0.0980] ;
% new_ColorOrder = zeros(3,3) ; hold on

fontSize = 16 ;


%% Get old parameters

asLi = get_params_set('orig') ;

old = get_params_set(origRun) ;



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

subplot_spacing = 0.1 ;

figure('Name','New vs. old parameters') ;
set(gcf,'color','w')

% Anthropogenic ignitions
subplot_tight(4,6,[1 2],subplot_spacing)
semilogx(popD,Ia(3,:),'-',popD,Ia(2,:),'-',popD,Ia(1,:),'--','LineWidth',3)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
semilogx(popD,Ia(3,:),'-',popD,Ia(2,:),'-',popD,Ia(1,:),'--','LineWidth',3)
hold off
set(gca,'FontSize',fontSize,'XLim',[0.01 1000],'XTick',10.^(-2:3))
% set(gca,'FontSize',fontSize,'XLim',[0.01 1000],'XTick',10.^(-2:3),'XTickLabel','')
xlabel('Population density (people km^{-2})')
ylabel('I_a')
legend ; clear this* r('New','Old','Location','northwest')

% Anthropogenic suppression
subplot_tight(4,6,[7 8],subplot_spacing)
semilogx(popD,1-frac_supp(3,:),'-',popD,1-frac_supp(2,:),'-',popD,1-frac_supp(1,:),'--','LineWidth',3)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
semilogx(popD,1-frac_supp(3,:),'-',popD,1-frac_supp(2,:),'-',popD,1-frac_supp(1,:),'--','LineWidth',3)
hold off
set(gca,'FontSize',fontSize,...
    'XLim',[0.01 1000],'XTick',10.^(-2:3),'YTick',0:0.2:1)
xlabel('Population density (people km^{-2})')
ylabel('1 - f_{supp}')

% Suppressed anthropogenic ignitions
subplot_tight(4,6,[3 4 9 10],subplot_spacing)
semilogx(popD,Ia_supp(3,:),'-',popD,Ia_supp(2,:),'-',popD,Ia_supp(1,:),'--','LineWidth',3)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
semilogx(popD,Ia_supp(3,:),'-',popD,Ia_supp(2,:),'-',popD,Ia_supp(1,:),'--','LineWidth',3)
hold off
set(gca,'FontSize',fontSize,'XLim',[0.01 1000],'XTick',10.^(-2:3))
xlabel('Population density (people km^{-2})')
ylabel('I_a \times (1-f_{supp})')

% AGB
subplot_tight(4,6,[11 12 17 18],subplot_spacing)
plot(agb,fn_agb(3,:),'-',agb,fn_agb(2,:),'-',agb,fn_agb(1,:),'--','LineWidth',3)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
plot(agb,fn_agb(3,:),'-',agb,fn_agb(2,:),'-',agb,fn_agb(1,:),'--','LineWidth',3)
hold off
set(gca,'FontSize',fontSize,...
        'XLim',[0 2],'YTick',0:0.2:1)
% set(gca,'FontSize',fontSize,'YTick',0:0.2:1)
xlabel('Aboveground biomass (kg C m^{-2})')
ylabel('f_{AGB}')

% RH
subplot_tight(4,6,[13 14],subplot_spacing)
plot(100*rh,fn_rh(3,:),'-',100*rh,fn_rh(2,:),'-',100*rh,fn_rh(1,:),'--','LineWidth',3)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
plot(100*rh,fn_rh(3,:),'-',100*rh,fn_rh(2,:),'-',100*rh,fn_rh(1,:),'--','LineWidth',3)
hold off
set(gca,'FontSize',fontSize,'YTick',0:0.2:1)
xlabel('Relative humidity (%)')
ylabel('f_{RH}')

% Soil moisture
subplot_tight(4,6,[19 20],subplot_spacing)
plot(theta,fn_theta(3,:),'-',theta,fn_theta(2,:),'-',theta,fn_theta(1,:),'--','LineWidth',3)
set(gca,'ColorOrder',new_ColorOrder) ; hold on
plot(theta,fn_theta(3,:),'-',theta,fn_theta(2,:),'-',theta,fn_theta(1,:),'--','LineWidth',3)
hold off
set(gca,'FontSize',fontSize,'YTick',0:0.2:1)
xlabel('Soil moisture (\Theta)')
ylabel('f_{\Theta}')

% Combined RH and soil moisture
subplot_tight(4,6,[15 16 21 22],subplot_spacing)
pcolor(fn_rh_theta_total_diff) ; shading flat
% pcolor(fn_rh_theta_total_diff./fn_rh_theta_total_old) ; shading flat
axis equal tight
xlabel('Soil moisture (\Theta)')
ylabel('Relative humidity (%)')
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
set(gcf,'Position',[1 41 1440 764])
set(gca,'FontSize',fontSize,'YTick',[20 40 60 80 100])


end