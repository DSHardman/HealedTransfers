classdef Attempt
% Figs 5 & 6: single line on a single plot, associated data
    properties
        results % A vector of either xy errors or depth percentages
        savename % A string used to find heatmaps
        transferns % Number of inputs for transfer learning
    end

    methods
        function obj = Attempt(results,savename)
            %Constructor
            obj.results = results;
            obj.savename = savename;
            obj.transferns = [49, 100, 196, 289, 484, 4900];
        end

        function heat(obj, transindex, n)
            % Display relevant heatmap
            stringimage = strcat('Images/', obj.savename, '_',...
                string(obj.transferns(transindex)), '_', string(n), '.png');
            imshow(stringimage);
        end

        function plot(obj, basecase, col, display)
            % Plot relevant data
            if nargin >= 2
                neg = zeros(7,1);
                pos = zeros(7,1);
                means = zeros(7,1);
                for i = 1:6
                    means(i+1) = mean(obj.results(:,i));
                    neg(i+1) = means(i+1) - min(obj.results(:,i));
                    pos(i+1) = max(obj.results(:,i)) - means(i+1);
                end
                if any(obj.results > 30)
                    means(1) = basecase.depthpercentage;
                else
                    means(1) = basecase.xymean;
                end
            else
                neg = zeros(5,1);
                pos = zeros(5,1);
                means = zeros(5,1);
                for i = 1:5
                    means(i) = mean(obj.results(:,i));
                    neg(i) = means(i) - min(obj.results(:,i));
                    pos(i) = max(obj.results(:,i)) - means(i);
                end
            end

            if nargin <= 2
                col = 'k';
            end
            errorbar([0 obj.transferns(1:6)], means, neg, pos, 'LineWidth', 2,...
                'Color', col, 'DisplayName', display);
            set(gca, 'LineWidth', 2, 'FontSize', 15);
            box off
            xlabel('Number of Inputs');
            if any(obj.results > 30)
                ylabel('Correct Depths (%)')
                ylim([0 100]);
            else
                ylabel('Average Error (mm)');
                ylim([0 15]);
            end
        end
    end
end