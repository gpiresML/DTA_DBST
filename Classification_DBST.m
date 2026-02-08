%% Self-paced ERP-based BCI speller conducted over multiple sessions spaced weeks apart (BCI-Self-paced Dataset - A unified framework) 
% Gabriel Pires, Aniana Cruz, Joana Figueiredo, Urbano J. Nunes

%% DEMO CODE

addpath('DTA_DBST_toolbox');

%%
clear; clc; 

%% %%%%%%%%%%%%%%%%%%%%%% Initializing parameters

sub=1;          %Subject id 1-8, example of subject S2
Session=1;      %session id 1-2

fc=[0.5 30];    %filter (Hz)
fs=256;         %sampling frequency (Hz)
Ts= 1/fs;
t = 0:Ts:1-Ts;
Nev = 28;            % Number of events
Num_channels = 12;   % Number of channels

t1=0; t2=1;         % Time segment onset offset  [0 1] seconds
nfeat = 100;        % Number of Feature
nepoch = 4;         % Number of epoch
factor = 2.75;      %
n_sybol=28;         % Number of symbol
ynonCONTROLstate = 77;    %Id for non control state

%% Subject S*

if Session == 1
    subject_id_list_train = {cat(2, 'S', num2str(sub), '_wo_Sess1_sentence1')};
    subject_id_list_update = {
        cat(2, 'S', num2str(sub), '_w_Sess1_sentence1'), ...
        cat(2, 'S', num2str(sub), '_w_Sess2_sentence1'), ...
        cat(2, 'S', num2str(sub), '_w_Sess3_sentence1')
    };
    subject_id_list_test = {
        cat(2, 'S', num2str(sub), '_w_Sess1_sentence2'), ...
        cat(2, 'S', num2str(sub), '_w_Sess2_sentence2'), ...
        cat(2, 'S', num2str(sub), '_w_Sess3_sentence2')
    };
else
    subject_id_list_train = {cat(2, 'S', num2str(sub), '_wo_Sess2_sentence1')};
    subject_id_list_update = {
        cat(2, 'S', num2str(sub), '_w_Sess2_sentence1'), ...
        cat(2, 'S', num2str(sub), '_w_Sess3_sentence1')
    };
    subject_id_list_test = {
        cat(2, 'S', num2str(sub), '_w_Sess2_sentence2'), ...
        cat(2, 'S', num2str(sub), '_w_Sess3_sentence2')
    };
end



Pa = [];
for j_sub = 1:length(subject_id_list_test) % participants
    
subject_id = subject_id_list_train{1};
dataset_train = strcat('Data/',subject_id,'.mat');
update=0;
test_file=0;

[~,  ~, ~, ~, ztargetTRAIN, zNONtargetTRAIN]  = ac_classification_update( ...
        update, test_file, dataset_train, [], ...
        t1, t2, fs, Num_channels, Nev, 1, nepoch, nfeat,[],[]);

fprintf('First Trainning\n');

update=1;
subject_id = subject_id_list_update{j_sub};
dataset_test = strcat('Data/',subject_id,'.mat');
test_file=1;


[result,  std_nt_tre, ztargetTEST, zNONtargetTEST]  = ac_classification_update( ...
        update, test_file, dataset_train, dataset_test, ...
        t1, t2, fs, Num_channels, Nev, 1, nepoch, nfeat,ztargetTRAIN,zNONtargetTRAIN);
    
fprintf('Test using Sentence 1 for update \n');

[ztargetTRAIN_update, zNONtargetTRAIN_update] = trial_update(result, dataset_test, std_nt_tre, ztargetTEST, zNONtargetTEST, ztargetTRAIN, zNONtargetTRAIN);

subject_id = subject_id_list_test{j_sub};
dataset_test = strcat('Data/',subject_id,'.mat');

[result,  std_nt_tre, ~, ~, ~, ~, train, n1, n2]  = ac_classification_update( ...
        update, test_file, dataset_train, dataset_test, ...
        t1, t2, fs, Num_channels, Nev, 1, nepoch, nfeat,ztargetTRAIN_update,zNONtargetTRAIN_update);

fprintf('Test using Sentence 2 \n');

std_nt_up =ac_bias_dist(train.model, train.n1);

proj_test= result;
n1_1=n1;
n2_1=n2;

n_t_nc_1=floor((n2_1-(n_sybol-1)*n1_1)/n_sybol);
n_t_nc=n_t_nc_1;

%target
trial_t=proj_test(1:n1_1);

%non-target
trial_nt_=proj_test(n1_1+1:n1_1+n1_1*(n_sybol-1));

trial_nt=reshape(trial_nt_,n_sybol-1,[]);
trial_nt=sort(trial_nt,1,'descend');

%trial_by_trial
trial=[trial_t;trial_nt];
trial=sort(trial,1,'descend');

% non-control
nc_tbt_= proj_test(n1_1+n1_1*(n_sybol-1)+1:n1_1+n1_1*(n_sybol-1)+n_sybol*n_t_nc_1);

nc_tbt= reshape(nc_tbt_,n_sybol,[]);
nc_tbt=sort(nc_tbt,'descend');


results = ac_FLD_Errors(trial, trial_t, trial_nt, nc_tbt, ...
                      factor, std_nt_up, n1, n_t_nc, 1);
                                    
Pa(j_sub)=results.Pa_accuracy;
P_c_r(j_sub)=results.P_c_r;
P_c_e(j_sub)=results.P_c_e;
P_c_nc(j_sub)=results.P_c_nc;
P_nc_nc(j_sub)=results.P_nc_nc;
end

