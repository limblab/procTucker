function [coeff,diffDist,matchDist,empDist]=getShapeComps_SA(units1,units2,SNRThresh)
%stand alone function for analysis of neuron tracking techniques:
    %[coeff,diffDist,matchDist,empDist]=getShapeComps(units,data,SNRThresh)
    %takes the data for this monkey and builds a statistical model of the
    %differences in shape across all units.
    %returns a vector that is the axis that maximally separates comparisons
    %between different units, and comparisons between the same unit in
    %different files. Also returns matlab distribution objects for the set
    %of known different comparisons, the modeled self comparisons, and the
    %empirical data containing both different and self comparisons. use the
    %functions pdf(dist,x), and cdf(dist,x) to get probabilities for values
    %in the distributions.
    
    disp('compiling sorted units already in unitData')
    numUnits=numel(units1.data);
    unitsMean=nan(numUnits,size(units1.data(1).spikes.wave,2));
    unitsStdev=unitsMean;
    unitsShift=nan(numUnits,1);
    unitsCount=nan(numUnits,1);
    unitsChans=[units1.data.chan];
    unitsArray={units1.data.array};
    unitsInUnits=ones(size(unitsChans));
    unitsThreshold=[units1.data.lowThreshold];
    unitsMinMaxTics=nan(numUnits,1);
    unitsMinMaxTicsStd=nan(numUnits,1);
    numData=numel(units2.data);
    unitsLogNEO=nan(numData,1);
    unitsLogNEOStd=nan(numData,1);
    for i=1:numUnits
        if(units1.data(i).ID==0 || units1.data(i).ID==255)
            %don't bother with invalid or unsorted
            continue
        end
        disp(['working on unit:',num2str(i)])
        unitsMean(i,:)=mean(units1.data(i).spikes.wave);
        unitsStdev(i,:)=std(units1.data(i).spikes.wave);
        unitsCount(i)=size(units1.data(i).spikes,1);
        threshCross=find(unitsMean(i,:)<unitsThreshold(i),1,'first');
        [~,~,~,minima]=extrema(unitsMean(i,:));
        firstMin=find(sort(minima)>=threshCross,1,'first');
        unitsShift(i)=firstMin;
        %the following arrayfun call is ~4x slower than the for-loop that
        %comes after it
        %[~,mx,~,mn]=arrayfun(@(wNum) extrema(units.data(i).spikes.wave(wNum,:)),1:size(units.data(i).spikes.wave,1),'UniformOutput',false);
        mx=cell(1,size(units1.data(i).spikes.wave,1));

        mn=cell(1,size(units1.data(i).spikes.wave,1));
        %accessing data directly from a table is slow, so put the spikes
        %into an array and work on them there:
        tmp=units1.data(i).spikes.wave;
        for j=1:size(units1.data(i).spikes.wave,1)
            [~,mx{j},~,mn{j}]=extrema(tmp(j,:));
        end
        %get the first minima after threshold:
        for j=1:size(mn,2)
            tmp=mn{j}(find(mn{j}>unitsThreshold(i),1,'first'));
            if isempty(tmp)
                minIdx(j)=unitsThreshold(i);
            else
                minIdx(j)=tmp;
            end
        end
        %get the first maxima after the first minima:
        for j=1:size(mx,2)
            tmp=mx{j}(find(mx{j}>minIdx(j),1,'first'));
            if isempty(tmp)
                maxIdx(j)=minIdx(j);
            else
                maxIdx(j)=tmp;
            end
        end
        
        unitsMinMaxTics(i)=mean(maxIdx-minIdx);
        unitsMinMaxTicsStd(i)=std(maxIdx-minIdx);
        
