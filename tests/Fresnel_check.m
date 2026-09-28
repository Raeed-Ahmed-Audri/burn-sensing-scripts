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

%% Fresnel Test
f = 3*10^9;
intrinsic_impedance = 377;

layers(1).filepath = [];
layers(1).eps = 1;
layers(1).d = [];

layers(2).filepath = "Skin_edit.txt";
layers(2).d = [];

N = numel(layers);
M = numel(f);

Zin = zeros(N,M); %N is whatever value, M is frequencies
Z0 = zeros(N,M);
gamma = zeros(N,M);
epsilon = zeros(N,M);

Zair = intrinsic_impedance;
Z0(1,:) = Zair;

[epsilon_skin, ~, ~] = fwrd_model_values(layers(2).filepath,f);
Zin(N, : ) = intrinsic_impedance ./sqrt(epsilon_skin);
Z0(N,:) = Zin(N,:);

%Find Characteristic Impedances
for k = 2:N-1
    [~,Z0_k, ~] = fwrd_model_values(layers(k).filepath,f);
    Z0(k,:) = Z0_k;
end

%Recursion: work backward up to layer 2 (skin)
for k =N-1:-1:2
    [~, ~, gk] = fwrd_model_values(layers(k).filepath,f);
    Zin(k,:) = Z0(k,:) .* (Zin(k+1, :)+Z0(k,:).*tanh(gk.*layers(k).d))./(Z0(k,:)+Zin(k+1,:).*tanh(gk.*layers(k).d));

end

gamma_th = (Zin(2,:)-Zair)./(Zin(2,:)+Zair);
