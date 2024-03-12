%% Set up  communication port 
device = serialport("COM13",12e6);


%% messages 
SpeedRPM = single(-600);
enable = single(80);

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
%timeInterval = 1 / 12e6; % Time interval between samples in seconds


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
% Capture starting time for real-time x-axis
%startTime = datetime('now');

try
  while true
    data = read(device, AllElements, 'single');
    startTime = datetime('now');
      % Extract DataA and DataB from received data and concatenate with existing arrays
      %Mode1
        % DataA = [DataA, data(1:2:end) .* PU_System.N_base];
        % DataB = [DataB, data(2:2:end) .* PU_System.N_base];
    %Mode 5
      DataA = [DataA, data(1:2:end) .* PU_System.I_base];
      DataB = [DataB, data(2:2:end) .* 2*pi];

    if numel(DataA) == 2500
    DataA = rmoutliers(DataA);
    DataB = rmoutliers(DataB);

    % Calculate elapsed time
        currentTime = datetime('now');
        elapsedTime = seconds(currentTime - startTime);
     % Generate time points for the x-axis
        xData = linspace(0, elapsedTime, numel(DataA));
    % Update plot data and x-axis
        set(hLine(1), 'XData', xData, 'YData', DataA);
        set(hLine(2), 'XData', xData, 'YData', DataB);
    % set(hLine(1), 'XData', linspace(0,numel(DataA),numel(DataA)), 'YData', DataA);
    % set(hLine(2), 'XData', linspace(0,numel(DataB),numel(DataB)), 'YData', DataB);
    drawnow;
    pause(0.05);  % Adjust pause time as needed
    DataA = [];
    DataB = [];
    end
  end
catch ME
  clear device;
  rethrow(ME);
end