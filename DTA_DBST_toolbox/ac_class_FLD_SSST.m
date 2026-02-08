function [train, result, model]=ac_class_FLD_SSST(zspatialTRAIN_t, zspatialTRAIN_nt, zspatialTEST_nt, zspatialTEST_t, feat_sel, nfeat)

%% train dataset
auxmod1=zspatialTRAIN_t(:,feat_sel(1:nfeat));
auxmod2=zspatialTRAIN_nt(:,feat_sel(1:nfeat));
n1=size(auxmod1,1);
n2=size(auxmod2,1);

data.X = [auxmod1 ;auxmod2]';
data.y=[ones(1,size(auxmod1,1)) 2*ones(1,size(auxmod2,1))];

%training the classifier
model =jf_fisher(data);
result= model.W'*data.X+model.b;


tbt_t= result(1:n1);

%non_target
tbt_nt_ =result(n1+1:n1+n1*27);
tbt_nt =reshape(result(n1+1:n1+n1*27),27,n1);
tbt_nt=sort(tbt_nt,1,'descend');

%trail_by_trail matix
tbt=[tbt_nt; tbt_t];
tbt=sort(tbt,1,'descend');
std_nt_tre=std(tbt_nt_);

train.result=result;
train.n1=n1;
train.n2=n2;
train.std=std_nt_tre;
%% 
auxmod1_=zspatialTEST_t(:,feat_sel(1:nfeat));
auxmod2_=zspatialTEST_nt(:,feat_sel(1:nfeat));

n1=size(auxmod1_,1);
n2=size(auxmod2_,1);
data.X = [auxmod1_ ;auxmod2_]';

%% Test 1 - binary classification
result= model.W'*data.X+model.b;

end