function std_nt =ac_bias_dist(result, n1)

m_t=mean(result(1:n1));
m_nt=mean(result(n1+1:n1+n1*27));
if m_t>m_nt
    result= result*(-1);
end

%% Train dataset
%target
tbt_t= result(1:n1);

%non_target
tbt_nt =reshape(result(n1+1:n1+n1*27),27,n1);
tbt_nt=sort(tbt_nt,1,'descend');

%trail_by_trail matix
tbt=[tbt_nt; tbt_t];
tbt=sort(tbt,1,'descend');

%% right target (train dataset)
trial_right=find(tbt(28,:)==result(1:n1));

%% Train dataset only with right data
%right target events
tbt_t=result(trial_right);

%right non-target events
tbt_nt=tbt_nt(:,trial_right);
nt=reshape(tbt_nt(1:27,:),1,27*size(trial_right,2));

std_nt=std(nt);

end