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
matrixsize = [20, 2];  % Reduced data size for smoother plotting
AllElements = prod(matrixsize);

% Define time interval between samples
timeInterval = 1 / 12e6; % Time interval between samples in seconds

% %Pre-allocate data arrays
% DataA = zeros(matrixsize(1), 1);
% DataB = zeros(matrixsize(1), 1);
% 

% Pre-calculate time vector
 %time = linspace(0, timeInterval*(matrixsize(1)-1), matrixsize(1));
 figure;
 %hLine = plot(NaN(matrixsize(1), 2));  % Initialize an empty plot with 2 lines
 hLine = plot(linspace(0,1200,1200),NaN(1200, 2) );  % Initialize an empty plot with 2 lines

 xlabel('Time (s)');
 ylabel('Data');
 title('Real-Time Plot');
 legend('DataA', 'DataB');
 % Initialize empty arrays for DataA and DataB
    DataA = [];
    DataB = [];

try
  while true
    data = read(device, AllElements, 'single');
      % Extract DataA and DataB from received data and concatenate with existing arrays
        DataA = [DataA, data(1:2:end) .* PU_System.N_base];
        DataB = [DataB, data(2:2:end) .* PU_System.N_base];
    % Extract data
    % DataA = data(1:2:end) .* PU_System.N_base;
    % DataB = data(2:2:end) .* PU_System.N_base;
    if numel(DataA) == 1200
    % Calculate time vector for the current data
    %time = linspace(0, (matrixsize(1) - 1) * timeInterval, 2*matrixsize(1));
    
     % Ensure DataA and DataB are vectors (if needed)
      % DataA = DataA(:);  % Extract first column if necessary
      % DataB = DataB(:);
      % Update plot data and time vector
    DataA = rmoutliers(DataA);
    DataB = rmoutliers(DataB);
    set(hLine(1), 'XData', linspace(0,numel(DataA),numel(DataA)), 'YData', DataA);
    set(hLine(2), 'XData', linspace(0,numel(DataB),numel(DataB)), 'YData', DataB);
    drawnow;
    pause(0.05);  % Adjust pause time as needed
    DataA = [];
    DataB = [];
    end
    % % Update plot data efficiently
    % set(hLine(1), 'YData', DataA);
    % set(hLine(2), 'YData', DataB);

    % % Force MATLAB to update the plot
    % drawnow;
    % pause(0.01);  % Adjust pause time as needed
  end
catch ME
  clear device;
  rethrow(ME);
end