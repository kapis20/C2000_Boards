            A = 42;
            B = 3;

            Model = 'Adder';
            %BlockPathA = 'Adder/A';
            %BlockPathB = 'Adder/B';
            %Load the system to memory 
            load_system(Model);

            %specify inputs for the simulation 
            SimIn = Simulink.SimulationInput(Model);
            %syntax to access the model workspace. Whatever was there
            %before will be replaced 
            SimIn = SimIn.setVariable('A',A,'Workspace',Model);
            SimIn = SimIn.setVariable('B',B,'Workspace',Model);
            %in = in.setBlockParameter()
            %simIn = simIn.setBlockParameter(BlockPathA,'A',A);
            %simIn = simIn.setBlockParameter(BlockPathB,'B',B);
            %simIn = setBlockParameter()

            %Simulate model and store the output in out 

            out = sim(SimIn);

            Sum = out.yout{1}.Values.Data;