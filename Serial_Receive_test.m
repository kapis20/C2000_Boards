%% Set up  communication port 
device = serialport("COM9",12e6);

%% Write 
enable = 19 ;
RefSpeed =700;
%Need to convert speed accordinly as in the host model
Speed = RefSpeed *1/PU_System.N_base;
message = [Speed;enable]
write(device,message,'single');

delete(device);
clear device
%% Receive 
device = serialport("COM9",12e6);
% configureTerminator(device,"CR");
 matrixsize = [20,2];  %array with  columns 
% AllElements = prod(matrixsize); %gets number of daatests to collect from an array 
AllElements = prod(matrixsize);
    data1 = [];
    data2 = [];
    DataSpeed1 = [];
    DataSpeed2 = [];
    data3 = [];
    data4 =[];
    figure;
    hLine = plot(NaN(matrixsize(1), 2)); 
    inverse_Scaling_Factor =  single(uint32(4294967295)) / single(uint16(65535));
%     % Calculate the inverse scale factor using single precision
% inverse_scale_factor1 = single(uint64(18446744073709551615)) / single(uint32(4294967295));

try
  while true
    data = read(device, 600, 'uint16');
    % Single2 = single(typecast(uint32(data), 'single'))
    % Scale the uint32 value back up to uint64 and maintain single precision
    % uint64_value_restored = uint64(single(data) * inverse_scale_factor1);
    % Singleval1 = single(typecast(uint64(uint64_value_restored), 'single'))
    datax = single(typecast(uint32(data), 'single'))
  
    uint32_value_restored = uint32(single(data) * inverse_Scaling_Factor);
    Singleval = single(typecast(uint32(uint32_value_restored), 'single'))
  
    startTime = datetime('now');
    %data1_single = single(typecast(uint32(data), 'single'));
    % data1 = bitand(data, hex2dec('0000FFFF')); % Extract lower 16 bits
    % data2 = bitshift(bitand(data, hex2dec('FFFF0000')), -16); % Extract upper 16 bits
    % Extract individual uint16 datasets
    %Extract datasets 
    %data= single(typecast(uint32(data), 'single'));
      data1 = [data1, Singleval(1:2:end)];
      data2 = [data2, Singleval(2:2:end)];
      DataSpeed1 = [DataSpeed1, data1(1:2:end)];
      DataSpeed2 = [DataSpeed2, data1(2:2:end)];
     % data1 = [data1, data(1:4:end).* PU_System.N_base];
     % data2 = [data2, data(2:4:end).* PU_System.N_base];
     % data3 = [data3, data(3:4:end).* PU_System.I_base];
     % data4 =[data4, data(4:4:end)* PU_System.I_base];

     % if numel(DataSpeed1) > 2500
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