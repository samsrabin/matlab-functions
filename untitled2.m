%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Compare cropped country maps to original %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Original
tmp = dlmread('/Users/Shared/unifying_gridlist/country_boundaries.asc','',6,0) ;
tmp = flipud(tmp) ;
map_orig = true(360,720) ;
map_orig(tmp<0) = false ;

% 64493
tmp = dlmread('/Users/Shared/unifying_gridlist/country_boundaries.asc','',6,0) ;
tmp = flipud(tmp) ;
map_64493 = true(360,720) ;
map_64493(tmp<0) = false ;