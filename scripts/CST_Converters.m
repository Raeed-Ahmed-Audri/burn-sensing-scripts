% %% Function to read port signals
close all; clc
% 
% runs = {
%     "A: Plate, no aperture",        "MetalPlateOnly_NoApperature",       [0.00 0.00 0.00], "-"
%     "B: Plate + aperture",          "Metal Plate with Apperature",       [0.00 0.45 0.74], "-"
%     "C: Plate + aperture + stack",  "Full Planar Stack with Aperature",  [0.85 0.15 0.10], "--"
% };
% sig = "o2,1";     % change to "o1,1" or "o2,1" later
% 
% fig = figure("Color","w","Position",[100 100 900 450]);
% ax  = axes(fig); hold(ax,"on")
% 
% for k = 1:size(runs,1)
%     T = readtable(fullfile(runs{k,2}, sig + ".txt"));
%     plot(ax, T{:,1}, T{:,2}, ...
%         "DisplayName", runs{k,1}, ...
%         "Color",       runs{k,3}, ...
%         "LineStyle",   runs{k,4}, ...
%         "LineWidth",   1.6)
% end
% 
% grid(ax,"on"); box(ax,"on")
% ax.FontSize      = 12;
% ax.LineWidth     = 1;
% ax.GridAlpha     = 0.25;
% ax.MinorGridAlpha = 0.1;
% 
% xlabel(ax, "Time (ns)")
% ylabel(ax, "Amplitude (W^{1/2})")
% title(ax,  sig + " for all runs")
% legend(ax, "Location","northeast","Box","off")
% xlim(ax, [0 6])



%o1_1 file
o1_1_file = readtable("Excitation_Signal.txt");

Time_ns_1 = o1_1_file{:,1};
SqrtW_1 = o1_1_file{:,2};

figure
plot(Time_ns_1, SqrtW_1)
title("Excitation Signal")
xlabel("Time (ns)")
ylabel("W^(1/2)")
% 
% %o2_1 file
% o2_1_file = readtable("data\raw\Planar Arm\o2_1.txt");
% 
% Time_ns_2 = o2_1_file{:,1};
% SqrtW_2 = o2_1_file{:,2};
% 
% figure
% plot(Time_ns_2, SqrtW_2)
% title("o21")
% xlabel("Time (ns)")
% ylabel("W^(1/2)")

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

%% .s2p files for two port device
s2p = sparameters ("yourfile.s2p");
rfplot(s2p,1,1); %Plot S11
rfplot(s2p,2,1); %Plot S22


%%
% Plots S11 and S21 (complex, from Re/Im exports) for runs A, B, C.
% Figure 1: magnitude (dB) and unwrapped phase overlays
% Figure 2: difference between runs (the actual effect you care about)

close all; clc

runs = struct( ...
    "label", {"A: Plate, no aperture", "B: Plate + aperture", "C: Plate + aperture + stack"}, ...
    "file",  {"MetalPlateOnly_NoApperature\S-parameters_real+imag.txt", "Metal Plate with Apperature\S_parameters_real_imag.txt", "Full Planar Stack with Aperature\S-parameters_Real_imag.txt"}, ...
    "color", {[0 0 0], [0 0.45 0.74], [0.85 0.15 0.10]}, ...
    "style", {"-", "-", "--"});
fmin = 2; fmax = 9;          % GHz plot range
saveFigs = true;

for k = 1:numel(runs)
    D = readSparams(runs(k).file);
    runs(k).f   = D.S21(:,1);
    runs(k).S11 = D.S11(:,2) + 1i*D.S11(:,3);
    runs(k).S21 = D.S21(:,2) + 1i*D.S21(:,3);
end

% sanity check: all runs must share the same frequency axis
for k = 2:numel(runs)
    assert(isequal(runs(k).f, runs(1).f), "Frequency axes differ between runs")
end
f = runs(1).f;

fig1 = figure("Color","w","Position",[100 100 1200 750]);
tl = tiledlayout(fig1, 2, 2, "TileSpacing","compact", "Padding","compact");

ax = nexttile(tl); hold(ax,"on")
for k = 1:numel(runs)
    plot(ax, f, 20*log10(abs(runs(k).S11)), "Color",runs(k).color, ...
        "LineStyle",runs(k).style, "LineWidth",1.6, "DisplayName",runs(k).label)
end
style_ax(ax, "|S_{11}| (dB)", "S_{11} magnitude", [fmin fmax]);
legend(ax, "Location","best", "Box","off")

