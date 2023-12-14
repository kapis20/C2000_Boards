classdef Open_Loop_Control_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MotorControlUIFigure         matlab.ui.Figure
        TabGroup                     matlab.ui.container.TabGroup
        ModelInfoTab                 matlab.ui.container.Tab
        PlaceholderSlider            matlab.ui.control.Slider
        PlaceholderSliderLabel       matlab.ui.control.Label
        ModelInfoLabel               matlab.ui.control.Label
        UITable                      matlab.ui.control.Table
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
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Selection changed function: ControlmechanismButtonGroup
        function ControlmechanismButtonGroupSelectionChanged(app, event)
            selectedButton = app.ControlmechanismButtonGroup.SelectedObject;
            ScriptOpenLoop = 'open_loop_control_script.m'
            OpenLoop = 'Open-Loop';
            Model = 'three_phase_Gen_SpeedControl_new';
            SubSystem = 'three_phase_Gen_SpeedControl_new/Open_loop_control';
            FOC = 'FOC';
            tf = strcmp(selectedButton.Text,OpenLoop);
            tf1 = strcmp(selectedButton.Text,FOC);

            if tf 
               ProgressBar(app);
               load_system(Model); 
               open_system(SubSystem);
               run(ScriptOpenLoop);
               close_system(Model);
               display= struct2table(Target);
               display(:,1) =[]; 
               display = rows2vars(display);
               app.UITable.Data = display;

               %specify inputs for the simulation 
               SimIn = Simulink.SimulationInput(Model);
               %run the simulation
               out = sim(SimIn);

               plot(app.UIAxes,out.yout{1}.Values.Time,out.yout{1}.Values.Data);
               title(app.UIAxes, 'Vabc');
               xlabel(app.UIAxes, 'Time (s)');
               ylabel(app.UIAxes,'Magnitude (V)');

               plot(app.UIAxes_2,out.yout{2}.Values.Time,out.yout{2}.Values.Data);
               title(app.UIAxes_2,'Duty Cycles ABC');
               xlabel(app.UIAxes_2,'Time (s)');
               ylabel(app.UIAxes_2,'Magnitude');
               close(app.d);
               close(app.ProgressFig);
                
            elseif tf1
                a = 2;
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
            app.MotorControlUIFigure.Icon = fullfile(pathToMLAPP, 'Pics', 'sq_logo.jpg');

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
            app.Image_4.ImageSource = fullfile(pathToMLAPP, 'Pics', 'UOSLogo_Primary_Violet_RGB.png');

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

            % Create UITable
            app.UITable = uitable(app.ModelInfoTab);
            app.UITable.BackgroundColor = [1 1 1;0.9412 0.9412 0.9412];
            app.UITable.ColumnName = '';
            app.UITable.RowName = {};
            app.UITable.FontSize = 14;
            app.UITable.Position = [249 166 302 182];

            % Create ModelInfoLabel
            app.ModelInfoLabel = uilabel(app.ModelInfoTab);
            app.ModelInfoLabel.FontSize = 18;
            app.ModelInfoLabel.Position = [353 356 94 23];
            app.ModelInfoLabel.Text = 'Model Info:';

            % Create PlaceholderSliderLabel
            app.PlaceholderSliderLabel = uilabel(app.ModelInfoTab);
            app.PlaceholderSliderLabel.HorizontalAlignment = 'right';
            app.PlaceholderSliderLabel.Position = [117 82 68 22];
            app.PlaceholderSliderLabel.Text = 'Placeholder';

            % Create PlaceholderSlider
            app.PlaceholderSlider = uislider(app.ModelInfoTab);
            app.PlaceholderSlider.Position = [206 91 275 3];

            % Create DiagnosticsTab
            app.DiagnosticsTab = uitab(app.TabGroup);
            app.DiagnosticsTab.Title = 'Diagnostics';
            app.DiagnosticsTab.BackgroundColor = [0.0706 0.6196 1];

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
        function app = Open_Loop_Control_exported

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