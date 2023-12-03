%clear everything from workspace and console 

clc; 
clear;

%% Names 
Script = 'open_loop_control_script.m';
Model = 'three_phase_Gen_SpeedControl_new';

%% Run the parameter script 

run(Script);

%% Simulink interaction 

load_system(Model);
SimIn = Simulink.SimulationInput(Model);
Sout = sim(SimIn);