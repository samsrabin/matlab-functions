function thisSystem = get_system_name()

if ispc
    homedir = getenv('USERPROFILE') ;
else
    homedir = getenv('HOME') ;
end

switch homedir
    case {'/Users/sam'}
        thisSystem = 'ssr_mac' ;
    case {'/home/rabin-s'}
        thisSystem = 'ssr_keal' ;
    otherwise
        error('thisSystem not recognized; home folder %s', homedir)
end

end