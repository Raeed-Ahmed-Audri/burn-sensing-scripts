%% Helper Function
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

%% FWRD Model Continoued 
Total_points = 3;
Step_Value = (9-2)/(Total_points-1);
f = [2:Step_Value:9]*10^9;

layers(1).filepath = [];
layers(1).eps = 1;
layers(1).d = [];

layers(2).filepath = "Skin_edit.txt";

layers(2).d = 0.002;

layers(3).filepath = "Skin_edit.txt";
layers(3).d = 0.005;

layers(4).filepath = "Skin_edit.txt";
layers(4).d = 0.010;

layers(5).filepath = "Skin_edit.txt";
layers(5).d = [];

%Add more layers as needed

N = numel(layers);
M = numel(f);

for k = N:2
   if k = N
       layers(k).input_impedance = 
       


end