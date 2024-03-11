%% Set up  communication port 
device = serialport("COM13",12e6);


%% messages 
SpeedRPM = single(600);
enable = single(81);

SpeedRPM = SpeedRPM * 1/PU_System.N_base;

Message = [SpeedRPM;enable];

%% Data transmission 

write(device,Message,'single')

%% clear port

delete(device);
clear device

%% data receive
device = serialport("COM13", 12e6);
% Increased to store more samples (doesn't affect plot size)
storageSize = 1200; 

% Define time interval between samples
timeInterval = 1 / 12e6; % Time interval between samples in seconds

% Pre-allocate storage arrays
dataBuffer = zeros(storageSize, 2);
bufferIndex = 1;

% Pre-allocate data arrays for plotting (fixed size)
DataA = zeros(300, 1);
DataB = zeros(300, 1);
time = linspace(0, (300-1) * timeInterval, 300);  % Pre-calculate for 300 points

figure;
hLine = plot(time, NaN(300, 2));  % Initialize empty plot with pre-calculated time

xlabel('Time (s)');
ylabel('Data');
title('Real-Time Plot');
legend('DataA', 'DataB');

try
  while true
    data = read(device, 2, 'single');  % Read two elements at a time
    % Extract data
    DataA(mod(bufferIndex-1,300)+1) = data(1) .* PU_System.N_base;  % Store in DataA with circular indexing
    DataB(mod(bufferIndex-1,300)+1) = data(2) .* PU_System.N_base;  % Store in DataB with circular indexing
    
    bufferIndex = mod(bufferIndex, storageSize) + 1;  % Update buffer index

    % Check if enough data is available for plotting (1200 - 300 = 900)
    if bufferIndex >= 900
      % Get the most recent 300 data points from the buffer
      startIndex = mod(bufferIndex-300, storageSize) + 1;
      currentData = dataBuffer(startIndex:end, :);
      if startIndex > 1
          currentData = [currentData; dataBuffer(1:startIndex-1, :)];
      end
      
      % Update plot data
      set(hLine(1), 'YData', currentData(:, 1));
      set(hLine(2), 'YData', currentData(:, 2));

      drawnow;
    end
    pause(0.01);  % Adjust pause time as needed
  end
catch ME
  clear device;
  rethrow(ME);
end
