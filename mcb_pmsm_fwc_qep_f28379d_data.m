% Model         :   PMSM Field Weakening Control with MTPA
% Description   :   Set Parameters for PMSM Field Weakening Control with MTPA
% File name     :   mcb_pmsm_fwc_qep_f28379d_data.m

% Copyright 2020-2022 The MathWorks, Inc.

%% Set PWM Switching frequency
PWM_frequency 	= 20e3;         %Hz         // Converter s/w freq
T_pwm           = 1/PWM_frequency;  %s      // PWM switching time period

%% Set Sample Times
Ts          	= T_pwm;        %sec        // Sample time for control system
Ts_simulink     = T_pwm/2;      %sec        // Simulation time step for model simulation
Ts_motor        = T_pwm/2;      %sec        // Simulation sample time for pmsm
Ts_inverter     = T_pwm/2;      %sec        // Simulation time step for inverter
Ts_speed        = 30*Ts;        %sec        // Sample time for speed controller

%% Set data type for the model (simulation & code-generation)

dataType = 'single';            % Floating point code-generation 
% dataType = fixdt(1,32,24);    % Fixed point code-generation  

%% System Parameters // Hardware parameters 
% Set motor parameters

%pmsm = mcb_SetPMSMMotorParameters('BLY171D');
 pmsm = mcb_SetPMSMMotorParameters('Teknic2310P');

% Set inverter parameters
inverter = mcb_SetInverterParameters('BoostXL-DRV8305');

% Set target hardware parameters
target = mcb_SetProcessorDetails('F28379D',PWM_frequency);
target.SCI_baud_rate    = 12e6;  % Set baud rate for serial communication
target.comport = '<Select a port...>';
 target.comport = 'COM9';       % Uncomment and update the appropriate serial port
%% Calibration section // Uncomment and update relevant parameters

target.ADCCalibEnable   = 1;     % Enable : 1, Disable :0 to Auto-calibrate ADCs

% %Update ADC offsets with manually calibrated values below
% inverter.CtSensAOffset = 2292;
% inverter.CtSensBOffset = 2286;

% %Update QEP position sensor with calibrated value below
% pmsm.PositionOffset     = 0.1282;  %PU position// QEP Offset 
pmsm.PositionOffset     = 0.0865;
% %Update ADC Gain for DRV8305
if pmsm.I_rated < 5
    inverter.ADCGain = 4;   % ADC Range = +- 4.825A wrt 0-4095 counts
    inverter.SPI_Gain_Setting = 0x502A;
    
elseif pmsm.I_rated < 7
    inverter.ADCGain = 2;   % ADC Range = +- 9.650A wrt 0-4095 counts
    inverter.SPI_Gain_Setting = 0x5015;

else     
    inverter.ADCGain = 1;   % ADC Range = +- 19.300A wrt 0-4095 counts       
    inverter.SPI_Gain_Setting = 0x5000;        
    
end

% Voltage output of inverter current sense circuit
inverter.ISenseVoltPerAmp = inverter.ISenseVoltPerAmp * inverter.ADCGain; 

% Update ISenseMax that is measurable by target ADC
inverter.ISenseMax = inverter.ISenseMax * target.ADC_Vref / inverter.ISenseVref;

% Update ISenseMax according to set ADC gain
inverter.ISenseMax = inverter.ISenseMax/inverter.ADCGain;

% Max and min ADC counts for current sense offsets
inverter.CtSensOffsetMax = 2500; % Maximum permitted ADC counts for current sense offset
inverter.CtSensOffsetMin = 1500; % Minimum permitted ADC counts for current sense offset

%% Derive Characteristics
pmsm.N_base = mcb_getBaseSpeed(pmsm,inverter);  %rpm // Base speed of motor at given Vdc
pmsm.N_max  = 2*pmsm.N_base;                    %rpm // Max speed of motor for characteristics

maxMotorCurrent = pmsm.I_rated;                 %Ampere // Maximum current allowed in motor during operation
mcb_getCharacteristics(pmsm,inverter);

%% PU System details // Set base values for pu conversion

PU_System = mcb_SetPUSystem(pmsm,inverter);

%% Controller design 

% IIR Filter for speed
IIR_filter_speed.type           = 'Low-pass';
IIR_filter_speed.min_speed      = 200; %rpm
IIR_filter_speed.f_cutoff       = IIR_filter_speed.min_speed*pmsm.p/(120/2); %Hz
IIR_filter_speed.coeff_Ts       = 2*pi*Ts*IIR_filter_speed.f_cutoff/(2*pi*Ts*IIR_filter_speed.f_cutoff + 1);
IIR_filter_speed.coeff_Ts_speed = 2*pi*Ts_speed*IIR_filter_speed.f_cutoff/(2*pi*Ts_speed*IIR_filter_speed.f_cutoff + 1);
IIR_filter_speed.time_const     = 1/(2*pi*IIR_filter_speed.f_cutoff);
IIR_filter_speed.delay_ss       = 4*IIR_filter_speed.time_const;

% Sensor Delays
Delays.Current_Sensor           = Ts;       %Current Sensor Delay
Delays.Speed_Sensor             = Ts;       %Speed Sensor Delay
Delays.Speed_Filter             = IIR_filter_speed.delay_ss;    %Delay for Speed filter

% Controller Delays
Delays.OM_damping_factor        = 1/sqrt(2);            %Damping factor for current control loop 
Delays.SO_factor_speed          = 1.2;                  %Speed controller delay factor 1 < x < 20

% Get PI Gains
PI_params = mcb_SetControllerParameters(pmsm,inverter,PU_System,T_pwm,Ts,Ts_speed,Delays);

%Updating delays for simulation
PI_params.delay_Currents    = 1;
PI_params.delay_Position    = 1;

% %Uncomment for frequency domain analysis
% mcb_getControlAnalysis(pmsm,inverter,PU_System,PI_params,Ts,Ts_speed);

%% Displaying model variables
disp(pmsm);
disp(inverter);
disp(target);
disp(PU_System);
