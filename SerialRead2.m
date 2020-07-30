%%
% ECG signal processing
% Capturing UART incomming signal
% Format : 1 sample = 10 bits, 8-high-bits first and then 8-low-bits later
% FIR filtering

%% Parameters
OBSERVE_TIME = 10000;      % ECG observing time [sec]

data_raw = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
data_filter = [0];
i = 1;
j = 1;
LPF_100HZ = [0.000454665481664494,0.00355945381522087,0.00635871854161046,-0.00422929091333384,-0.0317513205905760,-0.0380851026729248,0.0374608537584544,0.194837858068540,0.331466126840366,0.331466126840366,0.194837858068540,0.0374608537584544,-0.0380851026729248,-0.0317513205905760,-0.00422929091333384,0.00635871854161046,0.00355945381522087,0.000454665481664494];

% Serial port open
clear myserial 
myserial = serialport("COM11",250000);       % Choose COM port number, and BAUD rate

sub =  subplot(2,1,1);
h = animatedline(sub, 'Color', 'b');
% title('Raw ECG')
axis([0,300,0,1200]);

subf = subplot(2,1,2);
hf = animatedline(subf, 'Color', 'r');
% title('Low-Pass-Filtered ECG');
axis([0,300,0,1200]);


%% open file with date and time as the name
Filename = sprintf('%s.txt', datestr(now,'yyyymmdd_HHMMSS'));
fileID = fopen( Filename , 'w' );

tic
while(toc < OBSERVE_TIME)

    if ( myserial.NumBytesAvailable >= 2)
        byte_high = read(myserial,1,"uint8");
        byte_low = read(myserial,1,"uint8");
        data = byte_high*2^5 + byte_low;

disp(data)
        
        data_raw = [data_raw,data];

        %filtering
        data_filternew = dot(LPF_100HZ,data_raw(i:i+17));
        data_filter = [data_filter,data_filternew];
        i=i+1;
        
        realtimeplot(h, hf, j, data, data_filternew, sub, subf);
        j=j+1;
        if mod(j,300) == 0
            j = 0;
        end
        
% Plot the raw data to animatedline
%         addpoints(h,i,data_raw(i));
%         axis([i-300,i,0,2023]);
%         pause (0.00001)

% Plot the filtered data to animatedline
%         addpoints(hf,i,data_filter(i));
%          axis([i-300,i,0,2023]);     
%          pause (0.00001)
        
         %record each data to file with "yyyymmdd_hh:mm:ss,value”  format
         fprintf(fileID,'%s,%d\n',sprintf(datestr(now,'yyyymmdd_HH:MM:SS')),round(data_filter(i)));
    end
end

(fileID);

% Serial port close
clear myserial

%% FIR filtering

% FIR filter, low-pass, 17-tap, 100Hz/200Hz sampling, Fpass: 6Hz, Fstop: 30Hz
LPF_100HZ = [0.000454665481664494,0.00355945381522087,0.00635871854161046,-0.00422929091333384,-0.0317513205905760,-0.0380851026729248,0.0374608537584544,0.194837858068540,0.331466126840366,0.331466126840366,0.194837858068540,0.0374608537584544,-0.0380851026729248,-0.0317513205905760,-0.00422929091333384,0.00635871854161046,0.00355945381522087,0.000454665481664494];
LPF_200HZ = [-0.0105804683158701,-0.0142368301124630,-0.0140024181257667,-0.00194913227208785,0.0255281779916362,0.0668886533440887,0.114551247327214,0.156749240532542,0.181580907587758,0.181580907587758,0.156749240532542,0.114551247327214,0.0668886533440887,0.0255281779916362,-0.00194913227208785,-0.0140024181257667,-0.0142368301124630,-0.0105804683158701];
LPF_400HZ = [0.0215816621518628,0.0367210354190087,0.0307646463529835,0.0530424583189421,0.0566863278073250,0.0717664765888957,0.0770629644368969,0.0849992715093148,0.0873197452172508,0.0873197452172508,0.0849992715093148,0.0770629644368969,0.0717664765888957,0.0566863278073250,0.0530424583189421,0.0307646463529835,0.0367210354190087,0.0215816621518628];
LPF_800HZ = [0.121157955317435,0.0285458933228509,0.0312635243332654,0.0337351193219265,0.0359165860451073,0.0377397581817737,0.0391294487695380,0.0400503498501290,0.0405045526563749,0.0405045526563749,0.0400503498501290,0.0391294487695380,0.0377397581817737,0.0359165860451073,0.0337351193219265,0.0312635243332654,0.0285458933228509,0.121157955317435];

data_filtered_LPF = conv(LPF_100HZ,data_raw);
%data_filtered_LPF = conv(LPF_200HZ,data_raw);
%data_filtered_LPF = conv(LPF_400HZ,data_raw);
%data_filtered_LPF = conv(LPF_800HZ,data_raw);

%% Plotting
figure
subplot(2,1,1)
plot(data_raw,'b')
ylim([0 1050])
title('Raw ECG')
subplot(2,1,2) 
plot(data_filtered_LPF,'r')
ylim([0 1050])
title('Low-Pass-Filtered ECG')

%% Data save
save result
