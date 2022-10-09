classdef ScrollableAxes < matlab.mixin.SetGet
    % SCROLLABLEAXES Scrollable axes for plotting for 3D data.
	
	%% Constants and default property values
	properties (Constant, Access = private, Hidden)
		DEFAULT_AUTO_INDEX = true;
		DEFAULT_AUTO_LIMITS = true;
		DEFAULT_INDEX = 1;
		DEFAULT_INTERPOLATION = 'nearest'
		DEFAULT_MARKER_LINE_STYLE = '--'
		DEFAULT_MARKER_COLOR = 'red'
        DEFAULT_PLOT_FUNCTION = 'plot'
		DEFAULT_SLIDER_MARGIN = 2
		DEFAULT_SLIDER_POSITION = 'right'
		DEFAULT_SLIDER_WIDTH = 18
		DEFAULT_X_LIM_STRETCH = 1.0
		DEFAULT_Y_LIM_STRETCH = 1.1
		MAJOR_STEP = 0.1;
		MINOR_STEP_MIN = 1e-6;
	end
	
	%% Object properties
	properties (SetAccess = immutable, GetAccess = public)
        % Parent - Handle of the parent access.
        % Scalar Axes object (default: gca).
		Parent
    end
    
	properties (Access = public)
        % AutoIndex - Set index to maximum data trace on first plot.
        % 
        % Possible values:
        % true (default) | false
        %
        % See also ScrollableAxes.Index
        AutoIndex = ScrollableAxes.DEFAULT_AUTO_INDEX
        
        % Index - Current data index in the scrollable dimension.
        % If AutoIndex is set to true  
        %
        % Possible values:
        % 1 (default) | positive integer less then the number of points
        %
        % See also ScrollableAxes.AutoIndex
		Index = []
        
        % Interpolation - Method used to interpolate 2D data to the same points.
        % The default mode is 'nearest', meaning that the nearest point of the
        % original data is taken. For details see the description of the
        % interpolation modes in the documentation of interp2.
        % 
        % Possible values:
        % 'nearest' (default) | 'linear' | 'cubic' | 'spline' | 'makima'
        %
        % See also interp2
		Interpolation = ScrollableAxes.DEFAULT_INTERPOLATION
        
        % SliderMargin - Horizontal gap between slider and axes (in pixels).
        % 
        % Possible values:
        % 2 (default) | numeric
		SliderMargin = ScrollableAxes.DEFAULT_SLIDER_MARGIN
        
        % SliderPosition - Horizontal position of the slider relative to axes.
        % 
        % Possible values:
        % 'right' (default) | 'left'
		SliderPosition = ScrollableAxes.DEFAULT_SLIDER_POSITION
        
        % SliderWidth - Width of the slider (in pixels).
        % 
        % Possible values:
        % 18 (default) | positive number
		SliderWidth = ScrollableAxes.DEFAULT_SLIDER_WIDTH
        
        % AutoLimits - Automatic determination of x- and y-axis limits.
        % If true, axes limits are automatically adjusted to the match the data
        % range. Scalar logical (default: true).
        %
        % See also ScrollableAxes.XLimStretch, ScrollableAxes.YLimStretch
		AutoLimits = ScrollableAxes.DEFAULT_AUTO_LIMITS
        
        % XLimStretch - Stretching factor of x-axis limits.
        % If AutoLimits is set to true, the value determines the stretching of
        % the x-axis limits relative to the data range.
        % Scalar positive real number (default: 1.0).
		XLimStretch = ScrollableAxes.DEFAULT_X_LIM_STRETCH
        
        % YLimStretch - Stretching factor of y-axis limits.
        % If AutoLimits is set to true, the value determines the stretching of
        % the y-axis limits relative to the data range.
        % Scalar positive real number (default: 1.1).
		YLimStretch = ScrollableAxes.DEFAULT_Y_LIM_STRETCH
	end
	
	properties (SetAccess = private, GetAccess = public)
		Plots = gobjects(0)
		XData = {}
		YData = []
		ZData = {}
        inputParser
    end
	
	properties (Access = private)
		Slider
		XMarkers = gobjects(0)
		YMarkers = gobjects(0)
	end
	
	%% Object methods
	methods
		
		%% Constructor
		function obj = ScrollableAxes(varargin)
            % SCROLLABLEAXES
            %
            %   h = SCROLLABLEAXES
            %   h = SCROLLABLEAXES(ax)
            %   h = SCROLLABLEAXES(___, Name, Value)
            %
            
            % Handle optional parent Axes-handle argument.
            [parent, args] = ScrollableAxes.parseParentArg(gca, varargin{:});
			
			% Set immutable parent property and other non-immutable properties
			% from optional 'Name'-'Value' input.
			obj.Parent = parent;
			if ~isempty(args)
				set(obj, args{:});
			end
			
			% Create slider.
			createSlider(obj);
		end
		
		%% Plot function
		function h = plot(obj, varargin)
			% PLOT
			%
			%	PLOT(obj, x, z)
			%	PLOT(obj, x, y, z)
			%	PLOT(obj, functionName, x, y, z)
			%	PLOT(___, LineSpec)
			%	h = PLOT(___)
			%
			
			% Parse variable input arguments.
			try
				[functionName, x, y, z, args] = ...
					ScrollableAxes.parsePlotArgs(varargin{:});
			catch e
				throw(e);
			end
			
			%TODO: Input validation
			
			% Clear all plots if hold is off for parent axes.
			if ~isempty(obj.Plots) && ~ishold(obj.Parent)
				obj.Plots = gobjects(0);
				obj.XData = {};
				obj.YData = [];
				obj.ZData = {};
			end
			
			% Process and set abscissas and data matrix.
			[x, y, z] = processDataArrays(obj, x, y, z);
			
			% Store data and initialize slider on first-plot creation.
			obj.XData = [obj.XData, {x}];
			obj.ZData = [obj.ZData, {z}];
			if isempty(obj.Plots)
				obj.YData = y;
                initializeIndex(obj);
				initializeSlider(obj);
			end
			
			% Create plot.
			h = feval(functionName, obj.Parent, x, z(obj.Index, :), args{:});
			
			% Set axis limits.
			if obj.AutoLimits
				setAxisLimits(obj, x, z)
			end
			
			% Store plot object.
			obj.Plots = [obj.Plots, h];
		end
		
		%% Plot markers
		function h = plotXMarker(obj, varargin)
			% PLOTXMARKER
			%
			%	PLOTXMARKER(obj)
            %	PLOTXMARKER(obj, ax)
			%	PLOTXMARKER(___, LineSpec)
			%	h = PLOTXMARKER(___)
			%
            h = plotMarker(obj, 'X', varargin{:});
        end
        
		function h = plotYMarker(obj, varargin)
			% PLOTYMARKER
			%
			%	PLOTYMARKER(obj)
            %	PLOTYMARKER(obj, ax)
			%	PLOTYMARKER(___, LineSpec)
			%	h = PLOTYMARKER(___)
			%
            h = plotMarker(obj, 'Y', varargin{:});
		end
		
		%% Property-access methods
		
	end
	
	%% Auxilliary methods
	methods (Access = private)
		
		%% Plot-update function
		function replot(obj, index)
			
			% Set integer index value.
			obj.Index = round(index);
			set(obj.Slider, 'Value', obj.Index);
			
			% Update plot data.
			for iPlot = 1:numel(obj.Plots)
				h = obj.Plots(iPlot);
				z = obj.ZData{iPlot}(obj.Index, :);
				if all(isnan(z))
					set(h, 'Visible', 'off');
				else
					set(h, 'YData', z);
					set(h, 'Visible', 'on');
				end
			end
			drawnow;
			
			% Update all markers.
			for iMarker = 1:numel(obj.XMarkers)
				set(obj.XMarkers(iMarker), ...
                    'XData', obj.YData(obj.Index) * [1 1]);
			end
			for iMarker = 1:numel(obj.YMarkers)
				set(obj.YMarkers(iMarker), ...
                    'YData', obj.YData(obj.Index) * [1 1]);
            end
        end
		
        %% Marker-line plot function
		function h = plotMarker(obj, type, varargin)
            
            % Handle optional parent argument.
            [parent, varargin] = ScrollableAxes.parseParentArg(gca, varargin{:});
            
            % Set two-point data input for line marker.
            ydata = obj.YData(obj.Index) * [1 1];
            switch type
                case 'X'; data = {ydata, parent.YLim};
                case 'Y'; data = {parent.XLim, ydata};
            end
            
            % Set the markers' parent axes to hold while plotting the
            % marker line.
            holdState = 'off';
            if ishold(parent)
                holdState = 'on';
            end
			hold(parent, 'on');
            
            % Plot marker line.
			h = plot( ...
				parent, ...
				data{:}, ...
				'LineStyle', ScrollableAxes.DEFAULT_MARKER_LINE_STYLE, ...
                'Linewidth', 3, ...
				'Color', ScrollableAxes.DEFAULT_MARKER_COLOR, ...
				varargin{:});
            
            % Reset initial hold state of the markers' parent axes.
			hold(parent, holdState);
            
            % Register marker and add change listeners to parent axes
            % limits.
            switch type
                case 'X'
                    obj.XMarkers = [obj.XMarkers, h];
                    addlistener(parent, 'YLim', 'PostSet', ...
                        @(~, ~) set(h, 'YData', parent.YLim));
                case 'Y'
                    obj.YMarkers = [obj.YMarkers, h];
                    addlistener(parent, 'XLim', 'PostSet', ...
                        @(~, ~) set(h, 'XData', parent.XLim));
            end
		end
		
		%% Data processing
		function [x, y, z] = processDataArrays(obj, x, y, z)
			
			% Use first (row) dimension for plotting (x) and second (column)
			% dimension for scrolling (y).
			needsTranspose = ~isrow(x);
			if needsTranspose
				x = x.';
				y = y.';
				z = z.';
			end
			
			% Interpolate subsequent data sets to the reference plot's y axis.
			if ~isempty(obj.Plots)
				z = interp2(x, y, z, x, obj.YData, obj.Interpolation, NaN);
            end
		end
		
		%% Set axis limits based on x and z data
		function setAxisLimits(obj, x, z)
			if ~isempty(obj.Plots)
				xmin = min([min(x), min(obj.Parent.XLim)]);
				xmax = max([max(x), max(obj.Parent.XLim)]);
			else
				xmin = min(x);
				xmax = max(x);
				zmin = min(z(:));
				zmax = max(z(:));
				ylim([zmin zmax] + (obj.YLimStretch-1) * (zmax-zmin) * [-1 1]);
			end
			xlim([xmin xmax] + (obj.XLimStretch-1) * (xmax-xmin) * [-1 1]);
        end
		
		%% Slider creation
		function createSlider(obj)
			
			% Create slider.
			obj.Slider = ...
                uicontrol('Style', 'slider', 'Units', 'normalized');
            setSliderPosition(obj);
            
            % Add listener to size and location changes of parent axis.
            events = {'SizeChanged', 'LocationChanged'};
            for iEvent = 1:numel(events)
                addlistener(obj.Parent, events{iEvent}, ...
                    @(~, ~) setSliderPosition(obj));
            end
            
            % Add listener to update plots.
            addlistener(obj.Slider, 'ContinuousValueChange', ...
                @(src, ~) replot(obj, src.Value));
        end
        
        %% Slider positioning
        function setSliderPosition(obj)
            position = getpixelposition(obj.Parent);
			switch obj.SliderPosition
				case 'left'
                    position(1) = ...
                        position(1) - obj.SliderMargin - obj.SliderWidth;
				case 'right'
                    position(1) = ...
                        position(1) + position(3) + obj.SliderMargin;
			end
			position(3) = obj.SliderWidth;
            set(obj.Slider, 'Units', 'pixels', 'Position', position);
            set(obj.Slider, 'Units', 'normalized');
        end
		
		%% Index initialization (on first plot)
        function initializeIndex(obj)
            z = obj.ZData{1};
            if isempty(obj.Index)
                if obj.AutoIndex
                    [~, kmax] = max(z(:));
                    [obj.Index, ~] = ind2sub(size(z), kmax);
                else
                    obj.Index = ScrollableAxes.DEFAULT_INDEX;
                end
            end
        end
        
		%% Slider initialization (on first plot)
		function initializeSlider(obj)
			ny = numel(obj.YData);
			minorStep = max( ...
				1/ny, ...
				ScrollableAxes.MINOR_STEP_MIN);
			majorStep = ScrollableAxes.MAJOR_STEP;
			set(obj.Slider, ...
				'Min', 1, ...
				'Max', ny, ...
				'SliderStep', [minorStep majorStep], ...
				'Value', obj.Index);
        end
	end
	
	%% Static auxilliary methods
	methods (Static, Access = private)
        
        function [parent, args] = parseParentArg(default, varargin)
            args = varargin;
            parent = default;
