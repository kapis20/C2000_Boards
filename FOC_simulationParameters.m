%% Set PWM Switching frequency
PWM_frequency 	= 20e3;    %Hz          // converter s/w freq need to vary between 16 and 24 kHz 
T_pwm           = 1/PWM_frequency;  %s  // PWM switching time period

%% Set Sample Times
Ts          	= T_pwm;        %sec        // Sample time for control system
Ts_simulink     = T_pwm/2;      %sec        // Simulation time step for model simulation
Ts_motor        = T_pwm/2;      %Sec        // Simulation sample time for pmsm
Ts_inverter     = T_pwm/2;      %sec        // Simulation time step for inverter
Ts_speed        = 20*Ts;            %sec    // Sample time for speed controller

%% Set data type for controller & code-gen needed in the FOC example 
dataType = 'single';        % Floating point code-generation 
% dataType = fixdt(1,32,24);  % Fixed point code-generation  


%% System Parameters // Hardware parameters
% Set motor parameters
pmsm = mcb_SetPMSMMotorParameters('Teknic2310P'); %Our motor 


% Set inverter parameters
inverter = mcb_SetInverterParameters('BoostXL-DRV8301');

% Set target hardware parameters
target = mcb_SetProcessorDetails('F28379D',PWM_frequency);
target.comport = '<Select a port...>';
% target.comport = 'COM3';       % Uncomment and update the appropriate serial port

%% Calibration section // Uncomment and update relevant parameters

% %Update ADC offsets with manually calibrated values below
inverter.CtSensAOffset = 2087;
inverter.CtSensBOffset = 2082;

% %Update ADC offsets with auto-calibrate feature
inverter.ADCOffsetCalibEnable = 1; % Enable: 1, Disable: 0

% Update ADC Gain for DRV8305
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

% Update ISenseMax according to set ADC gain
inverter.ISenseMax = inverter.ISenseMax /inverter.ADCGain;

% Max and min ADC counts for current sense offsets
inverter.CtSensOffsetMax = 2500; % Maximum permitted ADC counts for current sense offset
inverter.CtSensOffsetMin = 1500; % Minimum permitted ADC counts for current sense offset


%% Derive Characteristics
pmsm.N_base = mcb_getBaseSpeed(pmsm,inverter); %rpm // Base speed of motor at given Vdc
% mcb_getCharacteristics(pmsm,inverter);

%% PU System details // Set base values for pu conversion
PU_System = mcb_SetPUSystem(pmsm,inverter);

%% Set Acceleration
acceleration = 20000/PU_System.N_base;                  % P.U/Sec // Maximum allowable acceleraton

%% Open loop reference values
T_Ref_openLoop          = 1;                    % Sec // Time for open-loop start-up
Speed_openLoop_PU       = 0.1;                  % PU  // Per-Unit speed referene for open-loop start-up
Vd_Ref_openLoop_PU      = Speed_openLoop_PU;    % Use 1.2x for Dyno setup and 1x for others

%% Controller design // Get ballpark values!
PI_params = mcb_SetControllerParameters(pmsm,inverter,PU_System,T_pwm,2*Ts,Ts_speed);

% Set SMO parameters
smo = mcb_ComputeSMOParameters(pmsm,Ts,PU_System);

%Updating delays for simulation
PI_params.delay_Currents    = 1; %No of samples delayed for current sensing

% %Uncomment for frequency domain analysis
% mcb_getControlAnalysis(pmsm,inverter,PU_System,PI_params,Ts,Ts_speed);

%% Displaying model variables
disp(pmsm);
disp(inverter);
disp(target);
disp(PU_System);
