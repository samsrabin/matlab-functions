function softball_sit(n,varargin)

if ~isempty(varargin)
    NfieldInnings = varargin{1} ;
    if ~isnumeric(NfieldInnings)
        error('NfieldInnings needs to be numeric')
    end
    if length(varargin)>1
        warning('Ignoring extra input arguments beyond n, NfieldInnings.')
    end
else
    NfieldInnings = 7 ;
end

if n <= 10
    disp(['All ' num2str(n) ' players field every inning.'])
else
    disp(['Bat entire lineup (assume ' num2str(NfieldInnings) ' field innings):'])
    out_personInnings = (n-10)*NfieldInnings ;
    meanSit = out_personInnings/n ;
    if isint(meanSit)
        disp(['   Everybody sits ' num2str(meanSit) 'x.'])
    else
        sitMin = floor(meanSit) ;
        sitMax = ceil(meanSit) ;
        n_sitMax = out_personInnings - n*sitMin ;
        n_sitMin = n - n_sitMax ;
        disp(['   ' num2str(n_sitMax) ' sit ' num2str(sitMax) 'x, ' num2str(n_sitMin) ' sit ' num2str(sitMin) 'x.'])
    end
    
    disp('MLB-style substitutions:')
    play_half = 2*(n-10) ;
    play_all = n - play_half ;
    disp(['   ' num2str(play_all) ' field every inning, ' num2str(play_half) ' have to sub.'])
end
disp(' ')

end