
if update==0
    datafile=dataset_train;
    train_file=1;
    if train_file     
        ynonCONTROLstate = 77;
        data_train = load(dataset_train);
         ytrain = gp_extract_epochs(data_train.y,t1,t2,fs, Num_channels, Nev, 60, 70, 14);

         if norm ~= 0 
                ytargetTRAIN=gp_norm_ensaio(ytrain.ytarget);
                znontarget=gp_norm_ensaio(ytrain.yNONtarget);
                if ~isempty(ytrain.yNonControl)
                    yNonControl = gp_norm_ensaio(ytrain.yNonControl);
                else
                    yNonControl = [];  
                end
         end
         
         if ~isempty(yNonControl)
            yNONtargetTRAIN = cat(3, znontarget, yNonControl);
        else
            yNONtargetTRAIN = znontarget;
        end  
    end

end

if test_file    
    data_test = load(dataset_test);
    ytrain = gp_extract_epochs(data_test.y,t1,t2,fs, Num_channels, Nev, 60, 70, 14);

     if norm ~= 0 
            ytargetTEST=gp_norm_ensaio(ytrain.ytarget);
            znontarget=gp_norm_ensaio(ytrain.yNONtarget);
            if ~isempty(ytrain.yNonControl)
                    yNonControl = gp_norm_ensaio(ytrain.yNonControl);
                else
                    yNonControl = [];  
            end
     end

    if ~isempty(yNonControl)
        yNONtargetTEST=cat(3,znontarget,yNonControl);
    else
        yNONtargetTEST=znontarget;
    end  
        
end

if test_file==0
    ytargetTEST=ytargetTRAIN;
    yNONtargetTEST=yNONtargetTRAIN;
end


 clear ztargetTEST zNONtargetTEST
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if update==0 
    nEventstarget=size(ytargetTRAIN,3)/nepoch;    nEventsNONtarget=size(yNONtargetTRAIN,3)/nepoch;
    [ztargetTRAIN zNONtargetTRAIN]=gp_average_epoch(ytargetTRAIN,yNONtargetTRAIN,nEventstarget,nEventsNONtarget,nepoch);
 end

%%
[ztargetTEST zNONtargetTEST]=gp_average_epoch(ytargetTEST,yNONtargetTEST,size(ytargetTEST,3)/nepoch,size(yNONtargetTEST,3)/nepoch,nepoch);

%--------------------------------------------------------------------------
% FEATURE EXTRACTION
%--------------------------------------------------------------------------
    clear zspatialTRAIN_t zspatialTRAIN_nt zspatialTEST_t zspatialTEST_nt Uall P
    class.spatial.ncomp=2;  %number of components

    %MODEL
    Uall = gp_feature_extraction_model(ztargetTRAIN,zNONtargetTRAIN,1:12,class);
    class.spatial.Uall=Uall;


    %TRAIN
    [zspatialTRAIN_t zspatialTRAIN_nt]=gp_feature_extraction(ztargetTRAIN,zNONtargetTRAIN,1:12,class);
    %TEST
    [zspatialTEST_t zspatialTEST_nt]=gp_feature_extraction(ztargetTEST,zNONtargetTEST,1:12,class);
    zfeat_all_train=cat(1,zspatialTRAIN_t,zspatialTRAIN_nt); 
    zfeat_all_test=cat(1,zspatialTEST_t,zspatialTEST_nt);
    
%--------------------------------------------------------------------------
% FEATURE SELECTION
%--------------------------------------------------------------------------
%     feat_sel=feature_selection_MAIN(zspatialTRAIN_t,zspatialTRAIN_nt, feat_method,nfeat); 
    feat_sel = ac_feature_selection(zspatialTRAIN_t,zspatialTRAIN_nt,nfeat);
    
%--------------------------------------------------------------------------
% CLASSIFICATION
%--------------------------------------------------------------------------
    jf_FLD_antigo   



