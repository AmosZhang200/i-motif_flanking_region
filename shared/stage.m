% this function used to store a stage of an experiment as a structure
% each cooling or heating trace is considered as a stage
% experiment in this paper contains 6 stages (traces)

classdef stage
    properties
        % name of the sample
        name
        % temperature ramp rate i.e. how fast the experiment is running
        scanrate
        % the temperature array in Kelvin, x-axis
        tempArr
        % the absorbance array, y-axis
        absArr
        % hexadecimal color code for this stage trace.
        color
    end
end