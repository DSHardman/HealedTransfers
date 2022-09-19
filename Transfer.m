classdef Transfer
% To contain data necessary for Fig 5 & 6's plots, separately.
% Contains SingleCase and Approach objects.
% Plotting code also included.

    properties
        scratchdepth % Depth percentages when trained from scatch: 3 repetitions
        scratchxy % xy errors when trained from scratch: 3 repetitions
        scratchpath % String beginning filenames of interest
        basecase % Final values if fully trained: SingleCase object
        zerocase % Final values if not retrained: SingleCase object
        grid % Approach object for grid probing
        random % Approach object for random probing
        weighted % Approach object for weighted probing
        twod % Approach object for 2D probing
        invert % Approach object for inverted probing: not included in paper
    end

    methods
        function obj = Transfer(basecase, zerocase, grid, random, weighted, twod, invert)
            % Constructor
            obj.basecase = basecase;
            obj.zerocase = zerocase;
            obj.grid = grid;
            obj.random = random;
            obj.weighted = weighted;
            obj.twod = twod;
            obj.invert = invert;
        end

        function plotxy(obj, frozen)
            % Plot all attempts for xy errors in transfer, given number of
            % frozen layers
            line([49 4900], [obj.zerocase.xymean obj.zerocase.xymean],...
                'Color', 'k', 'LineStyle', '--', 'LineWidth', 2,  'HandleVisibility', 'Off');
            hold on
            obj.plotscratchxy()
            endstr = strcat(frozen,'.plot(obj.zerocase, ');
            eval(strcat('obj.grid.xy',endstr,"1/255*[27 158 119], 'Grid');"));
            eval(strcat('obj.random.xy',endstr,"1/255*[217 95 2], 'Random');"));
            eval(strcat('obj.weighted.xy',endstr,"1/255*[117 112 179], 'Weighted');"));
            eval(strcat('obj.twod.xy',endstr,"1/255*[231 41 138], '2D');"));
            eval(strcat('obj.invert.xy',endstr,"1/255*[102 116 30], 'Inverted');"));
            set(gca, 'XScale', 'log');
        end

        function plotdp(obj, frozen)
            % Plot all attempts for depth percentages in transfer, given number of
            % frozen layers
            line([49 4900], [obj.zerocase.depthpercentage obj.zerocase.depthpercentage],...
                'Color', 'k', 'LineStyle', '--', 'LineWidth', 2,  'HandleVisibility', 'Off');
            hold on
            obj.plotscratchdp()
            endstr = strcat(frozen,'.plot(obj.zerocase, ');
            eval(strcat('obj.grid.dp',endstr,"1/255*[27 158 119], 'Grid');"));
            eval(strcat('obj.random.dp',endstr,"1/255*[217 95 2], 'Random');"));
            eval(strcat('obj.weighted.dp',endstr,"1/255*[117 112 179], 'Weighted');"));
            eval(strcat('obj.twod.dp',endstr,"1/255*[231 41 138], '2D');"));
            eval(strcat('obj.invert.dp',endstr,"1/255*[102 116 30], 'Inverted');"));
            %legend('Location', 'nw');
            set(gca, 'XScale', 'log');
        end

        function scratchheat(obj, transindex, n)
            % Look up and display heatmap for 'Fully Retrained' case 
            transferns = [49, 100, 196, 289, 484, 4900];
            stringimage = strcat('Images/', obj.scratchpath, '_',...
                string(transferns(transindex)), '_', string(n), '.png');
            imshow(stringimage);
        end

        function plotscratchxy(obj)
            % Plot xy errors in 'fully retrained' case
            neg = zeros(6,1);
            pos = zeros(6,1);
            means = zeros(6,1);
            for i = 1:6
                means(i) = mean(obj.scratchxy(:,i));
                neg(i) = means(i) - min(obj.scratchxy(:,i));
                pos(i) = max(obj.scratchxy(:,i)) - means(i);
            end
            errorbar([49, 100, 196, 289, 484 4900], means, neg, pos, 'LineWidth', 2,...
                'Color', [0.5 0.5 0.5], 'DisplayName', 'From Scratch', 'LineStyle', ':');
            set(gca, 'LineWidth', 2, 'FontSize', 15);
            box off
            xlabel('Number of Inputs');
            ylabel('Average Error (mm)');
        end

        function plotscratchdp(obj)
            % Plot depth percentages in 'Fully Retrained' case
            neg = zeros(6,1);
            pos = zeros(6,1);
            means = zeros(6,1);
            for i = 1:6
                means(i) = mean(obj.scratchdepth(:,i));
                neg(i) = means(i) - min(obj.scratchdepth(:,i));
                pos(i) = max(obj.scratchdepth(:,i)) - means(i);
            end
            errorbar([49, 100, 196, 289, 484 4900], means, neg, pos, 'LineWidth', 2,...
                'Color', [0.5 0.5 0.5], 'DisplayName', 'From Scratch', 'LineStyle', ':');
            set(gca, 'LineWidth', 2, 'FontSize', 15);
            box off
            xlabel('Number of Inputs');
            ylabel('Correct Depths (%)');
        end

        function plotall(obj)
            % Create fig 5 or 6
            figure();
            subplot(2,3,1); obj.plotxy('three'); title('1 Frozen');
            subplot(2,3,2); obj.plotxy('five'); title('2 Frozen');
            subplot(2,3,3); obj.plotxy('seven'); title('3 Frozen');
            subplot(2,3,4); obj.plotdp('three');
            subplot(2,3,5); obj.plotdp('five');
            legend('Location', 's', 'NumColumns', 2); legend boxoff
            subplot(2,3,6); obj.plotdp('seven');
            set(gcf, 'Position', 1000*[0.0010 0.0410 1.5360 0.8448]);
        end

    end
end