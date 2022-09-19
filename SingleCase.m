classdef SingleCase
% Contain reference data for figs 5 & 6 plots
% Contained in Transfer objects
    properties
        xymean % Mean xy error for case
        depthpercentage % Depth percentage for case
        savename % String if looking up heatmap
    end

    methods
        function obj = SingleCase(xymean, depthpercentage, savename)
            %Constructor
            obj.xymean = xymean;
            obj.depthpercentage = depthpercentage;
            obj.savename = savename;
        end

        function heat(obj)
            % Display heatmap
            stringimage = strcat('Images/', obj.savename, '.png');
            imshow(stringimage);
        end
    end
end