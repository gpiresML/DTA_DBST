
% n1 = 13;
% n2 = 491;
% 
% [~, baseName, ~] = fileparts(dataset_test);  % Get filename
% 
% if strcmp(baseName(1:2), 'S8')
%     n2 = 463;
% end
% 
% n_t_nc = floor((n2 - 27*n1) / 28);
% 
% trail_t = result(1:n1);
% 
% trail_nt_ = result(n1+1 : n1 + n1*27);
% trail_nt  = reshape(trail_nt_, 27, n1);
% trail_nt  = sort(trail_nt, 1, 'descend');
% 
% trail = [trail_nt; trail_t];
% trail_ord = sort(trail, 1, 'descend');
% 
% %% FIX 1: correct start index for non-control trials
% %nc_tbt_ = result(n1 + n1*27 + 1 : n1 + n1*27 + 28*n_t_nc);
% nc_tbt_ = result(n1*27 + 1 : n1*27 + 28*n_t_nc);
% nc_tbt  = reshape(nc_tbt_, 28, n_t_nc);
% nc_tbt_ord = sort(nc_tbt, 'descend');
% 
% trail = [trail nc_tbt];
% trail_ord = [trail_ord nc_tbt_ord];
% 
% j = find(mean(trail_ord(1:27,:)) - 3*std_nt_tre > trail_ord(28,:));
% 
% 
% [m, mn] = min(trail, [], 1);
% trail_result = ones(28, size(trail,2));
% 
% for k = 1:length(j)
%     trail_result(mn(j(k)), j(k)) = -1;
% end
% 
% target_new = [];
% target_new_ntarget = [];
% 
% ind_r = find(trail_result == -1)';
% 
% for k = 1:length(ind_r)
%     val = ind_r(k) / 28;
%     if isequal(fix(val), val) && val <= n1
%         target_new = [target_new val];
%     else
%         if val < n1
%             target_new_ntarget = [target_new_ntarget ind_r(k) - floor(val)];
%         else
%             target_new_ntarget = [target_new_ntarget ind_r(k) - n1];
%         end  
%     end
% end
% 
% nontarget_new_target = [];
% nontarget_new_ntarget = [];
% 
% ind_r = find(trail_result == -1)';
% 
% for k = 1:length(ind_r)
%     val = ind_r(k) / 28;
% 
%     if isequal(fix(val), val) && val <= n1
%         nontarget_new_ntarget = ...
%             [nontarget_new_ntarget (val*27 - 26 : 27*val)];
%     else
%         if val <= n1
%             val1 = ceil(val);
% 
%             %% FIX 2 & 3: correct non-target indexing (before & after target)
%             nontarget_new_ntarget = [nontarget_new_ntarget (val1-1)*27 + 1 : ind_r(k) - 28*(val1-1) - 1, ind_r(k) - 28*(val1-1) + 1 : val1*27];
% 
%             nontarget_new_target = [nontarget_new_target val1];
%         else
%             val1 = ceil(val);
%             nontarget_new_ntarget = ...
%                 [nontarget_new_ntarget ...
%                  (n1*27) + (val1-n1)*28 - 27 : ind_r(k) - n1 - 1, ...
%                  ind_r(k) - n1 + 1 : (n1*27) + (val1-n1)*28];
%         end
%     end
% end
% 
% update_type = 1;
% 
% if update_type == 1
%     ztargetTRAIN = cat(3, ztargetTRAIN, ztargetTEST(:,:,target_new));
%     ztargetTRAIN = cat(3, ztargetTRAIN, zNONtargetTEST(:,:,target_new_ntarget));
% 
%     zNONtargetTRAIN = cat(3, zNONtargetTRAIN, ztargetTEST(:,:,nontarget_new_target));
%     zNONtargetTRAIN = cat(3, zNONtargetTRAIN, zNONtargetTEST(:,:,nontarget_new_ntarget));
% 
%     PERC_erro = ...
%         length(target_new_ntarget)/(length(target_new)+length(target_new_ntarget)) + ...
%         length(nontarget_new_target)/(length(nontarget_new_ntarget)+length(nontarget_new_target))
% 
%     N_training_target = size(ztargetTRAIN)
%     N_training_NONtarget = size(zNONtargetTRAIN)
% 
% else
%     ztargetTRAIN = ztargetTEST(:,:,target_new);
%     ztargetTRAIN = cat(3, ztargetTRAIN, zNONtargetTEST(:,:,target_new_ntarget));
% 
%     zNONtargetTRAIN = ztargetTEST(:,:,nontarget_new_target);
%     zNONtargetTRAIN = cat(3, zNONtargetTRAIN, zNONtargetTEST(:,:,nontarget_new_ntarget));
% end




