function S = dir2(file_path)
% Just like DIR, except ignoring files beginning with period (.)

S = dir(file_path) ;
S(cellfun(@(x) strcmp(x(1),'.'), {S.name})) = [] ;


end