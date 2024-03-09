%% Set up  communication port 
device = serialport("COM13",12e6);


%% messages 
SpeedRPM = single(-600);
enable = single(16);

SpeedRPM = SpeedRPM * 1/PU_System.N_base;

Message = [SpeedRPM;enable]
x= 2;

%% Data transmission 

write(device,Message,'single')


%% clear port

delete(device);
clear device