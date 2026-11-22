function [t_out, y_diff, lag_s, residual_s, out] = diff_func(ref_in, tgt_in, win_start, win_end, max_lag, make_plots, verbose)
%DIFF_FUNC  Subtract a reference trace from a target trace, with time alignment.
%
%   [t_out, y_diff, lag_s, residual_s, out] = diff_func(ref_in, tgt_in, win_start, win_end)
%   [...] = diff_func(ref_in, tgt_in, win_start, win_end, max_lag, make_plots, verbose)
%
%   ref_in, tgt_in : CST export file name (time in ns, 2 columns)
%                    OR an N x 2 matrix [time_in_seconds, signal]
%   win_start, win_end : lag window in seconds (direct arrival only)
%   max_lag    : max xcorr lag to search, in samples      (default 24)
%   make_plots : true/false                                 (default true)
%   verbose    : true/false, print the reports              (default true)
%
%   y_diff     = target (aligned) - reference
%   lag_s      : applied lag in seconds. Positive = target leads (reference is late)
%   residual_s : lag left after alignment, in seconds (should be near 0)
%   out        : struct with the intermediate vectors, for plotting or tests
%
%   For the paper's pipeline the reference is ALWAYS Sc (aperture plate):
%       S1 = diff_func(Sc, Sm, ...)     S2 = diff_func(Sc, St, ...)

if nargin < 5 || isempty(max_lag),    max_lag = 24;       end
if nargin < 6 || isempty(make_plots), make_plots = true;  end
if nargin < 7 || isempty(verbose),    verbose = true;     end

% Read Files (file name or [t_s, y] matrix)
[t_ref, y_ref] = get_trace(ref_in);
[t_tgt, y_tgt] = get_trace(tgt_in);

%Valid Data check
assert(issorted(t_ref, "strictascend"), "Time is not Increasing for the Reference Trace");
assert(issorted(t_tgt, "strictascend"), "Time is not Increasing for the Target Trace");
assert(all(isfinite(t_ref)), "There appears to be Missing Time Values in the Reference Trace");
assert(all(isfinite(t_tgt)), "There appears to be Missing Time Values in the Target Trace");
assert(all(isfinite(y_ref)), "There appears to be Missing Data Values in the Reference Trace");
assert(all(isfinite(y_tgt)), "There appears to be Missing Data Values in the Target Trace");

%Comparing grids
diff_tref = diff(t_ref);
median_Ref_trace = median(diff_tref);
nonuniformity_ref = abs((max(diff_tref)-min(diff_tref))/median_Ref_trace);

diff_ttgt = diff(t_tgt);
median_tgt_trace = median(diff_ttgt);
nonuniformity_tgt = abs((max(diff_ttgt)-min(diff_ttgt))/median_tgt_trace);

if nonuniformity_ref > 1e-3
    warning("The Reference Trace is not Uniform")
end
if nonuniformity_tgt > 1e-3
    warning("The Target Trace is not Uniform")
end

rel_diff_dt = abs(median_Ref_trace - median_tgt_trace) / min(median_Ref_trace, median_tgt_trace);

t_start = max(t_ref(1), t_tgt(1));
t_end = min(t_ref(end), t_tgt(end));

dt = min(median_Ref_trace, median_tgt_trace);
N = round((t_end - t_start) / dt) + 1;
t_common_rows = linspace(t_start, t_end, N);
t_common = t_common_rows';
dt_c = (t_end - t_start) / (N - 1); %Exact grid step that linspace used

%Resampling both traces onto t_common
y_ref_resampled = pchip(t_ref, y_ref, t_common);
y_tgt_resampled = pchip(t_tgt, y_tgt, t_common);

%Estimate the lag (window on the direct arrival only)
t_common_mask = (t_common >= win_start) & (t_common <= win_end);
refined_lag = xcorr_lag(y_ref_resampled, y_tgt_resampled, t_common_mask, max_lag);
lag_s = refined_lag * dt_c; %lag in seconds

%Evaluate the target at shifted times
t_query = t_common - lag_s;        % times to read the target at by getting rid of the lag
y_tgt_aligned = pchip(t_tgt, y_tgt, t_query);

% Trim samples whose shifted time falls outside the target's original record
keep = (t_query >= t_tgt(1)) & (t_query <= t_tgt(end));
t_out = t_common(keep);
y_ref_out = y_ref_resampled(keep);
y_tgt_aligned = y_tgt_aligned(keep);

assert(all(isfinite(y_tgt_aligned)), "Aligned target contains NaN or Inf");

% Check: residual lag after alignment should be close to 0
m2 = (t_out >= win_start) & (t_out <= win_end);
residual_s = xcorr_lag(y_ref_out, y_tgt_aligned, m2, max_lag) * dt_c;

if abs(residual_s) > 0.5*dt_c %More than half a sample
    warning("Residual lag is %.3f ps. If it is about twice the applied lag, flip the sign of the shift.", residual_s*1e12);
end

% Difference (target minus reference)
y_diff = y_tgt_aligned - y_ref_out;

% Summary numbers
ref_peak = max(abs(y_ref_out));
[max_diff, i_max] = max(abs(y_diff));
tail = t_out >= (t_out(end) - 1e-9);              % last 1 ns of the record
tail_rms = sqrt(mean(y_diff(tail).^2));

