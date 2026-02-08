function model = jf_fisher (data)

inx1 = find( data.y == 1);
inx2 = find( data.y == 2);

n1 = length(inx1);
n2 = length(inx2);
m1 = mean(data.X(:,inx1),2);
m2 = mean(data.X(:,inx2),2);
model.m1=m1;
model.m2=m2;
S1 = (data.X(:,inx1)-m1*ones(1,n1))*(data.X(:,inx1)-m1*ones(1,n1))';
S2 = (data.X(:,inx2)-m2*ones(1,n2))*(data.X(:,inx2)-m2*ones(1,n2))';
Sw = S1 + S2;

dSw=diag(Sw)';
dSw=diag(dSw);

model.W = inv(dSw)*(m2-m1);

result1= model.W'*data.X;
if mean(result1(1:n1))<mean(result1(n1+1:end))
    b2=(mean(result1(1:n1))+std(result1(1:n1)));
    b1=(mean(result1(n1+1:end))-std(result1(n1+1:end)));
    model.b1=mean(result1(n1+1:end));
    
else
    b2=(mean(result1(1:n1))-std(result1(1:n1)));
    b1=(mean(result1(n1+1:end))+std(result1(n1+1:end)));
 
    model.b1=mean(result1(1:n1));
end
model.b=-(b1+b2)/2;
model.b1=model.b+model.b1;
end