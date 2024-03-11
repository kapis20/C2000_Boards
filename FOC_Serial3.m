%% Set up  communication port 
device = serialport("COM13",12e6);


%% messages 
SpeedRPM = single(-600);
enable = single(17);

SpeedRPM = SpeedRPM * 1/PU_System.N_base;

Message = [SpeedRPM;enable];

%% Data transmission 

write(device,Message,'single')

%% clear port

delete(device);
clear device





%% data receive
device = serialport("COM13", 12e6);
matrixsize = [100, 2];  % Reduced data size for smoother plotting
AllElements = prod(matrixsize);

% Define time interval between samples
timeInterval = 1 / 12e6; % Time interval between samples in seconds

% Pre-allocate data arrays
DataA = zeros(matrixsize(1), 1);
DataB = zeros(matrixsize(1), 1);

% Create a timer object for plot updates
t = timer('TimerFcn', @(~,~) updatePlot(data, hLine), 'Period', 0.1, 'ExecutionMode', 'fixedRate');



figure;
hLine = plot(NaN(matrixsize(1), 2));  % Initialize empty plot

xlabel('Time (s)');
ylabel('Data');
title('Real-Time Plot');
legend('DataA', 'DataB');

try
  % Start the timer
  start(t);
  
  while true
    % Your main code can run here if needed (outside timer callback)
    % Pause for a short time to avoid overloading (adjust as needed)
    pause(0.01);
  end
catch ME
  clear device;
  stop(t);  % Stop the timer before exiting
  rethrow(ME);
end

% Function to update plot within timer callback
function updatePlot(data, plotHandles)
  persistent prevTime;  % Store previous time for relative time calculation
  
  % Read data from device (assuming blocking read)
  data = read(device, AllElements, 'single');
  
  % Check if data is available (handle potential timeouts)
  if isempty(data)
      return;
  end
  
  % Extract and process data
  DataA = data(1:2:end) .* PU_System.N_base;
  DataB = data(2:2:end) .* PU_System.N_base;
  
  % Calculate time vector (adjust for elapsed or relative time as needed)
  if isempty(prevTime)
      currentTime = 0;
  else
      currentTime = toc(prevTime);  % Calculate elapsed time since last update
  end
  prevTime = tic;  % Update previous time for next iteration
  time = linspace(0, currentTime, matrixsize(1));
  
  % Update plot data
  set(plotHandles(1), 'XData', time, 'YData', DataA);
  set(plotHandles(2), 'XData', time, 'YData', DataB);
  drawnow;
end
