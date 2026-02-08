function feat_sel=ac_feature_selection(zfeat_t,zfeat_nt,nfeat)

%------------------------------------------------- 
% Selection method - Correlation

for samp=1:size(zfeat_t, 2) 
    x1(1,samp,:)=zfeat_t(:,samp);       
    x2(1,samp,:)=zfeat_nt(:,samp);
end


ch=1;  
for i=1:size(x1,3)
     tst(i,:)=x1(ch,:,i);
     class(i)=1;                             
end
 
for i=1:size(x2,3)
     tst(i+size(x1,3),:)=x2(ch,:,i);
     class(i+size(x1,3))=0;           
end


for samp=1:size(x2, 2) 
   ressq(samp, ch)=rsquare(x1(ch, samp,:),x2(ch, samp,:));
end
[ord ind]=sort(ressq(:,ch),'descend');
feat_sel=ind(1:nfeat);
