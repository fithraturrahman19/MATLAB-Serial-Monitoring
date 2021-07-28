%% Monitoring
% ECG signal processing
% Capturing UART incomming signal
% Format : 1 sample = 10 bits, 8-high-bits first and then 8-low-bits later
% FIR filtering

% clear all;

%% Parameters 
OBSERVE_TIME = 100; %60*60;      % ECG observing time [sec]

% declare a pre-allocated array for the raw and filtered signal
data_raw = transpose(zeros(100000000,1));
data_filter = transpose(zeros(100000000,1));
elapsed_time = transpose(zeros(100000000,1));
i = 1; %for adding signal value to array (data saving)
j = 1; %for adding signal value to animatedline (plotting)
LPF_100HZ = [0.000454665481664494,0.00355945381522087,0.00635871854161046,-0.00422929091333384,-0.0317513205905760,-0.0380851026729248,0.0374608537584544,0.194837858068540,0.331466126840366,0.331466126840366,0.194837858068540,0.0374608537584544,-0.0380851026729248,-0.0317513205905760,-0.00422929091333384,0.00635871854161046,0.00355945381522087,0.000454665481664494];

% Serial port open
clear myserial 
myserial = serialport("COM11",115200);
%myserial = serialport("COM9",19200);       % Choose COM port number, and BAUD rate

% animated line initiation for the raw signal
% figure
sub =  subplot(2,8,[1,6]);
h = animatedline(sub, 'Color', 'c');
title('Raw ECG', 'Color', 'c');
% ylabel('Strength');
xlabel('Elapsed  time(s)');
xlim([0,10]);
ylim([0,270]);
x1 = gca();
x1.XColor = 'c';
x1.YColor = 'c';
x1.YTickLabel = [];
x1.GridAlpha = 0.5;
x1.GridColor = 'c';
box on;
grid on;
set(gca,'color','k');
set(gcf,'color',[0.1, 0.1, 0.1]);
set(gcf,'name','ECG Real Time Monitoring');

% animated line initiation for the filtered signal
subf = subplot(2,8,[9,15]);
hf = animatedline(subf, 'Color', 'y','LineWidth',1.5);
title('Filtered ECG', 'Color', 'y');
% ylabel('Value');
xlabel('Elapsed  time(s)');
xlim([0,10]);
ylim([0,270]);
x2 = gca();
x2.XColor = 'y';
x2.YColor = 'y';
x2.YTickLabel = [];
x2.GridAlpha = 0.5;
x2.GridColor = 'y';
box on;
grid on;
set(gca,'color','k');

% text handle for displaying heartbeat rate
subf = subplot(2,8,[7,8]);
ht = annotation('textbox', [0.8, 0.7, 0.04, 0.1], 'string', '0');
title('Heart Rate', 'Color', [0 1 0]);
ht.FitBoxToText = 'on';
ht.Margin = 0.05;
% ht.EdgeColor = [0 1 0];
% ht.Units = 'centimeters';
ht.FontSize = 30;
ht.Color = [0 1 0];
ht.HorizontalAlignment = 'center';
ht.VerticalAlignment = 'middle';
ht.LineStyle = 'none';
ht.BackgroundColor = 'none';
ht.EdgeColor = 'none';
set(gca,'color','k');
set(gca,'XColor', 'g','YColor','g');
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
box on;

% battery status in rectangle indicator
subf = subplot(2,8,16);
title('Battery', 'Color', [1 0 0]);
set(gca,'color','k');
set(gca,'XColor', 'r','YColor','r');
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
box on;

% battery in voltage indicator, can be commented if not used
htb = annotation('textbox', [0.85, 0.47, 0.04, 0.1], 'string', '0');
htb.FitBoxToText = 'on';
htb.Margin = 0.05;
htb.FontSize = 15;
htb.Color = [1 0 0];
htb.HorizontalAlignment = 'center';
htb.VerticalAlignment = 'middle';
htb.LineStyle = 'none';
htb.BackgroundColor = 'none';
htb.EdgeColor = 'none';

