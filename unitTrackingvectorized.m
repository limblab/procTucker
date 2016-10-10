


mainMat=repmat(reshape(allMean,[1,numWaves,numPoints]),[numWaves,1,1]);
compMat=permute(mainMat,[2,1,3]);


A=mean(mainMat.*compMat,3)./mean(compMat.^2,3);

scaledCompMat=repmat(A,[1,1,numPoints]).*compMat;
errs=mainMat-scaledCompMat;
meanDeviation=mainMat-repmat(mean(mainMat,3),[1,1,numPoints]);

AStdev=sum(errs.^2,3)/((numPoints-2)*sum(meanDeviation.^2,3));




ACI=(sum((waveMat-repmat(A,[1,1,numPoints]).*permute(waveMat,[2,1,3])).^2,3))./...
    ((numPoints-2)*sum((waveMat-repmat(mean(waveMat,3),[1,1,numPoints])).^2,3));
tmp=(sum((permute(waveMat,[2,1,3])-repmat(A,[1,1,numPoints]).*waveMat).^2,3))./...
    ((numPoints-2)*sum((waveMat-repmat(mean(permute(waveMat,[2,1,3]),3),[1,1,numPoints])).^2,3));



chanMat=repmat(reshape(allChans,[1,numWaves]),[numWaves,1]);
compChanMat=permute(chanMat,[2,1]);