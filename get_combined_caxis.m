function caxis_out = get_combined_caxis(h1,h2)

caxis_h1 = caxis(h1) ;
caxis_h2 = caxis(h2) ;

caxis_all = [caxis_h1 caxis_h2] ;

caxis_out = [min(caxis_all) max(caxis_all)] ;


end