% battery level rectangle indicator
dim2 = [.83 .11 .074 .34];
hb = annotation('rectangle',dim2,'FaceColor','r');

% battery level rectangle indicator
bline1 = annotation('line',[.83 .904],[.110 .110]);
bline2 = annotation('line',[.83 .904],[.140 .140]);
bline3 = annotation('line',[.83 .904],[.175 .175]);
bline4 = annotation('line',[.83 .904],[.210 .210]);
bline5 = annotation('line',[.83 .904],[.245 .245]);
bline6 = annotation('line',[.83 .904],[.280 .280]);
bline7 = annotation('line',[.83 .904],[.315 .315]);
bline8 = annotation('line',[.83 .904],[.350 .350]);
bline9 = annotation('line',[.83 .904],[.385 .385]);
bline10 = annotation('line',[.83 .904],[.420 .420]);


%% open file with date and time as the name
Filename = sprintf('%s.txt', datestr(now,'yyyymmdd_HHMMSS'));
% fileID = fopen( Filename , 'w' );

tic
while(toc < OBSERVE_TIME)

    % pause(0.002);
    % wait for serial coming and read the two byte data
    if ( myserial.NumBytesAvailable >= 1)
        byte_high = read(myserial,1,"uint8");
        byte_low = read(myserial,1,"uint8");
        data = byte_high*2^8 + byte_low;
%         data = read(myserial,1,"uint8");

        if (data > 300)                 % battery status voltage transmission
            %batterylevel(hb, data);    % without voltage text
            batterylevel(hb, htb, data); % with voltage text
            data
        else

            % record timestamp 
            elapsed_time(i+17) = toc;

            % storing new raw data value
            data_raw(i+17) = data;

            % filtering
            data_filternew = dot(LPF_100HZ,data_raw(i:i+17));

            % storing new filtered data value
            data_filter(i+17) = data_filternew;
            i=i+1;

            % call plotting function
            realtimeplot(ht, h, hf, j, i, data, data_filter, data_filternew, sub, subf);

            % change x and y-axis to next frame
            if (mod(j,1000) == 0)
                j = 0;
                ymin = min(data_filter(i-999:i)) - 10;
                ymax = max(data_filter(i-999:i)) + 10;
                xlim(x1, [toc, toc+10]);
                xlim(x2, [toc, toc+10]);
                ylim(x2, [ymin, ymax]);
            end
            j=j+1;

            %record each data to file with "yyyymmdd_hh:mm:ss,value�  format
            %fprintf(fileID,'%d,%s\n',round(data_filternew),sprintf(datestr(now,'yyyymmdd_HH:MM:SS')));
            %fprintf(fileID,'%d,%s\n',round(data),sprintf(datestr(now,'yyyymmdd_HH:MM:SS')));
        end
    end
end

% Close File
% fclose(fileID);

% Serial port close
clear myserial

%% FIR filtering

% FIR filter, low-pass, 17-tap, 100Hz/200Hz sampling, Fpass: 6Hz, Fstop: 30Hz
LPF_100HZ = [0.000454665481664494,0.00355945381522087,0.00635871854161046,-0.00422929091333384,-0.0317513205905760,-0.0380851026729248,0.0374608537584544,0.194837858068540,0.331466126840366,0.331466126840366,0.194837858068540,0.0374608537584544,-0.0380851026729248,-0.0317513205905760,-0.00422929091333384,0.00635871854161046,0.00355945381522087,0.000454665481664494];
HPF_100HZ = [-0.237875170334970,-0.00425831986639167,-0.00431679731880498,-0.00438219210500956,-0.00413344779199064,-0.00429562819898364,-0.00428484666076090,-0.00427978019281810,-0.00432717336393302,0.995700575671699,-0.00432717336393302,-0.00427978019281810,-0.00428484666076090,-0.00429562819898364,-0.00413344779199064,-0.00438219210500956,-0.00431679731880498,-0.00425831986639167,-0.237875170334970];

data_filtered_LPF = conv(LPF_100HZ,data_raw(1:i));
data_filtered_LPF = conv(HPF_100HZ, data_filtered_LPF);