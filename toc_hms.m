function output = toc_hms( toc_sec )
%TOC_HMS Nicely displays output from "toc."
%
%   Usage
%       string = toc_hms(toc)
%           or
%       disp(toc_hms(toc))
%
%   If toc < 1 minute, "S.S seconds"
%   If 1 minute =< toc < 1 hour, "MM:SS"
%   If toc >= 1 hour, "HH:MM:SS"
%
%   (c) Sam S. Rabin, 2012

if toc_sec >= 3600
    output = datestr(datenum(0,0,0,0,0,toc_sec),'HH:MM:SS') ;
elseif toc_sec >= 60
    output = datestr(datenum(0,0,0,0,0,toc_sec),'MM:SS') ;
else
    output = [num2str(round(toc_sec*1e+1)*1e-1) ' seconds'] ;
end


end

