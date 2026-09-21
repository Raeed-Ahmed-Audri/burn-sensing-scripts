function [interpolated_complex_value] = load_itis_dispersion(filepath, frequency)
    filepath = readtable(filepath);
    freq = filepath{:,1};
    freq_HZ = transpose(freq*10^9);
    real_permittivity = filepath{:,2};
    imaginary_permittivity = filepath{:,3};
    complex_numbers = real_permittivity -j*imaginary_permittivity;
    complex_numbers_transpose = transpose(complex_numbers);
    
    %Interpolate the data
    interpolated_complex_value = interp1(freq_HZ,complex_numbers_transpose, frequency);
  
end

function [Z0_material] =  characteristic_impedance_material(filepath, f)
    eps_complex = load_itis_dispersion(filepath,f);
    Z0_material = 377./sqrt(eps_complex) 

end

function [gamma_epsilon] = gamma_epsilon_material(filepath, f)
    eps_complex = load_itis_dispersion(filepath,f);
    c = physconst("LightSpeed");
    gamma_epsilon = j*2*pi*f.*sqrt(eps_complex)./c
end

function [interpolated_complex_value, Z0_material, gamma_epsilon_material] = fwrd_model_values(filenames, f)
    n = numel(filenames)

end
    
https://www.mathworks.com/matlabcentral/answers/2100341-iterating-over-a-cell-array-do-for-loops-work
f = [3,5,6]*10^9;
f1 = 3*10^9;
filenames = ["Skin_edit.txt","Skin_edit.txt" ];
fwrd_model_values(filenames,f)
%characteristic_impedance_material(filename,f);
%gamma_epsilon_material("Skin_edit.txt",f);
