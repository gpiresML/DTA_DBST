%% Self-paced ERP-based BCI speller conducted over multiple sessions spaced weeks apart (BCI-Self-paced Dataset - A unified framework) 
% Gabriel Pires, Aniana Cruz, Joana Figueiredo, Urbano J. Nunes

%% DEMO CODE

addpath('DTA_DBST_toolbox');

%%
clear; clc; 

%% %%%%%%%%%%%%%%%%%%%%%% Initializing parameters

sub=1;          %Subject id 1-8, example of subject S2
Session=1;      %session id 1-2
threshold = 1;      % Selecting the method: 1-DTA and 0-FLD

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
    subject_id_list_test = {
        cat(2, 'S', num2str(sub), '_w_Sess1_sentence1'), ...
        cat(2, 'S', num2str(sub), '_w_Sess1_sentence2'), ...
        cat(2, 'S', num2str(sub), '_w_Sess2_sentence1'), ...
        cat(2, 'S', num2str(sub), '_w_Sess2_sentence2'), ...
        cat(2, 'S', num2str(sub), '_w_Sess3_sentence1'), ...
        cat(2, 'S', num2str(sub), '_w_Sess3_sentence2')
    };
else
    subject_id_list_train = {cat(2, 'S', num2str(sub), '_wo_Sess2_sentence1')};
    subject_id_list_test = {
        cat(2, 'S', num2str(sub), '_w_Sess2_sentence1'), ...
        cat(2, 'S', num2str(sub), '_w_Sess2_sentence2'), ...
        cat(2, 'S', num2str(sub), '_w_Sess3_sentence1'), ...
        cat(2, 'S', num2str(sub), '_w_Sess3_sentence2')
    };
end

%% TRAINING
for j =1:length(subject_id_list_train) % participants
    
subject_id = subject_id_list_train{j};


load(strcat('Data/',subject_id,'.mat'));

%% Extract P300 data    

ytrain = gp_extract_epochs(y,t1,t2,fs, Num_channels, Nev, 60, 70, 14);


ztarget=gp_norm_ensaio(ytrain.ytarget);
znontarget=gp_norm_ensaio(ytrain.yNONtarget);
 
%% -----------------------Feature Extraction------------------------------------ 

[ztargetTRAIN, zNONtargetTRAIN]=gp_average_epoch(ztarget,znontarget,size(ztarget,3)/5,size(znontarget,3)/5,nepoch);

class.spatial.ncomp=2;  %number of components

%MODEL
U = gp_feature_extraction_model(ztargetTRAIN,zNONtargetTRAIN,1:12,class);
class.spatial.Uall=U;

%TRAIN
[zspatialTRAIN_t, zspatialTRAIN_nt]=gp_feature_extraction(ztargetTRAIN,zNONtargetTRAIN,1:12,class);
        
%% Feature Selection
feat_sel = ac_feature_selection(zspatialTRAIN_t,zspatialTRAIN_nt,nfeat);

%% Model Classification
[result, model] = ac_class_FLD(zspatialTRAIN_t, zspatialTRAIN_nt, feat_sel, nfeat);

std_nt =ac_bias_dist(result, size(zspatialTRAIN_t,1));
end

Pa = [];
%% TESTING
for j_sub =1:length(subject_id_list_test) % participants
    
subject_id = subject_id_list_test{j_sub};


load(strcat('Data/',subject_id,'.mat'));


%% Extract P300 data    
% Get the target and non-target data
 
 ytrain = gp_extract_epochs(y,t1,t2,fs, Num_channels, Nev, 60, 70, 14);


ztarget=gp_norm_ensaio(ytrain.ytarget);
znontarget=gp_norm_ensaio(ytrain.yNONtarget);
yNonControl = gp_norm_ensaio(ytrain.yNonControl);
 
if ynonCONTROLstate~=0
    yNONtargetTEST=cat(3,znontarget,yNonControl);
else
    yNONtargetTEST=znontarget;
end
 
 %% Feature Extraction  

[ztargetTEST, zNONtargetTEST]=gp_average_epoch(ztarget,yNONtargetTEST,size(ztarget,3)/5,size(yNONtargetTEST,3)/5,nepoch);

[zspatialTEST_t, zspatialTEST_nt]=gp_feature_extraction(ztargetTEST,zNONtargetTEST,1:12,class);

auxmod1_=zspatialTEST_t(:,feat_sel(1:nfeat));
auxmod2_=zspatialTEST_nt(:,feat_sel(1:nfeat));

n2=size(auxmod2_,1);
data.X = [auxmod1_ ;auxmod2_]';

%% Test 1 - binary classification
proj_test= model.W'*data.X+model.b;

n1_1=size(zspatialTEST_t,1);
n2_1=size(zspatialTEST_nt,1);
n1=n1_1;

n_t_nc_1=floor((n2_1-(n_sybol-1)*n1_1)/n_sybol);
n_t_nc=n_t_nc_1;

%target
trial_t=[proj_test(1:n1_1)];

%non-target
trial_nt_=[proj_test(n1_1+1:n1_1+n1_1*(n_sybol-1))];

trial_nt=reshape(trial_nt_,n_sybol-1,[]);
trial_nt=sort(trial_nt,1,'descend');

%trial_by_trial
trial=[trial_t;trial_nt];
trial=sort(trial,1,'descend');

% non-control
nc_tbt_= [proj_test(n1_1+n1_1*(n_sybol-1)+1:n1_1+n1_1*(n_sybol-1)+n_sybol*n_t_nc_1)];

nc_tbt= reshape(nc_tbt_,n_sybol,[]);
nc_tbt=sort(nc_tbt,'descend');

results = ac_FLD_Errors(trial, trial_t, trial_nt, nc_tbt, ...
                      factor, std_nt, n1, n_t_nc, threshold);
                  
Pa(j_sub)=results.Pa_accuracy;
P_c_r(j_sub)=results.P_c_r;
P_c_e(j_sub)=results.P_c_e;
P_c_nc(j_sub)=results.P_c_nc;
P_nc_nc(j_sub)=results.P_nc_nc;
end

