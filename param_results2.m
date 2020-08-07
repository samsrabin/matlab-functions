function param_results2(origRun,new)


%% Get old parameters

% old = get_params_set('orig') ;
% old = get_params_set('hist_default') ;
old = get_params_set(origRun) ;


%% Calculate

% Anthropogenic ignitions and suppression
popD = 0:0.01:1000 ;
Ia(1,:) = calc_Ia(old,popD) ;
Ia(2,:) = calc_Ia(new,popD) ;
frac_supp(1,:) = calc_fn_popDnf(old,popD) ;
frac_supp(2,:) = calc_fn_popDnf(new,popD) ;
Ia_supp = Ia .* (1-frac_supp);

% AGB
agb = 0:0.001:2 ;
% agb = 0:0.01:10 ;
fn_agb = nan(2,length(agb)) ;
fn_agb(1,:) = calc_fn_AGB(old,agb) ;
fn_agb(2,:) = calc_fn_AGB(new,agb) ;

% RH
rh = 0.01:0.01:1 ;
fn_rh = nan(2,length(rh)) ;
fn_rh(1,:) = calc_fn_RH(old,rh) ;
fn_rh(2,:) = calc_fn_RH(new,rh) ;

% Soil moisture
theta = 0.01:0.01:1 ;
fn_theta(1,:) = calc_fn_theta(old,theta) ;
fn_theta(2,:) = calc_fn_theta(new,theta) ;

% Combined RH and soil moisture
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

subplot_spacing = 0.075 ;

figure('Name','New vs. old parameters') ;
set(gcf,'color','w')

% Anthropogenic ignitions
subplot_tight(4,6,[1 2],subplot_spacing)
semilogx(popD,Ia(2,:),'-',popD,Ia(1,:),'--','LineWidth',3)
set(gca,'FontSize',14,'XLim',[0.01 1000],'XTick',10.^(-2:3))
% set(gca,'FontSize',14,'XLim',[0.01 1000],'XTick',10.^(-2:3),'XTickLabel','')
xlabel('Population density (people km^{-2})')
ylabel('I_a')
legend ; clear this* r('New','Old','Location','northwest')

% Anthropogenic suppression
subplot_tight(4,6,[7 8],subplot_spacing)
semilogx(popD,1-frac_supp(2,:),'-',popD,1-frac_supp(1,:),'--','LineWidth',3)
set(gca,'FontSize',14,...
    'XLim',[0.01 1000],'XTick',10.^(-2:3),'YTick',0:0.2:1)
xlabel('Population density (people km^{-2})')
ylabel('1 - f_{supp}')

% Suppressed anthropogenic ignitions
subplot_tight(4,6,[3 4 9 10],subplot_spacing)
semilogx(popD,Ia_supp(2,:),'-',popD,Ia_supp(1,:),'--','LineWidth',3)
set(gca,'FontSize',14,'XLim',[0.01 1000],'XTick',10.^(-2:3))
xlabel('Population density (people km^{-2})')
ylabel('I_a \times (1-f_{supp})')

% AGB
subplot_tight(4,6,[11 12 17 18],subplot_spacing)
plot(agb,fn_agb(2,:),'-',agb,fn_agb(1,:),'--','LineWidth',3)
set(gca,'FontSize',14,...
        'XLim',[0 2],'YTick',0:0.2:1)
% set(gca,'FontSize',14,'YTick',0:0.2:1)
xlabel('Aboveground biomass (kg C m^{-2})')
ylabel('f_{AGB}')

% RH
subplot_tight(4,6,[13 14],subplot_spacing)
plot(100*rh,fn_rh(2,:),'-',100*rh,fn_rh(1,:),'--','LineWidth',3)
set(gca,'FontSize',14,'YTick',0:0.2:1)
xlabel('Relative humidity (%)')
ylabel('f_{RH}')

% Soil moisture
subplot_tight(4,6,[19 20],subplot_spacing)
plot(theta,fn_theta(2,:),'-',theta,fn_theta(1,:),'--','LineWidth',3)
set(gca,'FontSize',14,'YTick',0:0.2:1)
xlabel('Soil moisture (\Theta)')
ylabel('f_{\Theta}')

% Combined RH and soil moisture
subplot_tight(4,6,[15 16 21 22],subplot_spacing)
pcolor(fn_rh_theta_total_diff) ; shading flat
% pcolor(fn_rh_theta_total_diff./fn_rh_theta_total_old) ; shading flat
axis equal tight
xlabel('Soil moisture (\Theta)')
ylabel('Relative humidity (%)')
caxis([-max(abs(caxis)) max(abs(caxis))])
% colormap(gca,flipud(brewermap(64,'rdbu_ssr')))
colormap(gca,flipud(brewermap(64,'rdbu')))
hcb = colorbar ;
axis equal tight
% title(hcb,'Difference: New - Old') ;
set(gcf,'Position',[1 41 1440 764])
set(gca,'FontSize',14)


end