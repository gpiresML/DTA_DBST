function y=concat_components(x,ncomp)
% x dimension: channels x samples x 1 trial
% ncomp: number of components to concatenate

tmp(1,:)=x(1,:,1);   
y(1,:)=tmp;

if ncomp>1
    for i=2:ncomp
        tmp(1,:)=x(i,:,1);
        y=[y tmp];
    end
end

