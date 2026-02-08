function results = ac_FLD_Errors(trial, trial_t, trial_nt, nc_tbt, ...
                      factor, std_nt, n1, n_t_nc, threshold)
% Computes classification performance, considering control (target and non-target) and non-control trials.

% INPUTS:
%   trial      : FLD scores 
%   trial_t    : target trials  
%   trial_nt   : Non-target trials
%   nc_tbt     : non-control trials
%   factor     : Threshold 
%   std_nt     : Standard deviation for threshold calculation
%   n1         : Number of control trials
%   n_t_nc     : Number of non-control trials
%   threshold  : Selecting the method: 1-DTA and 0-FLD
%
% OUTPUT:
%   results : structure with fields
%       P_c_r          - Correct control and correct target character (well-written character) (%)
%       P_c_e          - Correct control but wrong target character (misspelled character) (%)
%       P_c_nc         - Control misclassified as non-control (false negative) (%)
%       P_nc_nc        - Correct non-control recognition(%)
%       Pa_accuracy  - final accuracy (%)
%

TARGET = 28;
NONTARGET = 1:27;

%% ================= CONTROL TRIALS =================

right_target = find(trial_t == trial(28,:));
wrong_target = find(trial_t ~= trial(28,:));

N_c_e = 0; N_c_r = 0; N_c_nc = 0; N_nc_nc = 0; N_nc_e = 0;

if threshold == 1

    % ---- correct control + wrong target
    if ~isempty(wrong_target)
        error_FLD = find(trial(TARGET, wrong_target) < ...
            mean(trial_nt(:, wrong_target), 1) - factor * std_nt);
        N_c_e = numel(error_FLD);
    end

    % ---- correct control + correct target
    correct_FLD = find(trial(TARGET, right_target) < ...
        mean(trial_nt(:, right_target), 1) - factor * std_nt);
    N_c_r = numel(correct_FLD);

    % ---- non-control
    error_absten = find(trial(TARGET, 1:n1) > ...
        mean(trial_nt, 1) - factor * std_nt);
    N_c_nc = numel(error_absten);


    correct_nc_FLD = find(nc_tbt(TARGET,:) > ...
        mean(nc_tbt(NONTARGET,:), 1) - factor * std_nt);
    N_nc_nc = numel(correct_nc_FLD);

    N_nc_e = sum(nc_tbt(TARGET,:) < ...
        mean(nc_tbt(NONTARGET,:), 1) - factor * std_nt);

else
    if ~isempty(wrong_target)
        N_c_e = sum(trial(TARGET, wrong_target) < 0);
    end

    N_c_r = sum(trial(TARGET, right_target) < 0);

    N_c_nc = sum(trial(TARGET,1:n1) > 0);

    N_nc_nc = sum(nc_tbt(TARGET,:) > 0);
    N_nc_e  = sum(nc_tbt(TARGET,:) < 0);
end

%% ================= METRICS =================
Pc_r   = (N_c_r  / n1)      * 100;
Pc_e   = (N_c_e  / n1)      * 100;
Pc_nc  = (N_c_nc / n1)      * 100;
Pnc_nc = (N_nc_nc / n_t_nc) * 100;

Pa = (1 - (N_c_e + N_c_nc + N_nc_e) / (n1 + n_t_nc)) * 100;

results = struct( ...
    'P_c_r',   Pc_r, ...
    'P_c_e',   Pc_e, ...
    'P_c_nc',  Pc_nc, ...
    'P_nc_nc', Pnc_nc, ...
    'Pa_accuracy', Pa );

end
