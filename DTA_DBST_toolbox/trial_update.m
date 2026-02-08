function [ztargetTRAIN, zNONtargetTRAIN] = trial_update(result, dataset_test, std_nt_tre, ztargetTEST, zNONtargetTEST, ztargetTRAIN, zNONtargetTRAIN)
% Performs trial update of training data based on classifier output scores.

% INPUTS:
%   result           : classifier scores 
%   dataset_test     : Dataset filename 
%   std_nt_tre       : Standard deviation for thresholding
%   ztargetTEST      : Target test data 
%   zNONtargetTEST   : Non-target test data
%   ztargetTRAIN     : Existing target training data
%   zNONtargetTRAIN  : Existing non-target training data
%
% OUTPUTS:
%   ztargetTRAIN     : Updated target training data
%   zNONtargetTRAIN  : Updated non-target training data
% =========================================================================

%% ==============================
% Parameters
% ==============================
nTarget    = 13;      % number of target trials
nSymbol    = 28;      % number of symbol
nNonTarget = 27;      % non-target per trial

n2 = 491;
[~, baseName, ~] = fileparts(dataset_test);
if strcmp(baseName(1:2), 'S8')
    n2 = 463;
end

nNonControl = floor((n2 - nNonTarget*nTarget) / nSymbol);

targetScores = result(1:nTarget);

ntScoresVec  = result(nTarget+1 : nTarget + nNonTarget*nTarget);
ntScoresMat  = reshape(ntScoresVec, nNonTarget, nTarget);
ntScoresMat  = sort(ntScoresMat, 1, 'descend');

trialControl = [ntScoresMat; targetScores];

startIdx = nTarget + nNonTarget*nTarget + 1;
endIdx   = startIdx + nSymbol*nNonControl - 1;
ncVec    = result(startIdx:endIdx);

trialNonControl = reshape(ncVec, nSymbol, nNonControl);

trial = [trialControl trialNonControl];
trial_ord = sort(trial, 1, 'descend');

T_Trials = find( ...
    mean(trial_ord(1:nNonTarget,:),1) - 3*std_nt_tre > trial_ord(nSymbol,:) ...
);

[~, minIdx] = min(trial, [], 1);
trial_result = ones(nSymbol, size(trial,2));

for k = 1:numel(T_Trials)
    c = T_Trials(k);
    trial_result(minIdx(c), c) = -1;
end

indT = find(trial_result == -1);

[classIdx, trialIdx] = ind2sub(size(trial_result), indT);


target_new = [];
target_new_ntarget = [];
nontarget_new_target = [];
nontarget_new_ntarget = [];

isControl_corr    = trialIdx <= nTarget;
isControl_err = ~isControl_corr;

isTarget     = classIdx == nSymbol;
isNonTarget  = ~isTarget;


ctrl_target = find(isControl_corr & isTarget);
ctrl_nt     = find(isControl_corr & isNonTarget);

for k = ctrl_target'
    t = trialIdx(k);
    target_new = [target_new t];

    % add all non-targets of this trial
    nontarget_new_ntarget = ...
        [nontarget_new_ntarget ((t-1)*nNonTarget+1):(t*nNonTarget)];
end

for k = ctrl_nt'
    t = trialIdx(k);      
    c = classIdx(k);     

    nontarget_new_target = ...
        [nontarget_new_target, t];

    all_idx = (t-1)*nNonTarget + (1:nNonTarget);
    all_idx(c) = [];
    nontarget_new_ntarget = ...
        [nontarget_new_ntarget, all_idx];
    target_new_ntarget = ...
        [target_new_ntarget, (t-1)*nNonTarget + c];
end



c_err_target = find(isControl_err & isTarget);
c_err_nt     = find(isControl_err & isNonTarget);

for k = c_err_target'
    nontarget_new_target = ...
        [nontarget_new_target trialIdx(k) - nTarget];
end


for k = c_err_nt'
    offset = nTarget * nNonTarget;

    sel_idx = offset + (trialIdx(k)-nTarget-1)*nSymbol + classIdx(k);
    target_new_ntarget = [target_new_ntarget, sel_idx];

    trial_base = offset + (trialIdx(k)-nTarget-1)*nSymbol;
    all_idx    = trial_base + (1:nSymbol);

    all_idx(classIdx(k)) = [];

    nontarget_new_ntarget = ...
        [nontarget_new_ntarget, all_idx];
end

%% ==============================
% Update training data
% ==============================
ztargetTRAIN = cat(3, ztargetTRAIN, ztargetTEST(:,:,target_new));
ztargetTRAIN = cat(3, ztargetTRAIN, zNONtargetTEST(:,:,target_new_ntarget));

zNONtargetTRAIN = cat(3, zNONtargetTRAIN, ztargetTEST(:,:,nontarget_new_target));
zNONtargetTRAIN = cat(3, zNONtargetTRAIN, zNONtargetTEST(:,:,nontarget_new_ntarget));

end


