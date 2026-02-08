function [zfeat_t, zfeat_nt]=gp_feature_extraction(ztarget,zNONtarget,g,class)

%--------------------------------------------------------------------------
% FLD several projections
ncomp=class.spatial.ncomp;  %number of components
Uall=class.spatial.Uall;

for i=1:size(ztarget,3)   
    [Zt(:,:,i) yt1(i,:)]=gp_LDA(Uall,ztarget(:,:,i),g);
    zfeat_t(i,:)=concat_components(Zt(:,:,i),ncomp);
end
for i=1:size(zNONtarget,3)
    [Znt(:,:,i) ynt2(i,:)]=gp_LDA(Uall,zNONtarget(:,:,i),g);
    zfeat_nt(i,:)=concat_components(Znt(:,:,i),ncomp);
end


end

