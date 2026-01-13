%% Set up  communication port 
device = serialport("COM7",5e6);

%% messages 
SpeedRPM = uint16(2000);
enable = uint16(0);

Message = [SpeedRPM,enable];

%% Data transmission 

write(device,Message,'uint16')

%% clear port
%flush(device);
%fclose(device);
delete(device);
%clear the object from maltab's workspace 
clear device
%% data receive set up
%device = serialport("COM7",5e6,'DataBits',8,'StopBits',1)
device = serialport("COM7",5e6);
% configureTerminator(device,"EE");


matrixsize = [600,2];
AllElements = prod(matrixsize);
% figure
% plotHandle = plot(zeros(1,600));
% % Initialize variables for real-time plotting 
% time = 0; 
% dataBuffer = zeros(1,600);

% %Set Up real time updates 
% Rate = 1/5e6; 
% Timer= timer('TimerFcn', @(~,~) updatePlot(device,plotHandle,time,dataBuffer,AllElements),'Period',Rate,'ExecutionMode','fixedRate');
% 


%% data receive 
% Set up the figure and axis
figure;
hLine = plot(NaN, NaN);  % Initialize an empty plot
xlabel('Time (ms)');
ylabel('Current');
title('Real-Time Plot');

numofPoints = 600;
try 
    while true 
        %Read data as uint 16
        data = read(device,AllElements,'uint16');
        %reshape data into the desired matrix shape 
        receivedData = reshape(data,[600,2]);
        currentIa = receivedData(:,1);
        currentIb = receivedData(:,2);
        set(hLine, 'XData', linspace(0,100,600), 'YData', currentIa);
        % Force MATLAB to update the plot
        drawnow;

    end
catch ME
    clear device;
    rethrow(ME);
end
%%
%  Main loop 
% % Main loop for real-time data reading
% start(Timer); %start count
% try
%     while isvalid(Timer)
%         % Pause to control the loop execution rate (adjust as needed)
%         pause(0.003);  
%     end
% catch ME
%     % Handle errors or close the serial port and timer in case of an exception
% 
%     clear port;
% 
%     stop(Timer);
%     delete(Timer);
%     clear Timer;
% 
%     rethrow(ME);
% end
% 
% %% Update plot
% function updatePlot(port, plotHandle, time, dataBuffer, elementsPerRead)
%     % Read data as uint16
%     data = read(device, elementsPerRead, 'uint16');
% 
% 
% 
% 
% 
%     % Reshape the data into the desired matrix shape
%     receivedData = reshape(data, [600, 2]);
% 
%     % Update time and data buffer
%     time = time + 1;
%     dataBuffer = [dataBuffer(2:end), receivedData(:, 1)];  % Assuming a 1D plot
% 
%         % Update the plot
%         set(plotHandle, 'YData', dataBuffer);
%         title(['Real-Time Plot - Time: ' num2str(time)]);
%         disp(time);
% 
% end
