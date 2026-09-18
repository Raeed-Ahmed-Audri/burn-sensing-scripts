%% Function to read port signals
i1_file = readtable("data\raw\Planar Arm\i1.txt");

Time_ns = i1_file{:,1};
SqrtW = i1_file{:,2};

figure
plot(Time_ns, SqrtW)
title("i1")
xlabel("Time (ns)")
ylabel("W^(1/2)")

%o1_1 file
o1_1_file = readtable("data\raw\Planar Arm\o1_1.txt");

Time_ns_1 = o1_1_file{:,1};
SqrtW_1 = o1_1_file{:,2};

figure
plot(Time_ns_1, SqrtW_1)
title("o11")
xlabel("Time (ns)")
ylabel("W^(1/2)")

%o2_1 file
o2_1_file = readtable("data\raw\Planar Arm\o2_1.txt");

Time_ns_2 = o2_1_file{:,1};
SqrtW_2 = o2_1_file{:,2};

figure
plot(Time_ns_2, SqrtW_2)
title("o21")
xlabel("Time (ns)")
ylabel("W^(1/2)")

%% S-Parameter txt file loader
%S11
S11_file = readtable("data\raw\Planar Arm\S1,1.txt");

Freq = S11_file{:,1};
dB = S11_file{:,2};

figure
plot(Freq, dB)
title("S_1_1")
xlabel("Frequency (GHz))")
ylabel("dB")

%S21
S21_file = readtable("data\raw\Planar Arm\S2,1.txt");

Freq = S21_file{:,1};
dB = S21_file{:,2};

figure
plot(Freq, dB)
title("S_2_1")
xlabel("Frequency (GHz))")
ylabel("dB")

%% Voltage Probes
Voltage1 = readtable("data\raw\Planar Arm\Voltage1.txt");
Freq_voltage = Voltage1{:,1};
dB_voltage = Voltage1{:,2};
figure
plot(Freq_voltage, dB_voltage)
title("Voltage Probe")
xlabel("Frequency (GHz)")
ylabel("abs dB")

Voltage1_1 = readtable("data\raw\Planar Arm\voltage1_1.txt");
Freq_voltage1_1 = Voltage1_1{:,1};
dB_voltage1_1 = Voltage1_1{:,2};
figure
plot(Freq_voltage1_1, dB_voltage1_1)
title("Voltage Probe 1,1")
xlabel("Frequency (GHz)")
ylabel("abs dB")

Voltage1_1_1 = readtable("data\raw\Planar Arm\voltage1_1_1.txt");
Freq_voltage1_1_1 = Voltage1_1_1{:,1};
dB_voltage1_1_1 = Voltage1_1_1{:,2};
figure
plot(Freq_voltage1_1_1, dB_voltage1_1_1)
title("Voltage Probe 1,1,1")
xlabel("Frequency (GHz)")
ylabel("abs dB")

Voltage1_1_1_1 = readtable("data\raw\Planar Arm\voltage1_1_1_1.txt");
Freq_voltage1_1_1_1 = Voltage1_1_1_1{:,1};
dB_voltage1_1_1_1 = Voltage1_1_1_1{:,2};
figure
plot(Freq_voltage1_1_1_1, dB_voltage1_1_1_1)
title("Voltage Probe 1,1,1,1")
xlabel("Frequency (GHz)")
ylabel("abs dB")


