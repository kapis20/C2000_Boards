classdef FOC_Control_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Field_Oriented_Control_with_field_weakeningUIFigure  matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        MAFFilterSwitch               matlab.ui.control.Switch
        MAFFilterSwitchLabel          matlab.ui.control.Label
        DatatodisplayButtonGroup      matlab.ui.container.ButtonGroup
        SpeedRefSpeedFeedbackTorquePowerButton  matlab.ui.control.RadioButton
        IdRefIdFeedbackIaIbButton     matlab.ui.control.RadioButton
        SpeedRefSpeedFeedbackIqRefIqFeedbackButton  matlab.ui.control.RadioButton
        FiealdWeakeningControlSwitch  matlab.ui.control.Switch
        FiealdWeakeningControlSwitchLabel  matlab.ui.control.Label
        StopSerialButton              matlab.ui.control.StateButton
        ReceiveSerialButton           matlab.ui.control.StateButton
        SpeedRPMSlider                matlab.ui.control.Slider
        SpeedRPMLabel                 matlab.ui.control.Label
        Tree                          matlab.ui.container.Tree
        SelectCOMPortNode             matlab.ui.container.TreeNode
        Lamp                          matlab.ui.control.Lamp
        TextArea_2                    matlab.ui.control.TextArea
        StopButton                    matlab.ui.control.StateButton
        StartButton                   matlab.ui.control.StateButton
        Image                         matlab.ui.control.Image
        RightPanel                    matlab.ui.container.Panel
        TextArea                      matlab.ui.control.TextArea
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes                        matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)

        SpeedDemand; % property to store speed demand of the motor 
        Operation; %Property to store operation type of motor
        Parameters; %Property to store conversion parameters 
        ProgressFig; %progress fig 
        d; %property for progress bar
        Port; % property to store com port 
        device; %property to store commport 
        enable = 'Enable';
        disable = 'Disable';
        FilteredSignal % property to store filtered MAF signal
    end
    
    methods (Access = private)
        
        function ComPortWarning(app)
            %warning window for invalid input
            opts = struct('WindowStyle','modal',... 
                  'Interpreter','tex');
            f = warndlg('\color{blue}The communication port has not been selected. Please select the appopiate port.',...
                'Invalid Input', opts);
        end
        
        function StartWarning(app)
            %warning window for invalid input
            opts = struct('WindowStyle','modal',... 
                  'Interpreter','tex');
            f = warndlg('\color{blue}Start was not pressed. Please click on Start first.',...
                'Invalid Input', opts);
       end

          function PopulateCOMPorts(app)
            %Function to generate available tree nodes 
            
            %get available ports list 
            FreePorts = serialportlist("available");
            nPorts = length(FreePorts);
            %populate the list if not empty 
            if ~isempty(FreePorts)
                % Clear existing nodes to prevent duplicates
                app.SelectCOMPortNode.Children = [];
               
                for i=1:nPorts
                    newNode(i) = uitreenode(app.SelectCOMPortNode);
                    
                    newNode(i).Text = FreePorts{i};
              
                    
                    
                end                
            else
                    noPortNode = uitreenode('Parent', app.SelectCOMPortNode);
                    noPortNode.Text = "No Ports available";

            end
                
               
                
          end

          function ProgressBar(app, action)
              switch action 
                  case 'open'
                 app.ProgressFig = uifigure('Position',[500,500,400,110], ...
                    'Name','FOC Control - dashboard', ...
                    'WindowStyle','alwaysontop','Icon','sq_logo.png');

                  app.d = uiprogressdlg(app.ProgressFig,'Title', ...
                    'Progress bar', 'Message', ...
                'Loading. Please wait.','Indeterminate','on','Icon','sq_logo.png');
                drawnow
                pause(.5)
                  case 'close'
                      %Close progress bar
             
                        if isvalid(app.d)
                        close(app.d); % Close the progress dialog
                        end
                         if isvalid(app.ProgressFig)
                            close(app.ProgressFig); % Close the figure
                        end
                end
          end

          function DataReceive(app,title1,title2,ylabel1,ylabel2,legend1,legend2, legend3, legend4, Par1, Par2, Par3, Par4,Mode)
              %initialize com port
              device = serialport(app.Port,12e6);
              %Initialize empty arrays for Data
              data1 = [];
              data2 =[];
              data3 =[];
              data4 = [];

              %set a value for x axises
              timex = 'Time (s)';

              %Initialize plit with two empty lines
              Plot1 = plot(app.UIAxes,NaN,NaN, NaN,NaN)
              title(app.UIAxes,title1);
              xlabel(app.UIAxes,timex);
              ylabel(app.UIAxes,ylabel1);
              legend(app.UIAxes,legend1,legend2);

              %Second graph:
              Plot2 = plot(app.UIAxes2,NaN,NaN, NaN,NaN);
              title(app.UIAxes2,title2);
              xlabel(app.UIAxes2,timex);
              ylabel(app.UIAxes2,ylabel2);
              legend(app.UIAxes2,legend3,legend4);

              %inverse scaling factor 
              inverse_Scaling_Factor =  single(uint32(4294967295)) / single(uint16(65535));
              %Predifine the time vector for 600 samples 
              Samples = 600;
              sampleInterval = 50e-6;% 50microseconds
              xData = (0:Samples-1)*sampleInterval;

              try 
                  while true 
                      %read serial
                      data = read(device, 600, 'uint32');
                      Tempdata = data;
                      % Shift right by 16 bits to get upper 16 bits
                      output1 = uint16(bitshift(Tempdata, -16)); 
                      % Extract the low 16 bits
                      output2 = uint16(bitand(uint32(Tempdata), uint32(65535))); 

                      %Convert back to uint32
                      uint32_value_restored1 = uint32(single(output1) * inverse_Scaling_Factor);
                      uint32_value_restored2 = uint32(single(output2) * inverse_Scaling_Factor);

                      %convert to single precision
                      Singleval1 = single(typecast(uint32(uint32_value_restored1), 'single'));
                      Singleval2 = single(typecast(uint32(uint32_value_restored2), 'single'));

                      %apply the appropaite parameters to read the values 
                      data1 = [data1, Singleval1(1:2:end).* Par1];
                      data2 = [data2, Singleval1(2:2:end).* Par2];
                      data3 = [data3, Singleval2(1:2:end).* Par3];
                      data4 = [data4, Singleval2(2:2:end).* Par4];

                      %Check if the MAF filter is enabled 
                      tf = strcmp(app.MAFFilterSwitch.Value,app.enable);
                      if tf 
                          %based on the mode select the Filter parameters
                          switch Mode
                              case 1
                                  MAF_filter1(app,data2,19,5);
                                  data2 = app.FilteredSignal{5,19};
                              case 2
                                  MAF_filter1(app,data3,5,3);
                                  data3 = app.FilteredSignal{2,5};

                                  MAF_filter1(app,data4,5,3);
                                  data4 = app.FilteredSignal{2,5};
                              case 3
                                  MAF_filter1(app,data2,19,5);
                                  data2 = app.FilteredSignal{5,19};
                          end
                      end



                      


                      %if statement to ensure we have 600 samples
                      if numel(data1) >500
                         set(Plot1(1),'XData', xData, 'YData', data1);
                         set(Plot1(2),'XData', xData, 'YData', data2);
                         set(Plot2(1),'XData', xData, 'YData', data3);
                         set(Plot2(2),'XData', xData, 'YData', data4);

                         %update the plots 
                         drawnow;
                         %clear datahoders
                         data1 = [];
                         data2 = [];
                         data3 = [];
                         data4 = [];
                      end
                      %check the value of a stop button, if pressed
                      %terminate serial communication 
                      if app.StopSerialButton.Value == 1
                          %stop serial communication
                          fclose(device);
                          delete(device);
                          clear device;
                          break; %Exit the loop 
                      end
                  end
              catch ME
                  delete(device);
                  clear device;
                  rethrow(ME);
              end

          end

          function MAF_filter1(app, NoisySignal, Lenghts, Passes)
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

                app.FilteredSignal = MAFFilteredSignal;



          end


                

       
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
               ProgressBar(app,'open');
               %populate all com ports beforehand
               PopulateCOMPorts(app)
              %Load parameters list - run the script and store them before
              %app is opened
                run("mcb_pmsm_fwc_qep_f28379d_data.m");
                app.Parameters = PU_System;
                %default operation (before any mode is selected) 
                app.Operation = 19;
                %close progress bar
                ProgressBar(app,'close');
               
        end

        % Value changed function: StartButton
        function StartButtonValueChanged(app, event)
             % This function is triggered whenever the StartButton's state changes.
             % Retrieve the current value of the StartButton (true if pressed)
            value = app.StartButton.Value;
            %Value to check whether the stop button was pressed
            Red = [1 0 0]; %red
              % Check if the StartButton is currently pressed (value is true)
            if value 
                if ~isempty(app.device)
                    if app.Lamp.Color == Red;
                            app.Operation = app.Operation +1;
                    end
                  
                    Message = [app.SpeedDemand,app.Operation];
                    write(app.device,Message,'single');
                    app.Lamp.Color = 'green';
                    %reset the StartButton's value to false after operations are complete
                    app.StartButton.Value = false;
                else
                % Check if the 'Port' property is not empty, indicating a
                % Port is selected
                    if ~isempty(app.Port)
                        %check if serialport is empty
                        %set up Com port 
                        device = serialport(app.Port,12e6);
                        
                        
                         
                        % Prepare the message to send to the device
                        % Concatenating SpeedDemand and Operation into a single array
    
                        %check if the stop button was pressed and add 1 to
                        %operation so the motor can spin again
                        
                        if app.Lamp.Color == Red;
                            app.Operation = app.Operation +1;
                        end
                        Message = [app.SpeedDemand,app.Operation]
                        % Send the prepared message to the connected device
                         write(device,Message,'single');
                         
                        % Change the lamp color to green indicating successful operation
                        app.Lamp.Color = 'green';
                        %reset the StartButton's value to false after operations are complete
                        app.StartButton.Value = false;
                        
                        %clear port
                        delete(device);
                        clear device;
                        
                    else
                        % If no device is connected, call the ComPortWarning function
                        % This function likely displays a warning message to the user
                        ComPortWarning(app);
                        % Change the lamp color to yellow indicating a warning or issue
                        app.Lamp.Color = 'yellow';
                        %reset the StartButton's value to false after operations are complete
                        app.StartButton.Value = false;
                    end
                end
            end
            
        end

        % Value changed function: StopButton
        function StopButtonValueChanged(app, event)
            value = app.StopButton.Value;
            if value 
                if ~isempty(app.device)
                    app.Operation = single(app.Operation-1);
                    Message = [0;app.Operation];
                    write(app.device,Message,'single');
                    app.Lamp.Color = 'red';
                else
                    % Check if the 'device' property is not empty, indicating a device is connected
                    if ~isempty(app.Port)
                        %set up communication port
                        device = serialport(app.Port,12e6)
                        %change operation
                        app.Operation = single(app.Operation-1);
                     
                        % Prepare the message to send to the device
                        %Concencanate speed and operation - just in case 0 
                        Message = [0;app.Operation];
                        % Send the prepared message to the connected device
                        write(device,Message,'single');
                        % Change the lamp color to green indicating successful operation
                        app.Lamp.Color = 'red';
                        %reset the StopButton's value to false after operations are complete
                        app.StopButton.Value = false;
                         %clear port
                        delete(device);
                        clear device;
                    else
                         
                        % If no device is connected, call the ComPortWarning function
                        % This function likely displays a warning message to the user
                        ComPortWarning(app);
                        app.Lamp.Color = 'yellow';
                        %reset the StopButton's value to false after operations are complete
                        app.StopButton.Value = false;
                    end
                end
            end
        end

        % Clicked callback: Tree
        function TreeClicked(app, event)
            
            MainRoot = 'Select COM Port:';
            %get the value of selected node
            node = event.InteractionInformation.Node;
            % %Genarate nodes based on the available COM ports
            % PopulateCOMPorts(app);
            %compare the selected node and MainRoot
            tf = strcmp(node.Text,MainRoot);

            % Generate nodes based on the available COM ports only if they haven't been populated yet
            if tf && isempty(node.Children)  % Check if main root node has no children
                PopulateCOMPorts(app);
            end
            %if the port was selected then establish serial communication
            if ~tf
                % Save com port
                app.Port = node.Text;
                %app.device = serialport(node.Text,12e6);
                 app.Lamp.Color = 'blue';
            end
        end

        % Value changed function: SpeedRPMSlider
        function SpeedRPMSliderValueChanged(app, event)
            %Value to check if start was pressed 
            Start = [0 1 0]; %green 
            Red = [1 0 0]; %red
         
            %Get speed demand and convert it to single 
            app.SpeedDemand = single(app.SpeedRPMSlider.Value);

            %conversion needed for sending 
            ConversionFactor = 1/ app.Parameters.N_base;  
            %Create a message for speed demand 
            app.SpeedDemand = app.SpeedDemand * ConversionFactor;

            %check if start was arleady pressed and write messege to com
            %port here 

            if app.Lamp.Color == Start 
                % Check if the 'Port' property is not empty, indicating a
                % Port is selected
   
                    if ~isempty(app.Port)
                        %set up coms 
                        device = serialport(app.Port,12e6)
                        % Prepare the message to send to the device
                        % Concatenating SpeedDemand and Operation into a single array
                                   
                        Message = [app.SpeedDemand,app.Operation];
                        % Send the prepared message to the connected device
                         write(device,Message,'single');
                                       
                        %clear port
                         delete(device);
                         clear device;
                        
                    else
                        % If no device is connected, call the ComPortWarning function
                        % This function likely displays a warning message to the user
                        ComPortWarning(app);
                        % Change the lamp color to yellow indicating a warning or issue
                        app.Lamp.Color = 'yellow';
    
                    end
                
            elseif app.Lamp.Color == Red
                    %ensure that operation mode is correct 
                    app.Operation = app.Operation+1;
                    %If start was not pressed - print out a warnign 
                    StartWarning(app);
                     % Change the lamp color to yellow indicating a warning or issue
                    app.Lamp.Color = 'yellow';
      
                    
            else

                    %  If start was not pressed - print out a warnign 
                    StartWarning(app);
                     % Change the lamp color to yellow indicating a warning or issue
                    app.Lamp.Color = 'yellow';
            end

                
           
         
        end

        % Value changed function: ReceiveSerialButton
        function ReceiveSerialButtonValueChanged(app, event)
            %Just in case change stop value to 0 
            app.StopSerialButton.Value = false;
            %if statement to ensure the right options are sent to coms for
            %display
            if (app.Operation == 19 || app.Operation == 17)
                title1 = 'Speed Reference & Speed Feedback';
                title2 = 'Iq Ref and Iq Feedback';

                ylabel1 = 'Speed (RPM)';
                ylabel2 = 'Current (A)';

                legend1 = 'SpeedRef';
                legend2 = 'SpeedFeed';
                legend3 = 'Iq Ref';
                legend4 = 'Iq Feed';

                Par1 = app.Parameters.N_base;
                Par2 = app.Parameters.N_base;
                Par3 = app.Parameters.I_base;
                Par4 = app.Parameters.I_base;

                Mode = 1; %for MAF filter if selected 
            elseif (app.Operation == 35 || app.Operation == 33)
                title1 = 'Id Ref and Id Feedback';
                title2 = 'Ia & Ib';

                ylabel1 = 'Current (A)';
                ylabel2 = ylabel1;

                legend1 = 'Id Ref';
                legend2 = 'Id Feed';
                legend3 = 'Ia';
                legend4 = 'Ib';

                Par1 = app.Parameters.I_base;
                Par2 = Par1;
                Par3 = Par1;
                Par4 = Par1;

                Mode = 2;
            elseif (app.Operation == 51 || app.Operation == 49)
                title1 = 'Speed Reference & Speed Feedback';
                title2 = 'Torque & Power';
              
                ylabel1 = 'Speed (RPM)';
                ylabel2 = '';   %empty string

                legend1 = 'SpeedRef';
                legend2 = 'SpeedFeed';
                legend3 = 'Torque';
                legend4 = 'Power';

                Par1 = app.Parameters.N_base;
                Par2 = Par1;
                Par3 = app.Parameters.T_base;
                Par4 = app.Parameters.P_base;

                Mode = 3;

            end
            DataReceive(app,title1,title2,ylabel1,ylabel2,legend1,legend2,legend3,legend4,Par1,Par2,Par3,Par4,Mode)
            %DataReceive(app);

          
        end

        % Value changed function: StopSerialButton
        function StopSerialButtonValueChanged(app, event)
         %Unselect Receive Serial button
            app.ReceiveSerialButton.Value = false; 
            
        end

        % Value changed function: FiealdWeakeningControlSwitch
        function FiealdWeakeningControlSwitchValueChanged(app, event)
            %anly called when value is changed so operation will be always right  
            %check the value of enable button 
              tf = strcmp(app.FiealdWeakeningControlSwitch.Value,app.disable);
              if tf
                 %if disable substract two from operation to send
                 %the right message 
                 app.Operation =app.Operation -2;
              else 
                  %add two back once changed 
                  app.Operation = app.Operation +2;
              end
        end

        % Selection changed function: DatatodisplayButtonGroup
        function DatatodisplayButtonGroupSelectionChanged(app, event)
            Start = [0 1 0]; %green for lamp
            selectedButton = app.DatatodisplayButtonGroup.SelectedObject;
               %selectedButton = app.DatatodisplayButtonGroup.SelectedObject;
            % options for different modes 
            Mode1 = 'SpeedRef, SpeedFeedback & IqRef, IqFeedback';
            Mode2 = 'IdRef, IdFeedback & Ia, Ib';
            Mode3 = 'SpeedRef, SpeedFeedback & Torque, Power';
          
            % if statement to write appropiate operation message that will 
            % be then sent to the C2000 board (field weakening by default)
            if strcmp(selectedButton.Text,Mode1)
                app.Operation =19;
            elseif strcmp(selectedButton.Text, Mode2)
                app.Operation = 35;
            elseif strcmp(selectedButton.Text,Mode3)
                app.Operation = 51;
            end

            if app.Lamp.Color == Start;
                
                    if ~isempty(app.Port)
                        %set up coms 
                        device = serialport(app.Port,12e6)
                        % Prepare the message to send to the device
                        % Concatenating SpeedDemand and Operation into a single array
                                   
                        Message = [app.SpeedDemand,app.Operation];
                        % Send the prepared message to the connected device
                         write(device,Message,'single');
                                       
                        %clear port
                         delete(device);
                         clear device;
                        
                    else
                        % If no device is connected, call the ComPortWarning function
                        % This function likely displays a warning message to the user
                        ComPortWarning(app);
                        % Change the lamp color to yellow indicating a warning or issue
                        app.Lamp.Color = 'yellow';
                      
    
                    end
            elseif app.Lamp.Color == Red
                    %ensure that operation mode is correct 
                    app.Operation = app.Operation+1;
                    %If start was not pressed - print out a warnign 
                    StartWarning(app);
                     % Change the lamp color to yellow indicating a warning or issue
                    app.Lamp.Color = 'yellow';
      
                    
            else

                    %  If start was not pressed - print out a warnign 
                    StartWarning(app);
                     % Change the lamp color to yellow indicating a warning or issue
                    app.Lamp.Color = 'yellow';
            end
            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.Field_Oriented_Control_with_field_weakeningUIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {700, 700};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {368, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Field_Oriented_Control_with_field_weakeningUIFigure and hide until all components are created
            app.Field_Oriented_Control_with_field_weakeningUIFigure = uifigure('Visible', 'off');
            app.Field_Oriented_Control_with_field_weakeningUIFigure.AutoResizeChildren = 'off';
            app.Field_Oriented_Control_with_field_weakeningUIFigure.Position = [100 100 996 700];
            app.Field_Oriented_Control_with_field_weakeningUIFigure.Name = 'Field_Oriented_Control_with_field_weakening';
            app.Field_Oriented_Control_with_field_weakeningUIFigure.Icon = 'sq_logo.jpg';
            app.Field_Oriented_Control_with_field_weakeningUIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Field_Oriented_Control_with_field_weakeningUIFigure);
            app.GridLayout.ColumnWidth = {368, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.BackgroundColor = [0.5412 0.1686 0.8902];
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create Image
            app.Image = uiimage(app.LeftPanel);
            app.Image.Position = [7 630 161 64];
            app.Image.ImageSource = 'snapedit_1714763450173-removebg-preview (2).png';

            % Create StartButton
            app.StartButton = uibutton(app.LeftPanel, 'state');
            app.StartButton.ValueChangedFcn = createCallbackFcn(app, @StartButtonValueChanged, true);
            app.StartButton.Text = 'Start';
            app.StartButton.BackgroundColor = [0 1 0];
            app.StartButton.FontSize = 18;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.Position = [48 538 100 38];

            % Create StopButton
            app.StopButton = uibutton(app.LeftPanel, 'state');
            app.StopButton.ValueChangedFcn = createCallbackFcn(app, @StopButtonValueChanged, true);
            app.StopButton.Text = 'Stop';
            app.StopButton.BackgroundColor = [1 0 0];
            app.StopButton.FontSize = 18;
            app.StopButton.FontWeight = 'bold';
            app.StopButton.Position = [216 539 100 37];

            % Create TextArea_2
            app.TextArea_2 = uitextarea(app.LeftPanel);
            app.TextArea_2.HorizontalAlignment = 'center';
            app.TextArea_2.FontSize = 36;
            app.TextArea_2.FontWeight = 'bold';
            app.TextArea_2.FontColor = [1 1 1];
            app.TextArea_2.BackgroundColor = [0.5412 0.1686 0.8902];
            app.TextArea_2.Position = [83 598 211 96];
            app.TextArea_2.Value = {'Control Panel:'};

            % Create Lamp
            app.Lamp = uilamp(app.LeftPanel);
            app.Lamp.Position = [169 542 30 30];
            app.Lamp.Color = [1 1 1];

            % Create Tree
            app.Tree = uitree(app.LeftPanel);
            app.Tree.FontSize = 16;
            app.Tree.ClickedFcn = createCallbackFcn(app, @TreeClicked, true);
            app.Tree.Position = [73 405 219 105];

            % Create SelectCOMPortNode
            app.SelectCOMPortNode = uitreenode(app.Tree);
            app.SelectCOMPortNode.Text = 'Select COM Port:';

            % Create SpeedRPMLabel
            app.SpeedRPMLabel = uilabel(app.LeftPanel);
            app.SpeedRPMLabel.HorizontalAlignment = 'center';
            app.SpeedRPMLabel.FontSize = 14;
            app.SpeedRPMLabel.FontColor = [1 1 1];
            app.SpeedRPMLabel.Position = [140 376 90 22];
            app.SpeedRPMLabel.Text = 'Speed (RPM)';

            % Create SpeedRPMSlider
            app.SpeedRPMSlider = uislider(app.LeftPanel);
            app.SpeedRPMSlider.Limits = [-6000 6000];
            app.SpeedRPMSlider.ValueChangedFcn = createCallbackFcn(app, @SpeedRPMSliderValueChanged, true);
            app.SpeedRPMSlider.FontSize = 14;
            app.SpeedRPMSlider.FontColor = [1 1 1];
            app.SpeedRPMSlider.Position = [36 358 310 3];

            % Create ReceiveSerialButton
            app.ReceiveSerialButton = uibutton(app.LeftPanel, 'state');
            app.ReceiveSerialButton.ValueChangedFcn = createCallbackFcn(app, @ReceiveSerialButtonValueChanged, true);
            app.ReceiveSerialButton.Text = 'Receive Serial';
            app.ReceiveSerialButton.BackgroundColor = [0 1 0];
            app.ReceiveSerialButton.FontSize = 18;
            app.ReceiveSerialButton.FontWeight = 'bold';
            app.ReceiveSerialButton.Position = [30 201 137 30];

            % Create StopSerialButton
            app.StopSerialButton = uibutton(app.LeftPanel, 'state');
            app.StopSerialButton.ValueChangedFcn = createCallbackFcn(app, @StopSerialButtonValueChanged, true);
            app.StopSerialButton.Text = 'Stop Serial';
            app.StopSerialButton.BackgroundColor = [1 0 0];
            app.StopSerialButton.FontSize = 18;
            app.StopSerialButton.FontWeight = 'bold';
            app.StopSerialButton.Position = [217 201 109 30];

            % Create FiealdWeakeningControlSwitchLabel
            app.FiealdWeakeningControlSwitchLabel = uilabel(app.LeftPanel);
            app.FiealdWeakeningControlSwitchLabel.HorizontalAlignment = 'center';
            app.FiealdWeakeningControlSwitchLabel.FontSize = 14;
            app.FiealdWeakeningControlSwitchLabel.FontWeight = 'bold';
            app.FiealdWeakeningControlSwitchLabel.FontColor = [1 1 1];
            app.FiealdWeakeningControlSwitchLabel.Position = [96 250 177 22];
            app.FiealdWeakeningControlSwitchLabel.Text = 'Fieald Weakening Control';

            % Create FiealdWeakeningControlSwitch
            app.FiealdWeakeningControlSwitch = uiswitch(app.LeftPanel, 'slider');
            app.FiealdWeakeningControlSwitch.Items = {'Disable', 'Enable'};
            app.FiealdWeakeningControlSwitch.ValueChangedFcn = createCallbackFcn(app, @FiealdWeakeningControlSwitchValueChanged, true);
            app.FiealdWeakeningControlSwitch.FontSize = 14;
            app.FiealdWeakeningControlSwitch.FontWeight = 'bold';
            app.FiealdWeakeningControlSwitch.FontColor = [1 1 1];
            app.FiealdWeakeningControlSwitch.Position = [160 287 45 20];
            app.FiealdWeakeningControlSwitch.Value = 'Enable';

            % Create DatatodisplayButtonGroup
            app.DatatodisplayButtonGroup = uibuttongroup(app.LeftPanel);
            app.DatatodisplayButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @DatatodisplayButtonGroupSelectionChanged, true);
            app.DatatodisplayButtonGroup.Title = 'Data to display:';
            app.DatatodisplayButtonGroup.BackgroundColor = [1 1 1];
            app.DatatodisplayButtonGroup.FontWeight = 'bold';
            app.DatatodisplayButtonGroup.FontSize = 14;
            app.DatatodisplayButtonGroup.Position = [29 93 310 95];

            % Create SpeedRefSpeedFeedbackIqRefIqFeedbackButton
            app.SpeedRefSpeedFeedbackIqRefIqFeedbackButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.SpeedRefSpeedFeedbackIqRefIqFeedbackButton.Text = 'SpeedRef, SpeedFeedback & IqRef, IqFeedback';
            app.SpeedRefSpeedFeedbackIqRefIqFeedbackButton.FontWeight = 'bold';
            app.SpeedRefSpeedFeedbackIqRefIqFeedbackButton.Position = [11 49 297 22];
            app.SpeedRefSpeedFeedbackIqRefIqFeedbackButton.Value = true;

            % Create IdRefIdFeedbackIaIbButton
            app.IdRefIdFeedbackIaIbButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.IdRefIdFeedbackIaIbButton.Text = 'IdRef, IdFeedback & Ia, Ib';
            app.IdRefIdFeedbackIaIbButton.FontWeight = 'bold';
            app.IdRefIdFeedbackIaIbButton.Position = [11 27 167 22];

            % Create SpeedRefSpeedFeedbackTorquePowerButton
            app.SpeedRefSpeedFeedbackTorquePowerButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.SpeedRefSpeedFeedbackTorquePowerButton.Text = 'SpeedRef, SpeedFeedback & Torque, Power';
            app.SpeedRefSpeedFeedbackTorquePowerButton.FontWeight = 'bold';
            app.SpeedRefSpeedFeedbackTorquePowerButton.Position = [11 5 276 22];

            % Create MAFFilterSwitchLabel
            app.MAFFilterSwitchLabel = uilabel(app.LeftPanel);
            app.MAFFilterSwitchLabel.HorizontalAlignment = 'center';
            app.MAFFilterSwitchLabel.FontSize = 14;
            app.MAFFilterSwitchLabel.FontWeight = 'bold';
            app.MAFFilterSwitchLabel.FontColor = [1 1 1];
            app.MAFFilterSwitchLabel.Position = [147 9 73 22];
            app.MAFFilterSwitchLabel.Text = 'MAF Filter';

            % Create MAFFilterSwitch
            app.MAFFilterSwitch = uiswitch(app.LeftPanel, 'slider');
            app.MAFFilterSwitch.Items = {'Disable', 'Enable'};
            app.MAFFilterSwitch.FontSize = 14;
            app.MAFFilterSwitch.FontWeight = 'bold';
            app.MAFFilterSwitch.FontColor = [1 1 1];
            app.MAFFilterSwitch.Position = [160 46 45 20];
            app.MAFFilterSwitch.Value = 'Disable';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.BackgroundColor = [0.5412 0.1686 0.8902];
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [65 336 520 279];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.RightPanel);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [64 43 520 273];

            % Create TextArea
            app.TextArea = uitextarea(app.RightPanel);
            app.TextArea.Editable = 'off';
            app.TextArea.HorizontalAlignment = 'center';
            app.TextArea.FontSize = 36;
            app.TextArea.FontWeight = 'bold';
            app.TextArea.FontColor = [1 1 1];
            app.TextArea.BackgroundColor = [0.5412 0.1686 0.8902];
            app.TextArea.Position = [4 636 621 58];
            app.TextArea.Value = {' FOC with field weakening'};

            % Show the figure after all components are created
            app.Field_Oriented_Control_with_field_weakeningUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = FOC_Control_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Field_Oriented_Control_with_field_weakeningUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Field_Oriented_Control_with_field_weakeningUIFigure)
        end
    end
end