%             if isempty(args)% || ~isgraphics(args{1})
%                 parent = default;
%             else
%                 parent = args{1};
%                 args(1) = [];
%             end
        end
		
		function [functionName, x, y, z, args] = parsePlotArgs(varargin)
			
			% Handle optional arguments.
			narginchk(3, inf);
			args = varargin;
			
			% First argument: plot-function name (string).
			functionName = args{1};
			if ischar(functionName)
				narginchk(4, inf);
				args(1) = [];
			else
				functionName = ScrollableAxes.DEFAULT_PLOT_FUNCTION;
			end
			
			% Second to fourth argument: x abscissa, y values and z data
			x = args{1};
			y = args{2};
			z = args{3};
			args(1:3) = [];
        end
	end
	
	%% Overload superclass methods to exclude them from the methods list
	methods (Hidden)
		function lh = addlistener(varargin)
			lh = addlistener@handle(varargin{:});
		end
		function notify(varargin)
			notify@handle(varargin{:});
		end
		function delete(varargin)
			delete@handle(varargin{:});
		end
		function h = findobj(varargin)
			h = findobj@handle(varargin{:});
		end
		function p = findprop(varargin)
			p = findprop@handle(varargin{:});
		end
		function TF = eq(varargin)
			TF = eq@handle(varargin{:});
		end
		function TF = ne(varargin)
			TF = ne@handle(varargin{:});
		end
		function TF = lt(varargin)
			TF = lt@handle(varargin{:});
		end
		function TF = le(varargin)
			TF = le@handle(varargin{:});
		end
		function TF = gt(varargin)
			TF = gt@handle(varargin{:});
		end
		function TF = ge(varargin)
			TF = ge@handle(varargin{:});
		end
		function getdisp(varargin)
			getdisp@matlab.mixin.SetGet(varargin{:});
		end
		function setdisp(varargin)
			setdisp@matlab.mixin.SetGet(varargin{:});
		end
    end
end