%Printouts
if verbose
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
    fprintf('%-24s %16.3e\n',        'Rel. diff in spacing',   rel_diff_dt);
    fprintf('%s\n', repmat('=', 1, line_w));

    fprintf('%-24s\n', 'ALIGNMENT AND DIFFERENCE');
    fprintf('%s\n', repmat('-', 1, line_w));
    fprintf('%-34s %22.4f\n', 'Common grid step (ps)',          dt_c*1e12);
    fprintf('%-34s %22.3f\n', 'Lag window (ns)',                 win_start*1e9);
    fprintf('%-34s %22.3f\n', '   to (ns)',                      win_end*1e9);
    fprintf('%-34s %22.3f\n', 'Applied lag (ps, + = tgt leads)', lag_s*1e12);
    fprintf('%-34s %22.3f\n', 'Residual lag (ps)',               residual_s*1e12);
    fprintf('%-34s %15d of %d\n', 'Samples kept',                nnz(keep), numel(keep));
    fprintf('%-34s %22.4e\n', 'Reference peak |y|',              ref_peak);
    fprintf('%-34s %22.4e\n', 'Max |diff|',                      max_diff);
    fprintf('%-34s %22.4f\n', '   at time (ns)',                 t_out(i_max)*1e9);
    fprintf('%-34s %21.2f%%\n', 'Max |diff| / ref peak',         100*max_diff/ref_peak);
    fprintf('%-34s %22.4e\n', 'Tail RMS of diff (last 1 ns)',    tail_rms);
    fprintf('%-34s %22.1f\n', 'Max |diff| / tail RMS',           max_diff/tail_rms);
    fprintf('%s\n\n', repmat('=', 1, line_w));
end

%Plots
if make_plots
    tn = t_common*1e9;   to = t_out*1e9;   % ns for plotting
    figure('Name', 'diff_func');

    subplot(3,1,1)
    plot(tn, y_ref_resampled, tn, y_tgt_resampled); hold on
    yl = ylim;  plot([win_start win_start]*1e9, yl, 'k--', [win_end win_end]*1e9, yl, 'k--'); hold off
    title('Before alignment (dashed = lag window)'); legend('Reference', 'Target'); xlabel('Time (ns)'); grid on

    subplot(3,1,2)
    plot(to, y_ref_out, to, y_tgt_aligned)
    title(sprintf('After alignment (applied lag %.3f ps, residual %.3f ps)', lag_s*1e12, residual_s*1e12))
    legend('Reference', 'Target aligned'); xlabel('Time (ns)'); grid on

    subplot(3,1,3)
    plot(to, y_diff)
    title(sprintf('Difference: target - reference (max %.3e, tail RMS %.3e)', max_diff, tail_rms))
    xlabel('Time (ns)'); grid on
end

% Extra outputs for tests / later steps
out.t_common = t_common;
out.y_ref_resampled = y_ref_resampled;
out.y_tgt_resampled = y_tgt_resampled;
out.y_ref_out = y_ref_out;
out.y_tgt_aligned = y_tgt_aligned;
out.dt_c = dt_c;
out.max_diff = max_diff;
out.ref_peak = ref_peak;
out.tail_rms = tail_rms;
end


%% ---------------- Local functions ----------------
function [t, y] = get_trace(in)
% File name -> read CST export (ns -> s). Matrix -> already [t_s, y].
if ischar(in) || isstring(in)
    T = readtable(in);
    t = T{:,1}*10^-9;   y = T{:,2};   % ns -> s
else
    t = in(:,1);  y = in(:,2);
end
t = t(:);  y = y(:);
end

function refined_lag = xcorr_lag(a, b, mask, max_lag)
% Sub-sample lag of a relative to b, in samples. Positive = a is delayed (b leads).
% a and b are FULL traces on the same grid. The window (mask) is applied to a only,
% and b is read at shifted positions, so every trial lag uses the same number of
% samples. (Correlating two cut-out segments loses overlap at the window edges and
% biases the lag toward 0.)
idx = find(mask);
idx = idx(idx - max_lag >= 1 & idx + max_lag <= numel(b));   % keep shifts in range
lags = -max_lag:max_lag;
r = zeros(size(lags));
for k = 1:numel(lags)
    b_k  = b(idx - lags(k));                  % target slid past the window
    r(k) = sum(a(idx) .* b_k) / sqrt(sum(b_k.^2));   % normalized: energy moving in/out of the window can't bias it
end
[~, idx] = max(r); %Index of the best match

if idx > 1 && idx < length(r)
    y_minus = r(idx - 1);
    y_zero  = r(idx);
    y_plus  = r(idx + 1);

    % Parabolic interpolation offset (-0.5 <= delta <= 0.5)
    delta = 0.5 * (y_minus - y_plus) / (y_minus - 2*y_zero + y_plus);
    if ~isfinite(delta)
        warning("Parabolic refinement failed (flat peak), using whole-sample lag")
        delta = 0;
    end
    refined_lag = lags(idx) + delta;
else
    warning("xcorr peak is at the edge of the lag range, widen the max lag or move the window")
    refined_lag = lags(idx);
end
end
