%clear everything from workspace and console 

clc; 
clear;

%% Names 
Script = 'open_loop_control_script.m';
Model = 'three_phase_Gen_SpeedControl_new';
SubSystem = 'three_phase_Gen_SpeedControl_new/Open_loop_control'

%% Run the parameter script 
load_system(Model);
open_system(SubSystem);
run(Script);
close_system(Model);

%% Simulink interaction 

%load_system(Model);
SimIn = Simulink.SimulationInput(Model);
Sout = sim(SimIn);
Test = Target;