ax = nexttile(tl); hold(ax,"on")
for k = 1:numel(runs)
    plot(ax, f, 20*log10(abs(runs(k).S21)), "Color",runs(k).color, ...
        "LineStyle",runs(k).style, "LineWidth",1.6, "DisplayName",runs(k).label)
end
style_ax(ax, "|S_{21}| (dB)", "S_{21} magnitude", [fmin fmax]);

ax = nexttile(tl); hold(ax,"on")
for k = 1:numel(runs)
    plot(ax, f, rad2deg(unwrap(angle(runs(k).S11))), "Color",runs(k).color, ...
        "LineStyle",runs(k).style, "LineWidth",1.6)
end
style_ax(ax, "Phase (deg)", "S_{11} phase", [fmin fmax]);

ax = nexttile(tl); hold(ax,"on")
for k = 1:numel(runs)
    plot(ax, f, rad2deg(unwrap(angle(runs(k).S21))), "Color",runs(k).color, ...
        "LineStyle",runs(k).style, "LineWidth",1.6)
end
style_ax(ax, "Phase (deg)", "S_{21} phase", [fmin fmax]);

% |S_x - S_y| in dB. Lower = runs agree. Compare against the early-time
% mesh noise floor before trusting small differences.
fig2 = figure("Color","w","Position",[100 100 1200 450]);
tl = tiledlayout(fig2, 1, 2, "TileSpacing","compact", "Padding","compact");

pairs = {2, 1, "B - A (aperture)", [0 0.45 0.74];
         3, 2, "C - B (stack)",    [0.85 0.15 0.10]};

ax = nexttile(tl); hold(ax,"on")
for p = 1:size(pairs,1)
    d = runs(pairs{p,1}).S11 - runs(pairs{p,2}).S11;
    plot(ax, f, 20*log10(abs(d)), "Color",pairs{p,4}, "LineWidth",1.6, "DisplayName",pairs{p,3})
end
style_ax(ax, "|\DeltaS_{11}| (dB)", "S_{11} difference", [fmin fmax]);
legend(ax, "Location","best", "Box","off")

ax = nexttile(tl); hold(ax,"on")
for p = 1:size(pairs,1)
    d = runs(pairs{p,1}).S21 - runs(pairs{p,2}).S21;
    plot(ax, f, 20*log10(abs(d)), "Color",pairs{p,4}, "LineWidth",1.6, "DisplayName",pairs{p,3})
end
style_ax(ax, "|\DeltaS_{21}| (dB)", "S_{21} difference", [fmin fmax]);

if saveFigs
    exportgraphics(fig1, "Sparams_mag_phase.png", "Resolution", 300);
    exportgraphics(fig2, "Sparams_differences.png", "Resolution", 300);
end

function style_ax(ax, ylab, ttl, xl)
    grid(ax,"on"); box(ax,"on")
    ax.FontSize = 12; ax.LineWidth = 1; ax.GridAlpha = 0.25;
    xlabel(ax, "Frequency (GHz)"); ylabel(ax, ylab); title(ax, ttl)
    xlim(ax, xl)
end

function D = readSparams(fname)
% Reads a CST ASCII export holding several blocks (S1,1 then S2,1, ...).
% Returns struct with fields S11, S21 as [f, Re, Im] matrices.
    L   = readlines(fname);
    D   = struct();
    cur = "";
    buf = zeros(0,3);
    for i = 1:numel(L)
        s = strtrim(L(i));
        if s == "", continue, end
        if startsWith(s, "#")
            tok = regexp(char(s), 'S(\d),(\d) \[Re\]', 'tokens', 'once');
            if ~isempty(tok)
                if cur ~= "", D.(cur) = buf; end
                cur = "S" + string(tok{1}) + string(tok{2});
                buf = zeros(0,3);
            end
        else
            v = sscanf(char(s), '%f')';
            if numel(v) == 3, buf(end+1,:) = v; end %#ok<AGROW>
        end
    end
    if cur ~= "", D.(cur) = buf; end
end

%% Delete Later
% Difference plots for o2,1 (or any port signal) between runs A, B, C.
% Top panel: raw overlay. Bottom panel: differences, with the mesh-noise
% window (0.85-1.85 ns) shaded and the noise floor drawn as dashed lines.

close all; clc

% ---- EDIT: folders and filename ----
folders = ["MetalPlateOnly_NoApperature", ...
           "Metal Plate with Apperature", ...
           "Full Planar Stack with Aperature"];
labels  = ["A: Plate, no aperture", "B: Plate + aperture", "C: Plate + aperture + stack"];
sigFile = "o2,1.txt";            % change to match your exported filename
noiseWin = [0.85 1.85];          % ns, window where all runs should agree
plotWin  = [0 6];                % ns, x-range for both panels
saveFig  = true;

