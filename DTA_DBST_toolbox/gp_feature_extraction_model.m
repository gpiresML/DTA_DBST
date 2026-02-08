function U_all =gp_feature_extraction_model(ztarget,zNONtarget,g,class)

    fprintf('Several projections FLD \n')
    
    ncomp_meth=class.spatial.ncomp;  
    
    [U_all , ~]=gp_LDA_model2(ztarget,zNONtarget,g,ncomp_meth); 
end

