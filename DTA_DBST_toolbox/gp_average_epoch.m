function [ztarget, zNONtarget]=gp_average_epoch(ytarget,yNONtarget,n_trial_target,n_trial_non_target,nepoch)

event=1;
for i=1:n_trial_target 
    ztarget(:,:,i)=mean(ytarget(:,:,event:event+(nepoch-1)),3); 
    event=event+5;
end
event=1;
for i=1:n_trial_non_target 
    zNONtarget(:,:,i)=mean(yNONtarget(:,:,event:event+(nepoch-1)),3); 
    event=event+5;
end


