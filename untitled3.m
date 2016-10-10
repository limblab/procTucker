numWaves=200;
allChans=sort(floor(rand(96,1)*3)+1);
chans=unique(allChans);
wavePoints=40;

waves=rand(numWaves,wavePoints);
tic
bigMat=repmat(reshape(waves,[1,numWaves,wavePoints]),[numWaves,1,1]);
stdevMat=repmat(reshape(waves,[1,numWaves,wavePoints]),[numWaves,1,1]);
numSpikes=round(rand(numWaves,1)*80000);
spikesMat=repmat(numSpikes,[1,numWaves,wavePoints]);

alphaMat=nan(numWaves,numWaves);
alphaStdMat=alphaMat;
for i=1:size(bigMat,1)
    for j=i+1:size(bigMat,2)
        %get the scaling factor for the transpose wave that makes it most
        %closely match the non-transpose wave
        [alphaMat(i,j),alphaCI]=regress(squeeze(bigMat(j,i,:)),squeeze(bigMat(i,j,:)));
        alphaStdMat(i,j)=(diff(alphaCI)/(2*1.96));
    end
end
%compute distance
bigMat=bigMat-permute(bigMat,[2,1,3]).*repmat(alphaMat,[1,1,wavePoints]);
mask=triu(true(numWaves),1);
diffs=bigMat(repmat(mask,[1,1,wavePoints]));
diffs=[reshape(diffs,numel(diffs)/wavePoints,wavePoints) ,alphaMat(mask)];


vars=sqrt((stdevMat.*spikesMat+permute(stdevMat,[2,1,3]).*permute(spikesMat,[2,1,3]))./(spikesMat+permute(spikesMat,[2,1,3])));
vars2=vars(repmat(mask,[1,1,wavePoints]));
vars2=[reshape(vars2,numel(vars2)/wavePoints,wavePoints) , alphaStdMat(mask)];
dPrime=diffs./vars2;
%now find the points that are matches
diffMask=true(numWaves,numWaves);
for i=1:numel(chans)
    tmp=find(allChans==chans(i));
    diffMask(tmp,tmp)=false;
end
knownDiff=diffMask(mask);
clear bigMat
toc



