function batterylevel(hb, htb, data)

BAT_OFFSET = 19;
data = data + BAT_OFFSET;  % Offset from observation
batLevel = ((data - 150) / 255) * 2.5 * 2;
batLevel = round(batLevel,3);

str = [num2str(batLevel)];
set(htb,'String', str);

if (batLevel <= 3.5)
    dim2 = [.83 .11 .074 .030];
elseif (batLevel <= 3.6)
    dim2 = [.83 .11 .074 .065];
elseif (batLevel <= 3.7)
    dim2 = [.83 .11 .074 .100];
elseif (batLevel <= 3.75)
    dim2 = [.83 .11 .074 .135];
elseif (batLevel <= 3.8)
    dim2 = [.83 .11 .074 .170];
elseif (batLevel <= 3.85)
    dim2 = [.83 .11 .074 .205];
elseif (batLevel <= 3.9)
    dim2 = [.83 .11 .074 .240];
elseif (batLevel <= 3.95)
    dim2 = [.83 .11 .074 .275];
elseif (batLevel <= 4.0)
    dim2 = [.83 .11 .074 .310];
else
    dim2 = [.83 .11 .074 .340];
end
%dim2 = [.83 .11 .074 .30];
set(hb,'Position',dim2);

drawnow