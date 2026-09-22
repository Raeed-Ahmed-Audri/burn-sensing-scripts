function [interpolated_complex_value, Z0_material, gamma_epsilon_material] = fwrd_model_values(filepath, f)
    filepath = readtable(filepath);
    m = numel(f);

    %Initialize loop values
    Z0_material = zeros(1, m);
    gamma_epsilon_material = zeros(1, m);
    interpolated_complex_value = zeros(1, m);
    
    %Collecting Data from File
    freq = filepath{:,1};
    freq_HZ = transpose(freq*10^9);
    real_permittivity = filepath{:,2};
    imaginary_permittivity = filepath{:,3};

    %Manipulate Data to transpose as interp1 only works with a
    %certain type of matrix
    complex_numbers = real_permittivity -j*imaginary_permittivity;
    complex_numbers_transpose = transpose(complex_numbers);
    c = physconst("LightSpeed");


    for i = 1:m
        %Now we do our operations
        

        %Interpolate Frequencies
        interpolated_complex_value(i) = interp1(freq_HZ, complex_numbers_transpose, f(:,i));
        
        %Calculate Characteristic Impedance
        Z0_material(i) = 377./sqrt(interpolated_complex_value(i));
        
        %Calculate the Complex Propagation Constant
        gamma_epsilon_material(i) = j*2*pi*f(:,i).*sqrt(interpolated_complex_value(i))./c;
        

    end

end
    
% f = [3,5,6]*10^9;
% f1 = 3*10^9;
% filenames = "Skin_edit.txt";
% fwrd_model_values(filenames,f);
%characteristic_impedance_material(filename,f);
%gamma_epsilon_material("Skin_edit.txt",f);

