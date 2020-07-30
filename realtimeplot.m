function realtimeplot(h, hf, j, data_raw, data_filter, sub, subf)

if mod(j,300) == 0
    clearpoints(h);
    clearpoints(hf);
    sub.XLim = [0 300];
    subf.XLim = [0 300];
end

addpoints(h,j,data_raw);
addpoints(hf,j,data_filter);

if mod(j,2) == 0
    drawnow %limitrate
end

end