%% Trail by trail update
n1=13;
n2=491;

[~, baseName, ~] = fileparts(dataset_test);  % Get filename 

if strcmp(baseName(1:2), 'S8')
    n2 = 463;
end

n_t_nc=floor((n2-27*n1)/28);
trail_t=[result(1:n1)];

trail_nt_=[result(n1+1:n1+n1*27)];
trail_nt=reshape(trail_nt_,27,n1);
trail_nt=sort(trail_nt,1,'descend');


trail=[trail_nt;trail_t];
trail_ord=sort(trail,1,'descend');
%nc_tbt_= [result(n1*27+1:n1*27+28*n_t_nc)];
nc_tbt_= [result(n1 + n1*27+1:n1+n1*27+28*n_t_nc)];
nc_tbt= reshape(nc_tbt_,28,(n_t_nc));
nc_tbt_ord=sort(nc_tbt,'descend');
trail=[trail nc_tbt];
trail_ord=[trail_ord nc_tbt_ord];
j=find (mean(trail_ord(1:27,:))-3*std_nt_tre>trail_ord(28,:));

[m mn]=min(trail,[],1);
trail_result=ones(28,size(trail,2));
for k=1:size(j,2)
trail_result(mn(j(k)),j(k))=-1;
end

target_new=[];target_new_ntarget=[];
ind_r=find(trail_result==-1)';
for k=1:size(ind_r,2)
    val=ind_r(k)/28;
   if isequal(fix(val),val) && val<=n1
        target_new=[target_new val];
   else
       if val<n1
       target_new_ntarget=[target_new_ntarget ind_r(k)-floor(val)];
       else
           target_new_ntarget=[target_new_ntarget ind_r(k)-n1];
       end  
   end
end

nontarget_new_target=[];nontarget_new_ntarget=[];
ind_r=find(trail_result==-1)';
for k=1:size(ind_r,2)
    val=ind_r(k)/28;
   if isequal(fix(val),val) && val<=n1
        nontarget_new_ntarget =[nontarget_new_ntarget  ([(val*27)-26:27*val])];
   else

       if val<=n1
       val1=ceil(val);
       
       nontarget_new_ntarget =[nontarget_new_ntarget (val1*27)-26:ind_r(k)-floor(val)-1 ind_r(k)-floor(val)+1:27*val1];
       nontarget_new_target=[nontarget_new_target val1];
       else 
           val1=ceil(val);
           nontarget_new_ntarget =[nontarget_new_ntarget (n1*27)+((val1-n1)*28)-27:ind_r(k)-n1-1 ind_r(k)-n1+1:(n1*27)+(val1-n1)*28];
       end 
   end  
end

update_type=1;

if update_type==1
    ztargetTRAIN=cat(3,ztargetTRAIN,ztargetTEST(:,:,target_new));
    ztargetTRAIN=cat(3,ztargetTRAIN,zNONtargetTEST(:,:,target_new_ntarget));

    zNONtargetTRAIN=cat(3,zNONtargetTRAIN,ztargetTEST(:,:, nontarget_new_target));
    zNONtargetTRAIN=cat(3,zNONtargetTRAIN,zNONtargetTEST(:,:,nontarget_new_ntarget ));
    
    PERC_erro = length(target_new_ntarget)/(length(target_new)+length(target_new_ntarget)) + length(nontarget_new_target)/(length(nontarget_new_ntarget)+length(nontarget_new_target))
    N_training_target = size(ztargetTRAIN)
    N_training_NONtarget = size(zNONtargetTRAIN)
%     length(target_new_ntarget)
%     length(target_new)
    

else
    ztargetTRAIN=ztargetTEST(:,:,target_new);
    ztargetTRAIN=cat(3,ztargetTRAIN,zNONtargetTEST(:,:,target_new_ntarget));

    zNONtargetTRAIN=ztargetTEST(:,:, nontarget_new_target);
    zNONtargetTRAIN=cat(3,zNONtargetTRAIN,zNONtargetTEST(:,:,nontarget_new_ntarget ));
    
end

