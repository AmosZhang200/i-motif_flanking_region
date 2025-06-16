% This class gives a struct to store raw UVTH (Thermal hysteresis)  
% data from Cary 3500 UV-vis (Agilent) as experiments               
% and provides functions for storing and loading experiments        

classdef uv
    properties
        % name of the sample
        name
        % date experiment is performed, with format "YYYY-MM-DD"
        date
        
        % stage properties
        x           % temperature array
        y           % absorbance array
        scanrate    % temperature ramp rates
        color       % color cells for all traces

        concentration   % sample concentration
        pH              % sample pH
        salt            % buffer salt concentration
        Tref            % reference temperature
        wavelength      % wavelength, 260 nm or 295 nm in this paper
        tempCorrected   % whether the temperature correction is applied
        stages          % each heating or cooling traces
    end

    methods
        function saveExperiment(temp)
            filepath = '../processed/';
            filename = strcat(temp.date, "_",temp.name, "_pH", temp.pH, "_",  temp.wavelength, '.mat'); %currExp.salt, "-",
            filepath = fullfile(filepath, filename); 
            save(filepath)
            return
        end

        % loads experiment (raw data)
        function [currExp, filename] = loadExperiment(~)
            [filename, filepath] = uigetfile('../../processed/*.*','MultiSelect','on');
            if isequal(filename, 0)
                error("User selected cancel. No .mat input files. " + ...
                    "Correct usage: input at least one .mat format file.");
            end
            
            if ~iscell(filename) 
                filename = {filename};
            end
            files = fullfile(filepath, filename);
            % a cell array of path + filenames
            for index = 1:length(files)
                file = files{index};
                currExp{index} = load(file).temp;
            end
        end

        function stages = loadStages(~)
            currExp = loadExperiment(uv);
            stages = currExp{1}.stages;
        end
    end
end