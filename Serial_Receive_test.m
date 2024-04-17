%% Set up  communication port 
device = serialport("COM9",12e6);

%% Write 
enable = 18;
RefSpeed =700;
%Need to convert speed accordinly as in the host model
Speed = RefSpeed *1/PU_System.N_base;
message = [Speed;enable]
write(device,message,'single');
%% Receive 
% matrixsize = [10,2;2,2];  %array with  columns 
% AllElements = prod(matrixsize); %gets number of daatests to collect from an array 

try
  while true
    data = read(device, 20, 'uint32');
    % data1 = bitand(data, hex2dec('0000FFFF')); % Extract lower 16 bits
    % data2 = bitshift(bitand(data, hex2dec('FFFF0000')), -16); % Extract upper 16 bits
    % Extract individual uint16 datasets
    % data1 = uint16(bitand(bitshift(data, -48), hex2dec('FFFF')));
    % data2 = uint16(bitand(bitshift(data, -32), hex2dec('FFFF')));
    % data3 = uint16(bitand(bitshift(data, -16), hex2dec('FFFF')));
    % data4 = uint16(bitand(data, hex2dec('FFFF')));
    
    % Convert uint16 datasets to single
    % data1_single = single(data1);
    % data2_single = single(data2);
    % data3_single = single(data3);
    % data4_single = single(data4);
        % Convert the uint16 datasets to single
    %dataConverted=typecast(data,'single');
     data1_single = single(typecast(uint32(data), 'single'));
    % data2_single = single(typecast(uint16(data2), 'single'));

  end
catch ME
  clear device;
  rethrow(ME);
end

%% clear port

delete(device);
clear device