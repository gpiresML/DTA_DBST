
%% Self-paced ERP-based BCI speller conducted over multiple sessions spaced weeks apart (BCI-Self-paced Dataset - A unified framework) 
% Gabriel Pires, Aniana Cruz, Joana Figueiredo, Urbano J. Nunes

%% DEMO CODE

addpath('DTA_DBST_toolbox');
%%
clear; clc; 

%% %%%%%%%%%%%%%%%%%%%%%% Initializing parameters

sub=1;          %Subject id 1-8, example of subject S2
Session=1;      %session id 1-3
fc=[0.5 30];    %filter (Hz)
fs=256;         %sampling frequency (Hz)
Ts= 1/fs;
t = 0:Ts:1-Ts;
Nev = 28;            % Number of events
Num_channels = 12;   % Number of channels

%settings to extract epochs
t1=0; t2=1;         % Time segment onset offset  [0 1] seconds


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

%% %%%%%%%%%%%%%%%%%%%% loading data
subject_id = subject_id_list_train{j};

load(strcat('Data/',subject_id,'.mat'));

%% Extract P300 data - Get the target and non-target data    

ytrain = gp_extract_epochs(y,t1,t2,fs, Num_channels, Nev, 60, 70, 14);


ztarget=gp_norm_ensaio(ytrain.ytarget);
znontarget=gp_norm_ensaio(ytrain.yNONtarget);



end

%% %%%%%%%%%%%%%%%%%%%%%% Displaying P300 signal
p300=mean(ytrain.ytarget,3);
yNontarget_s = ytrain.yNONtarget;
figure; hold on; plot(t,p300(9,:),'r','linewidth',3) % channel PO7 
plot(t,mean(yNontarget_s(9,:,:),3),'b','linewidth',3)
legend('Target','Non-target');
xlabel('time (s)','FontSize',8)
ylabel('Amplitude (uV)','FontSize',8)
title(['EEG Signal at channel PO7 - Session ' num2str(Session) ' (average - TRAINING)'], 'fontweight', 'bold')


%% TESTING
for j_sub =1:length(subject_id_list_test) 
    
%% %%%%%%%%%%%%%%%%%%%% loading data
subject_id = subject_id_list_test{j_sub};

load(strcat('Data/',subject_id,'.mat'));


%% Extract P300 data - Get the target, non-target data, and non-control 
 
 ytrain = gp_extract_epochs(y,t1,t2,fs, Num_channels, Nev, 60, 70, 14);


ztarget=gp_norm_ensaio(ytrain.ytarget);
znontarget=gp_norm_ensaio(ytrain.yNONtarget);
yNonControl = gp_norm_ensaio(ytrain.yNonControl);
 

 
end

%% %%%%%%%%%%%%%%%%%%%%%% Displaying P300 signal
p300=mean(ytrain.ytarget,3);
yNontarget_s = ytrain.yNONtarget;
yNonControl_s = ytrain.yNonControl;
figure; hold on; plot(t,p300(9,:),'r','linewidth',3) % channel PO7 
plot(t,mean(yNontarget_s(9,:,:),3),'b','linewidth',3)
plot(t,mean(yNonControl_s(9,:,:),3),'m','linewidth',3)
legend('Target','Non-target','Non-control');
xlabel('time (s)','FontSize',8)
ylabel('Amplitude (uV)','FontSize',8)
title(['EEG Signal at channel PO7 - Session ' num2str(Session) ' (average - TESTING)'], 'fontweight', 'bold')


