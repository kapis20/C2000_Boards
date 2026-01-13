function [MAFFilteredSignal] = MAF_filter(NoisySignal,Lenghts,Passes)
% This function performs moving average filtering with various filter lengths (M)
% and number of passes (N) on noisy segments. It returns the filtered
% signal. It also calculates Mean Square Error (MSE) for corresponding
% signals and Mean Absolute Error (MAE)

%Input 
    %NoisySignal - segment of the Noisy signal 
    %OriginalSig - corresponding segment of the original signal 
    %Lenghts - max number of filter length 
    %Passes - max number of number fo passes 
%Output
%   MAFFilteredSegments - Cell array containing filtered segments (same size as NoisySignal)
%   MSEFiltered - Matrix containing mean squared errors (size NxM)
%   MAEFiltered - MAtrix contatining mean absolute errors (size NxM)


%Initialize Filter cell and MSE cell 
MAFFilteredSignal = cell(Passes,Lenghts);

%get number of elemtns within the signal 
numberofelements = length(NoisySignal);



%loop through filter lenghts M every 2 (odd lenghts)
for M = 1:2:Lenghts
    %Calculate starting index for storing values within cell array
     %middle point
     indx= round(M/2);
     %Calculate element x neeed for MAF appropaite neighbouring
     %locations
      x = indx-1; 
      %Loop through number of passes N

    for N = 1:Passes
        %assign the signal to ensure sizes of arrays are always the same in
        %if statement for else condition
        MAFFilteredSignal{N,M} = NoisySignal;
        %Loop through all datapoints to apply MAF of length M and the
        %number of passes N
        %ignore the x number of points at the boundaries
        for i= indx:numberofelements-x
           
            %first pass use the noisy signal, then each time Filtered
            %signal in the previous pass so N-1 
            if N == 1
                %Calculate the sum of neighbouring M elements and MAF
               
                 MAFFilteredSignal{N,M}(i) = sum(NoisySignal(i-x:i+x))/M;
                % MAFFilteredSignal{N,M}(i) = (NoisySignal(i) + NoisySignal(i+1) + NoisySignal(i+2))/M;
            else
                %Calculate the sum of neighbouring M  elements and MAF for N passes 
                MAFFilteredSignal{N,M}(i) = sum(MAFFilteredSignal{N-1,M}(i-x:i+x))/M;
                % MAFFilteredSignal{N,M}(i) = (MAFFilteredSignal{N-1,M}(i-1) + MAFFilteredSignal{N-1,M}(i)+ MAFFilteredSignal{N-1,M}(i+1))/M;
            end
        end
 

    end
end


       
end
