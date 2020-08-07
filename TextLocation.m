function hOut = TextLocation(textString,fontSize,varargin)

l = legend(textString,varargin{:},'FontSize',fontSize);
t = annotation('textbox','FontSize',fontSize);
t.String = textString;
t.Position = l.Position;
delete(l);
t.LineStyle = 'None';

if nargout
    hOut = t;
end
end