%% Set up  communication port 
device = serialport("COM9",12e6);
matrixsize = [20, 2];  % Reduced data size for smoother plotting
AllElements = prod(matrixsize);

try
  while true
    data = read(device, AllElements, 'single');

    end
catch ME
  clear device;
  rethrow(ME);
end

%% clear port

delete(device);
clear device