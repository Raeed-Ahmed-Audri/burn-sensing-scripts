%% Difference Function
% Read Files
reference_file = readtable("MetalPlate_Apperature.txt"); %Left Empty for now
target_file = readtable("FullStack.txt"); %Left Empty for same reason above

t_ref = reference_file{:,1}*10^-9;   y_ref = reference_file{:,2};
t_tgt = target_file{:,1}*10^-9;  y_tgt = target_file{:,2};

%Valid Data check
assert(issorted(t_ref, "strictascend"), "Time is not Inreasing for the Reference Trace");
assert(issorted(t_tgt, "strictascend")==1, "Time is not Inreasing for the Difference Trace");
assert(~anynan(t_ref), "There appears to be Missing Time Values in the Reference Trance");
assert(~anynan(t_tgt), "There appears to be Missing Time Values in the Difference Trance");
assert(~anynan(y_ref), "There appears to be Missing Data Values in the Reference Trance");
assert(~anynan(y_tgt), "There appears to be Missing Data Values in the Difference Trance");

%Comparing grids
diff_tref = diff(t_ref);
median_Ref_trace = median(diff_tref);
nonuniformity_ref = abs((max(diff_tref)-min(diff_tref))/median_Ref_trace);

diff_ttgt = diff(t_tgt);
median_tgt_trace = median(diff_ttgt);
nonuniformity_tgt = abs((max(diff_ttgt)-min(diff_ttgt))/median_tgt_trace);


if nonuniformity_ref > 1e-3 
    warning("The Reference Trace is not Uniform")
    
elseif nonuniformity_tgt > 1e-3
      warning("The Difference Trace is not Uniform")

end

rel_diff_dt = abs(median_Ref_trace - median_tgt_trace) / min(median_Ref_trace, median_tgt_trace); %Grid Comparison Report
line_w = 58;

fprintf('\n%s\n', repmat('=', 1, line_w));
fprintf('%-24s %16s %16s\n', 'GRID COMPARISON', 'Reference', 'Target');
fprintf('%s\n', repmat('-', 1, line_w));
fprintf('%-24s %16d %16d\n',     'Samples',               numel(t_ref),           numel(t_tgt));
fprintf('%-24s %16.6g %16.6g\n', 'First time (ns)',        t_ref(1)*1e9,           t_tgt(1)*1e9);
fprintf('%-24s %16.6g %16.6g\n', 'Last time (ns)',         t_ref(end)*1e9,         t_tgt(end)*1e9);
fprintf('%-24s %16.6g %16.6g\n', 'Median spacing (ns)',    median_Ref_trace*1e9,   median_tgt_trace*1e9);
fprintf('%-24s %16.3e %16.3e\n', 'Non-uniformity ratio',   nonuniformity_ref,      nonuniformity_tgt);
fprintf('%s\n', repmat('-', 1, line_w));
fprintf('%-24s %16.3e\n',        'Rel. diff in spacing',  rel_diff_dt);
fprintf('%s\n\n', repmat('=', 1, line_w));


t_start = max(t_ref(1), t_tgt(1));
t_end = min (t_ref(end), t_tgt(end));

dt = min(median_Ref_trace, median_tgt_trace);
N = round((t_end - t_start) / dt) + 1;
t_common_rows = linspace(t_start, t_end, N);
t_common = t_common_rows';

%Resampling both traces onto t_common
y_ref_resampled = pchip(t_ref, y_ref, t_common);
y_tgt_resampled = pchip(t_tgt, y_tgt, t_common);

%Estimate the lag
%plot(t_common,y_ref_resampled, t_common, y_tgt_resampled)
t_common_mask = (t_common>=1.17e-9 ) & (t_common<= 2.04e-9);
y_ref_mask = y_ref_resampled(t_common_mask);
y_tgt_mask = y_tgt_resampled(t_common_mask);

[r, lags] = xcorr(y_ref_mask,y_tgt_mask,24);   
[maxVal, idx] = max(r); %Max Value and Index Position

if idx > 1 && idx < length(r)
    y_minus = r(idx - 1);
    y_zero  = r(idx);
    y_plus  = r(idx + 1);
    
    % Parabolic interpolation offset (-0.5 <= delta <= 0.5)
    delta = 0.5 * (y_minus - y_plus) / (y_minus - 2*y_zero + y_plus);
    
    % Refined lag and interpolated peak amplitude
    refined_lag = lags(idx) + delta;
else
    refined_lag = lags(idx);
end
lag_ps = refined_lag*dt*10^12 ;

%Evaluate the target at shifted times
y_target_shifted


%% Envelope Extraction Via Hilbert Transform