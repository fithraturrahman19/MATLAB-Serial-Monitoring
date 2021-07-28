function realtimeplot(ht, h, hf, j, i, data_raw, data_filter, data_filternew, sub, subf)

%   update frame and calculate heartrate every 10s
if mod(j,1000) == 0
    
    % Peak detection macros
    THRESHOLD =(max(data_filter(i-999:i)) - mean(data_filter(i-999:i))) * 0.5;  % set threshold to the middle of average and peak value
    THRESHOLD =(max(THRESHOLD,15)); % to prevent false-detection when there is no real beat (max value doesn't imply a peak)
    MINDISTANCE = 50;  % minimum distance to double detection in one peak

    % clear points in the animatedline to avoid increasing memory and runtime
    clearpoints(h);
    clearpoints(hf);
    
    % calculate heartbeat using threshold and findpeaks function
    signalValueL = data_filter(i-999:i); % take the last 1000 points (10s) of data for calculation
    averageSignalValue = mean(signalValueL); % take the average
    totalRPeak = findpeaks(signalValueL,'MinPeakHeight',averageSignalValue+THRESHOLD,'MinPeakDistance',MINDISTANCE); % define threshold and count the points above it
    totalRPeak = length(totalRPeak); % calculate R-peak points
    timeScale = 6;

    % get heartbeat rate per minute
    heartBeat = totalRPeak * timeScale;
    
    % display bpm in the filtered plot
    str = [num2str(heartBeat)];
    set(ht,'String', str);
    drawnow
    
end

% addpoint to animatedline every tick (100 Hz)
addpoints(h,toc,data_raw);
addpoints(hf,toc,data_filternew);

% plot with 50 Hz framerate
if mod(j,2) == 0
    drawnow
end

end

