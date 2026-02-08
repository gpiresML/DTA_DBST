function yout = gp_extract_epochs(y1,t1,t2,fs, Num_channels, Nev, TARGET1, TARGET2, label_id)
%extracts the target, non-target, and non-control epochs (if they exist).
    
    %Non-target events
    auxAll=[];
    for id_ev=1:Nev
        aux = gp_load_data_Symbols(y1,Num_channels,id_ev,t1,t2,fs,label_id);
        auxAll=cat(3,auxAll,aux);
    end
    yout.yNONtarget = auxAll;
    
    %Target events LEFT
    id_ev=TARGET1;
    aux = gp_load_data_Symbols(y1,Num_channels,id_ev,t1,t2,fs,label_id);    
    yout.ytarget1 = aux;

    %Target events RIGHT
    id_ev=TARGET2;
    aux = gp_load_data_Symbols(y1,Num_channels,id_ev,t1,t2,fs,label_id);    
    yout.ytarget2 = aux;

    %Concatenates left and right targets
    yout.ytarget = cat(3,yout.ytarget1,yout.ytarget2);
    
    %Non Control events 
    id_ev=77;
    if any(y1(label_id,:) >= id_ev)
        aux = gp_load_data_Symbols(y1, Num_channels, id_ev, t1, t2, fs, label_id);
    else
        aux = [];  % Empty instead of NaNs
    end
    yout.yNonControl = aux;
end