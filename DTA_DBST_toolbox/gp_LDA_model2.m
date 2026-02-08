function [U1, V1]=gp_LDA_model2(z1a,z2a,canais,metodo)

%z1a Class 1 trials (EEGlab format (channels, time samples, trials))
%z2a Class 2 


for i=1:length(canais)
    z1(i,:,:)=z1a(canais(i),:,:);
    z2(i,:,:)=z2a(canais(i),:,:);
end


Mean1=mean(z1,3);
Mean2=mean(z2,3);


for i=1:size(z1,3)   %nr de trials
    aux1=(z1(:,:,i)-Mean1)*(z1(:,:,i)-Mean1)';
    Cov1(:,:,i)=aux1/(trace(aux1));   %covariance
end
for i=1:size(z2,3)   %nr de trials
    aux2=(z2(:,:,i)-Mean2)*(z2(:,:,i)-Mean2)';
    Cov2(:,:,i)=aux2/(trace(aux2));   %covariance
end

p1=size(z1,3)/(size(z1,3)+size(z2,3));
p2=size(z2,3)/(size(z1,3)+size(z2,3));

Covavg1=sum(Cov1,3); 
Covavg2=sum(Cov2,3);  


MeanAll=p1*Mean1+p2*Mean2;  


%BETWEEN CLASS MATRIX -----------------
Sb=p1*(Mean1-MeanAll)*(Mean1-MeanAll)'+p2*(Mean2-MeanAll)*(Mean2-MeanAll)'; 


switch metodo
    case 1 %FLD 
        %WITHIN-CLASS MATRIX
        Sw=1*Covavg1+1*Covavg2; 
        [U1 V1]=eig(pinv(Sw)*Sb); 
        Vd1 = diag(V1);
        [junk, rindices] = sort(-1*Vd1);  
        Vd1 = Vd1(rindices);               
        V1=diag(Vd1);                      
        U1 = U1(:,rindices);

    case 2 %FLD regularized
        th=0.1;  
        Sw=p1*Covavg1+p2*Covavg2;  
        Sw= (1-th)*Sw + th*eye(size(Sw,1),size(Sw,1));  %default

        [U1 V1]=eig(pinv(Sw)*Sb); 
        Vd1 = diag(V1);
        [junk, rindices] = sort(-1*Vd1);   
        Vd1 = Vd1(rindices);               
        V1=diag(Vd1);                      
        U1 = U1(:,rindices);
          
end

