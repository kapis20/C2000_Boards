% Model         :   Open Loop Control of 3-phase motors
% Description   :   Set Parameters for Open Loop Control of 3-phase motors
% File name     :   mcb_open_loop_control_data.m

% Copyright 2020 The MathWorks, Inc.

load_system('open_loop_for_running');
%% Set parameters from Dashboard selection
PWM_frequency = eval(get_param([bdroot '/Open_loop_control/Parameters/PWM Frequency'], 'Value'));               %Hz   PWM frquency
motor_polePairs     = eval(get_param([bdroot '/Open_loop_control/Parameters/Number of pole pairs'], 'Value'));  %     Pole Pairs for the motor
motor_base_speed    = eval(get_param([bdroot '/Open_loop_control/Parameters/Base Speed'], 'Value'));            %rpm  Rated speed (Synchronous Speed)

selectedDataType = eval(get_param([bdroot '/Open_loop_control/Parameters/Data Type'],'Value'));
if selectedDataType == 0
    dataType = 'single';
else
    dataType = fixdt(1,32,17);
end
clear selectedDataType;

%% Derive paramters for the model
T_pwm           = 1/PWM_frequency;  %[sec] PWM switching time period
Ts          	= T_pwm;            %[sec] Sample time for controller
motor_base_freq     = motor_base_speed*motor_polePairs/60; % Derive motor base frequency

%Target.model                = 'LAUNCHXL-F28379D';	% 		// Manufacturer Model Number
            Target.sn                   = '123456';          	% 		// Manufacturer Serial Number
            Target.CPU_frequency        = 200e6;    			%Hz     // Clock frequency
            Target.PWM_frequency        = PWM_frequency;   		%Hz     // PWM frequency
            Target.PWM_Counter_Period   = round(Target.CPU_frequency/Target.PWM_frequency/2); % //PWM timer counts for up-down counter
            Target.PWM_Counter_Period   = Target.PWM_Counter_Period+mod(Target.PWM_Counter_Period,2); % // Count value needs to be even
            Target.ADC_Vref             = 3;					%V		// ADC voltage reference for LAUNCHXL-F28379D
            Target.ADC_MaxCount         = 4095;					%		// Max count for 12 bit ADC
			Target.SCI_baud_rate        = 12e6;                 %Hz     // Set baud rate for serial communication

