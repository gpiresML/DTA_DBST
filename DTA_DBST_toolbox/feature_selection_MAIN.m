function win=feature_selection_MAIN(zfeat_t,zfeat_nt, feat_method, Nfeat_f)

% Feature selection
% feat_method 1: correlation; method 2: Fisher Score; method 3: MI; method 4: MI-corr; method 5: downsample

for samp=1:size(zfeat_t, 2) 
    xCSP_t(1,samp,:)=zfeat_t(:,samp);        
    xCSP_nt(1,samp,:)=zfeat_nt(:,samp);
end

if feat_method<=4
   feat_sel=gp_feature_selection(xCSP_t(1,:,:),xCSP_nt(1,:,:),feat_method,Nfeat_f,0);  
   win=feat_sel;
end
if feat_method==5 
   downrate=10;
   fim=size(zfeat_t,2);
       
   win=1:downrate:fim;
       
end     


