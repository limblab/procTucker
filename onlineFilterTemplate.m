
%configure test
numTests=1000;
numPad=200;
expectedSamples=600;
nChan=96;
%establish variables
tmp=rand(nChan,2400);
times=nan(1,numTests);
inputData=nan(nChan,numTests,expectedSamples+5);
outputData=nan(nChan,numTests,expectedSamples+5);
% create filter
[bFilter,aFilter] = butter(6,500/(30000/2),'high');

%initialize timer
tic
%loop through tests
for i=1:numTests
    %'get data'
    tmp2=rand(nChan,expectedSamples+ceil(rand*4));
    inputData(:,i,1:size(tmp2,2))=tmp2;
    %roll new data onto end of old data
    tmp=[ tmp(:,size(tmp2,2)+1:end), tmp2];
    %filter data with pad:
    tmp3=fliplr(filter(bFilter,aFilter,fliplr([tmp,ones(nChan,numPad).*repmat(tmp(:,end),[1,numPad])]),[],2));%flips, forces filtering along dimension 2, then flips back
    %extract new filtered points
    outputData(:,i,1:size(tmp2,2))=tmp3(:,end-size(tmp2,2)+1:end);
    %get time
    times(i)=toc;
    
end
figure;
hist(diff(times)*1000);