% ---- Load ----
% Each run can have a different time step (time step depends on smallest
% mesh cell), so every signal is interpolated onto run A's time axis.
raw = cell(1,3);
for k = 1:3
    M = readmatrix(fullfile(folders(k), sigFile), "NumHeaderLines", 2);
    M = M(all(~isnan(M),2), :);
    raw{k} = M;
end

t = raw{1}(:,1);
tEnd = min(cellfun(@(M) M(end,1), raw));
t = t(t <= tEnd);

o = zeros(numel(t), 3);
for k = 1:3
    o(:,k) = interp1(raw{k}(:,1), raw{k}(:,2), t, "pchip");
end
oA = o(:,1); oB = o(:,2); oC = o(:,3);

% ---- Differences ----
d_BA = oB - oA;   % aperture effect
d_CB = oC - oB;   % stack effect
d_CA = oC - oA;   % net effect

% Noise floor = largest difference inside the window where nothing physical differs
inWin = t >= noiseWin(1) & t <= noiseWin(2);
floorLvl = max(abs([d_BA(inWin); d_CB(inWin); d_CA(inWin)]));

% ---- Plot ----
cA = [0 0 0]; cB = [0 0.45 0.74]; cC = [0.85 0.15 0.10];

fig = figure("Color","w","Position",[100 100 1100 750]);
tl = tiledlayout(fig, 2, 1, "TileSpacing","compact", "Padding","compact");

ax1 = nexttile(tl); hold(ax1,"on")
plot(ax1, t, oA, "Color",cA, "LineWidth",1.6, "DisplayName",labels(1))
plot(ax1, t, oB, "Color",cB, "LineWidth",1.6, "DisplayName",labels(2))
plot(ax1, t, oC, "--", "Color",cC, "LineWidth",1.6, "DisplayName",labels(3))
styleAx(ax1, "Amplitude (W^{1/2})", "o_{2,1} for all runs", plotWin)
legend(ax1, "Location","northeast", "Box","off")

ax2 = nexttile(tl); hold(ax2,"on")
yl = 1.2*max(abs([d_BA; d_CB; d_CA]));
patch(ax2, [noiseWin(1) noiseWin(2) noiseWin(2) noiseWin(1)], [-yl -yl yl yl], ...
    [0.5 0.5 0.5], "FaceAlpha",0.12, "EdgeColor","none", "DisplayName","Mesh-noise window")
plot(ax2, t, d_BA, "Color",cB, "LineWidth",1.6, "DisplayName","B - A (aperture)")
plot(ax2, t, d_CB, "Color",cC, "LineWidth",1.6, "DisplayName","C - B (stack)")
plot(ax2, t, d_CA, "Color",[0.47 0.67 0.19], "LineWidth",1.6, "DisplayName","C - A (net)")
yline(ax2,  floorLvl, ":", "Color",[0.3 0.3 0.3], "LineWidth",1.2, "HandleVisibility","off")
yline(ax2, -floorLvl, ":", "Color",[0.3 0.3 0.3], "LineWidth",1.2, "DisplayName","Noise floor (\pm)")
styleAx(ax2, "\Delta Amplitude (W^{1/2})", "Differences between runs", plotWin)
ylim(ax2, [-yl yl])
legend(ax2, "Location","northeast", "Box","off")

linkaxes([ax1 ax2], "x")
xlabel(tl, "Time (ns)", "FontSize", 12)

% ---- Numbers ----
after = t > noiseWin(2);
fprintf("Noise floor (max |diff| in %.2f-%.2f ns): %.4g\n", noiseWin, floorLvl)
fprintf("Peak |B-A| after window: %.4g  (%.1fx floor)\n", max(abs(d_BA(after))), max(abs(d_BA(after)))/floorLvl)
fprintf("Peak |C-B| after window: %.4g  (%.1fx floor)\n", max(abs(d_CB(after))), max(abs(d_CB(after)))/floorLvl)
fprintf("Peak |C-A| after window: %.4g  (%.1fx floor)\n", max(abs(d_CA(after))), max(abs(d_CA(after)))/floorLvl)

if saveFig
    exportgraphics(fig, "o21_differences.png", "Resolution", 300);
end

function styleAx(ax, ylab, ttl, xl)
    grid(ax,"on"); box(ax,"on")
    ax.FontSize = 12; ax.LineWidth = 1; ax.GridAlpha = 0.25;
    ylabel(ax, ylab); title(ax, ttl)
    xlim(ax, xl)
end