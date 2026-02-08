function [result, std_nt_tre, ztargetTEST, zNONtargetTEST, ztargetTRAIN, zNONtargetTRAIN, train, n1, n2]  = ac_classification_update( ...
        update, test_file, dataset_train, dataset_test, t1, t2, fs, Num_channels, Nev, norm, nepoch, nfeat,ztargetTRAIN,zNONtargetTRAIN)

% =============================
% INITIALIZATION
% =============================
train_file = 1;
ynonCONTROLstate = [];

% =============================
% TRAINING DATA
% =============================
if update == 0
    datafile = dataset_train;

    if train_file
        ynonCONTROLstate = 77;
        data_train = load(dataset_train);

        ytrain = gp_extract_epochs( ...
            data_train.y, t1, t2, fs, Num_channels, Nev, 60, 70, 14);

        
        ytargetTRAIN = gp_norm_ensaio(ytrain.ytarget);
        znontarget   = gp_norm_ensaio(ytrain.yNONtarget);

        if ~isempty(ytrain.yNonControl)
            yNonControl = gp_norm_ensaio(ytrain.yNonControl);
        else
            yNonControl = [];
        end
        

        if ~isempty(yNonControl)
            yNONtargetTRAIN = cat(3, znontarget, yNonControl);
        else
            yNONtargetTRAIN = znontarget;
        end
    end
end

% =============================
% TEST DATA
% =============================
if test_file
    data_test = load(dataset_test);

    ytrain = gp_extract_epochs( ...
        data_test.y, t1, t2, fs, Num_channels, Nev, 60, 70, 14);

    
    ytargetTEST = gp_norm_ensaio(ytrain.ytarget);
    znontarget  = gp_norm_ensaio(ytrain.yNONtarget);

    if ~isempty(ytrain.yNonControl)
        yNonControl = gp_norm_ensaio(ytrain.yNonControl);
    else
        yNonControl = [];
    end
    

    if ~isempty(yNonControl)
        yNONtargetTEST = cat(3, znontarget, yNonControl);
    else
        yNONtargetTEST = znontarget;
    end
end


% =============================
% AVERAGING EPOCHS
% =============================
if update == 0
    
    [ztargetTRAIN, zNONtargetTRAIN] = ...
        gp_average_epoch(ytargetTRAIN, yNONtargetTRAIN, ...
                         size(ytargetTRAIN,3)/5,  size(yNONtargetTRAIN,3)/5, nepoch);
end

% =============================
% FEATURE EXTRACTION
% =============================
class.spatial.ncomp = 2;

Uall = gp_feature_extraction_model( ...
    ztargetTRAIN, zNONtargetTRAIN, 1:12, class);
class.spatial.Uall = Uall;

[zspatialTRAIN_t, zspatialTRAIN_nt] = ...
    gp_feature_extraction(ztargetTRAIN, zNONtargetTRAIN, 1:12, class);


if test_file == 0
    zspatialTEST_t = [];
    zspatialTEST_nt = [];
    ztargetTEST = [];
    zNONtargetTEST = [];
else
    [ztargetTEST, zNONtargetTEST] = ...
    gp_average_epoch(ytargetTEST, yNONtargetTEST, ...
                     size(ytargetTEST,3)/5, ...
                     size(yNONtargetTEST,3)/5, nepoch);
                 
    [zspatialTEST_t, zspatialTEST_nt] = ...
    gp_feature_extraction(ztargetTEST, zNONtargetTEST, 1:12, class);
end


% =============================
% FEATURE SELECTION
% =============================
feat_sel = ac_feature_selection( ...
    zspatialTRAIN_t, zspatialTRAIN_nt, nfeat);

% =============================
% CLASSIFICATION
% =============================
[result, std_nt_tre, train, n1, n2] = jf_FLD( zspatialTRAIN_t, zspatialTRAIN_nt, zspatialTEST_t, zspatialTEST_nt, feat_sel, nfeat, test_file);

end
