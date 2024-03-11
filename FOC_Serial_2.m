%% Set up  communication port 
device = serialport("COM13",12e6);


%% messages 
SpeedRPM = single(-600);
enable = single(16);

SpeedRPM = SpeedRPM * 1/PU_System.N_base;

Message = [SpeedRPM;enable];

%% Data transmission 

write(device,Message,'single')

%% clear port

delete(device);
clear device




%% data receive 
 device = serialport("COM13",12e6);
matrixsize = [300, 2];  % Reduced data size for smoother plotting
AllElements = prod(matrixsize);

% Define time interval between samples
timeInterval = 1 / 12e6; % Time interval between samples in seconds

%Pre-allocate data arrays
DataA = zeros(matrixsize(1), 1);
DataB = zeros(matrixsize(1), 1);
    

% Pre-calculate time vector
 time = linspace(0, timeInterval*(matrixsize(1)-1), matrixsize(1));
 figure;
 hLine = plot(NaN(matrixsize(1), 2));  % Initialize an empty plot with 2 lines

 xlabel('Time (s)');
 ylabel('Data');
 title('Real-Time Plot');
 legend('DataA', 'DataB');
% 
 %numofPoints = 600;


try
  while true
    data = read(device, AllElements, 'single');
    % Extract data
    DataA = data(1:2:end) .* PU_System.N_base;
    DataB = data(2:2:end) .* PU_System.N_base;
    
 
    % Update plot data efficiently
    set(hLine(1), 'YData', DataA);
    set(hLine(2), 'YData', DataB);

    % Force MATLAB to update the plot
    drawnow;
    pause(0.01);  % Adjust pause time as needed
  end
catch ME
  clear device;
  rethrow(ME);
end