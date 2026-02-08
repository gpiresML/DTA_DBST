function std_nt_tre =ac_bias_dist_SSST(result, n1)

%% Calculo do valor do bias_distancia
tbt_t= result(1:n1);

%non_target
tbt_nt_ =result(n1+1:n1+n1*27);
tbt_nt =reshape(result(n1+1:n1+n1*27),27,n1);
tbt_nt=sort(tbt_nt,1,'descend');

%trail_by_trail matix
tbt=[tbt_nt; tbt_t];
tbt=sort(tbt,1,'descend');
std_nt_tre=std(tbt_nt_);
end