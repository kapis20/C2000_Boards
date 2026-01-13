function [f,FT] = NiceFFT(data)
% calculates the Fast Fourier Transform (FFT) of a given signal segment 
% and returns the frequency vector 'f' in (radians per sample) 
% andd the transformed signal FT
N = length(data);
FT = fftshift(fft(data));
if mod(N,2) == 0 % Check if N is even
  index = ceil(-N/2):floor(N/2)-1;
else % N is odd
  index = ceil(-N/2):floor(N/2);
end
%index = ceil(-N/2):floor(N/2)-1;
f = 2*pi*index/N; %normalised w (radians per sample) 

end