%         logNEO=log(  sum(   ...
%                         [unitsMean(i,1),unitsMean(i,:),unitsMean(i,end)].*[unitsMean(i,1),unitsMean(i,:),unitsMean(i,end)]...
%                         -[unitsMean(i,1),unitsMean(i,1),unitsMean(i,:)].*[unitsMean(i,:),unitsMean(i,end),unitsMean(i,end)]...
%                         ,2));%this is the nonlinear energy operator
%         
        logNEO=log(sum([units1.data(i).spikes.wave(:,1),units1.data(i).spikes.wave,units1.data(i).spikes.wave(:,end)].*[units1.data(i).spikes.wave(:,1),units1.data(i).spikes.wave,units1.data(i).spikes.wave(:,end)]...
            -[units1.data(i).spikes.wave(:,1),units1.data(i).spikes.wave(:,1),units1.data(i).spikes.wave].*[units1.data(i).spikes.wave,units1.data(i).spikes.wave(:,end),units1.data(i).spikes.wave(:,end)]...
            ,2));
        unitsLogNEO(i)=mean(logNEO);
        unitsLogNEOStd(i)=std(logNEO);
    end
    range=max(unitsMean,[],2)-min(unitsMean,[],2);
    SNR=range./mean(unitsStdev,2);
    %build mask to remove undesireable units:
    mask=(~isnan(unitsCount) & ... stuff leftover from units 0 and 255
            unitsChans'<128 & ... sorted units on the analog front panel of the cerebus
            SNR>=SNRThresh);% lowSNR units

    unitsMean=unitsMean(mask,:);
    unitsStdev=unitsStdev(mask,:);
    unitsShift=unitsShift(mask);
    unitsCount=unitsCount(mask);
    unitsChans=unitsChans(mask);
    unitsArray=unitsArray(mask);
    unitsInUnits=unitsInUnits(mask);
    unitsThreshold=unitsThreshold(mask);
    unitsMinMaxTics=unitsMinMaxTics(mask);
    unitsMinMaxTicsStd=unitsMinMaxTicsStd(mask);
    unitsLogNEO=unitsLogNEO(mask);
    unitsLogNEOStd=unitsLogNEOStd(mask);
    %now work on the data
    disp('compiling sorted units already in new data')
    dataMean=nan(numData,size(units2.data(1).spikes.wave,2));
    dataStdev=dataMean;
    dataShift=nan(numData,1);
    dataCount=nan(numData,1);
    dataChans=[units2.data.chan];
    dataArray={units2.data.array};
    dataInUnits=zeros(size(dataChans));
    dataThreshold=[units2.data.lowThreshold];
    dataMinMaxTics=nan(numData,1);
    dataMinMaxTicsStd=nan(numData,1);
    dataLogNEO=nan(numData,1);
    dataLogNEOStd=nan(numData,1);
    for i=1:numData
        if(units2.data(i).ID==0 || units2.data(i).ID==255)
            continue
        end
        disp(['working on unit:',num2str(i)])
        dataMean(i,:)=mean(units2.data(i).spikes.wave);
        dataStdev(i,:)=std(units2.data(i).spikes.wave);
        dataCount(i)=size(units2.data(i).spikes,1);
        threshCross=find(dataMean(i,:)<dataThreshold(i),1,'first');
        [~,~,~,minima]=extrema(dataMean(i,:));
        firstMin=find(sort(minima)>=threshCross,1,'first');
        dataShift(i)=firstMin;
        %the following arrayfun call is ~4x slower than the for-loop that
        %comes after it
        %[~,mx,~,mn]=arrayfun(@(wNum) extrema(data(i).spikes.wave(wNum,:)),1:size(data(i).spikes.wave,1),'UniformOutput',false);

        mx=cell(1,size(units2.data(i).spikes.wave,1));
        mn=cell(1,size(units2.data(i).spikes.wave,1));
        %accessing data directly from a table is slow, so put the spikes
        %into an array and work on them there:
        tmp=units2.data(i).spikes.wave;
        for j=1:size(units2.data(i).spikes.wave,1)
            [~,mx{j},~,mn{j}]=extrema(tmp(j,:));
        end
        %get the first minima after threshold:
        for j=1:size(mn,2)
            tmp=mn{j}(find(mn{j}>dataThreshold(i),1,'first'));
            if isempty(tmp)
                minIdx(j)=dataThreshold(i);
            else
                minIdx(j)=tmp;
            end
        end
        %get the first maxima after the first minima:
        for j=1:size(mx,2)
            tmp=mx{j}(find(mx{j}>minIdx(j),1,'first'));
            if isempty(tmp)
                maxIdx(j)=minIdx(j);
            else
                maxIdx(j)=tmp;
            end
        end

        dataMinMaxTics(i)=mean(maxIdx-minIdx);
        dataMinMaxTicsStd(i)=std(maxIdx-minIdx);
