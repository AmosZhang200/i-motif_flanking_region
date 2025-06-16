% This function reads csv data files output from an UV-vis machine 
% Cary3500 (Agilent) and converts it to a matlab variable

function currExp = saveUV()

% First we open up the dialog box to get the files from rawdata directory
[filenames,directory] = uigetfile('../rawdata/*.*','MultiSelect','on');

% uigetfile returns a cell array if multiple files are selected 
% if only one file is selected, it will only return the name as the string
% the code only works with cell arrays,
% so a single file name is turned to a cell array to prevent error
if ~iscell(filenames)
    filenames = {filenames};
end

% Iterate through all input files
for names_index = 1:length(filenames)
    filename = filenames{names_index};
    disp(filename)
    currExp = {};

    % Asking for how many samples run in the same csv file
    numSamples = input('The number of samples:');
    % asking for how many stages run in each experiment
    numStages = input('The number of stages:');

    for i = 1:numSamples
        experiment = uv();
        stageCell = {};
        for j = 1:numStages
            stageCell{end+1} = stage();
        end
        experiment.stages = stageCell;
        currExp{end+1} = experiment;
    end

    %% get name of each experiment
    for i = 1:numSamples
        name = input(strcat('The name of Sample', string(i), ":"));
        currExp{i}.name = name;
        for j = 1:numStages
            currExp{i}.stages{j}.name = name;
        end
    end


    %% get concentration of each experiment, optional
    for i = 1:numSamples
        concentration = input(strcat('The concentration of Sample', string(i), ":"));
        currExp{i}.concentration = concentration;
    end

    %% get pH of each experiment
    pH = input(strcat('The pH of Sample', string(i), ":"));
    for i = 1:numSamples
        currExp{i}.pH = pH;
    end

    %% get salt concentration of each buffer, optional
    for i = 1:numSamples
        salt = input(strcat('The salt and concentration of Sample', string(i), ":"));
        currExp{i}.salt = salt;
    end

    %% get wavelength of each experiment
    for i = 1:numSamples
        wavelength = input(strcat('The wavelength of the experiment', string(i), ":"));
        currExp{i}.wavelength = wavelength;
    end

    %% get temperature ramp rates of each experiment
    % cooling: negative scanrate
    % heating: positive scanrate
    prompt = [];
    for j = 1:numStages
        prompt = [prompt, strcat('The scan rate of stage', string(j))];
    end
    dlgtitle = "Initialize the scan rates of each stages";
    dims = [1, 45];
    % default temperature ramp rates are +-3, +-2, and +-1 for an UV-TH
    % experiment.
    definput = ["-3", "3", "-2", "2", "-1", "1"];
    answer = inputdlg(prompt, dlgtitle, dims, definput);

    for i = 1:numSamples
        for j = 1:numStages
            currExp{i}.scanrate{j} = str2double(answer(j));
            currExp{i}.stages{j}.scanrate = str2double(answer(j));
        end
    end
    
    %% get reference temperature of the experiment
    % optional
    Tref = input('The reference temperature of the samples:');
    for i = 1:numSamples
        if Tref < 150
            Tref = Tref + 273.15;
        end
        currExp{i}.Tref = Tref;
    end

    %% get temperature array and absorbance array of these experiments
    % read the csv file content 
    eachStageData = readcell(strcat(directory,filename));
    [~, nCol] = size(eachStageData);
    sampleNumber = nCol/2;
    if sampleNumber ~= numSamples*numStages
        disp("The sample size input doesn't match the actual data during initialization")
        saveUV()
    end
        
    %% Get if the experiment contained technical hysteresis
    % and correct for this hysteresis
    tempCorrection = input('If your temperature need correction:');
    for i = 1:numSamples
        for j = 1:numStages
            % for the temperature
            index = (i-1)*numStages + j;
            tempArr = [eachStageData{3:end, index*2-1}];
            tempNan = isnan(tempArr);
            % check if tempNan contain any 1
            % if the array contains 1, the array is missing values
            contain1 = any(tempNan(:) == 1);
            if contain1 == 1
                tempArr(tempNan) = [];
            end
            
            if tempCorrection == 1
                tempArr = actualTemperature(tempArr, currExp{i}.scanrate{j}, currExp{i}.pH);
            end

            % convert tempArr to unit Kalvin
            tempArr = tempArr + 273.15;
            currExp{i}.x{j} = tempArr;
            currExp{i}.stages{j}.tempArr = tempArr;
    
            % for the absorbance
            absArr = [eachStageData{3:end, index*2}];
            absNan = isnan(absArr);
            % check if absNan contain any 1
            % if the array contains 1, the array is missing values
            contain1 = any(absNan(:) == 1);
            if contain1 == 1
                absArr(absNan) = [];
            end
            currExp{i}.y{j} = absArr;
            currExp{i}.stages{j}.absArr = absArr;
        end
        currExp{i}.tempCorrected = tempCorrection;
    end
    
    %% set up color based on the sample and heating or cooling
    colors = getColor(numStages);
    for i = 1:numSamples
        for j = 1:numStages
            currExp{i}.color{j} = colors{j};
            currExp{i}.stages{j}.color = colors{j};
        end
    end

    date = filename(1:10);
    for i = 1:numSamples
        currExp{i}.date = date;
    end
    
    % create the new uv experiment (each store one experiment(multiple s))
    for i = 1:numSamples
        %saveExperiment(currExp{i}, filename(1:end-4));
        saveExperiment(currExp{i})
    end
    disp("Experiment save successfully in directory '" + "../processed/" + "'");
end
end