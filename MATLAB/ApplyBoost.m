function CONF = ApplyBoost(features,thresholds,polarities,alphas,C)
% assumes feature, threshold, polarity and alpha are column vectors
% of equal size, that is each has t rows and 1 column
% T1 are test samples from class 1, T2 are test samples from class 2
% outputs the confusion matrix CONF

t = size(alphas,1);
% C = [T1(:,features);T2(:,features)];

numSamples = size(C,1);

R = zeros(numSamples,1);

for i = 1:numSamples
    acc = 0;
    for j = 1:size(features,1)
        acc = acc + alphas(j)*sign((thresholds(j)-C(i,features(j)+1))*polarities(j));
    end
    R(i) = sign(acc);
end

% T=repmat(thresholds',numSamples,1);
% R = sign((T-C(:,2:end)).*repmat(polarities',numSamples,1));
% I=find( R == 0);
% R(I) = -1;                     %0 means the negative class, class 2
% 
% A=repmat(alphas',numSamples,1);
% 
% R = R .*A;
% R = sign(sum(R,2));
% I=find( R == 0);
% R(I) = -1;                     %0 means the negative class, class 2


% R1 = R(1:size(T1,1),:);
% R2 = R(size(T1,1)+1:numSamples,:);

CONF = zeros(2);
I = find(C(:,1)==1);
CONF(1,2) = sum(C(I,1)~=R(I));
CONF(1,1) = sum(C(I,1)==R(I));
I = find(C(:,1)==-1);
CONF(2,1) = sum(C(I,1)~=R(I));
CONF(2,2) = sum(C(I,1)==R(I));
