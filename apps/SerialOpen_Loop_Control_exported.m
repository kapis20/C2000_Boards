classdef SerialOpen_Loop_Control_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MotorControlUIFigure         matlab.ui.Figure
        TabGroup                     matlab.ui.container.TabGroup
        ModelInfoTab                 matlab.ui.container.Tab
        Tree                         matlab.ui.container.Tree
        SelectCOMPortNode            matlab.ui.container.TreeNode
        SpeedRPMEditField            matlab.ui.control.NumericEditField
        SpeedRpmLabel                matlab.ui.control.Label
        StopButton                   matlab.ui.control.Button
        SpeedRPMSlider               matlab.ui.control.Slider
        SpeedRPMSliderLabel          matlab.ui.control.Label
        ControlmechanismButtonGroup  matlab.ui.container.ButtonGroup
        DummyButton                  matlab.ui.control.ToggleButton
        FOCButton                    matlab.ui.control.ToggleButton
        OpenLoopButton               matlab.ui.control.ToggleButton
        DiagnosticsTab               matlab.ui.container.Tab
        UIAxes_2                     matlab.ui.control.UIAxes
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
    end
    
    methods (Access = private)
        
        function ProgressBar(app)
            
            
                app.ProgressFig = uifigure('Position',[500,500,400,110], ...
                    'Name','Motor Control - dashboard', ...
                    'WindowStyle','modal','Icon','sq_logo.png');
           
                app.d = uiprogressdlg(app.ProgressFig,'Title', ...
                    'Progress bar', 'Message', ...
                'Loading the simulation','Indeterminate','on','Icon','sq_logo.png');
                drawnow
                pause(.5)
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

        % Selection changed function: ControlmechanismButtonGroup
        function ControlmechanismButtonGroupSelectionChanged(app, event)
            selectedButton = app.ControlmechanismButtonGroup.SelectedObject;
            %buttons
            OpenLoop = 'Open-Loop';
            FOC = 'FOC';

            % Set up communication port
            %app.device = serialport("COM7",5e6);
            % Enable the operation and create a message
            app.Operation = uint16(1);

            Message = [app.SpeedDemand,app.Operation];



            tf = strcmp(selectedButton.Text,OpenLoop);
            tf1 = strcmp(selectedButton.Text,FOC);

            if tf 
                %write(app.device,Message,'uint16');
                app.OpenLoopButton.Value = false;
                app.DummyButton.Value = true;
                if ~isempty(app.device)
                   write(app.device,Message,'uint16');
                else
                     ComPortWarning(app);
                end

            elseif tf1
                a = 2;
                app.FOCButton.Value = false;
                app.DummyButton.Value = true;
            end



        end

        % Value changed function: SpeedRPMEditField
        function SpeedRPMEditFieldValueChanged(app, event)
            %get the speed demand and convert the value
            app.SpeedDemand = uint16(app.SpeedRPMEditField.Value);

            
        end

        % Value changed function: SpeedRPMSlider
        function SpeedRPMSliderValueChanged(app, event)
            app.SpeedDemand = uint16(app.SpeedRPMSlider.Value);
            
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            
            %change operation
            app.Operation = uint16(0);
            %just in case set speed to 0
            app.SpeedDemand = uint16(0);

            Message = [app.SpeedDemand,app.Operation];

            write(app.device,Message,'uint16');
            %flush(app.device);
        end

        % Double-clicked callback: Tree
        function TreeDoubleClicked(app, event)
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
                app.device = serialport(node.Text,5e6);
            end

        end

        % Button down function: DiagnosticsTab
        function DiagnosticsTabButtonDown(app, event)
            matrixsize = [600,2];
            AllElements = prod(matrixsize);

            %Data receive 
            % Set up the figure and axis
        
              
           
            Iaplot = plot(app.UIAxes,NaN, NaN);  % Initialize an empty plot
                title(app.UIAxes, 'Ia (ADC counts)');
                xlabel(app.UIAxes, 'Time (ms)');
                ylabel(app.UIAxes,'Ia');

            Ibplot = plot(app.UIAxes_2,NaN, NaN);
                 title(app.UIAxes_2, 'Ib (ADC counts)');
                 xlabel(app.UIAxes_2, 'Time (ms)');
                 ylabel(app.UIAxes_2,'Ib');

    
            
            %numofPoints = 600;
            try 
                while true 
                    %Read data as uint 16
                    data = read(app.device,AllElements,'uint16');
                    %reshape data into the desired matrix shape 
                    receivedData = reshape(data,[600,2]);
                    currentIa = receivedData(:,1);
                    currentIb = receivedData(:,2);
                    set(Iaplot, 'XData', linspace(0,100,600), 'YData', currentIa);
                    
                    set(Ibplot, 'XData', linspace(0,100,600), 'YData', currentIb);
                    % Force MATLAB to update the plot
                    drawnow;
            
                end
            catch ME
                %clear app.device;
                rethrow(ME);
            end

           
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

            % Create ControlmechanismButtonGroup
            app.ControlmechanismButtonGroup = uibuttongroup(app.ModelInfoTab);
            app.ControlmechanismButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ControlmechanismButtonGroupSelectionChanged, true);
            app.ControlmechanismButtonGroup.ForegroundColor = [1 1 1];
            app.ControlmechanismButtonGroup.TitlePosition = 'centertop';
            app.ControlmechanismButtonGroup.Title = 'Control mechanism';
            app.ControlmechanismButtonGroup.BackgroundColor = [0.3294 0.6 0];
            app.ControlmechanismButtonGroup.Position = [53 256 121 92];

            % Create OpenLoopButton
            app.OpenLoopButton = uitogglebutton(app.ControlmechanismButtonGroup);
            app.OpenLoopButton.Text = 'Open-Loop';
            app.OpenLoopButton.BackgroundColor = [1 0.451 0.0706];
            app.OpenLoopButton.Position = [11 35 100 26];

            % Create FOCButton
            app.FOCButton = uitogglebutton(app.ControlmechanismButtonGroup);
            app.FOCButton.Text = 'FOC';
            app.FOCButton.BackgroundColor = [1 0.451 0.0706];
            app.FOCButton.Position = [12 9 100 23];

            % Create DummyButton
            app.DummyButton = uitogglebutton(app.ControlmechanismButtonGroup);
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
            app.SpeedRPMSlider.Limits = [0 4000];
            app.SpeedRPMSlider.ValueChangedFcn = createCallbackFcn(app, @SpeedRPMSliderValueChanged, true);
            app.SpeedRPMSlider.Position = [206 91 275 3];

            % Create StopButton
            app.StopButton = uibutton(app.ModelInfoTab, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.BackgroundColor = [1 0 0];
            app.StopButton.FontColor = [1 1 1];
            app.StopButton.Position = [64 190 100 23];
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

            % Create Tree
            app.Tree = uitree(app.ModelInfoTab);
            app.Tree.DoubleClickedFcn = createCallbackFcn(app, @TreeDoubleClicked, true);
            app.Tree.Position = [420 271 150 77];

            % Create SelectCOMPortNode
            app.SelectCOMPortNode = uitreenode(app.Tree);
            app.SelectCOMPortNode.Icon = 'ComPort.png';
            app.SelectCOMPortNode.Text = 'Select COM Port:';

            % Create DiagnosticsTab
            app.DiagnosticsTab = uitab(app.TabGroup);
            app.DiagnosticsTab.Title = 'Diagnostics';
            app.DiagnosticsTab.BackgroundColor = [0.0706 0.6196 1];
            app.DiagnosticsTab.ButtonDownFcn = createCallbackFcn(app, @DiagnosticsTabButtonDown, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.DiagnosticsTab);
            app.UIAxes.Position = [1 206 639 185];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.DiagnosticsTab);
            app.UIAxes_2.Position = [0 1 641 185];

            % Show the figure after all components are created
            app.MotorControlUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SerialOpen_Loop_Control_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MotorControlUIFigure)

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