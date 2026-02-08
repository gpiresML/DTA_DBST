function [Z, y1]=gp_LDA(U1,tsta,canais)

%transposes all channels to the beginning if they are not sequential
tst(:,:)=tsta(canais(1:length(canais)),:);

%projection of the test sequence
Z=U1'*tst(:,:);     %

%returns only the 1st component
y1=Z(1,:);

