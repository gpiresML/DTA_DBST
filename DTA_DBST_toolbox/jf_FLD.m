function [result, std_nt_tre, train, n1, n2] = jf_FLD( zspatialTRAIN_t, zspatialTRAIN_nt, zspatialTEST_t, zspatialTEST_nt, feat_sel, nfeat, test_file)

%% ===============================
% TRAIN
% ===============================
auxmod1 = zspatialTRAIN_t(:, feat_sel(1:nfeat));
auxmod2 = zspatialTRAIN_nt(:, feat_sel(1:nfeat));

n1 = size(auxmod1,1);
n2 = size(auxmod2,1);

data.X = [auxmod1 ; auxmod2]';
data.y = [ones(1,n1) 2*ones(1,n2)];

model = jf_fisher(data);

result_train = model.W' * data.X + model.b;

tbt_t  = result_train(1:n1);
tbt_nt_ = result_train(n1+1:end);

std_nt_tre = std(tbt_nt_);

train.model = result_train;
train.n1 = n1;
train.n2 = n2;
train.std = std_nt_tre;

%% ===============================
% TEST
% ===============================

if test_file == 0
    result = [];
else
    auxmod1_ = zspatialTEST_t(:, feat_sel(1:nfeat));
    auxmod2_ = zspatialTEST_nt(:, feat_sel(1:nfeat));

    n1 = size(auxmod1_,1);
    n2 = size(auxmod2_,1);

    data.X = [auxmod1_ ; auxmod2_]';

    result = model.W' * data.X + model.b;
end
end
