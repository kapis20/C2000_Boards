%% Set up  communication port 
device = serialport("COM9",12e6);

%% Write 
% option 1 = 17, 19 
% option 2 = 33, 35 (higher numbers - field weakening enabled 
% option 3 = 51, 49 
enable = 50 ;
RefSpeed =1000;
%Need to convert speed accordinly as in the host model
Speed = RefSpeed *1/PU_System.N_base;
message = [Speed;enable]
write(device,message,'single');

delete(device);
clear device
%% Receive 
device = serialport("COM9",12e6);

    data1 = [];
    data2 = [];
    data3 = []; 
    data4 = [];
    % Create figure and subplot handles
    figure;
    subplot(2,1,1);
    hLine1 = plot(NaN, NaN, NaN, NaN);  % Placeholder for first subplot
    title('Data 1 and Data 2');
    xlabel('Time');
    ylabel('Values');
    legend('Data 1', 'Data 2');
    
    subplot(2,1,2);
    hLine2 = plot(NaN, NaN, NaN, NaN);  % Placeholder for second subplot
    title('Data 3 and Data 4');
    xlabel('Time');
    ylabel('Values');
    legend('Data 3', 'Data 4');

    inverse_Scaling_Factor =  single(uint32(4294967295)) / single(uint16(65535));
    %timeStamps =[];

try
  while true
    data = read(device, 600, 'uint32');
    startTime = datetime('now');

    %DecodeUint32 into two uint16s 
    % Extract the high 16 bits
    Tempdata = data;
    % msb_uint16 =  bitand(Tempdata, uint32(65535));  % Isolate lower 16 bits
    % lsb_uint16 = bitshift(Tempdata, -16);       % Shift right by 16 bits to get upper 16 bits
    % lsb_uint16 = bitand(lsb_uint16, uint32(65535)); % Mask out upper bits of shifted value

    output1 = uint16(bitshift(Tempdata, -16)); 
    % Extract the low 16 bits
    output2 = uint16(bitand(uint32(Tempdata), uint32(65535))); 
   
    uint32_value_restored1 = uint32(single(output1) * inverse_Scaling_Factor);
    uint32_value_restored2 = uint32(single(output2) * inverse_Scaling_Factor);

    Singleval1 = single(typecast(uint32(uint32_value_restored1), 'single'));
    Singleval2 = single(typecast(uint32(uint32_value_restored2), 'single'));
      % 
      % % data1 = [data1, Singleval(1:2:end)];
      % % data2 = [data2, Singleval(2:2:end)];
      % % DataSpeed1 = [DataSpeed1, data1(1:2:end)];
      % % DataSpeed2 = [DataSpeed2, data1(2:2:end)];
      % 
      % data1 = [data1, Singleval1(1:2:end)];
      % data2 = [data2, Singleval1(2:2:end)];
      % data3 = [data3, Singleval2(1:2:end)];
      % data4 = [data3, Singleval2(2:2:end)];
      %Speed and %Iq 
       % data1 = [data1, Singleval1(1:2:end).* PU_System.N_base];
       % data2 = [data2, Singleval1(2:2:end).* PU_System.N_base];
       % data3 = [data3, Singleval2(1:2:end).* PU_System.I_base];
       % data4 =[data4, Singleval2(2:2:end)* PU_System.I_base];
       % FilteredSpeed = MAF_filter(data2,19,5);
       % %Id and Ia/Ib
       %  data1 = [data1, Singleval1(1:2:end).* PU_System.I_base];
       % data2 = [data2, Singleval1(2:2:end).* PU_System.I_base];
       % data3 = [data3, Singleval2(1:2:end).* PU_System.I_base];
       % data4 =[data4, Singleval2(2:2:end)* PU_System.I_base];
       % Filtereddata3 = MAF_filter(data3,5,3);
       % Filtereddata4 = MAF_filter(data4,5,3);

       %Speed and Torque power 
       data1 = [data1, Singleval1(1:2:end).* PU_System.N_base];
       data2 = [data2, Singleval1(2:2:end).* PU_System.N_base];
       data3 = [data3, Singleval2(1:2:end).* PU_System.T_base];
       data4 = [data4, Singleval2(2:2:end).* PU_System.P_base];
        

       if numel(data1) > 500
         % Get current time elapsed
         timeElapsed = seconds(datetime('now') - startTime);
         xData = linspace(0, timeElapsed, numel(data1));
          % Update plots
            set(hLine1(1), 'XData', xData, 'YData', data1);
             set(hLine1(2), 'XData', xData, 'YData', data2);
            set(hLine2(1), 'XData', xData, 'YData', data3);
            set(hLine2(2), 'XData', xData, 'YData', data4);
            % for Speed
             % set(hLine1(2), 'XData', xData, 'YData', FilteredSpeed{5,19});
              % set(hLine2(1), 'XData', xData, 'YData', data3);
              % set(hLine2(2), 'XData', xData, 'YData', data4);
            
             % % For Ia and IB
             % set(hLine2(1), 'XData', xData, 'YData', Filtereddata3{2,5});
             % set(hLine2(2), 'XData', xData, 'YData', Filtereddata4{2,5});
             % 
             drawnow; % Update the plots
              data1 =[];
                data2 = [];
                data3 = [];
                data4 =[];
       end
          
     %    DataSpeed1 = rmoutliers(DataSpeed1);
     %    DataSpeed2 = rmoutliers(DataSpeed2);
     %    % data1Single = single(typecast(uint32(data1), 'single'))
     %    % data2Single = single(typecast(uint32(data2), 'single'))
     % 
     %    %     for i = 1:1:length(data1Single)
     %    %         if data1Single(i) == 0.1675078
     %    %             x = 1.398e+09;
     %    %         end
     %    %     end
     %    % % data3 = rmoutliers(data3);
     %    % data4 = rmoutliers(data4);
     %    currentTime = datetime('now');
     %    elapsedTime = seconds(currentTime - startTime);
     %     xData = linspace(0, elapsedTime, numel(DataSpeed1));
     % % 
     %    %  plot(data1);
     %    % hold on;
     %    % plot(data2);
     %    set(hLine(1),'XData', xData,'YData', DataSpeed1);
     %    set(hLine(2),'XData', xData, 'YData', DataSpeed2);
     %    drawnow;
     %    pause(0.05);  % Adjust pause time as needed
     %    DataSpeed1=[];
     %    DataSpeed2=[];
     %    xData = [];
     %    data1 = [];
     %    data2 = [];
     %    %data2 =[];
     % end
    % datax = typecast(data1,'single');
    % data1 = uint16(bitand(bitshift(data, -48), hex2dec('FFFF')));
    % data2 = uint16(bitand(bitshift(data, -32), hex2dec('FFFF')));
    % data3 = uint16(bitand(bitshift(data, -16), hex2dec('FFFF')));
    % data4 = uint16(bitand(data, hex2dec('FFFF')));
    % 
    % % Convert uint16 datasets to single
    % data1_single = single(data1);
    % data2_single = single(data2);
    % data3_single = single(data3);
    % data4_single = single(data4);
        % Convert the uint16 datasets to single
    %dataConverted=typecast(data,'single');
    %dataConverted = typecast(data,'single');
     %data1_single = single(typecast(uint32(data), 'single'));
    % data2_single = single(typecast(uint16(data2), 'single'));

  end
catch ME
  clear device;
  rethrow(ME);
end

%% clear port

delete(device);
clear device