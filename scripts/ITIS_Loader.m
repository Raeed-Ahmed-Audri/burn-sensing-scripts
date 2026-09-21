%% ---- Settings ----
scriptDir   = fileparts(matlab.desktop.editor.getActiveFilename); % folder where this script lives
if isempty(scriptDir)
    scriptDir = pwd; % fallback if not run from the Editor
end

inputFolderName  = 'Sasaki Data';              % <-- name of the folder containing your .txt files
outputFolderName = 'Working Data';   % <-- name of the folder to save results into

inputFolder  = fullfile(scriptDir, inputFolderName);
outputFolder = fullfile(scriptDir, outputFolderName);

% Create output folder if it doesn't exist
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% ---- Process all .txt files in the input folder ----
epsilon_not = 8.8541878188*10^-12;

txtFiles = dir(fullfile(inputFolder, '*.txt'));

for k = 1:length(txtFiles)
    filename = txtFiles(k).name;
    fullInputPath = fullfile(inputFolder, filename);

    % Read data
    data = readmatrix(fullInputPath, 'NumHeaderLines', 2);

    % Apply the math
    omega = data(:,1)*2*pi;
    data(:,3) = data(:,3)./(omega*epsilon_not);
    data(:,1) = data(:,1) * 10^-9;

    % Build new filename: "originalname_edit.txt"
    [~, name, ext] = fileparts(filename);
    newfilename = [name '_edit' ext];
    fullOutputPath = fullfile(outputFolder, newfilename);

    % Write it out
    writematrix(data, fullOutputPath, 'Delimiter', 'tab');

    fprintf('Processed: %s -> %s\n', filename, newfilename);
end

fprintf('Done. %d file(s) processed.\n', length(txtFiles));

%% Dispersion Loader
%Write function in the form of epsilon' - j*epsilon"
clc
function [complex_numbers, interpolated_complex_value] = load_itis_dispersion(filepath, frequency)
    filepath = readtable(filepath);
    freq = filepath{:,1};
    freq_HZ = transpose(freq*10^9);
    real_permittivity = filepath{:,2};
    imaginary_permittivity = filepath{:,3};
    complex_numbers = real_permittivity -j*imaginary_permittivity;
    complex_numbers_transpose = transpose(complex_numbers);
    
    %Interpolate the data
    interpolated_complex_value = interp1(freq_HZ,complex_numbers_transpose, frequency)
  
end
f = [3,5,6]*10^9;
load_itis_dispersion("Skin_edit.txt", f);

