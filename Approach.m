classdef Approach
% Single transfer methods, with different weightings.
% i.e. each line in figs 5 & 6 stored as an Approach object.

    properties
        xythree % 1 frozen layer: xy errors
        xyfive % 3 frozen layers: xy errors
        xyseven % 5 frozen layers: xy errors
        dpthree % 1 frozen layer: depth percentages
        dpfive % 2 frozen layers: depth percentages
        dpseven % 3 frozen layers: depth percentages
    end

    methods
        function obj = Approach(xythree, xyfive, xyseven, dpthree, dpfive, dpseven)
            %Constructor
            obj.xythree = xythree;
            obj.xyfive = xyfive;
            obj.xyseven = xyseven;
            obj.dpthree = dpthree;
            obj.dpfive = dpfive;
            obj.dpseven = dpseven;
        end
    end
end