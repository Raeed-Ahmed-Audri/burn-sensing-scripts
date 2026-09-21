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
f = {3,5,6}*10^9;
load_itis_dispersion("Skin_edit.txt", f);

