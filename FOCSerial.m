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
 matrixsize = [600,2];
 AllElements = prod(matrixsize);

% Define time interval between samples
timeInterval = 1 / 12e6; % Time interval between samples in seconds

% % Define time interval between updates
% updateInterval = 1; % Update interval in seconds



 figure;
 hLine = plot(NaN(matrixsize(1), 2));  % Initialize an empty plot with 2 lines
 %hLine = plot(NaN, NaN);  % Initialize an empty plot
 %hold on;  % Hold the plot for subsequent data
% hLineB = plot(NaN, NaN);  % Initialize an empty plot for DataB
% hold off; % Release the plot after initialization
 xlabel('Time (s)');
 ylabel('Data');
 title('Real-Time Plot');
 legend('DataA', 'DataB');
% 
% numofPoints = 600;
% 
% % Create timer object
% timerObj = timer('TimerFcn', @(~,~)updatePlot(device, hLine, AllElements), ...
%                  'ExecutionMode', 'fixedRate', ...
%                  'Period', updateInterval, ...
%                  'BusyMode', 'queue');
% 
% % Start the timer
% start(timerObj);
% 
% % Function to update the plot
% function updatePlot(device, hLine, AllElements)
%     % Read data from the serial port
%     data = read(device, AllElements, 'single');
% 
%     % Extract every first element as Data1 and every second element as Data2
%     Data1 = data(1:2:end);
%     Data2 = data(2:2:end);
% 
%     % Construct time vector
%     timeVector = (0:size(Data1,1)-1);
% 
%     % Update the plot
%     set(hLine(1), 'XData', timeVector, 'YData', Data1); % Update the first line with Data1
%     set(hLine(2), 'XData', timeVector, 'YData', Data2); % Update the second line with Data2
% end

try 
    while true 

        data = read(device, AllElements, 'single')
        %extract every first element
        Data1=data(1:2:end)

        %extract every second element 
        Data2= data(2:2:end)
        %Data1=data(:,1)
        %Data2=data(:,2)

        % Construct time vector
        timeVector = (0:matrixsize(1)-1) * timeInterval;

        %element wise multiplication:(Speed and ref)
        DataA = Data1 .* PU_System.N_base;
        DataB = Data2 .* PU_System.N_base;
        %  % %reshape data into the desired matrix shape 
        % % receivedData = reshape(data,[600,2]);
        % % DataA = receivedData(:,1);
        % % DataB = receivedData(:,2);
        % % set(hLineA, 'XData', linspace(0,0.1,numofPoints), 'YData', DataA);
        % % set(hLineB, 'XData', linspace(0, 0.1, numofPoints), 'YData', DataB);
        % % % Force MATLAB to update the plot
        % Update the plot
        set(hLine(1), 'XData', timeVector, 'YData', Data1); % Update the first line with Data1
        set(hLine(2), 'XData', timeVector, 'YData', Data2); % Update the second line with Data2
        % Force MATLAB to update the plot
        %drawnow;
    end
catch ME
    clear device;
    rethrow(ME);
end