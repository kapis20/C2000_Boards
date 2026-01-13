classdef MotorControl_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MotorControlUIFigure         matlab.ui.Figure
        TabGroup                     matlab.ui.container.TabGroup
        ModelInfoTab                 matlab.ui.container.Tab
        ForcomportButton             matlab.ui.control.StateButton
        Tree                         matlab.ui.container.Tree
        SelectCOMPortNode            matlab.ui.container.TreeNode
        StartButton                  matlab.ui.control.StateButton
        DatatodisplayButtonGroup     matlab.ui.container.ButtonGroup
        DummybuttonButton            matlab.ui.control.RadioButton
        IaPositionButton             matlab.ui.control.RadioButton
        IaIbButton                   matlab.ui.control.RadioButton
        IqrefIqfeedbackButton        matlab.ui.control.RadioButton
        IdrefIdfeedbackButton        matlab.ui.control.RadioButton
        SpeedrefSpeedfeedbackButton  matlab.ui.control.RadioButton
        SpeedRPMEditField            matlab.ui.control.NumericEditField
        SpeedRpmLabel                matlab.ui.control.Label
        StopButton                   matlab.ui.control.Button
        SpeedRPMSlider               matlab.ui.control.Slider
        SpeedRPMSliderLabel          matlab.ui.control.Label
        MotorButtonGroup             matlab.ui.container.ButtonGroup
        DummyButton                  matlab.ui.control.ToggleButton
        IMMotorButton                matlab.ui.control.ToggleButton
        PMMotorButton                matlab.ui.control.ToggleButton
        DiagnosticsTab               matlab.ui.container.Tab
        UIAxes                       matlab.ui.control.UIAxes
        MotorControlPanel            matlab.ui.container.Panel
        Image_4                      matlab.ui.control.Image
        Image_3                      matlab.ui.control.Image
        Image_2                      matlab.ui.control.Image
    end

    
    properties (Access = private)
        ProgressFig; 
        d;
        SpeedDemand;
        Operation;
        device;
        NewNode;
        Parameters;
       
    end
    
    methods (Access = private)
        
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

        function PopulateCOMPorts(app)
            %Function to generate available tree nodes 

            %get available ports list 
            FreePorts = serialportlist("available");
            %populate the list if not empty 
            if ~isempty(FreePorts)
                for i=1:length(FreePorts)
                    app.NewNode{i} = uitreenode(app.SelectCOMPortNode);
                    app.NewNode{i}.Text = FreePorts{i};
                    %newNode = uitreenode('Text',FreePorts{i});
                    %app.SelectCOMPortNode.add(newNode);

                    
                end
            else
                    app.NewNode{1} = uitreenode(app.SelectCOMPortNode);
                    app.NewNode{1}.Text = "No Ports available";


            end



        end



        function ComPortWarning(app)
                %warning window for invalid input
            opts = struct('WindowStyle','modal',... 
                  'Interpreter','tex');
            f = warndlg('\color{blue}The communication port has not been selected. Please select the appopiate port.',...
                'Invalid Input', opts);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            ProgressBar(app,'open');
            run("mcb_pmsm_foc_qep_f28379d_data_11.m");
            app.Parameters = PU_System;
            %default operation (before any mode is selected) 
            
            %close progress bar
            ProgressBar(app,'close');
        end

        % Selection changed function: MotorButtonGroup
        function MotorButtonGroupSelectionChanged(app, event)
            selectedButton = app.MotorButtonGroup.SelectedObject;
            %buttons
            Motor1 = 'PM Motor';
            Motor2 = 'IM Motor';
            
             tf = strcmp(selectedButton.Text,Motor1);
             tf1 = strcmp(selectedButton.Text,Motor2);

           
            % Set up communication port
            %app.device = serialport("COM7",5e6);
            % Enable the operation and create a message
            % app.Operation = single(17);
            % 
            % 
            % Message = [app.SpeedDemand,app.Operation];
            % 
            % 
            % 
            % tf = strcmp(selectedButton.Text,Motor1);
            % tf1 = strcmp(selectedButton.Text,Motor2);
            % 
            if tf 
                %Load parameters list - run the script and store them in
                %the property 
                % run("FOC_Param.m");
                % app.Parameters = PU_System;
                %write(app.device,Message,'uint16');
                % app.PMMotorButton.Value = false;
                % app.DummyButton.Value = true;
                % if ~isempty(app.device)
                %    write(app.device,Message,'single');
                % else
                %      ComPortWarning(app);
                % end
                x =2;

            elseif tf1
                %placeholder for IM motor control
                a = 2;
                app.IMMotorButton.Value = false;
                app.DummyButton.Value = true;
            end


        end

        % Value changed function: SpeedRPMEditField
        function SpeedRPMEditFieldValueChanged(app, event)
            %get the speed demand and convert the value
            app.SpeedDemand = single(app.SpeedRPMEditField.Value);
            ConversionFactor = 1/ app.Parameters.N_base;  
            app.SpeedDemand = app.SpeedDemand * ConversionFactor;
            
        end

        % Value changed function: SpeedRPMSlider
        function SpeedRPMSliderValueChanged(app, event)
            app.SpeedDemand = single(app.SpeedRPMSlider.Value);

            %conversion 
            ConversionFactor = 1/ app.Parameters.N_base;  
            %app.SpeedDemand = app.SpeedDemand *1/4107;
            app.SpeedDemand = app.SpeedDemand * ConversionFactor;
       
           
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            
            %change operation
            app.Operation = single(app.Operation-1);
            %just in case set speed to 0
            app.SpeedDemand = single(0);

            Message = [app.SpeedDemand;app.Operation];

            write(app.device,Message,'single');
            %flush(app.device);
        end

        % Button down function: DiagnosticsTab
        function DiagnosticsTabButtonDown(app, event)
            matrixsize = [20,2];
            AllElements = prod(matrixsize);
            % Initialize empty arrays for DataA and DataB
            DataA = [];
            DataB = [];
            %Data receive 
            % Set up the figure and axis
        
              switch app.Operation
                  case 17
                      %Initialize plit with two empty lines
                      SpeedPlot =plot(app.UIAxes,NaN(matrixsize(1), 2));
                      title(app.UIAxes,'Speed Reference & Speed Feedback');
                      xlabel(app.UIAxes,'Time (s)');
                      ylabel(app.UIAxes,'Speed (RPM)');
                      legend(app.UIAxes,'SpeedRef', 'SpeedFeed');
                      % %Predifine the time vector for 600 samples 
                      % Samples = 600;
                      % sampleInterval = 50e-6;% 50microseconds
                      % xData = (0:Samples-1)*sampleInterval;
                
                      %loop for receiving the data 
                      try 
                          while true
                              data = read(app.device, AllElements, 'single');
                              startTime = datetime('now');
                           

                                % Extract DataA and DataB from received data and concatenate with existing arrays
                               
                                DataA = [DataA, data(1:2:end) .* app.Parameters.N_base];
                                DataB = [DataB, data(2:2:end) .* app.Parameters.N_base];

                                %if loop to display many stored data points
                                %at once so the graph makes sense 
                                if numel(DataA) == 2100
                                    %Clear data out of noise 
                                    DataA = rmoutliers(DataA);
                                    DataB = rmoutliers(DataB);


                                    % Calculate elapsed time
                                    currentTime = datetime('now');
                                    elapsedTime = seconds(currentTime - startTime);
                                    %Generate time points for the x-axis
                                    xData = linspace(0, elapsedTime, numel(DataA));

                                    set(SpeedPlot(1), 'XData', xData, 'YData', DataA);
                                    set(SpeedPlot(2), 'XData', xData, 'YData', DataB);

                                    drawnow;
                                    pause(0.05);  % Adjust pause time as needed
                                    DataA = [];
                                    DataB = [];

                                end
                          end
                      catch ME
                          %clear app.device;
                          rethrow(ME);
                      end



                  case 33
                      Idplot =plot(app.UIAxes,NaN(matrixsize(1), 2));
                      title(app.UIAxes,'Id reference & Id feedback');
                      xlabel(app.UIAxes,'Time (s)');
                      ylabel(app.UIAxes,'Current (A)');
                      legend(app.UIAxes,'Id Ref', 'Id Feed');
                        % Samples = 600;
                        % sampleInterval = 50e-6;% 50microseconds
                        % xData = (0:Samples-1)*sampleInterval;
                     try 
                          while true
                              data = read(app.device, AllElements, 'single');
                              startTime = datetime('now');

                                % Extract DataA and DataB from received data and concatenate with existing arrays
                               
                                DataA = [DataA, data(1:2:end) .* app.Parameters.I_base];
                                DataB = [DataB, data(2:2:end) .* app.Parameters.I_base];

                                %if loop to display many stored data points
                                %at once so the graph makes sense 
                                if numel(DataA) == 2100
                                    %Clear data out of noise 
                                    DataA = rmoutliers(DataA);
                                    DataB = rmoutliers(DataB);


                                    %Calculate elapsed time
                                    currentTime = datetime('now');
                                    elapsedTime = seconds(currentTime - startTime);
                                    % Generate time points for the x-axis
                                    xData = linspace(0, elapsedTime, numel(DataA));

                                    set(Idplot(1), 'XData', xData, 'YData', DataA);
                                    set(Idplot(2), 'XData', xData, 'YData', DataB);

                                    drawnow;
                                    pause(0.05);  % Adjust pause time as needed
                                    DataA = [];
                                    DataB = [];
                                end

                         end
                       
                      catch ME
                          %clear app.device;
                          rethrow(ME);
                      end

                  case 49
                      Iqplot =plot(app.UIAxes,NaN(matrixsize(1), 2));
                      title(app.UIAxes,'Iq reference & Iq feedback');
                      xlabel(app.UIAxes,'Time (s)');
                      ylabel(app.UIAxes,'Current (A)');
                      legend(app.UIAxes,'Iq Ref', 'Iq Feed');

                      %Predifine the time vector for 600 samples 
                      % Samples = 600;
                      % sampleInterval = 50e-6;% 50microseconds
                      % xData = (0:Samples-1)*sampleInterval;

                      try 
                          while true
                              data = read(app.device, AllElements, 'single');
                              % startTime = datetime('now');

                                % Extract DataA and DataB from received data and concatenate with existing arrays
                               
                                DataA = [DataA, data(1:2:end) .* app.Parameters.I_base];
                                DataB = [DataB, data(2:2:end) .* app.Parameters.I_base];

                                %if loop to display many stored data points
                                %at once so the graph makes sense 
                                if numel(DataA) == 2100
                                    %Clear data out of noise 
                                    DataA = rmoutliers(DataA);
                                    DataB = rmoutliers(DataB);


                                    % Calculate elapsed time
                                    currentTime = datetime('now');
                                    elapsedTime = seconds(currentTime - startTime);
                                    % Generate time points for the x-axis
                                    xData = linspace(0, elapsedTime, numel(DataA));

                                    set(Iqplot(1), 'XData', xData, 'YData', DataA);
                                    set(Iqplot(2), 'XData', xData, 'YData', DataB);

                                    drawnow;
                                    pause(0.05);  % Adjust pause time as needed
                                    DataA = [];
                                    DataB = [];
                                end

                         end
                       
                      catch ME
                          %clear app.device;
                          rethrow(ME);
                      end
                    
                  case 65
                      IaIbplot =plot(app.UIAxes,NaN(matrixsize(1), 2));
                      title(app.UIAxes,'Ia current & Ib current');
                      xlabel(app.UIAxes,'Time (s)');
                      ylabel(app.UIAxes,'Current (A)');
                      legend(app.UIAxes,'Ia', 'Ib');
                       %Predifine the time vector for 600 samples 
                      % Samples = 600;
                      % sampleInterval = 50e-6;% 50microseconds
                      % xData = (0:Samples-1)*sampleInterval;
                      try 
                          while true
                              data = read(app.device, AllElements, 'single');
                              startTime = datetime('now');

                                % Extract DataA and DataB from received data and concatenate with existing arrays
                               
                                DataA = [DataA, data(1:2:end) .* app.Parameters.I_base];
                                DataB = [DataB, data(2:2:end) .* app.Parameters.I_base];

                                %if loop to display many stored data points
                                %at once so the graph makes sense 
                                if numel(DataA) == 2100
                                    %Clear data out of noise 
                                    DataA = rmoutliers(DataA);
                                    DataB = rmoutliers(DataB);


                                    % % Calculate elapsed time
                                    currentTime = datetime('now');
                                    elapsedTime = seconds(currentTime - startTime);
                                    % Generate time points for the x-axis
                                    xData = linspace(0, elapsedTime, numel(DataA));

                                    set(IaIbplot(1), 'XData', xData, 'YData', DataA);
                                    set(IaIbplot(2), 'XData', xData, 'YData', DataB);

                                    drawnow;
                                    pause(0.05);  % Adjust pause time as needed
                                    DataA = [];
                                    DataB = [];
                                end

                         end
                       
                      catch ME
                          %clear app.device;
                          rethrow(ME);
                      end
                   
                  case 81 
                      IaPosplot =plot(app.UIAxes,NaN(matrixsize(1), 2));
                      title(app.UIAxes,'Ia current & Position');
                      xlabel(app.UIAxes,'Time (s)');
                      ylabel(app.UIAxes,'Current & Position');
                      legend(app.UIAxes,'Ia', 'Pos');
                      %Predifine the time vector for 600 samples 
                       % Samples = 600;
                       % sampleInterval = 50e-6;% 50microseconds
                       % xData = (0:Samples-1)*sampleInterval;

                    try 
                          while true
                              data = read(app.device, AllElements, 'single');
                              % startTime = datetime('now');

                                % Extract DataA and DataB from received data and concatenate with existing arrays
                               
                                DataA = [DataA, data(1:2:end) .* app.Parameters.I_base];
                                DataB = [DataB, data(2:2:end) .* 2*pi];

                                %if loop to display many stored data points
                                %at once so the graph makes sense 
                                if numel(DataA) == 2100
                                    %Clear data out of noise 
                                    DataA = rmoutliers(DataA);
                                    DataB = rmoutliers(DataB);


                                    % % Calculate elapsed time
                                    currentTime = datetime('now');
                                    elapsedTime = seconds(currentTime - startTime);
                                    % Generate time points for the x-axis
                                    xData = linspace(0, elapsedTime, numel(DataA));

                                    set(IaPosplot(1), 'XData', xData, 'YData', DataA);
                                    set(IaPosplot(2), 'XData', xData, 'YData', DataB);

                                    drawnow;
                                    pause(0.05);  % Adjust pause time as needed
                                    DataA = [];
                                    DataB = [];
                                end

                         end
                       
                     catch ME
                          %clear app.device;
                          rethrow(ME);
                     end
              end
         

           
        end

        % Selection changed function: DatatodisplayButtonGroup
        function DatatodisplayButtonGroupSelectionChanged(app, event)
            selectedButton = app.DatatodisplayButtonGroup.SelectedObject;
            % options for different modes 
            Mode1 = 'Speed ref & Speed feedback';
            Mode2 = 'Id ref & Id feedback';
            Mode3 = 'Iq ref & Iq feedback';
            Mode4 = 'Ia &Ib';
            Mode5 = 'Ia & Position';
            % if statement to write appropiate operation message that will 
            % be then sent to the C2000 board
            if strcmp(selectedButton.Text,Mode1)
                app.Operation =17;
            elseif strcmp(selectedButton.Text, Mode2)
                app.Operation = 33;
            elseif strcmp(selectedButton.Text,Mode3)
                app.Operation = 49;
            elseif strcmp(selectedButton.Text,Mode4)
                app.Operation = 65;
            elseif strcmp(selectedButton.Text, Mode5)
                app.Operation = 81;
            end
        end

        % Value changed function: StartButton
        function StartButtonValueChanged(app, event)
            value = app.StartButton.Value;
            if value 
                if ~isempty(app.device)
                    Message = [app.SpeedDemand,app.Operation]
                    write(app.device,Message,'single');
                 else
                      ComPortWarning(app);
                 end
            end


        end

        % Clicked callback: Tree
        function TreeClicked(app, event)
           
                %node = event.InteractionInformation.Node;
              %Value of the main tree node
            MainRoot = 'Select COM Port:';
            %get the value of selected node
            node = event.InteractionInformation.Node;
            %Genarate nodes based on the available COM ports
            PopulateCOMPorts(app);
            %compare the selected node and MainRoot
            tf = strcmp(node.Text,MainRoot);
            %if the port was selected then establish serial communication
            if ~tf
                % Set up communication port
                app.device = serialport(node.Text,12e6);
            end
        end

        % Value changed function: ForcomportButton
        function ForcomportButtonValueChanged(app, event)
            value = app.ForcomportButton.Value;
            app.device = serialport("COM9",12e6);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create MotorControlUIFigure and hide until all components are created
            app.MotorControlUIFigure = uifigure('Visible', 'off');
            app.MotorControlUIFigure.Color = [0.9412 0.9412 0.9412];
            app.MotorControlUIFigure.Position = [100 100 640 480];
            app.MotorControlUIFigure.Name = 'MotorControl';
            app.MotorControlUIFigure.Icon = 'sq_logo.jpg';

            % Create MotorControlPanel
            app.MotorControlPanel = uipanel(app.MotorControlUIFigure);
            app.MotorControlPanel.ForegroundColor = [0.2588 0 0.6];
            app.MotorControlPanel.TitlePosition = 'centertop';
            app.MotorControlPanel.Title = 'Motor Control ';
            app.MotorControlPanel.BackgroundColor = [0.3294 0.6 0];
            app.MotorControlPanel.FontSize = 36;
            app.MotorControlPanel.Position = [1 428 640 53];

            % Create Image_2
            app.Image_2 = uiimage(app.MotorControlPanel);
            app.Image_2.Position = [8 -132 141 126];
            app.Image_2.ImageSource = fullfile(pathToMLAPP, 'Pics', 'UOSLogo_Primary_Violet_RGB.png');

            % Create Image_3
            app.Image_3 = uiimage(app.MotorControlPanel);
            app.Image_3.Position = [8 -132 141 126];
            app.Image_3.ImageSource = fullfile(pathToMLAPP, 'Pics', 'UOSLogo_Primary_Violet_RGB.png');

            % Create Image_4
            app.Image_4 = uiimage(app.MotorControlPanel);
            app.Image_4.Position = [2 5 141 48];
            app.Image_4.ImageSource = 'UOSLogo_Primary_Violet_RGB.png';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.MotorControlUIFigure);
            app.TabGroup.Position = [1 1 641 428];

            % Create ModelInfoTab
            app.ModelInfoTab = uitab(app.TabGroup);
            app.ModelInfoTab.Title = 'Model Info';
            app.ModelInfoTab.BackgroundColor = [0.0706 0.6196 1];

            % Create MotorButtonGroup
            app.MotorButtonGroup = uibuttongroup(app.ModelInfoTab);
            app.MotorButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @MotorButtonGroupSelectionChanged, true);
            app.MotorButtonGroup.ForegroundColor = [1 1 1];
            app.MotorButtonGroup.TitlePosition = 'centertop';
            app.MotorButtonGroup.Title = 'Motor ';
            app.MotorButtonGroup.BackgroundColor = [0.3294 0.6 0];
            app.MotorButtonGroup.Position = [53 256 121 92];

            % Create PMMotorButton
            app.PMMotorButton = uitogglebutton(app.MotorButtonGroup);
            app.PMMotorButton.Text = 'PM Motor';
            app.PMMotorButton.BackgroundColor = [1 0.451 0.0706];
            app.PMMotorButton.Position = [11 35 100 26];

            % Create IMMotorButton
            app.IMMotorButton = uitogglebutton(app.MotorButtonGroup);
            app.IMMotorButton.Text = 'IM Motor';
            app.IMMotorButton.BackgroundColor = [1 0.451 0.0706];
            app.IMMotorButton.Position = [12 9 100 23];

            % Create DummyButton
            app.DummyButton = uitogglebutton(app.MotorButtonGroup);
            app.DummyButton.HandleVisibility = 'off';
            app.DummyButton.Enable = 'off';
            app.DummyButton.Visible = 'off';
            app.DummyButton.Text = 'Dummy';
            app.DummyButton.BackgroundColor = [1 0.451 0.0706];
            app.DummyButton.Position = [12 -8 100 10];
            app.DummyButton.Value = true;

            % Create SpeedRPMSliderLabel
            app.SpeedRPMSliderLabel = uilabel(app.ModelInfoTab);
            app.SpeedRPMSliderLabel.HorizontalAlignment = 'right';
            app.SpeedRPMSliderLabel.Position = [107 82 78 22];
            app.SpeedRPMSliderLabel.Text = 'Speed (RPM)';

            % Create SpeedRPMSlider
            app.SpeedRPMSlider = uislider(app.ModelInfoTab);
            app.SpeedRPMSlider.Limits = [-6000 6000];
            app.SpeedRPMSlider.ValueChangedFcn = createCallbackFcn(app, @SpeedRPMSliderValueChanged, true);
            app.SpeedRPMSlider.Position = [206 91 275 3];

            % Create StopButton
            app.StopButton = uibutton(app.ModelInfoTab, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.BackgroundColor = [1 0 0];
            app.StopButton.FontColor = [1 1 1];
            app.StopButton.Position = [66 184 100 23];
            app.StopButton.Text = 'Stop';

            % Create SpeedRpmLabel
            app.SpeedRpmLabel = uilabel(app.ModelInfoTab);
            app.SpeedRpmLabel.HorizontalAlignment = 'right';
            app.SpeedRpmLabel.Position = [110 131 78 22];
            app.SpeedRpmLabel.Text = 'Speed (RPM)';

            % Create SpeedRPMEditField
            app.SpeedRPMEditField = uieditfield(app.ModelInfoTab, 'numeric');
            app.SpeedRPMEditField.ValueChangedFcn = createCallbackFcn(app, @SpeedRPMEditFieldValueChanged, true);
            app.SpeedRPMEditField.Position = [203 131 100 22];

            % Create DatatodisplayButtonGroup
            app.DatatodisplayButtonGroup = uibuttongroup(app.ModelInfoTab);
            app.DatatodisplayButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @DatatodisplayButtonGroupSelectionChanged, true);
            app.DatatodisplayButtonGroup.Title = 'Data to display:';
            app.DatatodisplayButtonGroup.Position = [412 212 193 136];

            % Create SpeedrefSpeedfeedbackButton
            app.SpeedrefSpeedfeedbackButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.SpeedrefSpeedfeedbackButton.Text = 'Speed ref & Speed feedback';
            app.SpeedrefSpeedfeedbackButton.Position = [11 90 175 22];

            % Create IdrefIdfeedbackButton
            app.IdrefIdfeedbackButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.IdrefIdfeedbackButton.Text = 'Id ref & Id feedback';
            app.IdrefIdfeedbackButton.Position = [11 68 126 22];

            % Create IqrefIqfeedbackButton
            app.IqrefIqfeedbackButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.IqrefIqfeedbackButton.Text = 'Iq ref & Iq feedback';
            app.IqrefIqfeedbackButton.Position = [11 46 126 22];

            % Create IaIbButton
            app.IaIbButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.IaIbButton.Text = 'Ia &Ib';
            app.IaIbButton.Position = [11 23 53 22];

            % Create IaPositionButton
            app.IaPositionButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.IaPositionButton.Text = 'Ia & Position';
            app.IaPositionButton.Position = [11 0 89 22];

            % Create DummybuttonButton
            app.DummybuttonButton = uiradiobutton(app.DatatodisplayButtonGroup);
            app.DummybuttonButton.Enable = 'off';
            app.DummybuttonButton.Visible = 'off';
            app.DummybuttonButton.Text = 'Dummy button';
            app.DummybuttonButton.Position = [11 -23 100 22];
            app.DummybuttonButton.Value = true;

            % Create StartButton
            app.StartButton = uibutton(app.ModelInfoTab, 'state');
            app.StartButton.ValueChangedFcn = createCallbackFcn(app, @StartButtonValueChanged, true);
            app.StartButton.Text = 'Start';
            app.StartButton.BackgroundColor = [0.4667 0.6745 0.1882];
            app.StartButton.FontColor = [1 1 1];
            app.StartButton.Position = [67 212 100 23];

            % Create Tree
            app.Tree = uitree(app.ModelInfoTab);
            app.Tree.ClickedFcn = createCallbackFcn(app, @TreeClicked, true);
            app.Tree.Position = [228 265 150 83];

            % Create SelectCOMPortNode
            app.SelectCOMPortNode = uitreenode(app.Tree);
            app.SelectCOMPortNode.Text = 'Select COM Port:';

            % Create ForcomportButton
            app.ForcomportButton = uibutton(app.ModelInfoTab, 'state');
            app.ForcomportButton.ValueChangedFcn = createCallbackFcn(app, @ForcomportButtonValueChanged, true);
            app.ForcomportButton.Text = 'For com port';
            app.ForcomportButton.Position = [436 130 100 23];

            % Create DiagnosticsTab
            app.DiagnosticsTab = uitab(app.TabGroup);
            app.DiagnosticsTab.Title = 'Diagnostics';
            app.DiagnosticsTab.BackgroundColor = [0.0706 0.6196 1];
            app.DiagnosticsTab.ButtonDownFcn = createCallbackFcn(app, @DiagnosticsTabButtonDown, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.DiagnosticsTab);
            app.UIAxes.Position = [0 45 639 338];

            % Show the figure after all components are created
            app.MotorControlUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MotorControl_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MotorControlUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MotorControlUIFigure)
        end
    end
end