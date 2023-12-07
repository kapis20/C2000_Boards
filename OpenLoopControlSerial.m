%% Set up  communication port 
device = serialport("COM7",5e6);

%% messages 
SpeedRPM = uint16(2000);
enable = uint16(0);

Message = [SpeedRPM,enable];

%% Data transmission 

write(device,Message,'uint16')