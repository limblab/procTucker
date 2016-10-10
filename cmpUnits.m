function [pVals,alphaMat]=cmpUnits(unitsA,unitsB,ldaAxis, diffDist,SNRThresh,threshPoint)
    %cmpUnits(unitsA,unitsB,ldaAxis, diffDist,thresh)
    %compare 2 lists of units and return best match
    %assumes units are from same channel, same monkey different days
    %requires as input the vector defining the LDA axis, and a
    %distribution of differences for comparisons of neurons that are known
    %to be different (e.g. comparisons across different channels)
    %
    %inputs:
    %unitsA:    unit struct (equvalent format to unitData.data)
    %unitsB:    unit struct (equvalent format to unitData.data)
    %ldaAxis:   the vector defining the axis of maximal separation between
    %           comparisons of the same unit across sessions, and different
    %           units across sessions.
    %diffDist:  a distribution of comparisons of different units across
    %           sessions projected onto ldaAxis. This should be a matlab
    %           distribution object
    %SNRThresh: signal noise threshold below which units will be rejected
    %           before comparison
    %threshPoint:   data point where we will synchronize threshold
    %           crossings. This compensates for misalignment due to
    %           aligning waveforms on other features during manual sorting.
    %           Should normally be set to the nominal threshold crossing
    %           point in the source data. E.G. with 10 pts of pre-threshold
    %           data, set threshPoint to 11.
    %thresh:    the statistical threshold for rejecting the assumption that
    %           a comparison is drawn from the same distribution as the
    %           data in diffDist. NOTE: thresh is equivalent to the false
    %           positive rate for comparisons of two units that are not
    %           actually the same, and care should be with the results when
    %           large values are used for thresh
    %
    %outputs:
    %matchList: a column matrix, of index pairs for each matched pair of
    %           units. First column is index of unitA, second column of
    %           unitB, e.g. [2,1] means that unitA(2) matches unitB(1)
    
    %sanity checks:
    %same channel?
    channels=unique([[unitsA.chan],[unitsB.chan]]);
    if numel(channels)~=1
        error('cmpUnits:channelMismatch',['expected data from a single channel, instead got data from chans: ',num2str(channels)])
    end
    %same array?
    arrays=unique([{unitsA.array},{unitsB.array}]);
    if numel(arrays)~=1
        error('cmpUnits:arrayMismatch',['expected data from a single array, instead got data from arrays: ',strjoin(arrays,', ')])
    end
    %invalid or unsorted?
    unsorted=[find([unitsA.ID]==0),find([unitsB.ID]==0)];
    invalid=[find([unitsA.ID]==255),find([unitsB.ID]==255)];
    if ~isempty(invalid) || ~isempty(unsorted)
        error('cmpUnits:unsorted',['data includes ',num2str(numel(unsorted)),' unsorted and ',num2str(numel(invalid)),' invalid units'])
    end
    %same number of points in each waveform:
    points=size(unitsA(1).spikes.wave,2);
    if size(unitsB(1).spikes.wave,2)~=points
        error('cmpUnits:numPointsMismatch',['in order to compare units by shape they must have the same number of units. In this data we have waves with ',num2str(points),' and ',num2str(size(unitsB(1).spikes.wave,2)),' points'])
    end
    
    meansA=nan(numel(unitsA),points);
    meansB=nan(numel(unitsB),points);
    stdevA=meansA;
    stdevB=meansB;
    shiftA=nan(numel(unitsA),1);
    shiftB=nan(numel(unitsB),1);
    countA=nan(numel(unitsA),1);
    countB=nan(numel(unitsB),1);
    threshA=[unitsA.lowThreshold];
    threshB=[unitsB.lowThreshold];
    %loop through unitsA and populate variables:
    for i=1:numel(unitsA)
        meansA(i,:)=mean(unitsA(i).spikes.wave)';
        stdevA(i,:)=std(unitsA(i).spikes.wave)';
        countA(i)=size(unitsA(i).spikes.wave,1);
        shiftA(i)=find(meansA(i,:)<threshA(i),1,'first')-threshPoint;
    end
    %loop through unitsB and populate variables:
    for i=1:numel(unitsB)
        meansB(i,:)=mean(unitsB(i).spikes.wave)';
        stdevB(i,:)=std(unitsB(i).spikes.wave)';
        countB(i)=size(unitsB(i).spikes.wave,1);
        shiftB(i)=find(meansB(i,:)<threshB(i),1,'first')-threshPoint;
    end
    %now align the means and stdevs to threshold crossing to take care of
    %cases where the user aligned waves to peak in offline sorter. the
    %following line is ugly, but it simply extracts the relevant portion of
    %the wave, truncating the part shifted outside the range of the wave,
    %and then pads the empty points by extending the tail of the wave.
    %e.g.: [1,2,3,4], shifted by 1, results in [2,3,4,4]. Positive shift
    %amounts shift the wave left.
    meansA=cell2mat(arrayfun(@(a,b) [repmat(meansA(b,1),[1,max(0,-a)]),meansA(b,1+max(0,a):end-max(0,-a)),repmat(meansA(b,end),[1,max(0,a)])],shiftA,[1:numel(shiftA)]','UniformOutput',false));
    stdevA=cell2mat(arrayfun(@(a,b) [repmat(stdevA(b,1),[1,max(0,-a)]),stdevA(b,1+max(0,a):end-max(0,-a)),repmat(stdevA(b,end),[1,max(0,a)])],shiftA,[1:numel(shiftA)]','UniformOutput',false));
    meansB=cell2mat(arrayfun(@(a,b) [repmat(meansB(b,1),[1,max(0,-a)]),meansB(b,1+max(0,a):end-max(0,-a)),repmat(meansB(b,end),[1,max(0,a)])],shiftB,[1:numel(shiftB)]','UniformOutput',false));
    stdevB=cell2mat(arrayfun(@(a,b) [repmat(stdevB(b,1),[1,max(0,-a)]),stdevB(b,1+max(0,a):end-max(0,-a)),repmat(stdevB(b,end),[1,max(0,a)])],shiftB,[1:numel(shiftB)]','UniformOutput',false));
    
    %make SNR estimates and reject units with SNR below SNRThresh:
    rangeA=max(meansA,[],2)-min(meansA,[],2);
    SNRA=rangeA./mean(stdevA,2);
    rangeB=max(meansB,[],2)-min(meansB,[],2);
    SNRB=rangeB./mean(stdevB,2);
    SNROK=repmat(SNRA>SNRThresh,[1,numel(unitsB)]) & repmat([SNRB>SNRThresh]',[numel(unitsA),1]);
    
    %build matrix of comparisons:
    %get matrix of A where every row i (AMat(i,:,:)), is a replication of
    %the mean waves in A:
    AMat=repmat(reshape(meansA,[size(meansA,1),1,points]),[1,numel(unitsB),1]);
    stdevMatA=repmat(reshape(stdevA,[size(meansA,1),1,points]),[1,numel(unitsB),1]);
    countMatA=repmat(countA,[1,numel(unitsB),points]);
    %get matrix of B where every row i (BMat(:,i,:)), is a replication of
    %the mean waves in B:
    BMat=repmat(reshape(meansB,[1,size(meansB,1),points]),[numel(unitsA),1,1]);
    stdevMatB=repmat(reshape(stdevB,[1,size(meansB,1),points]),[numel(unitsA),1,1]);
    countMatB=repmat(countB',[numel(unitsA),1,points]);
    %now find the scale parameter for each comparison that results in the
    %best fit:
    alphaMat=nan(numel(unitsA),numel(unitsB));
    alphaCIMat=nan(numel(unitsA),numel(unitsB),2);
    for i=1:size(alphaCIMat,1)
        for j=1:size(alphaCIMat,2)
            if SNROK(i,j)
                [alphaMat(i,j),alphaCIMat(i,j,:)]=regress(squeeze(AMat(i,j,:)),squeeze(BMat(i,j,:)));
            end
        end
    end
    %now that we have scales, compute the difference waves
    jointStdev=(stdevMatA.*countMatA+stdevMatB.*countMatB)./(countMatA+countMatB);
    diffMat=abs(AMat-BMat.*repmat(alphaMat,[1,1,points]));
    
    %nowtake raw scales, and make them into a 1-sided distribution. We do
    %this by centering on zero and then taking the absolute value.
    %subtracting 1 takes care of the fact that gain of 1 means no change,
    %and absolute value takes care of the fact that a scale of less than 1
    %is equivalent to a scale of more than 1 if we reverse the order of the
    %waves in the comparison
    rectAlpha=abs(alphaMat-1);
    %get matrix of raw difference values:
    diffs=cat(3,rectAlpha,diffMat);
    
    %convert CI into stdev for the scaling factor. Remember to convert CI
    %values for alphas<1 so the CI range matches the range for the
    %converted alpha:
    alphaCIMat(repmat(alphaMat<1,[1,1,2]))=1./alphaCIMat(repmat(alphaMat<1,[1,1,2]));
    alphaStdMat=abs(diff(alphaCIMat,1,3))/(2*1.96);
    stdevs=cat(3,alphaStdMat,jointStdev);
    %use stdevs to convert raw differences into d'
    dPrime=log(diffs./stdevs);
    
    %project d' onto LDA:
    proj=sum(dPrime.*repmat(reshape(ldaAxis,[1,1,numel(ldaAxis)]),[numel(unitsA),numel(unitsB)]),3);
    %cdf function only accepts vector input, so just loop through rows
    %getting the probability of the difference being in the difference set:
    pVals=nan(size(proj));
    for i=1:size(pVals,1)
        pVals(i,:)=cdf(diffDist,proj(i,:));
    end
    
end