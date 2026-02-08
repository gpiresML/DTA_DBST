function [result, model]=ac_class_FLD(zspatialTRAIN_t, zspatialTRAIN_nt, feat_sel, nfeat)

%% train dataset
auxmod1=zspatialTRAIN_t(:,feat_sel(1:nfeat));
auxmod2=zspatialTRAIN_nt(:,feat_sel(1:nfeat));

data.X = [auxmod1 ;auxmod2]';
data.y=[ones(1,size(auxmod1,1)) 2*ones(1,size(auxmod2,1))];

%training the classifier
model =jf_fisher(data);
result= model.W'*data.X+model.b;

end