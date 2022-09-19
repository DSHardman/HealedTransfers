% Object stores 3 SingleTest objects in a given sensor 'state' 
% e.g. damaged state 1, healed state 2.
% All functions other than constructor are used to create plots or videos

classdef SensorState < handle
    properties
        random      %SingleTest object: series of random presses
        repeated    % SingleTest object: series of repeated presses
        line        % SingleTest object, optional: probe along a sensor line
    end
    
    methods
        % Constructor
        % 'letter' inputs are used for extracting raw signals from data files
        % and are not relevent thereafter
        function obj = SensorState(randomletter, randomn, repeatedletter,...
                repeatedn, lineletter, linen)
            obj.random = SingleTest(randomletter, randomn, 0);
            obj.repeated = SingleTest(repeatedletter, repeatedn, 0);
            
            if nargin == 6
                obj.line = SingleTest(lineletter, linen, 1);
            elseif nargin == 4
                obj.line = NaN;
            else
                error('Check Number of Inputs');
            end
        end
        
        % Show obj.line response as video
        % Used to create supplementary content
        function animateline(obj)
            obj.line.plotresponse(1);
            pause(0.1);
            for i = 2:obj.line.n
                
                obj.line.plotresponse(i);
                
                subplot(1,2,1);
                children = get(gca, 'Children');
                delete(children(end-8:end));
                
                subplot(1,2,2);
                children = get(gca, 'Children');
                delete(children(end-7:end));
                legend('Orientation', 'Horizontal', 'Location', 's');
                legend boxoff
                
                set(gcf, 'Color', 'w');
                pause(0.1);
            end
        end
        
        % Create video from obj.repeated response
        function animaterepeats(obj)
            
            obj.repeated.plotresponse(1);
            pause(0.05);
            for i = 2:obj.repeated.n
                
                obj.repeated.plotresponse(i);
                
                subplot(1,2,1);
                children = get(gca, 'Children');
                delete(children(end-8:end));
                
                subplot(1,2,2);
                children = get(gca, 'Children');
                delete(children(end-7:end));
                legend('Orientation', 'Horizontal', 'Location', 's');
                legend boxoff
                
                set(gcf, 'color', 'w');

                pause(0.05);
            end
        end
        
        % Plot magnitude of response as probing along line
        % See 'Response magnitude along sensor' in fig 4
        function lineplot(obj, sensor)
            if nargin < 2 % if no sensor specified, plot all 8 responses
                for i = 1:8
                    obj.lineplot(i);
                    hold on;
                end
                return
            end
            
            colors = [0 0.447 0.741;...
                        0.85 0.325 0.98;...
                        0.929 0.694 0.125;...
                        0.494 0.184 0.556;...
                        0.466 0.674 0.188;...
                        0.301 0.745 0.933;...
                        0.635 0.078 0.184;
                        0 0 0];
            lineresponse = zeros(obj.line.n, 1);

            % Calculate response magnitudes at each point
            for i = 1:obj.line.n
                 if size(obj.line.rawresponses, 2) == 200
                     lineresponse(i) = ((obj.line.rawresponses(i,20,sensor)+...
                         obj.line.rawresponses(i,200,sensor))/2) -...
                         obj.line.rawresponses(i,120,sensor);                        
                 else
                    lineresponse(i) = ((obj.line.rawresponses(i,40,sensor)+...
                        obj.line.rawresponses(i,290,sensor))/2) -...
                        obj.line.rawresponses(i,135,sensor);   
                 end
            end
            
            % Format image
            if obj.line.positions(end,1) == obj.line.positions(1,1)
                plot(obj.line.positions(:,2), lineresponse, 'Color',...
                    colors(sensor,:), 'LineWidth', 2);
                xlabel('y Position (mm)');
            else
                plot(obj.line.positions(:,1), lineresponse, 'Color',...
                    colors(sensor,:), 'LineWidth', 2);
                xlabel('x Position (mm)');
            end
            
            set(gca, 'LineWidth', 2, 'Fontsize', 15);
            ylabel('\Delta Response (V)');
            box off
            xlim([0 34.5]);
            ylim([-1 0.6]);
            set(gcf, 'Position', [462.6000  391.4000  596.0000  280.8000]);
        end
        
        function index = findclosest(obj, x, y)
            % Search random probes for positions closest to input data
            % Depth is not considered
            assert(length(x)==length(y));
            index = zeros(length(x),1);
            for i = 1:length(x)
                errors = zeros(obj.random.n,1);
                for j = 1:obj.random.n
                    errors(j) = norm(obj.random.positions(j,1:2) - [x(i) y(i)]);
                end
                [~, index(i)] = min(errors);
            end
        end
    end
end

