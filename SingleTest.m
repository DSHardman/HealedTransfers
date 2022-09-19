classdef SingleTest < handle
    % Testing either random probes, repeated probes, or probes along a line
    properties
        n               % Number of presses in dataset 
        positions       % [x y depth]s of all presses
        rawresponses    % Raw response to all presses
        extracted3      % '24-input' case in Fig. 2D
        extracted10     % '80-input' case in Fig. 2D
        poses           % Robot arm joints throughout motion
        times           % Associated times for response data
    end
    
    methods
        
        % Constructor
        % 'letter' input is used for extracting raw signals from data files
        % and is not relevent thereafter
        function obj = SingleTest(letter,n,line)
            % 'line' input is just Boolean
            
            % Initialise properties
            obj.n = n;
            if line
                obj.rawresponses = zeros(n,310,8);
            else
                obj.rawresponses = zeros(n,200,8);
            end
            obj.positions = zeros(n, 3);
            obj.extracted3 = zeros(n, 24);
            obj.extracted10 = zeros(n, 80);
            obj.poses = zeros(n,200,6);
            obj.times = zeros(n,200);
            
            % Read raw data from files
            for i = 1:n
                % Set positions
                obj.positions(i, :) = 1000*readNPY(strcat(letter,'/rawdata/xy',string(i-1), '.npy'));
                if ~line
                    % Set times
                    obj.times(i,:) = readNPY(strcat(letter,'/rawdata/times',string(i-1), '.npy')).';
                    % Set poses
                    obj.poses(i,:,:) = readNPY(strcat(letter,'/rawdata/poses',string(i-1), '.npy'));
                end
                
                % Set responses
                discretepoints = zeros(n,8,3);
                touchpoints = zeros(n,8,10);
                % Filter & extract points as shown in Fig. 2D
                y = readNPY(strcat(letter,'/rawdata/response',string(i-1), '.npy'));
                obj.rawresponses(i,:,:) = y;
                x = zeros(size(y));
                for j = 1:8
                    [x(:,j), ~] = pwc_tvdrobust(y(:,j), 15, 0);
                    discretepoints(i,j,:) = [x(40,j) x(80,j) x(180,j)];
                    touchpoints(i,j,:) = [y(45:5:65,j).' y(150:5:170,j).'];
                end
                for j = 1:24
                    obj.extracted3(i, j) = discretepoints(i, rem(j-1,8)+1, floor((j-1)/8)+1);
                end
                for j = 1:80
                    obj.extracted10(i, j) = touchpoints(i, rem(j-1,8)+1, floor((j-1)/8)+1);
                end
            end
        end
        
        % Plot & format raw sensor responses
        function plotresponse(obj, iteration, sensor)
           
            set(gcf, 'Position', 1000*[0.0130    0.3850    1.5032    0.4200]);
            subplot(1,2,2)
            if nargin == 3
                plot(obj.rawresponses(iteration,:,sensor));
            else
                colors = [0 0.447 0.741;...
                            0.85 0.325 0.98;...
                            0.929 0.694 0.125;...
                            0.494 0.184 0.556;...
                            0.466 0.674 0.188;...
                            0.301 0.745 0.933;...
                            0.635 0.078 0.184;
                            0 0 0];
                for i = 1:8
                    plot(obj.rawresponses(iteration,:,i), 'LineWidth', 2,...
                        'Color', colors(i,:), 'DisplayName', string(i-1));
                    hold on
                end
            end
            ylim([min(min(min(obj.rawresponses)))-0.5 max(max(max(obj.rawresponses)))]);
            xlim([0 308])
            set(gca, 'LineWidth', 2, 'FontSize', 15, 'XTickLabel', []);
            box off
            ylabel('Sensor Response (V)');
            titlestring = sprintf('x = %.3fmm, y = %.3fmm, Press %d',...
                obj.positions(iteration,1), obj.positions(iteration,2),...
                iteration);
            title(titlestring);
            
            
            subplot(1,2,1);
            for i = 1:4
                line([-11.5 46], [(i-1)*11.5 (i-1)*11.5]', 'Color', colors((9-i),:),...
                    'LineWidth', 2);
                line([(i-1)*11.5 (i-1)*11.5]', [-11.5 46], 'Color', colors((5-i),:),...
                    'LineWidth', 2);
            end
            set(gca, 'Visible', 'off')
            ylim([-16.5 51]); xlim([-16.5 51]); axis square
            hold on
            scatter(obj.positions(iteration,1), obj.positions(iteration,2),...
                150, 'r', 'filled');
        end
        
    end
end