%         logNEO=log(  sum(   ...
%                         [dataMean(i,1),dataMean(i,:),dataMean(i,end)].*[dataMean(i,1),dataMean(i,:),dataMean(i,end)]...
%                         -[dataMean(i,1),dataMean(i,1),dataMean(i,:)].*[dataMean(i,:),dataMean(i,end),dataMean(i,end)]...
%                         ,2));%this is the nonlinear eneergy operator
        logNEO=log(sum([units2.data(i).spikes.wave(:,1),units2.data(i).spikes.wave,units2.data(i).spikes.wave(:,end)].*[units2.data(i).spikes.wave(:,1),units2.data(i).spikes.wave,units2.data(i).spikes.wave(:,end)]...
            -[units2.data(i).spikes.wave(:,1),units2.data(i).spikes.wave(:,1),units2.data(i).spikes.wave].*[units2.data(i).spikes.wave,units2.data(i).spikes.wave(:,end),units2.data(i).spikes.wave(:,end)]...
            ,2));
        dataLogNEO(i)=mean(logNEO);
        dataLogNEOStd(i)=std(logNEO);
    end
    range=max(dataMean,[],2)-min(dataMean,[],2);
    SNR=range./mean(dataStdev,2);
    %build mask to remove undesireable units:
    mask=(~isnan(dataCount) & ... stuff leftover from units 0 and 255
            dataChans'<128 & ... sorted units on the analog front panel of the cerebus
            SNR>=SNRThresh);% lowSNR units
        

    dataMean=dataMean(mask,:);
    dataStdev=dataStdev(mask,:);
    dataShift=dataShift(mask);
    dataCount=dataCount(mask);
    dataChans=dataChans(mask);
    dataArray=dataArray(mask);
    dataInUnits=dataInUnits(mask);
    dataThreshold=dataThreshold(mask);
    dataMinMaxTics=dataMinMaxTics(mask);
    dataMinMaxTicsStd=dataMinMaxTicsStd(mask);
    dataLogNEO=dataLogNEO(mask);
    dataLogNEOStd=dataLogNEOStd(mask);
    %concatenate data& units together:
    disp('merging units')    
    allMean=[unitsMean;dataMean];
    allStdev=[unitsStdev;dataStdev];
    allShift=[unitsShift;dataShift]-units1.appendConfig.thresholdPoint;
    allCount=[unitsCount;dataCount];
    allChans=[unitsChans';dataChans'];
    allArray=[unitsArray';dataArray'];
    allInUnits=[unitsInUnits';dataInUnits'];
    allThreshold=[unitsThreshold';dataThreshold'];
    allMinMaxTics=[unitsMinMaxTics;dataMinMaxTics];
    allMinMaxTicsVar=[unitsMinMaxTicsStd;dataMinMaxTicsStd];
    allLogNEO=[unitsLogNEO;dataLogNEO];
    allLogNEOVar=[unitsLogNEOStd;dataLogNEOStd];
    %now align the means and stdevs to first minima after threshold to take 
    %care of cases where the user aligned waves to peak in offline sorter. the
    %following line is ugly, but it simply extracts the relevant portion of
    %the wave, truncating the part shifted outside the range of the wave,
    %and then pads the empty points by extending the tail of the wave.
    %e.g.: [1,2,3,4], shifted by 1, results in [2,3,4,4]. Positive shift
    %amounts shift the wave left.
    allMean=cell2mat(arrayfun(@(a,b) [repmat(allMean(b,1),[1,max(0,-a)]),allMean(b,1+max(0,a):end-max(0,-a)),repmat(allMean(b,end),[1,max(0,a)])],allShift,[1:numel(allShift)]','UniformOutput',false));
    allStdev=cell2mat(arrayfun(@(a,b) [repmat(allStdev(b,1),[1,max(0,-a)]),allStdev(b,1+max(0,a):end-max(0,-a)),repmat(allStdev(b,end),[1,max(0,a)])],allShift,[1:numel(allShift)]','UniformOutput',false));
    
    %now loop through the units and get scaling factors:
    numWaves=size(allMean,1);
    numPoints=size(allMean,2);
    waveMat=repmat(reshape(allMean,[1,numWaves,numPoints]),[numWaves,1,1]);
    stdevMat=repmat(reshape(allStdev,[1,numWaves,numPoints]),[numWaves,1,1]);
    spikesMat=repmat(allCount,[1,numWaves,numPoints]);%number of spikes
    
    ticsMat=repmat(allMinMaxTics',[numWaves,1,1]);
    ticsStdMat=repmat(allMinMaxTicsVar',[numWaves,1,1]);
    NEOMat=repmat(allLogNEO',[numWaves,1,1]);
    NEOStdMat=repmat(allLogNEOVar',[numWaves,1,1]);
    
    disp('computing scaling factors for best shape-matching')
    alphaMat=nan(numWaves,numWaves);
    alphaCIMat=nan(numWaves,numWaves,2);
    for i=1:size(waveMat,1)
        for j=1:size(waveMat,2)
            %now get the alpha (gain) factor to multiply the transpose
            %element in order to match the scale of the non-transpose
            %element
            [alphaMat(i,j),alphaCIMat(i,j,:)]=regress(squeeze(waveMat(i,j,:)),squeeze(waveMat(j,i,:)));
%            alphaStdMat(i,j)=diff(alphaCI)/(2*1.96);
        end
    end
    
    %compute all distances in wavespace. Subtract the scaled transpose from
    %the non-transpose (recall that alphas are scales to apply to the
    %transpose). note this results in a symmetric matrix, with duplicate 
    %entries.
    disp('computing distances metrics')
    waveMat=waveMat-permute(waveMat,[2,1,3]).*repmat(alphaMat,[1,1,numPoints]);
    %create an upper triangular mask excluding the self comparisons and 
    %the bottom half
    mask=triu(true(numWaves));
    %further mask any comparisons with a negative scaling factor- if the
    %units are inverted we know they aren't the same thing
    mask=mask | alphaMat<0;
    %finally mask any comparisons where the smaller wave does not pass
    %threshold on the larger wave by more than its standard deviation. This
    %in theory compensates for the fact that a channel with a large unit
    %will be less likely to have small units, and thus the distribution of
    %units in cross channel comparisons will have more large differences
    %than comparisons of different units on the same channel.
    threshMat=repmat(allThreshold,[1,numWaves]);
    threshMat=min(threshMat,threshMat');%minimum of the 2 thresholds involved in the comparison
    minMat=repmat(min(allMean,[],2),[1,numWaves]);
    minMat=max(minMat,minMat');%smaller excursion of the two waves
    mask=mask | (minMat-double(threshMat))>0;
    
    %use the mask to get a list of differences in wavespace
    diffs=abs(waveMat(repmat(~mask,[1,1,numPoints])));
    % use only the gains that are greater than 1;
    alphaMat = max(alphaMat,alphaMat');
    %convert alpha into 1 sided distribution:
    alphaMat(mask)=nan;%set all the stuff we aren't going to use to nan, so that we don't try to call log(-1) or something

    %get the difference in minmaxTics
    ticsMat=abs(ticsMat-ticsMat');
    %get the difference in NEO
    NEOMat=abs(NEOMat-NEOMat');
    %reshape the differences into a column matrix where each row is a
    %difference observation include the alpha values here as the last 
    %difference:
    diffs=[reshape(diffs,numel(diffs)/numPoints,numPoints), alphaMat(~mask),ticsMat(~mask),NEOMat(~mask)];
    %diffs=[sqrt(sum(reshape(diffs,numel(diffs)/numPoints,numPoints).^2,2)), alphas];
    
    %now compute joint standard deviation (S1*N1+S2*N2*alpha)/(N1+N2):
    stdevMat=stdevMat.*spikesMat;
    stdevMat= stdevMat./ (spikesMat+permute(spikesMat,[2,1,3]));
    stdevMat=stdevMat+permute(stdevMat.*repmat(alphaMat',[1,1,numPoints]),[2,1,3]);
    alphaCIMat(repmat(alphaMat<1,[1,1,2]))=1./alphaCIMat(repmat(alphaMat<1,[1,1,2]));
    %convert CI into stdev for the scaling factor. Remember to convert CI
    %values for alphas<1 so the CI range matches the range for the
    %converted alpha:
    alphaStdMat=abs(diff(alphaCIMat,1,3))/(2*1.96); % 1.96? from what?
    %get the stdev for the minMaxTics
    ticsStdMat=ticsStdMat.*spikesMat(:,:,1);
    ticsStdMat=ticsStdMat+ticsStdMat';
    ticsStdMat=ticsStdMat./ (spikesMat(:,:,1)+spikesMat(:,:,1)');
    %get the stdev for the NEO
    NEOStdMat=NEOStdMat.*spikesMat(:,:,1);
    NEOStdMat=NEOStdMat./ (spikesMat(:,:,1)+spikesMat(:,:,1)');
    NEOStdMat=NEOStdMat+NEOStdMat';
    
    %convert the 3D standard deviation matrix into a 2D matrix to match the
    %diffs matrix. Again, we add on the value for the alpha, tics, and NEO
    stdevs=stdevMat(repmat(~mask,[1,1,numPoints]));
    stdevs=[reshape(stdevs,numel(stdevs)/numPoints,numPoints),alphaStdMat(~mask),ticsStdMat(~mask),NEOStdMat(~mask)];
    
    %stdevs=[mean(reshape(stdevs,numel(stdevs)/numPoints,numPoints),2),alphaStdMat(mask)];
    %calculte dPrime from the differences and standard deviations. Log
    %transform to get from a positive only, skewed distribution to 
    %something that looks normal
    dPrime=log(diffs./stdevs);
    %now get the logical index for things that are the same channel:
    disp('getting projections onto LDA')
    diffMask=true(numWaves,numWaves);
    for i=1:numel(allChans)
        tmp=find(allChans==allChans(i) & strcmp(allArray,allArray{i}) & allInUnits~=allInUnits(i));
        diffMask(i,tmp)=false;
        diffMask(tmp,i)=false;
    end
    knownDiff=diffMask(~mask);
    %now lets get the axis between the mean cluster position for our dPrime
    %data. This is the same as the LDA axis, but we get to skip all the
    %logic associated with classifying individual points:
    coeff=mean(dPrime(knownDiff,:))-mean(dPrime(~knownDiff,:));
    %now use projections onto the LDA axis to form distributions for the
    %known difference comparisons and the mixed different and self
    %comparisons.
    knownDiffProj=dPrime(knownDiff,:)*coeff';
    putativeMatchProj=dPrime(~knownDiff,:)*coeff';
    rangeProj=[min(dPrime*coeff'),max(dPrime*coeff')];
    x=rangeProj(1):diff(rangeProj)/1000:rangeProj(2);
    diffDist=fitdist(knownDiffProj,'kernel','width',4);
    empDist=fitdist(putativeMatchProj,'kernel','width',4);
    %diffDist=fitdist(knownDiffProj,'kernel');
    %empDist=fitdist(putativeMatchProj,'kernel');

    diffPDF=pdf(diffDist,x);
    empPDF=pdf(empDist,x);
    [mx,idx]=max(diffPDF);
    %PDFScale=empPDF(idx)/mx;
    PDFScale=regress(empPDF(idx:end)',diffPDF(idx:end)');
    matchPDF=empPDF-PDFScale*diffPDF;

    matchPDF(matchPDF<0)=0;
    %convert the PDF into theoretical counts:
    matchCounts=round(matchPDF/min(matchPDF(matchPDF>0)));
    matchDist=fitdist(x','kernel','frequency',matchCounts','width',4);
    %matchDist=fitdist(x','kernel','frequency',matchCounts');
end